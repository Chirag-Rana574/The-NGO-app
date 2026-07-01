import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:delhi_legal_assistant/core/utils/text_wrapper.dart';

void main() {
  group('TextWrapper', () {
    const testStyle = TextStyle(fontSize: 14, height: 1.5);
    const maxWidth = 100.0;

    test('wrapText should split text into lines that fit maxWidth', () {
      final text = 'Hello world this is a test';
      final lines = TextWrapper.wrapText(
        text: text,
        style: testStyle,
        maxWidth: maxWidth,
      );

      expect(lines, isNotEmpty);
      // Each line should fit within maxWidth
      for (final line in lines) {
        final tp = TextPainter(
          text: TextSpan(text: line, style: testStyle),
          maxLines: 1,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: maxWidth);
        expect(tp.didExceedMaxLines, isFalse);
      }
    });

    test('wrapText should handle empty string', () {
      final lines = TextWrapper.wrapText(
        text: '',
        style: testStyle,
        maxWidth: maxWidth,
      );
      expect(lines, isEmpty);
    });

    test('wrapText should handle single word', () {
      final lines = TextWrapper.wrapText(
        text: 'Hello',
        style: testStyle,
        maxWidth: maxWidth,
      );
      expect(lines, equals(['Hello']));
    });

    test('calculateTextHeight should return positive height', () {
      final height = TextWrapper.calculateTextHeight(
        text: 'Hello world',
        style: testStyle,
        maxWidth: maxWidth,
      );
      expect(height, greaterThan(0));
    });

    test('truncateText should not truncate short text', () {
      final text = 'Short';
      final result = TextWrapper.truncateText(
        text: text,
        style: testStyle,
        maxWidth: maxWidth,
      );
      expect(result, equals(text));
    });

    test('truncateText should truncate long text with ellipsis', () {
      final text = 'This is a very long text that should be truncated';
      final result = TextWrapper.truncateText(
        text: text,
        style: testStyle,
        maxWidth: 50,
        ellipsis: '...',
      );
      expect(result.endsWith('...'), isTrue);
    });

    test('truncateText should return ellipsis for empty string', () {
      final result = TextWrapper.truncateText(
        text: '',
        style: testStyle,
        maxWidth: maxWidth,
        ellipsis: '...',
      );
      expect(result, equals('...'));
    });
  });
}
