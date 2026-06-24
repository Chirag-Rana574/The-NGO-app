import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/document_registry.dart';
import '../data/preview_factory.dart';
import '../theme/app_text_styles.dart';
import '../shared/widgets/lal_app_bar.dart';
import '../shared/widgets/pietra_card.dart';
import 'package:printing/printing.dart';
import '../utils/pdf_generator_service.dart';

enum BuilderTab { form, chat, preview }

class EnhancedDocumentBuilderScreen extends ConsumerStatefulWidget {
  final String formId;
  const EnhancedDocumentBuilderScreen({super.key, required this.formId});

  @override
  ConsumerState<EnhancedDocumentBuilderScreen> createState() => _EnhancedDocumentBuilderScreenState();
}

class _EnhancedDocumentBuilderScreenState extends ConsumerState<EnhancedDocumentBuilderScreen> {
  final Map<String, TextEditingController> _controllers = {};
  late DocumentConfig _config;
  BuilderTab _activeTab = BuilderTab.form;

  @override
  void initState() {
    super.initState();
    final entry = DocumentRegistry.getById(widget.formId);
    if (entry == null) {
      // Fallback to vakalatnama if not found
      _config = _getDefaultConfig();
    } else {
      _config = entry.config;
    }
    _initializeControllers();
  }

  void _initializeControllers() {
    for (final field in _config.fields) {
      _controllers[field.key] = TextEditingController();
    }
  }

  DocumentConfig _getDefaultConfig() {
    return DocumentConfig(
      id: 'vakalatnama',
      title: 'Vakalatnama',
      description: 'Power of Attorney authorizing an advocate to represent a client.',
      category: 'Civil Procedure',
      fields: [
        DocumentField(key: 'court', label: 'Court Name', type: FieldType.text, required: true),
        DocumentField(key: 'case_type', label: 'Case Type', type: FieldType.text, required: true),
        DocumentField(key: 'case_number', label: 'Case Number', type: FieldType.text, required: true),
        DocumentField(key: 'plaintiffs', label: 'Plaintiff(s)', type: FieldType.textarea, required: true),
        DocumentField(key: 'defendants', label: 'Defendant(s)', type: FieldType.textarea, required: true),
        DocumentField(key: 'advocate_name', label: 'Advocate Name', type: FieldType.text, required: true),
        DocumentField(key: 'advocate_enrollment', label: 'Advocate Enrollment', type: FieldType.text),
      ],
    );
  }

  Map<String, String> _getFormData() {
    return _controllers.map((key, controller) => MapEntry(key, controller.text));
  }

  int get _completeness {
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

  Future<void> _downloadPdf() async {
    try {
      final bytes = await PdfGeneratorService.generatePdf(_config.id, _getFormData());
      
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
    final bytes = await PdfGeneratorService.generatePdf(_config.id, _getFormData());
    await Printing.sharePdf(bytes: bytes, filename: '${_config.id}.pdf');
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
              for (final controller in _controllers.values) {
                controller.clear();
              }
              Navigator.pop(context);
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
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
    final entry = DocumentRegistry.getById(_config.id);
    
    return Scaffold(
      appBar: LalAppBar(
        title: _config.title,
        actions: [
          IconButton(icon: const Icon(Icons.picture_as_pdf), onPressed: _downloadPdf),
          IconButton(icon: const Icon(Icons.print), onPressed: _printDocument),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _resetForm),
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
                Text('$_completeness% Complete'),
              ],
            ),
          ),

          // Main content area
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 768) {
                  // Tablet/Desktop: split pane
                  return _buildSplitPane(entry);
                } else {
                  // Mobile: tabbed view
                  return _buildTabbedView(entry);
                }
              },
            ),
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
          width: 400,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SegmentedButton<BuilderTab>(
                  segments: const [
                    ButtonSegment(value: BuilderTab.form, label: Text('Form'), icon: Icon(Icons.edit)),
                    ButtonSegment(value: BuilderTab.chat, label: Text('AI'), icon: Icon(Icons.chat)),
                  ],
                  selected: {_activeTab == BuilderTab.preview ? BuilderTab.form : _activeTab},
                  onSelectionChanged: (value) {
                    setState(() {
                      _activeTab = value.first;
                    });
                  },
                ),
              ),
              Expanded(
                child: _activeTab == BuilderTab.chat
                    ? _GuidedDraftingChat(
                        config: _config,
                        controllers: _controllers,
                        onStateUpdated: () => setState(() {}),
                      )
                    : _buildFormPanel(),
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
                ? buildDocumentPreview(entry.previewId, _getFormData()) 
                : const Center(child: Text('Preview')),
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
                    ButtonSegment(value: BuilderTab.chat, label: Text('AI'), icon: Icon(Icons.chat)),
                    ButtonSegment(value: BuilderTab.preview, label: Text('Preview'), icon: Icon(Icons.preview)),
                  ],
                  selected: {_activeTab},
                  onSelectionChanged: (value) {
                    setState(() {
                      _activeTab = value.first;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: () {
            switch (_activeTab) {
              case BuilderTab.form:
                return _buildFormPanel();
              case BuilderTab.chat:
                return _GuidedDraftingChat(
                  config: _config,
                  controllers: _controllers,
                  onStateUpdated: () => setState(() {}),
                );
              case BuilderTab.preview:
                return Container(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  child: entry != null 
                      ? buildDocumentPreview(entry.previewId, _getFormData()) 
                      : const Center(child: Text('Preview')),
                );
            }
          }(),
        ),
      ],
    );
  }

  Widget _buildFormPanel() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final field in _config.fields) ...[
            PietraCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    field.label,
                    style: AppTextStyles.label(),
                  ),
                  const SizedBox(height: 8),
                  _buildFieldInput(field),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Widget _buildFieldInput(DocumentField field) {
    final controller = _controllers[field.key]!;
    
    switch (field.type) {
      case FieldType.text:
        return TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: field.placeholder ?? 'Enter ${field.label.toLowerCase()}',
            border: const OutlineInputBorder(),
          ),
        );
      case FieldType.textarea:
        return TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: field.placeholder ?? 'Enter ${field.label.toLowerCase()}',
            border: const OutlineInputBorder(),
          ),
          maxLines: 3,
        );
      case FieldType.select:
        return DropdownMenu<String>(
          controller: TextEditingController(),
          dropdownMenuEntries: (field.options ?? []).map((opt) => DropdownMenuEntry(value: opt, label: opt)).toList(),
          hintText: field.placeholder,
        );
      case FieldType.date:
        return TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: field.placeholder ?? 'YYYY-MM-DD',
            border: const OutlineInputBorder(),
            suffixIcon: const Icon(Icons.calendar_today),
          ),
          readOnly: true,
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2030),
            );
            if (date != null) {
              controller.text = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
            }
          },
        );
      case FieldType.number:
        return TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: field.placeholder,
            border: const OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        );
    }
  }
}

