import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bookmark.dart';

class CaseDocument {
  final String id;
  final String fileName;
  final String fileSize;
  final String date;
  final String ocrStatus; // pending, processing, completed, failed
  final String ocrText;
  final List<Bookmark> bookmarks;

  CaseDocument({
    required this.id,
    required this.fileName,
    required this.fileSize,
    required this.date,
    required this.ocrStatus,
    this.ocrText = '',
    this.bookmarks = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'fileName': fileName,
    'fileSize': fileSize,
    'date': date,
    'ocrStatus': ocrStatus,
    'ocrText': ocrText,
    'bookmarks': bookmarks.map((b) => b.toJson()).toList(),
  };

  factory CaseDocument.fromJson(Map<String, dynamic> json) => CaseDocument(
    id: json['id'],
    fileName: json['fileName'] ?? '',
    fileSize: json['fileSize'] ?? '0 KB',
    date: json['date'] ?? '',
    ocrStatus: json['ocrStatus'] ?? 'pending',
    ocrText: json['ocrText'] ?? '',
    bookmarks: (json['bookmarks'] as List? ?? []).map((b) => Bookmark.fromJson(b)).toList(),
  );

  CaseDocument copyWith({
    String? ocrStatus,
    String? ocrText,
    List<Bookmark>? bookmarks,
  }) => CaseDocument(
    id: id,
    fileName: fileName,
    fileSize: fileSize,
    date: date,
    ocrStatus: ocrStatus ?? this.ocrStatus,
    ocrText: ocrText ?? this.ocrText,
    bookmarks: bookmarks ?? this.bookmarks,
  );
}

class CaseDocumentNotifier extends StateNotifier<List<CaseDocument>> {
  CaseDocumentNotifier() : super([]) {
    _loadFromStorage();
  }

  static const String _storageKey = 'case_documents_list_v2';

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString(_storageKey);
      if (jsonStr != null) {
        final List<dynamic> decoded = jsonDecode(jsonStr);
        state = decoded.map((item) => CaseDocument.fromJson(item)).toList();
      } else {
        // Seeding initial documents if empty
        state = [
          CaseDocument(
            id: '1',
            fileName: 'FIR_Copy_Section_420.pdf',
            fileSize: '2.4 MB',
            date: 'Oct 12, 2024',
            ocrStatus: 'completed',
            ocrText: 'This is the FIR report under Section 420 for cheating. Accused represented by counsel. Complaint filed by complainant on October 10th.',
            bookmarks: [
              Bookmark(id: 'b1', pageNumber: 1, note: 'FIR Details & Section 420 invocation', createdAt: DateTime.now().toIso8601String())
            ],
          ),
          CaseDocument(
            id: '2',
            fileName: 'Bail_Application_Draft_v2.pdf',
            fileSize: '840 KB',
            date: 'Oct 15, 2024',
            ocrStatus: 'pending',
          ),
        ];
        _saveToStorage();
      }
    } catch (e) {
      // Handle storage load failure gracefully
      state = [];
    }
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = jsonEncode(state.map((d) => d.toJson()).toList());
      await prefs.setString(_storageKey, encoded);
    } catch (_) {}
  }

  Future<void> addDocument(CaseDocument doc) async {
    state = [...state, doc];
    await _saveToStorage();
  }

  Future<void> removeDocument(String id) async {
    state = state.where((doc) => doc.id != id).toList();
    await _saveToStorage();
  }

  Future<void> clearAll() async {
    state = [];
    await _saveToStorage();
  }

  Future<void> updateOcrResult(String id, String status, String text) async {
    state = state.map((doc) {
      if (doc.id == id) {
        return doc.copyWith(ocrStatus: status, ocrText: text);
      }
      return doc;
    }).toList();
    await _saveToStorage();
  }

  Future<void> addBookmark(String docId, Bookmark bookmark) async {
    state = state.map((doc) {
      if (doc.id == docId) {
        return doc.copyWith(bookmarks: [...doc.bookmarks, bookmark]);
      }
      return doc;
    }).toList();
    await _saveToStorage();
  }

  Future<void> removeBookmark(String docId, String bookmarkId) async {
    state = state.map((doc) {
      if (doc.id == docId) {
        return doc.copyWith(bookmarks: doc.bookmarks.where((b) => b.id != bookmarkId).toList());
      }
      return doc;
    }).toList();
    await _saveToStorage();
  }

  Future<void> updateBookmarkNote(String docId, String bookmarkId, String note) async {
    state = state.map((doc) {
      if (doc.id == docId) {
        return doc.copyWith(
          bookmarks: doc.bookmarks.map((b) {
            if (b.id == bookmarkId) {
              return Bookmark(id: b.id, pageNumber: b.pageNumber, note: note, createdAt: b.createdAt);
            }
            return b;
          }).toList()
        );
      }
      return doc;
    }).toList();
    await _saveToStorage();
  }
}

final caseDocumentProvider = StateNotifierProvider<CaseDocumentNotifier, List<CaseDocument>>((ref) {
  return CaseDocumentNotifier();
});
