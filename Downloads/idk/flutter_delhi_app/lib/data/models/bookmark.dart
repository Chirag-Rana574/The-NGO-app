class Bookmark {
  final String id;
  final int pageNumber;
  final String note;
  final String createdAt;
  final String? color; // Optional color coding

  Bookmark({
    required this.id,
    required this.pageNumber,
    required this.note,
    required this.createdAt,
    this.color,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'pageNumber': pageNumber,
    'note': note,
    'createdAt': createdAt,
    'color': color,
  };

  factory Bookmark.fromJson(Map<String, dynamic> json) => Bookmark(
    id: json['id'] ?? '',
    pageNumber: json['pageNumber'] ?? 1,
    note: json['note'] ?? '',
    createdAt: json['createdAt'] ?? '',
    color: json['color'],
  );

  Bookmark copyWith({
    String? id,
    int? pageNumber,
    String? note,
    String? createdAt,
    String? color,
  }) {
    return Bookmark(
      id: id ?? this.id,
      pageNumber: pageNumber ?? this.pageNumber,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      color: color ?? this.color,
    );
  }
}