class _GuidedDraftingChat extends StatefulWidget {
  final DocumentConfig config;
  final Map<String, TextEditingController> controllers;
  final VoidCallback onStateUpdated;

  const _GuidedDraftingChat({
    required this.config,
    required this.controllers,
    required this.onStateUpdated,
  });

  @override
  State<_GuidedDraftingChat> createState() => _GuidedDraftingChatState();
}

class _GuidedDraftingChatState extends State<_GuidedDraftingChat> {
  final List<Map<String, String>> _messages = [];
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int _currentFieldIndex = 0;

  @override
  void initState() {
    super.initState();
    _startInterview();
  }

  void _startInterview() {
    if (widget.config.fields.isEmpty) {
      _messages.add({
        'sender': 'ai',
        'text': "There are no fields configured for this document template.",
      });
      return;
    }
    _messages.add({
      'sender': 'ai',
      'text': "Welcome to the guided drafter for *${widget.config.title}*. Let's complete the fields together step-by-step.\n\nFirst, please enter the **${widget.config.fields[0].label}**:",
    });
  }

  void _handleSend() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    _inputController.clear();
    setState(() {
      _messages.add({
        'sender': 'user',
        'text': text,
      });
    });

    // Save to controller
    final currentField = widget.config.fields[_currentFieldIndex];
    widget.controllers[currentField.key]?.text = text;
    widget.onStateUpdated();

    // Scroll to end
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    // Move to next field
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      
      setState(() {
        if (_currentFieldIndex < widget.config.fields.length - 1) {
          _currentFieldIndex++;
          final nextField = widget.config.fields[_currentFieldIndex];
          _messages.add({
            'sender': 'ai',
            'text': "Received! Now, what is the **${nextField.label}**?",
          });
        } else {
          _currentFieldIndex = widget.config.fields.length; // Complete
          _messages.add({
            'sender': 'ai',
            'text': "🎉 Wonderful! All fields have been populated. You can switch to the **Form** tab to make edits or the **Preview** tab to check the generated PDF and print/save it.",
          });
        }
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header info
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.2),
          child: Row(
            children: [
              Icon(Icons.chat_bubble_outline, size: 16, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _currentFieldIndex < widget.config.fields.length
                      ? 'Guided Interview: ${_currentFieldIndex + 1} of ${widget.config.fields.length} fields'
                      : 'Guided Interview: Complete',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              if (_currentFieldIndex > 0)
                TextButton(
                  onPressed: () {
                    setState(() {
                      if (_currentFieldIndex >= widget.config.fields.length) {
                        _currentFieldIndex = widget.config.fields.length - 1;
                      } else {
                        _currentFieldIndex--;
                      }
                      _messages.add({
                        'sender': 'ai',
                        'text': "Let's re-enter: **${widget.config.fields[_currentFieldIndex].label}**",
                      });
                    });
                  },
                  child: const Text('Back', style: TextStyle(fontSize: 12)),
                ),
            ],
          ),
        ),
        
        // Chat area
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final msg = _messages[index];
              final isAi = msg['sender'] == 'ai';
              return Align(
                alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isAi 
                        ? Theme.of(context).colorScheme.surfaceContainerHigh 
                        : Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(12).copyWith(
                      bottomLeft: isAi ? Radius.zero : const Radius.circular(12),
                      bottomRight: isAi ? const Radius.circular(12) : Radius.zero,
                    ),
                  ),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  child: Text(
                    msg['text'] ?? '',
                    style: TextStyle(
                      color: isAi 
                          ? Theme.of(context).colorScheme.onSurface 
                          : Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        
        // Input area
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _inputController,
                  decoration: InputDecoration(
                    hintText: _currentFieldIndex < widget.config.fields.length
                        ? 'Type your answer here...'
                        : 'Interview completed',
                    enabled: _currentFieldIndex < widget.config.fields.length,
                    border: const OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _currentFieldIndex < widget.config.fields.length ? _handleSend() : null,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: _currentFieldIndex < widget.config.fields.length
                    ? _handleSend
                    : null,
                color: Theme.of(context).primaryColor,
              ),
            ],
          ),
        ),
      ],
    );
  }
}