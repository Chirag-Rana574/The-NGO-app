import 'package:flutter/foundation.dart';

@immutable
class Judgment {
  final String id;
  final String caseNumber;
  final String court;
  final String parties;
  final DateTime date;
  final String? pdfUrl;
  final String? summary;

  const Judgment({
    required this.id,
    required this.caseNumber,
    required this.court,
    required this.parties,
    required this.date,
    this.pdfUrl,
    this.summary,
  });

  factory Judgment.fromJson(Map<String, dynamic> json) {
    return Judgment(
      id: (json['id'] ?? '').toString(),
      caseNumber: (json['citation'] ?? json['case_number']) as String? ?? 'N/A',
      court: json['court'] as String? ?? 'Unknown',
      parties: (json['title'] ?? json['parties']) as String? ?? 'N/A',
      date: DateTime.parse((json['judgement_date'] ?? json['date'] ?? DateTime.now().toIso8601String()) as String),
      pdfUrl: (json['url'] ?? json['pdf_url']) as String?,
      summary: json['summary'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'citation': caseNumber,
        'court': court,
        'title': parties,
        'judgement_date': date.toIso8601String(),
        if (pdfUrl != null) 'url': pdfUrl,
        if (summary != null) 'summary': summary,
      };
}