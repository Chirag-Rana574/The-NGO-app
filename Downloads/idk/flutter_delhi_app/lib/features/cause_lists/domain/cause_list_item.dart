import 'package:flutter/foundation.dart';

@immutable
class CauseListItem {
  final String caseNo;
  final String parties;
  final String listedOn;
  final String courtRoom;
  final String judge;
  final String rawLine;

  const CauseListItem({
    required this.caseNo,
    required this.parties,
    required this.listedOn,
    required this.courtRoom,
    required this.judge,
    this.rawLine = '',
  });

  factory CauseListItem.fromJson(Map<String, dynamic> json) {
    return CauseListItem(
      caseNo: (json['item_no'] ?? '').toString(),
      parties: (json['raw_text'] ?? json['case_details'] ?? 'N/A') as String,
      listedOn: json['page'] != null ? 'Page ${json['page']}' : 'TBA',
      courtRoom: json['courtroom'] as String? ?? 'TBA',
      judge: json['judge'] as String? ?? 'N/A',
      rawLine: json['raw_text'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'item_no': caseNo,
        'raw_text': parties,
        'page': listedOn,
        'courtroom': courtRoom,
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
  final List<CauseListItem> cases;
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
    final structData = json['structured_data'] as Map<String, dynamic>? ?? {};
    final casesJson = structData['cases'] as List<dynamic>? ?? [];
    return CauseListPayload(
      court: json['court'] as String? ?? 'Unknown',
      date: json['date'] as String? ?? 'N/A',
      totalCases: (json['total_cases'] as int?) ?? casesJson.length,
      sourceUrl: json['url'] as String? ?? '',
      scrapedAt: json['created_at'] as String? ?? '',
      cases: casesJson.map((e) => CauseListItem.fromJson(e as Map<String, dynamic>)).toList(),
      error: json['error'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'court': court,
        'date': date,
        'total_cases': totalCases,
        'url': sourceUrl,
        'created_at': scrapedAt,
        'structured_data': {
          'cases': cases.map((e) => e.toJson()).toList(),
        },
        if (error != null) 'error': error,
      };
}