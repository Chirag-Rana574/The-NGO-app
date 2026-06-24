class LegalNews {
  final String id;
  final String title;
  final String? content;
  final String? source;
  final String? sourceUrl;
  final String category;
  final bool isBreaking;
  final DateTime publishedAt;

  LegalNews({
    required this.id,
    required this.title,
    this.content,
    this.source,
    this.sourceUrl,
    required this.category,
    required this.isBreaking,
    required this.publishedAt,
  });

  factory LegalNews.fromJson(Map<String, dynamic> json) {
    return LegalNews(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String?,
      source: json['source'] as String?,
      sourceUrl: json['source_url'] as String?,
      category: json['category'] as String,
      isBreaking: json['is_breaking'] as bool? ?? false,
      publishedAt: DateTime.parse(json['published_at'] as String),
    );
  }
}
