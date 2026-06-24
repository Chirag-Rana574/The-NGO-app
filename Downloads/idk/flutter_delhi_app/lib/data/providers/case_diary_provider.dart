import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/case_diary_model.dart';

class CaseDiaryNotifier extends StateNotifier<List<CaseItem>> {
  CaseDiaryNotifier() : super([
    CaseItem(
      id: '1',
      title: 'Sharma vs. Singh Property Dispute',
      caseNumber: 'CS 1024/2023',
      court: 'Delhi High Court',
      nextHearingDate: DateTime.now().add(const Duration(days: 5)).toIso8601String(),
      status: 'active',
      notes: 'Need to prepare cross-examination questions for Mr. Singh.',
    ),
    CaseItem(
      id: '2',
      title: 'TechCorp Breach of Contract',
      caseNumber: 'ARB 45/2024',
      court: 'Arbitration Tribunal, Delhi',
      nextHearingDate: DateTime.now().add(const Duration(days: 12)).toIso8601String(),
      status: 'active',
      notes: 'Pending final arguments.',
    ),
  ]);

  void addCase(CaseItem item) {
    state = [...state, item];
  }

  void updateCase(CaseItem item) {
    state = [
      for (final c in state)
        if (c.id == item.id) item else c
    ];
  }

  void deleteCase(String id) {
    state = state.where((c) => c.id != id).toList();
  }
}

final caseDiaryProvider = StateNotifierProvider<CaseDiaryNotifier, List<CaseItem>>((ref) {
  return CaseDiaryNotifier();
});
