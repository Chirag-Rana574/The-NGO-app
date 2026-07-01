import 'package:flutter/foundation.dart';
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
      debugPrint('Error fetching judgments: $e');
      return [];
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
      debugPrint('Error fetching judgment count: $e');
      return 0;
    }
  }
}