import 'dart:io';
import 'dart:ui' show Rect;
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart' as mlkit;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfx/pdfx.dart' as pdfx;

class OcrService {
  final mlkit.TextRecognizer _textRecognizer = mlkit.TextRecognizer();

  /// Extract text from an image file
  Future<OcrResult> extractTextFromImage(File imageFile) async {
    try {
      final inputImage = mlkit.InputImage.fromFile(imageFile);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      return OcrResult(
        text: recognizedText.text,
        blocks: recognizedText.blocks.map((b) => OcrTextBlock(
          text: b.text,
          boundingBox: b.boundingBox,
        )).toList(),
      );
    } catch (e) {
      return OcrResult(text: '', blocks: [], error: e.toString());
    }
  }

  /// Extract text from a PDF file with progress tracking
  Future<OcrPdfResult> extractTextFromPdf(
    File pdfFile, {
    void Function(int current, int total)? onProgress,
  }) async {
    final allText = <String>[];
    final allBlocks = <OcrTextBlock>[];
    String? error;
    int totalPages = 0;

    try {
      final pdfDocument = await pdfx.PdfDocument.openFile(pdfFile.path);
      totalPages = pdfDocument.pagesCount;

      for (int i = 1; i <= totalPages; i++) {
        File? tempFile;
        try {
          final page = await pdfDocument.getPage(i);
          final pageImage = await page.render(
            width: page.width * 2,
            height: page.height * 2,
          );

          if (pageImage != null) {
            final tempDir = Directory.systemTemp;
            tempFile = File('${tempDir.path}/ocr_page_$i.png');
            await tempFile.writeAsBytes(pageImage.bytes);

            final inputImage = mlkit.InputImage.fromFile(tempFile);
            final recognizedText = await _textRecognizer.processImage(inputImage);

            allText.add(recognizedText.text);
            allBlocks.addAll(recognizedText.blocks.map((b) => OcrTextBlock(
              text: '[Page $i] ${b.text}',
              boundingBox: b.boundingBox,
            )));
          }

          await page.close();

          if (onProgress != null) {
            onProgress(i, totalPages);
          }
        } catch (e) {
          error = 'Error on page $i: $e';
          allText.add('[Error on page $i: $e]');
        } finally {
          await tempFile?.delete();
        }
      }

      await pdfDocument.close();
    } catch (e) {
      error = 'Failed to open PDF: $e';
    }

    return OcrPdfResult(
      fullText: allText.join('\n\n'),
      blocks: allBlocks,
      totalPages: totalPages,
      error: error,
    );
  }

  Future<void> dispose() async {
    _textRecognizer.close();
  }
}

class OcrResult {
  final String text;
  final List<OcrTextBlock> blocks;
  final String? error;

  OcrResult({required this.text, required this.blocks, this.error});
}

class OcrPdfResult {
  final String fullText;
  final List<OcrTextBlock> blocks;
  final int totalPages;
  final String? error;

  OcrPdfResult({
    required this.fullText,
    required this.blocks,
    required this.totalPages,
    this.error,
  });
}

class OcrTextBlock {
  final String text;
  final Rect boundingBox;

  OcrTextBlock({required this.text, required this.boundingBox});
}

class OcrProgress {
  final int currentPage;
  final int totalPages;
  final double percentage;

  OcrProgress({
    required this.currentPage,
    required this.totalPages,
  }) : percentage = totalPages > 0 ? currentPage / totalPages : 0.0;
}

// Provider for OCR service
final ocrServiceProvider = Provider<OcrService>((ref) {
  return OcrService();
});

// Provider for OCR state
final ocrStateProvider = StateNotifierProvider<OcrStateNotifier, OcrScreenState>((ref) {
  return OcrStateNotifier();
});

class OcrScreenState {
  final bool isProcessing;
  final String extractedText;
  final String? error;
  final OcrProgress? progress;

  OcrScreenState({
    this.isProcessing = false,
    this.extractedText = '',
    this.error,
    this.progress,
  });

  OcrScreenState copyWith({
    bool? isProcessing,
    String? extractedText,
    String? error,
    OcrProgress? progress,
  }) {
    return OcrScreenState(
      isProcessing: isProcessing ?? this.isProcessing,
      extractedText: extractedText ?? this.extractedText,
      error: error,
      progress: progress ?? this.progress,
    );
  }
}

class OcrStateNotifier extends StateNotifier<OcrScreenState> {
  OcrStateNotifier() : super(OcrScreenState());

  void setProcessing(bool processing) {
    state = state.copyWith(isProcessing: processing);
  }

  void setProgress(OcrProgress progress) {
    state = state.copyWith(progress: progress);
  }

  void setExtractedText(String text) {
    state = state.copyWith(extractedText: text, isProcessing: false, progress: null);
  }

  void setError(String error) {
    state = state.copyWith(error: error, isProcessing: false, progress: null);
  }

  void reset() {
    state = OcrScreenState();
  }
}
