import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/document.dart';
import 'document_service.dart';

final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  final service = ref.watch(documentServiceProvider);
  return DocumentRepository(service);
});

class DocumentRepository {
  final DocumentService _service;

  DocumentRepository(this._service);

  Future<List<Document>> getDocuments({String? category}) {
    return _service.fetchDocuments(category: category);
  }

  Future<Document?> getDocumentById(String id) {
    return _service.fetchDocumentById(id);
  }

  Future<Document> saveDocument(Document document) {
    return _service.saveDocument(document);
  }

  Future<void> deleteDocument(String id) {
    return _service.deleteDocument(id);
  }

  Future<String> uploadPdf(String path, List<int> bytes) {
    return _service.uploadPdf(path, bytes);
  }
}