import 'package:flutter_test/flutter_test.dart';
import 'package:delhi_legal_assistant/core/utils/date_formatter.dart';

void main() {
  group('DateFormatter', () {
    final testDate = DateTime(2025, 2, 10, 14, 30);

    test('toIndianFormat should format as DD/MM/YYYY', () {
      final result = DateFormatter.toIndianFormat(testDate);
      expect(result, equals('10/02/2025'));
    });

    test('toIndianFormatWithTime should format as DD/MM/YYYY HH:mm', () {
      final result = DateFormatter.toIndianFormatWithTime(testDate);
      expect(result, equals('10/02/2025 14:30'));
    });

    test('toApiFormat should format as YYYY-MM-DD', () {
      final result = DateFormatter.toApiFormat(testDate);
      expect(result, equals('2025-02-10'));
    });

    test('toDisplayFormat should format as MMM DD, YYYY', () {
      final result = DateFormatter.toDisplayFormat(testDate);
      expect(result, equals('Feb 10, 2025'));
    });

    test('fromIndianFormat should parse valid date string', () {
      final result = DateFormatter.fromIndianFormat('10/02/2025');
      expect(result, isNotNull);
      expect(result!.year, equals(2025));
      expect(result.month, equals(2));
      expect(result.day, equals(10));
    });

    test('fromIndianFormat should return null for invalid date string', () {
      final result = DateFormatter.fromIndianFormat('invalid-date');
      expect(result, isNull);
    });

    test('getRelativeTime should return "Just now" for recent time', () {
      final now = DateTime.now();
      final result = DateFormatter.getRelativeTime(now);
      expect(result, equals('Just now'));
    });

    test('getRelativeTime should return minutes ago', () {
      final date = DateTime.now().subtract(const Duration(minutes: 5));
      final result = DateFormatter.getRelativeTime(date);
      expect(result, equals('5 min ago'));
    });

    test('getRelativeTime should return hours ago', () {
      final date = DateTime.now().subtract(const Duration(hours: 3));
      final result = DateFormatter.getRelativeTime(date);
      expect(result, equals('3 hours ago'));
    });

    test('getRelativeTime should return days ago', () {
      final date = DateTime.now().subtract(const Duration(days: 2));
      final result = DateFormatter.getRelativeTime(date);
      expect(result, equals('2 days ago'));
    });

    test('getRelativeTime should return weeks ago', () {
      final date = DateTime.now().subtract(const Duration(days: 14));
      final result = DateFormatter.getRelativeTime(date);
      expect(result, equals('2 weeks ago'));
    });

    test('getRelativeTime should return months ago', () {
      final date = DateTime.now().subtract(const Duration(days: 60));
      final result = DateFormatter.getRelativeTime(date);
      expect(result, equals('2 months ago'));
    });

    test('getRelativeTime should return years ago', () {
      final date = DateTime.now().subtract(const Duration(days: 400));
      final result = DateFormatter.getRelativeTime(date);
      expect(result, equals('1 years ago'));
    });

    test('isToday should return true for today', () {
      expect(DateFormatter.isToday(DateTime.now()), isTrue);
    });

    test('isToday should return false for yesterday', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      expect(DateFormatter.isToday(yesterday), isFalse);
    });

    test('isThisWeek should return true for current week', () {
      final thisWeek = DateTime.now().subtract(const Duration(days: 2));
      expect(DateFormatter.isThisWeek(thisWeek), isTrue);
    });

    test('isThisWeek should return false for last week', () {
      final lastWeek = DateTime.now().subtract(const Duration(days: 10));
      expect(DateFormatter.isThisWeek(lastWeek), isFalse);
    });
  });
}
