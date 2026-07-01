import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/cause_list_item.dart';

final causeListsServiceProvider = Provider<CauseListsService>((ref) {
  return CauseListsService(Supabase.instance.client);
});

class CauseListsService {
  final SupabaseClient _client;

  CauseListsService(this._client);

  Future<List<CauseListPayload>> fetchCauseLists({
    String? court,
    String? date,
    String? searchQuery,
  }) async {
    try {
      var query = _client.from('cause_lists').select();

      if (court != null && court.isNotEmpty) {
        query = query.eq('court', court);
      }

      if (date != null && date.isNotEmpty) {
        query = query.eq('date', date);
      }

      // Only fetch cause lists from the last 2 days
      final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2)).toIso8601String().split('T').first;
      query = query.gte('date', twoDaysAgo);

      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final formattedQuery = searchQuery.trim().split(RegExp(r'\s+')).join(' & ');
        query = query.textSearch('fts_vector', formattedQuery);
      }

      final response = await query.order('date', ascending: false);

      return response.map((json) => CauseListPayload.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching cause lists: $e');
      return [];
    }
  }

  Future<List<String>> fetchCourts() async {
    try {
      final response = await _client
          .from('cause_lists')
          .select('court')
          .order('court');

      final courts = response
          .map((e) => e['court'] as String)
          .toSet()
          .toList();
      return courts;
    } catch (e) {
      debugPrint('Error fetching courts: $e');
      return [];
    }
  }
}