import 'package:intl/intl.dart';

/// Date formatting utilities for Indian legal context
class DateFormatter {
  static final _indianFormat = DateFormat('dd/MM/yyyy');
  static final _indianFormatWithTime = DateFormat('dd/MM/yyyy HH:mm');
  static final _apiFormat = DateFormat('yyyy-MM-dd');
  static final _displayFormat = DateFormat('MMM dd, yyyy');

  /// Format date to Indian format (DD/MM/YYYY)
  static String toIndianFormat(DateTime date) {
    return _indianFormat.format(date);
  }

  /// Format date with time to Indian format
  static String toIndianFormatWithTime(DateTime date) {
    return _indianFormatWithTime.format(date);
  }

  /// Format date for API submission (YYYY-MM-DD)
  static String toApiFormat(DateTime date) {
    return _apiFormat.format(date);
  }

  /// Format date for display (MMM DD, YYYY)
  static String toDisplayFormat(DateTime date) {
    return _displayFormat.format(date);
  }

  /// Parse date from Indian format string
  static DateTime? fromIndianFormat(String dateString) {
    try {
      return _indianFormat.parseStrict(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Get relative time string (e.g., "2 hours ago", "3 days ago")
  static String getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks weeks ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months months ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years years ago';
    }
  }

  /// Check if a date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Check if a date is this week
  static bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
        date.isBefore(endOfWeek.add(const Duration(days: 1)));
  }
}
