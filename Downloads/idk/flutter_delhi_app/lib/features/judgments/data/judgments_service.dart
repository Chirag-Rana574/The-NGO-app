import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/judgment.dart';

final judgmentsServiceProvider = Provider<JudgmentsService>((ref) {
  return JudgmentsService(Supabase.instance.client);
});

class JudgmentsService {
  final SupabaseClient _client;

  JudgmentsService(this._client);

  Future<List<Judgment>> fetchJudgments({
    int limit = 20,
    int offset = 0,
    String? searchQuery,
  }) async {
    try {
      var query = _client.from('landmark_judgements').select();

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or('title.ilike.%$searchQuery%,citation.ilike.%$searchQuery%');
      }

      final response = await query
          .order('judgement_date', ascending: false)
          .range(offset, offset + limit - 1);

      return response.map((json) => Judgment.fromJson(json)).toList();
    } catch (e) {
      return _getFallbackJudgments();
    }
  }

  Future<int> fetchTotalCount({String? searchQuery}) async {
    try {
      var query = _client.from('landmark_judgements').select();

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or('title.ilike.%$searchQuery%,citation.ilike.%$searchQuery%');
      }

      final countResult = await query.count();
      return countResult.count;
    } catch (e) {
      return _getFallbackJudgments().length;
    }
  }

  List<Judgment> _getFallbackJudgments() {
    return [
      Judgment(
        id: '1',
        caseNumber: 'CS(OS) 123/2024',
        court: 'Delhi High Court',
        parties: 'ABC vs XYZ',
        date: DateTime.now().subtract(const Duration(days: 5)),
        summary: 'Judgment on contract dispute',
      ),
      Judgment(
        id: '2',
        caseNumber: 'Writ Petition 456/2024',
        court: 'Supreme Court',
        parties: 'State vs Citizen',
        date: DateTime.now().subtract(const Duration(days: 10)),
        summary: 'Constitutional validity of law',
      ),
    ];
  }
}