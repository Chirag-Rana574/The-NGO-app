import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/legal_news.dart';

final legalNewsProvider = FutureProvider.family<List<LegalNews>, int>((ref, limit) async {
  try {
    final response = await Supabase.instance.client
        .from('legal_updates')
        .select()
        .order('published_at', ascending: false)
        .limit(limit);
    if (response.isNotEmpty) {
      return response.map((json) {
        final src = json['source'] as String? ?? 'General';
        return LegalNews(
          id: (json['id'] ?? '').toString(),
          title: json['title'] as String? ?? 'N/A',
          content: json['summary'] as String?,
          source: src,
          sourceUrl: json['url'] as String?,
          category: src,
          isBreaking: json['is_breaking'] as bool? ?? false,
          publishedAt: DateTime.parse(json['published_at'] as String? ?? DateTime.now().toIso8601String()),
        );
      }).toList();
    }
  } catch (e) {
    debugPrint('Error fetching legal updates for news provider: $e');
  }
  return [];
});

final legalNewsByCategoryProvider = FutureProvider.family<List<LegalNews>, String>((ref, category) async {
  try {
    final response = await Supabase.instance.client
        .from('legal_updates')
        .select()
        .eq('source', category)
        .order('published_at', ascending: false);
    if (response.isNotEmpty) {
      return response.map((json) {
        final src = json['source'] as String? ?? 'General';
        return LegalNews(
          id: (json['id'] ?? '').toString(),
          title: json['title'] as String? ?? 'N/A',
          content: json['summary'] as String?,
          source: src,
          sourceUrl: json['url'] as String?,
          category: src,
          isBreaking: json['is_breaking'] as bool? ?? false,
          publishedAt: DateTime.parse(json['published_at'] as String? ?? DateTime.now().toIso8601String()),
        );
      }).toList();
    }
  } catch (e) {
    debugPrint('Error fetching news by category: $e');
  }
  return [];
});
