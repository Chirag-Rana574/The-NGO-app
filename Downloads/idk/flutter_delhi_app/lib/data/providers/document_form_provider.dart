import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/secure_storage_helper.dart';

// Document form state model
class DocumentFormData {
  final String formId;
  final Map<String, String> fieldValues;

  DocumentFormData({required this.formId, required this.fieldValues});

  DocumentFormData copyWith({String? formId, Map<String, String>? fieldValues}) {
    return DocumentFormData(
      formId: formId ?? this.formId,
      fieldValues: fieldValues ?? this.fieldValues,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'formId': formId,
      'fieldValues': fieldValues,
    };
  }

  factory DocumentFormData.fromJson(Map<String, dynamic> json) {
    return DocumentFormData(
      formId: json['formId'] as String? ?? '',
      fieldValues: Map<String, String>.from(json['fieldValues'] as Map? ?? {}),
    );
  }
}

// StateNotifier for document form state
class DocumentFormNotifier extends StateNotifier<DocumentFormData> {
  DocumentFormNotifier() : super(DocumentFormData(formId: '', fieldValues: {}));

  void setFieldValue(String key, String value) {
    final newValues = Map<String, String>.from(state.fieldValues)..[key] = value;
    state = state.copyWith(fieldValues: newValues);
    _saveToPrefs();
  }

  void setFormId(String formId) {
    state = state.copyWith(formId: formId);
    _saveToPrefs();
  }

  void reset() {
    state = DocumentFormData(formId: '', fieldValues: {});
    _clearPrefs();
  }

  Future<void> _saveToPrefs() async {
    final key = 'document_form_${state.formId}';
    await SecureStorageHelper.instance.write(key, jsonEncode(state.toJson()));
  }

  Future<void> loadFromPrefs(String formId) async {
    final key = 'document_form_$formId';
    final saved = await SecureStorageHelper.instance.read(key);
    if (saved != null) {
      try {
        final decoded = jsonDecode(saved) as Map<String, dynamic>;
        state = DocumentFormData.fromJson(decoded);
      } catch (_) {
        // If the saved string isn't valid JSON (legacy format), discard it
        state = DocumentFormData(formId: formId, fieldValues: {});
      }
    } else {
      state = DocumentFormData(formId: formId, fieldValues: {});
    }
  }

  Future<void> _clearPrefs() async {
    await SecureStorageHelper.instance.deleteWithPrefix('document_form_');
  }
}

// Provider for document form state
final documentFormProvider = StateNotifierProvider<DocumentFormNotifier, DocumentFormData>((ref) {
  return DocumentFormNotifier();
});

// Provider for loading saved document data
final savedDocumentDataProvider = FutureProvider.family<DocumentFormData?, String>((ref, formId) async {
  final key = 'document_form_$formId';
  final saved = await SecureStorageHelper.instance.read(key);
  if (saved != null) {
    try {
      final decoded = jsonDecode(saved) as Map<String, dynamic>;
      return DocumentFormData.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }
  return null;
});