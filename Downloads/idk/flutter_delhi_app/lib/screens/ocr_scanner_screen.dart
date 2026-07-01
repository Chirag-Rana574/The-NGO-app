import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/context_colors.dart';
import '../shared/widgets/pietra_card.dart';
import '../utils/ocr_service.dart';
import '../data/providers/ocr_history_provider.dart';

class OcrScannerScreen extends ConsumerStatefulWidget {
  const OcrScannerScreen({super.key});

  @override
  ConsumerState<OcrScannerScreen> createState() => _OcrScannerScreenState();
}

class _OcrScannerScreenState extends ConsumerState<OcrScannerScreen> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _showHistory = false;

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
      _processImage();
    }
  }

  Future<void> _processImage() async {
    if (_selectedImage == null) return;
    
    final ocrService = ref.read(ocrServiceProvider);
    ref.read(ocrStateProvider.notifier).setProcessing(true);
    
    final result = await ocrService.extractTextFromImage(_selectedImage!);
    
    if (result.error != null) {
      ref.read(ocrStateProvider.notifier).setError(result.error!);
    } else {
      ref.read(ocrStateProvider.notifier).setExtractedText(result.text);
      // Persist to OCR history
      if (result.text.isNotEmpty) {
        final fileName = _selectedImage!.path.split('/').last;
        await ref.read(ocrHistoryProvider.notifier).addScan(
          fileName: fileName,
          extractedText: result.text,
        );
      }
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard'), duration: Duration(seconds: 2)),
    );
  }

  void _shareText(String text) {
    Share.share(text);
  }

  @override
  void dispose() {
    ref.read(ocrServiceProvider).dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ocrState = ref.watch(ocrStateProvider);
    final history = ref.watch(ocrHistoryProvider);

    return Scaffold(
      backgroundColor: context.ground,
      appBar: AppBar(
        title: Text('Document Scanner', style: AppTextStyles.screenTitle(color: context.textPri)),
        backgroundColor: context.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_showHistory ? Icons.camera_alt : Icons.history, color: context.textSec),
            onPressed: () => setState(() => _showHistory = !_showHistory),
            tooltip: _showHistory ? 'Scanner' : 'Scan History',
          ),
        ],
      ),
      body: _showHistory ? _buildHistoryView(context, history) : _buildScannerView(context, ocrState),
    );
  }

  Widget _buildScannerView(BuildContext context, OcrScreenState ocrState) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Scan legal documents to auto-fill form fields',
            style: AppTextStyles.body(color: context.textSec),
          ),
          const SizedBox(height: 24),
          
          PietraCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Capture Method', style: AppTextStyles.body(color: context.textPri).copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _pickImage(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Camera'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.lal,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _pickImage(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Gallery'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.raised,
                          foregroundColor: context.textPri,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          if (_selectedImage != null)
            PietraCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Preview', style: AppTextStyles.body(color: context.textPri).copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: Image.file(_selectedImage!, fit: BoxFit.contain),
                  ),
                ],
              ),
            ),
          
          if (ocrState.isProcessing)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
          
          if (ocrState.error != null)
            PietraCard(
              accentColor: Colors.red,
              padding: const EdgeInsets.all(16),
              child: Text(ocrState.error!, style: const TextStyle(color: Colors.red)),
            ),
          
          if (ocrState.extractedText.isNotEmpty)
            Expanded(
              child: PietraCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Extracted Text', style: AppTextStyles.body(color: context.textPri).copyWith(fontWeight: FontWeight.bold)),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.copy, size: 20, color: context.primary),
                              onPressed: () => _copyToClipboard(ocrState.extractedText),
                              tooltip: 'Copy to Clipboard',
                            ),
                            IconButton(
                              icon: Icon(Icons.share, size: 20, color: context.primary),
                              onPressed: () => _shareText(ocrState.extractedText),
                              tooltip: 'Share',
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        child: SelectableText(
                          ocrState.extractedText,
                          style: AppTextStyles.bodySmall(color: context.textSec),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHistoryView(BuildContext context, List<OcrHistoryItem> history) {
    if (history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.document_scanner, size: 48, color: context.textDim),
            const SizedBox(height: 16),
            Text('No scan history', style: AppTextStyles.body(color: context.textSec)),
            const SizedBox(height: 8),
            Text('Scanned documents will appear here', style: AppTextStyles.bodySmall(color: context.textDim)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final item = history[index];
        final scanDate = DateTime.tryParse(item.scanDate);
        final dateStr = scanDate != null 
            ? '${scanDate.day}/${scanDate.month}/${scanDate.year} ${scanDate.hour}:${scanDate.minute.toString().padLeft(2, '0')}'
            : item.scanDate;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: PietraCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.fileName,
                        style: AppTextStyles.body(color: context.textPri).copyWith(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.copy, size: 18, color: context.primary),
                          onPressed: () => _copyToClipboard(item.extractedText),
                          tooltip: 'Copy',
                        ),
                        IconButton(
                          icon: Icon(Icons.share, size: 18, color: context.primary),
                          onPressed: () => _shareText(item.extractedText),
                          tooltip: 'Share',
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, size: 18, color: context.danger),
                          onPressed: () => ref.read(ocrHistoryProvider.notifier).removeScan(item.id),
                          tooltip: 'Delete',
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(dateStr, style: AppTextStyles.bodySmall(color: context.textDim)),
                const SizedBox(height: 8),
                Text(
                  item.extractedText.length > 200 
                      ? '${item.extractedText.substring(0, 200)}...' 
                      : item.extractedText,
                  style: AppTextStyles.bodySmall(color: context.textSec),
                ),
                if (item.extractedText.length > 200)
                  TextButton(
                    onPressed: () => _showFullTextDialog(context, item),
                    child: Text('View Full Text', style: TextStyle(color: context.primary)),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFullTextDialog(BuildContext context, OcrHistoryItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.surface,
        title: Text(item.fileName, style: AppTextStyles.chatTitle(color: context.textPri)),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: SingleChildScrollView(
            child: SelectableText(
              item.extractedText,
              style: AppTextStyles.bodySmall(color: context.textSec),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => _copyToClipboard(item.extractedText),
            child: const Text('Copy All'),
          ),
          TextButton(
            onPressed: () => _shareText(item.extractedText),
            child: const Text('Share'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}