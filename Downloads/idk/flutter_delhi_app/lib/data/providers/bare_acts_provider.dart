import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/bare_act.dart';
export '../models/bare_act.dart';

class BareActsState {
  final AsyncValue<List<BareAct>> acts;
  const BareActsState({this.acts = const AsyncValue.loading()});

  BareActsState copyWith({AsyncValue<List<BareAct>>? acts}) =>
      BareActsState(acts: acts ?? this.acts);

  factory BareActsState.initial() => const BareActsState();
}

class BareActsNotifier extends StateNotifier<BareActsState> {
  BareActsNotifier() : super(BareActsState.initial()) {
    _init();
  }

  Future<void> _init() async {
    try {
      List<BareAct> items = [];

      // 1. Try querying Supabase
      try {
        if (kDebugMode) debugPrint('BareActsNotifier: loading from Supabase');
        final response = await Supabase.instance.client
            .from('bare_acts')
            .select('id, name, year, category, sections_count, is_active, full_text_url');
        
        if (response.isNotEmpty) {
          items = response.map((json) => BareAct.fromJson(json)).toList();
          if (kDebugMode) debugPrint('BareActsNotifier: successfully loaded ${items.length} acts from Supabase');
        }
      } catch (e) {
        if (kDebugMode) debugPrint('BareActsNotifier: Supabase load failed: $e');
      }

      // 2. Try loading local catalog fallback if Supabase is empty/failed
      if (items.isEmpty) {
        if (kDebugMode) debugPrint('BareActsNotifier: loading local fallback catalog');
        final raw = await rootBundle.loadString('assets/data/bare_acts_catalog.json');
        final decoded = json.decode(raw) as Map<String, dynamic>;
        final list = (decoded['acts'] as List?) ?? const [];
        items = list.asMap().entries.map((entry) {
          final index = entry.key;
          final act = entry.value as Map<String, dynamic>;
          final title = act['title'] as String? ?? 'N/A';
          final yearMatch = RegExp(r'\d{4}').firstMatch(title);
          final year = yearMatch != null ? int.parse(yearMatch.group(0)!) : 2024;
          final isCriminal = title.toLowerCase().contains('penal') || title.toLowerCase().contains('criminal') || title.toLowerCase().contains('bns');
          return BareAct(
            id: 'scraper-$index',
            name: title,
            year: year,
            category: isCriminal ? 'criminal' : 'civil',
            sectionsCount: 0,
            isActive: true,
            fullTextUrl: act['url'] as String?,
          );
        }).toList();
      }

      state = state.copyWith(acts: AsyncValue.data(items));
    } catch (e, st) {
      state = state.copyWith(acts: AsyncValue.error(e, st));
      if (kDebugMode) debugPrint('BareActsNotifier Error: $e');
    }
  }
}

final bareActsProvider =
    StateNotifierProvider<BareActsNotifier, BareActsState>((_) => BareActsNotifier());

final bareActsListingProvider = Provider<List<BareAct>>((ref) {
  final actState = ref.watch(bareActsProvider);
  return switch (actState.acts) {
    AsyncData(:final value) => value,
    AsyncError(:final error) => <BareAct>[
        BareAct(
          id: 'error',
          name: 'Error: $error',
          year: 0,
          category: 'error',
          sectionsCount: 0,
          isActive: true,
        ),
      ],
    _ => const <BareAct>[],
  };
});

final searchBareActsProvider = Provider.family<List<BareAct>, String>((ref, query) {
  final acts = ref.watch(bareActsListingProvider);
  if (query.isEmpty) return acts;
  final q = query.toLowerCase();
  return acts.where((a) => a.name.toLowerCase().contains(q) || a.category.toLowerCase().contains(q)).toList();
});
