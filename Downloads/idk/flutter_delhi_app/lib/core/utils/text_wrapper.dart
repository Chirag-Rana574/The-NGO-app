import 'package:flutter/material.dart';

/// Text wrapping utility using TextPainter for multiline text measurement
class TextWrapper {
  /// Wraps text to fit within a maximum width
  static List<String> wrapText({
    required String text,
    required TextStyle style,
    required double maxWidth,
    int? maxLines,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1, // Must be 1 to measure single line overflow boundary
      textDirection: TextDirection.ltr,
    );

    final words = text.split(' ');
    final lines = <String>[];
    var currentLine = '';

    for (final word in words) {
      final testLine = currentLine.isEmpty ? word : '$currentLine $word';
      textPainter.text = TextSpan(text: testLine, style: style);
      textPainter.layout(maxWidth: maxWidth);

      if (textPainter.didExceedMaxLines && currentLine.isNotEmpty) {
        lines.add(currentLine);
        currentLine = word;
      } else {
        currentLine = testLine;
      }
    }

    if (currentLine.isNotEmpty) {
      lines.add(currentLine);
    }

    return lines;
  }

  /// Calculates the height needed for text with given constraints
  static double calculateTextHeight({
    required String text,
    required TextStyle style,
    required double maxWidth,
    int? maxLines,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: maxLines,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(maxWidth: maxWidth);
    return textPainter.height;
  }

  /// Truncates text with ellipsis if it exceeds maxWidth
  static String truncateText({
    required String text,
    required TextStyle style,
    required double maxWidth,
    String ellipsis = '...',
  }) {
    if (text.isEmpty) {
      return ellipsis;
    }
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(maxWidth: maxWidth);

    if (!textPainter.didExceedMaxLines) {
      return text;
    }

    var truncated = text;
    while (truncated.isNotEmpty) {
      truncated = truncated.substring(0, truncated.length - 1);
      textPainter.text = TextSpan(text: '$truncated$ellipsis', style: style);
      textPainter.layout(maxWidth: maxWidth);
      if (!textPainter.didExceedMaxLines) {
        return '$truncated$ellipsis';
      }
    }

    return ellipsis;
  }
}
