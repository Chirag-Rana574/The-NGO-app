import 'package:flutter/foundation.dart';

@immutable
class CauseListEntry {
  final String caseNo;
  final String parties;
  final String listedOn;
  final String courtRoom;
  final String judge;
  final String rawLine;

  const CauseListEntry({
    required this.caseNo,
    required this.parties,
    required this.listedOn,
    required this.courtRoom,
    required this.judge,
    this.rawLine = '',
  });

  factory CauseListEntry.fromJson(Map<String, dynamic> json) {
    return CauseListEntry(
      caseNo: json['case_no'] as String? ?? 'N/A',
      parties: json['parties'] as String? ?? 'N/A',
      listedOn: json['listed_on'] as String? ?? 'TBA',
      courtRoom: json['court_room'] as String? ?? 'TBA',
      judge: json['judge'] as String? ?? 'N/A',
      rawLine: json['raw_line'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'case_no': caseNo,
    'parties': parties,
    'listed_on': listedOn,
    'court_room': courtRoom,
    'judge': judge,
    'raw_line': rawLine,
  };
}

@immutable
class CauseListPayload {
  final String court;
  final String date;
  final int totalCases;
  final String sourceUrl;
  final String scrapedAt;
  final List<CauseListEntry> cases;
  final String? error;

  const CauseListPayload({
    required this.court,
    required this.date,
    required this.totalCases,
    required this.sourceUrl,
    required this.scrapedAt,
    required this.cases,
    this.error,
  });

  factory CauseListPayload.fromJson(Map<String, dynamic> json) {
    final casesJson = json['cases'] as List<dynamic>? ?? [];
    return CauseListPayload(
      court: json['court'] as String? ?? 'Unknown',
      date: json['date'] as String? ?? 'N/A',
      totalCases: (json['total_cases'] as int?) ?? casesJson.length,
      sourceUrl: json['source_url'] as String? ?? '',
      scrapedAt: json['scraped_at'] as String? ?? '',
      cases: casesJson.map((e) => CauseListEntry.fromJson(e as Map<String, dynamic>)).toList(),
      error: json['error'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'court': court,
    'date': date,
    'total_cases': totalCases,
    'source_url': sourceUrl,
    'scraped_at': scrapedAt,
    'cases': cases.map((e) => e.toJson()).toList(),
    if (error != null) 'error': error,
  };
}
