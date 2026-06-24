import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/context_colors.dart';
import '../../../../shared/widgets/lal_app_bar.dart';
import 'generic_form_panel.dart';
import 'generic_chatbot_panel.dart';
import 'vakalatnama_chatbot.dart';
import '../../../../screens/previews/vakalatnama_preview.dart';
import 'package:printing/printing.dart';
import '../../../../utils/pdf_generator_service.dart';
import '../../../../data/document_registry.dart';
import '../../../../data/providers/vakalatnama_provider.dart';

enum BuilderTab { form, chat, preview }

class DocumentBuilderShell extends ConsumerStatefulWidget {
  final String formId;
  const DocumentBuilderShell({super.key, required this.formId});

  @override
  ConsumerState<DocumentBuilderShell> createState() => _DocumentBuilderShellState();
}

class _DocumentBuilderShellState extends ConsumerState<DocumentBuilderShell> {
  BuilderTab _activeTab = BuilderTab.form;
  final Map<String, TextEditingController> _controllers = {};
  late DocumentConfig _config;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    final entry = DocumentRegistry.getById(widget.formId);
    if (entry != null) {
      _config = entry.config;
    } else {
      _config = _getDefaultConfig();
    }
    _initializeControllers();
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  DocumentConfig _getDefaultConfig() {
    return DocumentConfig(
      id: 'vakalatnama',
      title: 'Vakalatnama',
      description: 'Power of Attorney authorizing an advocate to represent a client.',
      category: 'Civil Procedure',
      fields: [
        DocumentField(key: 'court', label: 'Court', type: FieldType.text, required: true),
        DocumentField(key: 'case_type', label: 'Case Type', type: FieldType.text, required: true),
        DocumentField(key: 'case_number', label: 'Case Number', type: FieldType.text, required: true),
        DocumentField(key: 'plaintiffs', label: 'Plaintiffs', type: FieldType.textarea, required: true),
        DocumentField(key: 'defendants', label: 'Defendants', type: FieldType.textarea, required: true),
        DocumentField(key: 'advocate_name', label: 'Advocate Name', type: FieldType.text, required: true),
        DocumentField(key: 'advocate_enrollment', label: 'Enrollment Number', type: FieldType.text),
      ],
    );
  }

  void _initializeControllers() {
    for (final field in _config.fields) {
      _controllers[field.key] = TextEditingController();
    }
  }

  Map<String, String> get _formData {
    return _controllers.map((key, controller) => MapEntry(key, controller.text));
  }

  int get _completeness {
    if (widget.formId == 'vakalatnama') {
      return ref.read(vakalatnamaProvider).completeness;
    }
    int filled = 0;
    int required = 0;
    for (final field in _config.fields) {
      if (field.required ?? false) {
        required++;
        if ((_controllers[field.key]?.text ?? '').isNotEmpty) {
          filled++;
        }
      }
    }
    return required == 0 ? 100 : ((filled / required) * 100).round();
  }

  Map<String, String> get _pdfFormData {
    if (widget.formId == 'vakalatnama') {
      return ref.read(vakalatnamaProvider).toFormData();
    }
    return _formData;
  }

