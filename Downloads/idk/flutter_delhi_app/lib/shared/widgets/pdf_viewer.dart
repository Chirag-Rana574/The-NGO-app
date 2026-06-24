import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfx/pdfx.dart' as pdfx;
import '../../data/models/bookmark.dart';
import '../../theme/app_text_styles.dart';

class PdfViewerWidget extends ConsumerStatefulWidget {
  final File pdfFile;
  final String documentId;
  final List<Bookmark> bookmarks;
  final Function(int pageNumber, String note)? onBookmarkAdded;

  const PdfViewerWidget({
    super.key,
    required this.pdfFile,
    required this.documentId,
    required this.bookmarks,
    this.onBookmarkAdded,
  });

  @override
  ConsumerState<PdfViewerWidget> createState() => _PdfViewerWidgetState();
}

class _PdfViewerWidgetState extends ConsumerState<PdfViewerWidget> {
  pdfx.PdfController? _pdfController;
  int _currentPage = 1;
  int _totalPages = 0;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  pdfx.PdfDocument? _document;

  Future<void> _loadPdf() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      _document = await pdfx.PdfDocument.openFile(widget.pdfFile.path);
      setState(() {
        _totalPages = _document!.pagesCount;
        _isLoading = false;
      });

      _pdfController = pdfx.PdfController(
        document: pdfx.PdfDocument.openFile(widget.pdfFile.path),
        initialPage: 1,
      );
    } catch (e) {
      setState(() {
        _error = 'Failed to load PDF: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    _document?.close();
    super.dispose();
  }

  void _goToPage(int page) {
    if (_pdfController != null && page >= 1 && page <= _totalPages) {
      _pdfController!.jumpToPage(page);
      setState(() => _currentPage = page);
    }
  }

  void _nextPage() {
    if (_currentPage < _totalPages) {
      _goToPage(_currentPage + 1);
    }
  }

  void _previousPage() {
    if (_currentPage > 1) {
      _goToPage(_currentPage - 1);
    }
  }

  void _showAddBookmarkDialog() {
    final pageController = TextEditingController(text: _currentPage.toString());
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Bookmark'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: pageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Page Number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final pageNum = int.tryParse(pageController.text) ?? _currentPage;
              final note = noteController.text;
              widget.onBookmarkAdded?.call(pageNum, note);
              Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bookmark added!')),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        // PDF Viewer
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 48, color: cs.error),
                            const SizedBox(height: 16),
                            Text(
                              _error!,
                              style: AppTextStyles.body(color: cs.onSurface),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : _pdfController != null
                      ? pdfx.PdfView(
                          controller: _pdfController!,
                          scrollDirection: Axis.vertical,
                          onPageChanged: (page) {
                            setState(() => _currentPage = page);
                          },
                        )
                      : const SizedBox.shrink(),
        ),

        // Page Navigation Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: cs.surface,
            border: Border(top: BorderSide(color: cs.outlineVariant)),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: _currentPage > 1 ? _previousPage : null,
                icon: const Icon(Icons.chevron_left),
                tooltip: 'Previous Page',
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$_currentPage / $_totalPages',
                  style: AppTextStyles.bodySmall(color: cs.onPrimaryContainer).copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: _currentPage < _totalPages ? _nextPage : null,
                icon: const Icon(Icons.chevron_right),
                tooltip: 'Next Page',
              ),
              const Spacer(),
              // Bookmark button
              IconButton(
                onPressed: _showAddBookmarkDialog,
                icon: Icon(Icons.bookmark_add, color: cs.primary),
                tooltip: 'Add Bookmark',
              ),
              // Jump to page
              IconButton(
                onPressed: () {
                  final controller = TextEditingController();
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Go to Page'),
                      content: TextField(
                        controller: controller,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Page Number',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            final page = int.tryParse(controller.text);
                            if (page != null && page >= 1 && page <= _totalPages) {
                              _goToPage(page);
                              Navigator.pop(ctx);
                            }
                          },
                          child: const Text('Go'),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.search),
                tooltip: 'Go to Page',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
