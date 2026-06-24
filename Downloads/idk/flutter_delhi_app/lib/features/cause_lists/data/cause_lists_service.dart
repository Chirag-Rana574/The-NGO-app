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

      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final formattedQuery = searchQuery.trim().split(RegExp(r'\s+')).join(' & ');
        query = query.textSearch('fts_vector', formattedQuery);
      }

      final response = await query.order('date', ascending: false);

      return response.map((json) => CauseListPayload.fromJson(json)).toList();
    } catch (e) {
      return _getFallbackCauseLists();
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
      return ['Delhi High Court', 'Supreme Court', 'District Court'];
    }
  }

  List<CauseListPayload> _getFallbackCauseLists() {
    return [
      CauseListPayload(
        court: 'Delhi High Court',
        date: '2025-01-15',
        totalCases: 15,
        sourceUrl: '',
        scrapedAt: DateTime.now().toIso8601String(),
        cases: [
          CauseListItem(
            caseNo: 'CS(OS) 123/2024',
            parties: 'ABC vs XYZ',
            listedOn: '10:30 AM',
            courtRoom: 'Court No. 12',
            judge: 'Hon. Judge A',
          ),
        ],
      ),
    ];
  }
}