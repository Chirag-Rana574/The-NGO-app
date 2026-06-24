class CaseItem {
  final String id;
  final String title;
  final String caseNumber;
  final String court;
  final String nextHearingDate;
  final String status;
  final String notes;

  CaseItem({
    required this.id,
    required this.title,
    required this.caseNumber,
    required this.court,
    required this.nextHearingDate,
    required this.status,
    required this.notes,
  });

  CaseItem copyWith({
    String? id,
    String? title,
    String? caseNumber,
    String? court,
    String? nextHearingDate,
    String? status,
    String? notes,
  }) {
    return CaseItem(
      id: id ?? this.id,
      title: title ?? this.title,
      caseNumber: caseNumber ?? this.caseNumber,
      court: court ?? this.court,
      nextHearingDate: nextHearingDate ?? this.nextHearingDate,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }
}
