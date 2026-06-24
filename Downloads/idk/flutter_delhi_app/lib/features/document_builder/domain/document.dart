import 'package:flutter/foundation.dart';

@immutable
class Document {
  final String id;
  final String title;
  final String description;
  final String category;
  final String? icon;
  final String? templatePdf;
  final Map<String, dynamic> formData;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Document({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.icon,
    this.templatePdf,
    required this.formData,
    this.createdAt,
    this.updatedAt,
  });

  Document copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? icon,
    String? templatePdf,
    Map<String, dynamic>? formData,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Document(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      icon: icon ?? this.icon,
      templatePdf: templatePdf ?? this.templatePdf,
      formData: formData ?? this.formData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'category': category,
        if (icon != null) 'icon': icon,
        if (templatePdf != null) 'template_pdf': templatePdf,
        'form_data': formData,
        if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
        if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      };

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      icon: json['icon'] as String?,
      templatePdf: json['template_pdf'] as String?,
      formData: json['form_data'] as Map<String, dynamic>? ?? {},
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }
}