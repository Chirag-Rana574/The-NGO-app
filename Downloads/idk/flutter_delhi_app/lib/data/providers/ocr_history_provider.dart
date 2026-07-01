import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Model for a single OCR scan result
class OcrHistoryItem {
  final String id;
  final String fileName;
  final String extractedText;
  final String scanDate;

  OcrHistoryItem({
    required this.id,
    required this.fileName,
    required this.extractedText,
    required this.scanDate,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'fileName': fileName,
    'extractedText': extractedText,
    'scanDate': scanDate,
  };

  factory OcrHistoryItem.fromJson(Map<String, dynamic> json) => OcrHistoryItem(
    id: json['id'] as String? ?? '',
    fileName: json['fileName'] as String? ?? '',
    extractedText: json['extractedText'] as String? ?? '',
    scanDate: json['scanDate'] as String? ?? '',
  );
}

/// Notifier for OCR scan history with SharedPreferences persistence
class OcrHistoryNotifier extends StateNotifier<List<OcrHistoryItem>> {
  OcrHistoryNotifier() : super([]) {
    _loadFromStorage();
  }

  static const String _storageKey = 'ocr_scan_history_v1';
  static const int _maxItems = 50;

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString(_storageKey);
      if (jsonStr != null) {
        final List<dynamic> decoded = jsonDecode(jsonStr);
        state = decoded.map((item) => OcrHistoryItem.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      debugPrint('Error loading OCR history: $e');
      state = [];
    }
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = jsonEncode(state.map((item) => item.toJson()).toList());
      await prefs.setString(_storageKey, encoded);
    } catch (e) {
      debugPrint('Error saving OCR history: $e');
    }
  }

  Future<void> addScan({
    required String fileName,
    required String extractedText,
  }) async {
    final item = OcrHistoryItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fileName: fileName,
      extractedText: extractedText,
      scanDate: DateTime.now().toIso8601String(),
    );
    // Prepend new items, cap at _maxItems
    state = [item, ...state].take(_maxItems).toList();
    await _saveToStorage();
  }

  Future<void> removeScan(String id) async {
    state = state.where((item) => item.id != id).toList();
    await _saveToStorage();
  }

  Future<void> clearAll() async {
    state = [];
    await _saveToStorage();
  }
}

final ocrHistoryProvider = StateNotifierProvider<OcrHistoryNotifier, List<OcrHistoryItem>>((ref) {
  return OcrHistoryNotifier();
});
