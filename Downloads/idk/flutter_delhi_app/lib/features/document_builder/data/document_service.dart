import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/document.dart';

final documentServiceProvider = Provider<DocumentService>((ref) {
  return DocumentService(Supabase.instance.client);
});

class DocumentService {
  final SupabaseClient _client;

  DocumentService(this._client);

  Future<List<Document>> fetchDocuments({String? category}) async {
    try {
      var query = _client.from('documents').select();

      if (category != null && category.isNotEmpty) {
        query = query.eq('category', category);
      }

      final response = await query.order('created_at', ascending: false);

      return response.map((json) => Document.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<Document?> fetchDocumentById(String id) async {
    try {
      final response = await _client
          .from('documents')
          .select()
          .eq('id', id)
          .limit(1);

      if (response.isEmpty) return null;
      return Document.fromJson(response.first);
    } catch (e) {
      return null;
    }
  }

  Future<Document> saveDocument(Document document) async {
    try {
      final response = await _client
          .from('documents')
          .upsert(document.toJson())
          .select();

      return Document.fromJson(response.first);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteDocument(String id) async {
    try {
      await _client.from('documents').delete().eq('id', id);
    } catch (e) {
      rethrow;
    }
  }

  Future<String> uploadPdf(String path, List<int> bytes) async {
    try {
      await _client.storage
          .from('documents')
          .uploadBinary(path, Uint8List.fromList(bytes));

      return _client.storage.from('documents').getPublicUrl(path);
    } catch (e) {
      rethrow;
    }
  }
}