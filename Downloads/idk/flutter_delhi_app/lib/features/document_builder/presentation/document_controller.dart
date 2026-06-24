import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/document.dart';
import '../data/document_repository.dart';
import '../../../data/document_registry.dart';

// Document form data provider
final documentFormDataProvider = StateProvider<Map<String, dynamic>>((ref) => {});

// Selected document config provider
final selectedDocumentConfigProvider = StateProvider<DocumentConfig?>((ref) => null);

// Document list provider
final documentListProvider = FutureProvider.autoDispose<List<Document>>((ref) async {
  final repository = ref.watch(documentRepositoryProvider);
  return repository.getDocuments();
});

// Controller
class DocumentController extends AutoDisposeNotifier<DocumentState> {
  @override
  DocumentState build() {
    return const DocumentState();
  }

  void updateField(String key, dynamic value) {
    final newFormData = Map<String, dynamic>.from(state.formData);
    newFormData[key] = value;
    state = state.copyWith(formData: newFormData);
  }

  void setDocumentConfig(DocumentConfig config) {
    ref.read(selectedDocumentConfigProvider.notifier).state = config;
    state = state.copyWith(
      formData: {},
      isEditing: false,
    );
  }

  void setEditing(bool editing) {
    state = state.copyWith(isEditing: editing);
  }

  Future<void> saveDocument() async {
    final config = ref.read(selectedDocumentConfigProvider);
    if (config == null) return;

    final document = Document(
      id: state.isEditing ? state.documentId ?? '' : DateTime.now().millisecondsSinceEpoch.toString(),
      title: config.title,
      description: config.description,
      category: config.category,
      icon: config.icon,
      templatePdf: config.templatePdf,
      formData: state.formData,
      createdAt: state.isEditing ? state.createdAt : DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final repository = ref.read(documentRepositoryProvider);
    await repository.saveDocument(document);
  }
}

class DocumentState {
  final Map<String, dynamic> formData;
  final bool isEditing;
  final String? documentId;
  final DateTime? createdAt;

  const DocumentState({
    this.formData = const {},
    this.isEditing = false,
    this.documentId,
    this.createdAt,
  });

  DocumentState copyWith({
    Map<String, dynamic>? formData,
    bool? isEditing,
    String? documentId,
    DateTime? createdAt,
  }) {
    return DocumentState(
      formData: formData ?? this.formData,
      isEditing: isEditing ?? this.isEditing,
      documentId: documentId ?? this.documentId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

final documentControllerProvider = AutoDisposeNotifierProvider<DocumentController, DocumentState>(() {
  return DocumentController();
});