  Future<void> _downloadPdf() async {
    try {
      final bytes = await PdfGeneratorService.generatePdf(_config.id, _pdfFormData);
      await Printing.sharePdf(bytes: bytes, filename: '${_config.id}.pdf');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF generated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF generation failed: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _printDocument() async {
    try {
      final bytes = await PdfGeneratorService.generatePdf(_config.id, _pdfFormData);
      await Printing.layoutPdf(
        onLayout: (format) async => bytes,
        name: '${_config.id}_document.pdf',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Print failed: ${e.toString()}')),
        );
      }
    }
  }

  void _downloadText() {
    final buffer = StringBuffer();
    buffer.writeln(_config.title.toUpperCase());
    buffer.writeln('=' * 40);
    buffer.writeln();
    
    if (widget.formId == 'vakalatnama') {
      final data = ref.read(vakalatnamaProvider);
      buffer.writeln('Court Name: ${data.courtName}');
      buffer.writeln('Case Type: ${data.caseType}');
      buffer.writeln('Case Number: ${data.caseNumber}');
      buffer.writeln('Jurisdiction Year: ${data.jurisdictionYear}');
      buffer.writeln('Plaintiffs: ${data.plaintiffs.where((p) => p.trim().isNotEmpty).join(", ")}');
      buffer.writeln('Defendants: ${data.defendants.where((d) => d.trim().isNotEmpty).join(", ")}');
      buffer.writeln('Advocates: ${data.advocates.where((a) => a.trim().isNotEmpty).join(", ")}');
      buffer.writeln('Execution Date: ${data.signingDay} ${data.signingMonth} ${data.signingYear}');
      buffer.writeln('Consent Confirmed: ${data.consentConfirmed}');
    } else {
      for (final field in _config.fields) {
        final value = _controllers[field.key]?.text ?? '';
        buffer.writeln('${field.label}:');
        buffer.writeln(value.isEmpty ? '[Not filled]' : value);
        buffer.writeln();
      }
    }
    
    final text = buffer.toString();
    
    // Copy to clipboard as fallback
    Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Text copied to clipboard')),
      );
    }
  }

  void _resetForm() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Form'),
        content: const Text('Reset all fields? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (widget.formId == 'vakalatnama') {
                ref.read(vakalatnamaProvider.notifier).reset();
              } else {
                for (final controller in _controllers.values) {
                  controller.clear();
                }
              }
              Navigator.pop(context);
              setState(() {});
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _syncVakalatnamaToControllers(Map<String, dynamic> updates) {
    // Sync vakalatnama provider updates to the legacy controllers for PDF generation
    for (final entry in updates.entries) {
      switch (entry.key) {
        case 'courtName':
          _controllers['courtName']?.text = entry.value as String;
          break;
        case 'caseType':
          _controllers['caseType']?.text = entry.value as String;
          break;
        case 'caseNumber':
          _controllers['caseNumber']?.text = entry.value as String;
          break;
        case 'jurisdictionYear':
          _controllers['jurisdictionYear']?.text = entry.value as String;
          break;
        case 'plaintiffs':
          final plaintiffs = List<String>.from(entry.value);
          _controllers['plaintiffs']?.text = plaintiffs.where((p) => p.trim().isNotEmpty).join(', ');
          break;
        case 'defendants':
          final defendants = List<String>.from(entry.value);
          _controllers['defendants']?.text = defendants.where((d) => d.trim().isNotEmpty).join(', ');
          break;
        case 'advocates':
          final advocates = List<String>.from(entry.value);
          _controllers['advocateNames']?.text = advocates.where((a) => a.trim().isNotEmpty).join(', ');
          _controllers['advocate_name']?.text = advocates.where((a) => a.trim().isNotEmpty).join(', ');
          break;
        case 'signingDay':
          _controllers['executionDay']?.text = entry.value as String;
          _controllers['signing_day']?.text = entry.value as String;
          break;
        case 'signingMonth':
          _controllers['executionMonth']?.text = entry.value as String;
          break;
        case 'signingYear':
          _controllers['executionYear']?.text = entry.value as String;
          break;
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final entry = DocumentRegistry.getById(_config.id);
    final isWideScreen = MediaQuery.of(context).size.width > 768;

    return Scaffold(
      backgroundColor: context.ground,
      appBar: LalAppBar(
        title: _config.title,
        actions: [
          IconButton(icon: const Icon(Icons.picture_as_pdf), onPressed: _downloadPdf, tooltip: 'Download PDF'),
          IconButton(icon: const Icon(Icons.text_snippet), onPressed: _downloadText, tooltip: 'Download Text'),
          IconButton(icon: const Icon(Icons.print), onPressed: _printDocument, tooltip: 'Print'),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _resetForm, tooltip: 'Reset'),
        ],
      ),
      body: Column(
        children: [
          // Completeness indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: _completeness == 100 ? Colors.green.shade50 : Colors.amber.shade50,
            child: Row(
              children: [
                Icon(
                  _completeness == 100 ? Icons.check_circle : Icons.warning,
                  color: _completeness == 100 ? Colors.green : Colors.amber,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text('$_completeness% Complete', style: AppTextStyles.label(color: _completeness == 100 ? Colors.green : Colors.amber)),
                const Spacer(),
                widget.formId == 'vakalatnama'
                    ? Text('${ref.read(vakalatnamaProvider).errors.length} issues', 
                        style: AppTextStyles.bodySmall(color: Colors.grey.shade600))
                    : Text('${_formData.values.where((v) => v.isNotEmpty).length}/${_config.fields.length} fields', 
                        style: AppTextStyles.bodySmall(color: Colors.grey.shade600)),
              ],
            ),
          ),

          // Main content area
          Expanded(
            child: isWideScreen ? _buildSplitPane(entry) : _buildTabbedView(entry),
          ),
        ],
      ),
    );
  }

  Widget _buildSplitPane(RegistryEntry? entry) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left panel: Form / Chat
        SizedBox(
          width: 420,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SegmentedButton<BuilderTab>(
                  segments: const [
                    ButtonSegment(value: BuilderTab.form, label: Text('Form'), icon: Icon(Icons.edit)),
                    ButtonSegment(value: BuilderTab.chat, label: Text('AI Chat'), icon: Icon(Icons.chat)),
                  ],
                  selected: {_activeTab},
                  onSelectionChanged: (value) {
                    setState(() => _activeTab = value.first);
                  },
                ),
              ),
              Expanded(
                child: _activeTab == BuilderTab.chat
                    ? widget.formId == 'vakalatnama'
                        ? VakalatnamaChatbotPanel(
                            initialData: ref.watch(vakalatnamaProvider),
                            onDataUpdated: (updates) {
                              ref.read(vakalatnamaProvider.notifier).bulkUpdate(updates);
                              _syncVakalatnamaToControllers(updates);
                              setState(() {});
                            },
                            onComplete: () {
                              setState(() {});
                            },
                          )
                        : GenericChatbotPanel(
                            config: _config,
                            controllers: _controllers,
                            onFieldUpdated: () => setState(() {}),
                          )
                    : widget.formId == 'vakalatnama'
                        ? const _VakalatnamaFormPanel()
                        : GenericFormPanel(
                            config: _config,
                            controllers: _controllers,
                            onFieldUpdated: () => setState(() {}),
                          ),
              ),
            ],
          ),
        ),
        const VerticalDivider(width: 1),
        // Right panel: Preview
        Expanded(
          child: Container(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            child: entry != null
                ? _buildPreview(entry.previewId)
                : const Center(child: Text('No preview available')),
          ),
        ),
      ],
    );
  }

  Widget _buildTabbedView(RegistryEntry? entry) {
    return Column(
      children: [
        Container(
          color: Theme.of(context).cardColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: SegmentedButton<BuilderTab>(
                  segments: const [
                    ButtonSegment(value: BuilderTab.form, label: Text('Form'), icon: Icon(Icons.edit)),
                    ButtonSegment(value: BuilderTab.chat, label: Text('AI Chat'), icon: Icon(Icons.chat)),
                    ButtonSegment(value: BuilderTab.preview, label: Text('Preview'), icon: Icon(Icons.preview)),
                  ],
                  selected: {_activeTab},
                  onSelectionChanged: (value) {
                    setState(() => _activeTab = value.first);
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: switch (_activeTab) {
            BuilderTab.form => widget.formId == 'vakalatnama'
                ? const _VakalatnamaFormPanel()
                : GenericFormPanel(
                    config: _config,
                    controllers: _controllers,
                    onFieldUpdated: () => setState(() {}),
                  ),
            BuilderTab.chat => widget.formId == 'vakalatnama'
                ? VakalatnamaChatbotPanel(
                    initialData: ref.watch(vakalatnamaProvider),
                    onDataUpdated: (updates) {
                      ref.read(vakalatnamaProvider.notifier).bulkUpdate(updates);
                      _syncVakalatnamaToControllers(updates);
                      setState(() {});
                    },
                    onComplete: () {
                      setState(() {});
                    },
                  )
                : GenericChatbotPanel(
                    config: _config,
                    controllers: _controllers,
                    onFieldUpdated: () => setState(() {}),
                  ),
            BuilderTab.preview => Container(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                child: entry != null ? _buildPreview(entry.previewId) : const Center(child: Text('No preview available')),
              ),
          },
        ),
      ],
    );
  }

  Widget _buildPreview(String previewId) {
    // Try to use the preview factory for proper previews
    try {
      return _PreviewWrapper(
        child: _buildPreviewContent(previewId),
      );
    } catch (e) {
      return const Center(child: Text('Preview not available'));
    }
  }

  Widget _buildPreviewContent(String previewId) {
    switch (previewId) {
      case 'vakalatnama':
        final vakalatnamaData = ref.watch(vakalatnamaProvider);
        return VakalatnamaPreview(
          data: vakalatnamaData.toFormData(),
          activeField: vakalatnamaData.activeField,
        );
      case 'legalMeeting':
        return _LegalMeetingPreviewContent(data: _formData);
      default:
        return _GenericPreviewContent(data: _formData, config: _config);
    }
  }
}

class _PreviewWrapper extends StatelessWidget {
  final Widget child;
  const _PreviewWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: child,
        ),
      ),
    );
  }
}

