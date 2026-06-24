class BareAct {
  final String id;
  final String name;
  final int year;
  final String category;
  final int sectionsCount;
  final bool isActive;
  final String? fullTextUrl;
  final String? fullText;

  BareAct({
    required this.id,
    required this.name,
    required this.year,
    required this.category,
    required this.sectionsCount,
    required this.isActive,
    this.fullTextUrl,
    this.fullText,
  });

  factory BareAct.fromJson(Map<String, dynamic> json) {
    return BareAct(
      id: json['id'] as String,
      name: json['name'] as String,
      year: json['year'] as int,
      category: json['category'] as String,
      sectionsCount: json['sections_count'] as int,
      isActive: json['is_active'] as bool,
      fullTextUrl: json['full_text_url'] as String?,
      fullText: json['full_text'] as String?,
    );
  }
}
