import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/secure_storage_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../models/case_diary_model.dart';

class CaseDiaryNotifier extends StateNotifier<List<CaseItem>> {
  CaseDiaryNotifier() : super([]) {
    _initSync();
  }

  static const String _storageKey = 'case_diary_items_v1';
  final SupabaseClient _client = Supabase.instance.client;

  Future<void> _initSync() async {
    await _loadFromStorage();
    await syncWithSupabase();
  }

  Future<void> _loadFromStorage() async {
    try {
      final String? jsonStr = await SecureStorageHelper.instance.read(_storageKey);
      if (jsonStr != null) {
        final List<dynamic> decoded = jsonDecode(jsonStr);
        state = decoded.map((item) => CaseItem.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      debugPrint('Error loading case diary: $e');
      state = [];
    }
  }

  Future<void> _saveToStorage() async {
    try {
      final String encoded = jsonEncode(state.map((c) => c.toJson()).toList());
      await SecureStorageHelper.instance.write(_storageKey, encoded);
    } catch (e) {
      debugPrint('Error saving case diary: $e');
    }
  }

  Future<void> syncWithSupabase() async {
    final user = fb.FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final response = await _client
          .from('cases')
          .select()
          .eq('user_id', user.uid);

      if (response.isNotEmpty) {
        final List<CaseItem> remoteCases = response.map((rc) {
          return CaseItem(
            id: rc['id'] as String? ?? '',
            title: rc['title'] as String? ?? '',
            caseNumber: rc['cnr_number'] as String? ?? '',
            court: rc['court_name'] as String? ?? '',
            nextHearingDate: rc['next_date_of_hearing'] as String? ?? '',
            status: rc['status'] as String? ?? 'active',
            notes: rc['notes'] as String? ?? '',
          );
        }).toList();

        // Merge remote cases with local cases (remote wins on conflict)
        final mergedMap = <String, CaseItem>{};
        for (final c in state) {
          mergedMap[c.id] = c;
        }
        for (final c in remoteCases) {
          mergedMap[c.id] = c;
        }

        state = mergedMap.values.toList();
        await _saveToStorage();
      }
    } catch (e) {
      debugPrint('Supabase case sync failed: $e');
    }
  }

  Future<void> addCase(CaseItem item) async {
    state = [...state, item];
    await _saveToStorage();

    final user = fb.FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final uuidRegex = RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$', caseSensitive: false);
        final String? dbId = uuidRegex.hasMatch(item.id) ? item.id : null;

        await _client.from('cases').insert({
          if (dbId != null) 'id': dbId,
          'user_id': user.uid,
          'title': item.title,
          'cnr_number': item.caseNumber,
          'court_name': item.court,
          'next_date_of_hearing': item.nextHearingDate.isNotEmpty ? item.nextHearingDate : null,
          'status': item.status,
          'notes': item.notes,
        });
      } catch (e) {
        debugPrint('Failed to sync new case to Supabase: $e');
      }
    }
  }

  Future<void> updateCase(CaseItem item) async {
    state = [
      for (final c in state)
        if (c.id == item.id) item else c
    ];
    await _saveToStorage();

    final user = fb.FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final uuidRegex = RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$', caseSensitive: false);
        if (uuidRegex.hasMatch(item.id)) {
          await _client.from('cases').update({
            'title': item.title,
            'cnr_number': item.caseNumber,
            'court_name': item.court,
            'next_date_of_hearing': item.nextHearingDate.isNotEmpty ? item.nextHearingDate : null,
            'status': item.status,
            'notes': item.notes,
            'updated_at': DateTime.now().toIso8601String(),
          }).eq('id', item.id);
        }
      } catch (e) {
        debugPrint('Failed to sync updated case to Supabase: $e');
      }
    }
  }

  Future<void> deleteCase(String id) async {
    state = state.where((c) => c.id != id).toList();
    await _saveToStorage();

    final user = fb.FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final uuidRegex = RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$', caseSensitive: false);
        if (uuidRegex.hasMatch(id)) {
          await _client.from('cases').delete().eq('id', id);
        }
      } catch (e) {
        debugPrint('Failed to sync deleted case to Supabase: $e');
      }
    }
  }
}

final caseDiaryProvider = StateNotifierProvider<CaseDiaryNotifier, List<CaseItem>>((ref) {
  return CaseDiaryNotifier();
});
