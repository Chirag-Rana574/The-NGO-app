import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    final prefs = await SharedPreferences.getInstance();
    final key = 'document_form_${state.formId}';
    await prefs.setString(key, state.fieldValues.toString());
  }

  Future<void> loadFromPrefs(String formId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'document_form_$formId';
    final saved = prefs.getString(key);
    if (saved != null) {
      // Simple parsing - in production use proper JSON serialization
      final map = <String, String>{};
      // Parse saved string to map (simplified)
      state = DocumentFormData(formId: formId, fieldValues: map);
    }
  }

  Future<void> _clearPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith('document_form_')) {
        await prefs.remove(key);
      }
    }
  }
}

// Provider for document form state
final documentFormProvider = StateNotifierProvider<DocumentFormNotifier, DocumentFormData>((ref) {
  return DocumentFormNotifier();
});

// Provider for loading saved document data
final savedDocumentDataProvider = FutureProvider.family<DocumentFormData?, String>((ref, formId) async {
  final prefs = await SharedPreferences.getInstance();
  final key = 'document_form_$formId';
  final saved = prefs.getString(key);
  if (saved != null) {
    // Return parsed data
    return DocumentFormData(formId: formId, fieldValues: {});
  }
  return null;
});