class _VakalatnamaFormPanel extends ConsumerWidget {
  const _VakalatnamaFormPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(vakalatnamaProvider);
    final notifier = ref.read(vakalatnamaProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress bar
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Document Completion', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        Text('${data.completeness}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: FractionallySizedBox(
                        widthFactor: data.completeness / 100,
                        alignment: Alignment.centerLeft,
                        child: Container(
                          decoration: BoxDecoration(
                            color: data.completeness == 100 ? Colors.green : Colors.amber,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Validation errors
          if (data.errors.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                border: Border.all(color: Colors.amber.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, size: 16, color: Colors.amber.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${data.errors.length} field${data.errors.length > 1 ? 's' : ''} need attention',
                      style: TextStyle(fontSize: 12, color: Colors.amber.shade800),
                    ),
                  ),
                ],
              ),
            ),

          // Court Details
          _buildSectionHeader('1', 'Court Details'),
          const SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              labelText: 'Court Name *',
              hintText: 'e.g., District Court, Patiala House, New Delhi',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              errorText: data.errors.any((e) => e.field == 'courtName') ? data.errors.firstWhere((e) => e.field == 'courtName').message : null,
            ),
            onChanged: (v) => notifier.setField('courtName', v),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Case Type',
                    border: OutlineInputBorder(),
                  ),
                  initialValue: data.caseType,
                  items: const [
                    DropdownMenuItem(value: 'Suit', child: Text('Suit')),
                    DropdownMenuItem(value: 'Appeal', child: Text('Appeal')),
                  ],
                  onChanged: (v) => notifier.setField('caseType', v ?? 'Suit'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Case Number',
                    hintText: 'e.g., 123/2025',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => notifier.setField('caseNumber', v),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Year',
                    hintText: '2025',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  onChanged: (v) => notifier.setField('jurisdictionYear', v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Plaintiffs
          _buildSectionHeader('2', 'Plaintiff(s) / Petitioner(s) *'),
          const SizedBox(height: 8),
          for (final entry in data.plaintiffs.asMap().entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Plaintiff ${entry.key + 1} name',
                        border: const OutlineInputBorder(),
                        errorText: data.errors.any((e) => e.field == 'plaintiffs') && entry.value.trim().isEmpty
                            ? data.errors.firstWhere((e) => e.field == 'plaintiffs').message
                            : null,
                      ),
                      onChanged: (v) => notifier.setArrayItem('plaintiffs', entry.key, v),
                    ),
                  ),
                  if (data.plaintiffs.length > 1)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => notifier.removeArrayItem('plaintiffs', entry.key),
                    ),
                ],
              ),
            ),
          TextButton.icon(
            onPressed: () => notifier.addArrayItem('plaintiffs'),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Add Plaintiff'),
          ),
          const SizedBox(height: 20),

          // Defendants
          _buildSectionHeader('3', 'Defendant(s) / Respondent(s)'),
          const SizedBox(height: 8),
          for (final entry in data.defendants.asMap().entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Defendant ${entry.key + 1} name',
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (v) => notifier.setArrayItem('defendants', entry.key, v),
                    ),
                  ),
                  if (data.defendants.length > 1)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => notifier.removeArrayItem('defendants', entry.key),
                    ),
                ],
              ),
            ),
          TextButton.icon(
            onPressed: () => notifier.addArrayItem('defendants'),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Add Defendant'),
          ),
          const SizedBox(height: 20),

          // Advocates
          _buildSectionHeader('4', 'Advocate(s) *'),
          const SizedBox(height: 8),
          for (final entry in data.advocates.asMap().entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Advocate ${entry.key + 1} name',
                        border: const OutlineInputBorder(),
                        errorText: data.errors.any((e) => e.field == 'advocates') && entry.value.trim().isEmpty
                            ? data.errors.firstWhere((e) => e.field == 'advocates').message
                            : null,
                      ),
                      onChanged: (v) => notifier.setArrayItem('advocates', entry.key, v),
                    ),
                  ),
                  if (data.advocates.length > 1)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => notifier.removeArrayItem('advocates', entry.key),
                    ),
                ],
              ),
            ),
          TextButton.icon(
            onPressed: () => notifier.addArrayItem('advocates'),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Add Advocate'),
          ),
          const SizedBox(height: 20),

          // Execution Date
          _buildSectionHeader('5', 'Execution Date *'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Day',
                    hintText: 'DD',
                    border: const OutlineInputBorder(),
                    errorText: data.errors.any((e) => e.field == 'signingDay') ? data.errors.firstWhere((e) => e.field == 'signingDay').message : null,
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => notifier.setField('signingDay', v),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Month',
                    border: OutlineInputBorder(),
                  ),
                  initialValue: data.signingMonth.isEmpty ? null : data.signingMonth,
                  hint: const Text('Select...'),
                  items: months.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                  onChanged: (v) => notifier.setField('signingMonth', v ?? ''),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Year',
                    hintText: 'YYYY',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => notifier.setField('signingYear', v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Consent
          _buildSectionHeader('6', 'Authorization Consent'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Checkbox(
                  value: data.consentConfirmed,
                  onChanged: (v) => notifier.setField('consentConfirmed', v ?? false),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'I confirm that I authorize the above-named Advocate(s) with full authority to act, appear, plead, '
                    'sign petitions, compromise, withdraw proceedings, appoint substitute advocates, deposit/withdraw '
                    'money, and perform all necessary acts on my behalf in the above-noted case.',
                    style: const TextStyle(fontSize: 12, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String number, String title) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: Color(0xFF1a1a2e),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(number, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _LegalMeetingPreviewContent extends StatelessWidget {
  final Map<String, String> data;
  const _LegalMeetingPreviewContent({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(child: Text('APPLICATION FOR LEGAL MEETING', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
          const SizedBox(height: 30),
          _buildRow('Jail No.', data['jailNo'] ?? '____________________'),
          _buildRow('State Vs.', data['stateVs'] ?? '____________________'),
          _buildRow('Accused Name', data['accusedName'] ?? '____________________'),
          _buildRow('Father Name', data['fatherName'] ?? '____________________'),
          _buildRow('Address', data['address'] ?? '____________________'),
          _buildRow('Advocate Name', data['advocateName'] ?? '____________________'),
          _buildRow('Date', '${data['Day'] ?? '____'}/${data['month'] ?? '____'}/${data['year'] ?? '____'}'),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 150, child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}

class _GenericPreviewContent extends StatelessWidget {
  final Map<String, String> data;
  final DocumentConfig config;
  const _GenericPreviewContent({required this.data, required this.config});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(config.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 30),
          ...config.fields.map((field) {
            final value = data[field.key] ?? '';
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(field.label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(value.isEmpty ? '[Not filled]' : value, style: const TextStyle(fontSize: 14)),
                  const Divider(height: 24),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
