import 'package:flutter/foundation.dart';

@immutable
class LegalUpdate {
  final String id;
  final String title;
  final String? content;
  final String? source;
  final String? sourceUrl;
  final String category;
  final bool isBreaking;
  final DateTime publishedAt;

  const LegalUpdate({
    required this.id,
    required this.title,
    this.content,
    this.source,
    this.sourceUrl,
    required this.category,
    required this.isBreaking,
    required this.publishedAt,
  });

  factory LegalUpdate.fromJson(Map<String, dynamic> json) {
    final src = json['source'] as String? ?? 'General';
    return LegalUpdate(
      id: (json['id'] ?? '').toString(),
      title: json['title'] as String? ?? 'N/A',
      content: json['summary'] as String?,
      source: src,
      sourceUrl: json['url'] as String?,
      category: src,
      isBreaking: json['is_breaking'] as bool? ?? false,
      publishedAt: DateTime.parse(json['published_at'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        if (content != null) 'summary': content,
        if (source != null) 'source': source,
        if (sourceUrl != null) 'url': sourceUrl,
        'category': category,
        'is_breaking': isBreaking,
        'published_at': publishedAt.toIso8601String(),
      };
}