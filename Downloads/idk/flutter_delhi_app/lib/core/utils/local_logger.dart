import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class LocalLogger {
  // Use your Mac's local IP address
  static const String _logServerUrl = 'http://192.168.0.106:8089/log';

  static Future<void> log(String message, {String type = 'info', String? stackTrace}) async {
    final logData = {
      'timestamp': DateTime.now().toIso8601String(),
      'type': type,
      'message': message,
      'stackTrace': stackTrace ?? '',
      'platform': kIsWeb ? 'web' : 'android',
    };

    // Print to developer console
    debugPrint('[$type] $message');

    // Send to local logging server
    try {
      await http.post(
        Uri.parse(_logServerUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(logData),
      ).timeout(const Duration(seconds: 2));
    } catch (e) {
      // Fail silently to prevent infinite log loops if server is offline
    }
  }

  static Future<void> logError(dynamic error, dynamic stackTrace) async {
    await log(
      error.toString(),
      type: 'error',
      stackTrace: stackTrace?.toString(),
    );
  }
}
