import 'dart:typed_data';
import 'dart:ui' show Rect;
import 'package:flutter/services.dart' show rootBundle;
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:pdf/pdf.dart' as pw;
import 'package:pdf/widgets.dart' as pw_widgets;
import 'pdf_coordinates.dart';

/// PDF Generator Service — Template Overlay + Screenshot-based PDF
///
/// Supports two modes:
/// 1. Template overlay: Loads original PDF template and overlays data at calibrated coordinates
/// 2. Screenshot-based: Captures widget preview as image and embeds in Legal-size PDF
class PdfGeneratorService {
  /// Maps camelCase registry IDs to the snake_case keys used in allFieldCoords.
  static const Map<String, String> _coordIdAliases = {
    'bailBond437a': 'bail_bond_437a',
    'affidavitConvict': 'affidavit_convict',
    'certifiedForm': 'criminal_cai',
    'memorandumOfAppearance': 'memo_appearance',
    'processFee': 'process_fee',
    'extraPartyInfo': 'extra_party_info',
    'listOfDocumentsCommercial': 'list_documents_commercial',
    'bailPerforma': 'bail_performa',
    'form45BailBond': 'form45_bail_bond',
    'niActComplaint': 'niact_complaint',
    'checkList138': 'checklist_138',
    'gatePass': 'gate_pass',
    'urgentMentioning': 'urgent_mentioning',
    'rtiApplication': 'rti_application',
    'indexForm': 'index_form',
    'inspectionForm': 'inspection_form',
    'listOfDocuments': 'list_of_documents',
    'addressForm': 'address_form',
    'caseInformation': 'case_information',
    'bailBond116': 'bail_bond_116',
    'annexureBBailBond': 'annexure_b_bail_bond',
    'civilCertifiedCopy': 'civil_certified_copy',
    'listingPerforma': 'listing_performa',
  };

  static String _resolveCoordId(String formId) {
    if (allFieldCoords.containsKey(formId)) return formId;
    return _coordIdAliases[formId] ?? formId;
  }

  /// Generates a filled PDF using template overlay approach.
  /// Returns raw PDF bytes (Uint8List).
  static Future<Uint8List> generatePdf(
      String formId, Map<String, String> data) async {
    // Resolve the template filename
    final templateName = templateFiles[formId];
    if (templateName == null) {
      throw Exception('No template mapping found for form: $formId');
    }

    // Load template from assets
    final ByteData byteData =
        await rootBundle.load('assets/templates/$templateName');
    final Uint8List templateBytes = byteData.buffer.asUint8List();

    // Open the existing PDF
    final PdfDocument document = PdfDocument(inputBytes: templateBytes);

    // Get the coordinate map for this form (resolve camelCase → snake_case)
    final coordId = _resolveCoordId(formId);
    final coords = allFieldCoords[coordId];
    if (coords == null) {
      // No coordinates mapped yet — return the blank template
      final Uint8List result = Uint8List.fromList(document.saveSync());
      document.dispose();
      return result;
    }

    // Create brush for text overlay
    final PdfBrush fillBrush =
        PdfSolidBrush(PdfColor(26, 26, 102)); // rgb(0.1, 0.1, 0.4)

    // Draw each field
    data.forEach((fieldName, text) {
      if (text.trim().isEmpty) return;

      final coord = coords[fieldName];
      if (coord == null) return; // No coordinate for this field — skip

      // Get the target page
      if (coord.page >= document.pages.count) return;
      final PdfPage page = document.pages[coord.page];

      // Create font at the correct size
      final double actualFontSize = coord.fontSize;
      PdfFont fieldFont = PdfStandardFont(
          PdfFontFamily.helvetica, actualFontSize,
          style: PdfFontStyle.bold);

      // Handle multiline text by auto-wrapping
      List<String> autoWrapText(String text, double maxWidth, PdfFont font) {
        if (text.isEmpty) return [];
        final manualLines = text.split('\n');
        final finalLines = <String>[];
        for (final manualLine in manualLines) {
          if (manualLine.trim().isEmpty) {
            finalLines.add('');
            continue;
          }
          if (font.measureString(manualLine).width <= maxWidth) {
            finalLines.add(manualLine);
            continue;
          }
          final words = manualLine.split(' ');
          String currentLine = words.isNotEmpty ? words[0] : '';
          for (int j = 1; j < words.length; j++) {
            final word = words[j];
            final testLine = '$currentLine $word';
            if (font.measureString(testLine).width > maxWidth && currentLine.trim().isNotEmpty) {
              finalLines.add(currentLine);
              currentLine = word;
            } else {
              currentLine = testLine;
            }
          }
          if (currentLine.isNotEmpty) {
            finalLines.add(currentLine);
          }
        }
        return finalLines;
      }

      final lines = autoWrapText(text, coord.maxWidth, fieldFont);

      // Auto-shrink font if any single word exceeds maxWidth
      double fontSize = actualFontSize;
      final longestLine = lines.reduce((a, b) =>
          fieldFont.measureString(a).width >
                  fieldFont.measureString(b).width
              ? a
              : b);
      while (fieldFont.measureString(longestLine).width > coord.maxWidth &&
          fontSize > 7) {
        fontSize -= 0.5;
        fieldFont = PdfStandardFont(PdfFontFamily.helvetica, fontSize,
            style: PdfFontStyle.bold);
      }

      final double lineHeight = fontSize * 1.2;

      // Draw whiteout rectangle if needed
      if (coord.whiteout) {
        final double textWidth =
            fieldFont.measureString(longestLine).width;
        page.graphics.drawRectangle(
          brush: PdfSolidBrush(PdfColor(255, 255, 255)),
          bounds: Rect.fromLTWH(
            coord.x - 15,
            coord.yFromTop - 2,
            textWidth + 20,
            fontSize + 4 + (lineHeight * (lines.length - 1)),
          ),
        );
      }

      // Draw each line of text
      for (int i = 0; i < lines.length; i++) {
        if (lines[i].trim().isEmpty) continue;
        
        // Check if there is an explicit continuation coordinate for this line
        FieldCoord? lineCoord = (i == 0) ? coord : null;
        if (i > 0) {
          // Look for common suffix patterns used in pdf_coordinates.dart
          lineCoord = coords['$fieldName ${i + 1}'] ?? 
                      coords['$fieldName${i + 1}'];
        }

        final double drawX = lineCoord != null ? lineCoord.x : coord.x;
        final double drawY = lineCoord != null ? lineCoord.yFromTop : coord.yFromTop + (i * lineHeight);
        final double drawMaxWidth = lineCoord != null ? lineCoord.maxWidth : coord.maxWidth;
        final int targetPage = lineCoord != null ? lineCoord.page : coord.page;

        // Ensure we draw on the correct page (in case continuation spans to next page)
        final PdfPage targetPdfPage = targetPage < document.pages.count 
            ? document.pages[targetPage] 
            : page;

        targetPdfPage.graphics.drawString(
          lines[i],
          fieldFont,
          brush: fillBrush,
          bounds: Rect.fromLTWH(
            drawX,
            drawY,
            drawMaxWidth,
            lineHeight + 2,
          ),
        );
      }
    });

    // Save and return
    final Uint8List result = Uint8List.fromList(document.saveSync());
    document.dispose();
    return result;
  }

