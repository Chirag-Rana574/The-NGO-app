import 'package:flutter/foundation.dart';
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
      debugPrint('Error fetching legal updates: $e');
      return [];
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
      debugPrint('Error fetching legal update categories: $e');
      return [];
    }
  }
}