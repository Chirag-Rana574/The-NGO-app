import 'package:flutter/foundation.dart';

enum FieldType { text, textarea, select, date, number }

@immutable
class DocumentField {
  final String key;
  final String label;
  final FieldType type;
  final String? placeholder;
  final bool? required;
  final List<String>? options;

  const DocumentField({
    required this.key,
    required this.label,
    required this.type,
    this.placeholder,
    this.required,
    this.options,
  });

  factory DocumentField.fromJson(Map<String, dynamic> json) {
    return DocumentField(
      key: json['key'] as String,
      label: json['label'] as String,
      type: FieldType.values.firstWhere(
        (e) => e.name == (json['type'] as String? ?? 'text'),
        orElse: () => FieldType.text,
      ),
      placeholder: json['placeholder'] as String?,
      required: json['required'] as bool?,
      options: (json['options'] as List<dynamic>?)?.cast<String>(),
    );
  }

  Map<String, dynamic> toJson() => {
        'key': key,
        'label': label,
        'type': type.name,
        if (placeholder != null) 'placeholder': placeholder,
        if (required != null) 'required': required,
        if (options != null) 'options': options,
      };
}