  /// Generates a Legal-size (8.5" × 14") PDF from a widget image.
  /// This is useful for documents without pre-existing templates.
  /// [imageBytes] should be a PNG representation of the document preview.
  static Future<Uint8List> generatePdfFromImage(
      Uint8List imageBytes, {
      String title = 'Document',
    }) async {
    final pdf = pw_widgets.Document();

    // Legal size: 8.5" × 14" = 215.9mm × 355.6mm
    const legalPage = pw.PdfPageFormat.legal;

    pdf.addPage(
      pw_widgets.Page(
        pageFormat: legalPage,
        build: (pw_widgets.Context context) {
          return pw_widgets.Center(
            child: pw_widgets.Image(
              pw_widgets.MemoryImage(imageBytes),
              fit: pw_widgets.BoxFit.contain,
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Generates a text-based Legal-size PDF for simple documents.
  static Future<Uint8List> generateTextPdf(
      String title,
      Map<String, String> data, {
      List<String>? sections,
    }) async {
    final pdf = pw_widgets.Document();
    const legalPage = pw.PdfPageFormat.legal;

    final sectionsList = sections ?? data.keys.toList();

    pdf.addPage(
      pw_widgets.Page(
        pageFormat: legalPage,
        build: (pw_widgets.Context context) {
          return pw_widgets.Padding(
            padding: const pw_widgets.EdgeInsets.all(40),
            child: pw_widgets.Column(
              crossAxisAlignment: pw_widgets.CrossAxisAlignment.start,
              children: [
                pw_widgets.Text(
                  title,
                  style: pw_widgets.TextStyle(
                    fontSize: 18,
                    fontWeight: pw_widgets.FontWeight.bold,
                  ),
                ),
                pw_widgets.SizedBox(height: 20),
                ...sectionsList.map((section) {
                  final value = data[section] ?? '';
                  return pw_widgets.Padding(
                    padding: const pw_widgets.EdgeInsets.symmetric(vertical: 8),
                    child: pw_widgets.Column(
                      crossAxisAlignment: pw_widgets.CrossAxisAlignment.start,
                      children: [
                        pw_widgets.Text(
                          section,
                          style: pw_widgets.TextStyle(
                            fontSize: 12,
                            fontWeight: pw_widgets.FontWeight.bold,
                            color: pw.PdfColors.grey,
                          ),
                        ),
                        pw_widgets.SizedBox(height: 4),
                        pw_widgets.Text(
                          value.isEmpty ? '[Not filled]' : value,
                          style: const pw_widgets.TextStyle(fontSize: 14),
                        ),
                        pw_widgets.Divider(height: 24),
                      ],
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }
}
