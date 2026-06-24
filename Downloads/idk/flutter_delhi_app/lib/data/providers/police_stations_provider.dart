import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/police_station.dart';

final policeStationsProvider = FutureProvider<List<PoliceStation>>((ref) async {
  // 1. Try querying Supabase
  try {
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('police_stations')
        .select()
        .order('name');
    if (response.isNotEmpty) {
      return response.asMap().entries.map((entry) {
        return PoliceStation.fromJson(entry.value, entry.key + 1);
      }).toList();
    }
  } catch (e) {
    debugPrint('Failed to load police stations from Supabase: $e');
  }

  // 2. Fallback to local JSON asset
  try {
    final String response = await rootBundle.loadString('assets/data/Delhi_PS_Data.json');
    final List<dynamic> data = json.decode(response);
    
    return data.asMap().entries.map((entry) {
      return PoliceStation.fromJson(entry.value, entry.key + 1);
    }).toList();
  } catch (e) {
    debugPrint('Failed to load police stations fallback: $e');
    return [];
  }
});

final policeStationsByDistrictProvider = FutureProvider.family<List<PoliceStation>, String>((ref, district) async {
  final allStations = await ref.watch(policeStationsProvider.future);
  return allStations.where((s) => s.district == district).toList();
});

final searchPoliceStationsProvider = FutureProvider.family<List<PoliceStation>, String>((ref, query) async {
  if (query.trim().isEmpty) return [];
  final q = query.toLowerCase();
  
  final allStations = await ref.watch(policeStationsProvider.future);
  return allStations.where((s) => 
    s.name.toLowerCase().contains(q) ||
    s.address.toLowerCase().contains(q) ||
    s.district.toLowerCase().contains(q)
  ).toList();
});

final policeDistrictsProvider = FutureProvider<List<String>>((ref) async {
  final allStations = await ref.watch(policeStationsProvider.future);
  final districts = allStations.map((s) => s.district).toSet().toList();
  districts.sort();
  return districts;
});
