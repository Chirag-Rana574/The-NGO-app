import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/context_colors.dart';
import '../shared/widgets/pietra_card.dart';
import '../utils/ocr_service.dart';

class OcrScannerScreen extends ConsumerStatefulWidget {
  const OcrScannerScreen({super.key});

  @override
  ConsumerState<OcrScannerScreen> createState() => _OcrScannerScreenState();
}

class _OcrScannerScreenState extends ConsumerState<OcrScannerScreen> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

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
    }
  }

  @override
  void dispose() {
    ref.read(ocrServiceProvider).dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ocrState = ref.watch(ocrStateProvider);

    return Scaffold(
      backgroundColor: context.ground,
      appBar: AppBar(
        title: Text('Document Scanner', style: AppTextStyles.screenTitle(color: context.textPri)),
        backgroundColor: context.surface,
        elevation: 0,
      ),
      body: Padding(
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
                      Text('Extracted Text', style: AppTextStyles.body(color: context.textPri).copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Text(ocrState.extractedText, style: AppTextStyles.bodySmall(color: context.textSec)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}