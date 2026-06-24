import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/legal_update.dart';

final legalUpdatesServiceProvider = Provider<LegalUpdatesService>((ref) {
  return LegalUpdatesService(Supabase.instance.client);
});

class LegalUpdatesService {
  final SupabaseClient _client;

  LegalUpdatesService(this._client);

  Future<List<LegalUpdate>> fetchLegalUpdates({
    int limit = 20,
    String? searchQuery,
    String? category,
  }) async {
    try {
      var query = _client.from('legal_updates').select();

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.ilike('title', '%$searchQuery%');
      }

      if (category != null && category.isNotEmpty) {
        query = query.eq('source', category);
      }

      final response = await query
          .order('published_at', ascending: false)
          .limit(limit);

      return response.map((json) => LegalUpdate.fromJson(json)).toList();
    } catch (e) {
      // Fallback to mock data on error
      return _getFallbackNews();
    }
  }

  Future<List<String>> fetchCategories() async {
    try {
      final response = await _client
          .from('legal_updates')
          .select('source');

      final categories = response
          .map((e) => e['source'] as String? ?? 'General')
          .toSet()
          .toList();
      return categories;
    } catch (e) {
      return ['LiveLaw', 'Bar and Bench', 'SCC Online Blog', 'iPleaders', 'ETLegalWorld'];
    }
  }

  List<LegalUpdate> _getFallbackNews() {
    return [
      LegalUpdate(
        id: '1',
        title: 'Supreme Court to hear Electoral Bonds case review on Feb 10',
        content: null,
        source: 'Legal News India',
        sourceUrl: null,
        category: 'Supreme Court',
        isBreaking: true,
        publishedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      LegalUpdate(
        id: '2',
        title: 'Delhi HC makes e-filing mandatory for all fresh matters from Feb 1, 2025',
        content: null,
        source: 'Bar & Bench',
        sourceUrl: null,
        category: 'Delhi High Court',
        isBreaking: false,
        publishedAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      LegalUpdate(
        id: '3',
        title: 'Ministry issues clarification on BNS Section 111 - Organized Crime provisions',
        content: null,
        source: 'Ministry of Home Affairs',
        sourceUrl: null,
        category: 'New Laws',
        isBreaking: false,
        publishedAt: DateTime.now().subtract(const Duration(hours: 24)),
      ),
    ];
  }
}