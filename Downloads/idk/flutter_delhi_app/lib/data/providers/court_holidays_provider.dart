import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final courtHolidaysProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  try {
    final response = await Supabase.instance.client
        .from('court_holidays')
        .select()
        .order('date');
    if (response.isNotEmpty) {
      return List<Map<String, dynamic>>.from(response);
    }
  } catch (e) {
    debugPrint('Failed to load court holidays from Supabase: $e');
  }

  // Fallback to static holiday entries
  return [
    {'date': '2025-01-01', 'name': "New Year's Day", 'court_type': 'all', 'is_gazetted': true},
    {'date': '2025-01-26', 'name': 'Republic Day', 'court_type': 'all', 'is_gazetted': true},
    {'date': '2025-02-26', 'name': 'Maha Shivaratri', 'court_type': 'all', 'is_gazetted': true},
    {'date': '2025-03-14', 'name': 'Holi', 'court_type': 'all', 'is_gazetted': true},
    {'date': '2025-03-31', 'name': 'Id-ul-Fitr', 'court_type': 'all', 'is_gazetted': true},
    {'date': '2025-04-06', 'name': 'Ram Navami', 'court_type': 'all', 'is_gazetted': true},
    {'date': '2025-04-10', 'name': 'Mahavir Jayanti', 'court_type': 'all', 'is_gazetted': true},
    {'date': '2025-04-14', 'name': 'Dr. Ambedkar Jayanti', 'court_type': 'all', 'is_gazetted': true},
    {'date': '2025-04-18', 'name': 'Good Friday', 'court_type': 'all', 'is_gazetted': true},
    {'date': '2025-05-01', 'name': 'May Day', 'court_type': 'all', 'is_gazetted': true},
    {'date': '2025-05-12', 'name': 'Buddha Purnima', 'court_type': 'all', 'is_gazetted': true},
    {'date': '2025-07-17', 'name': 'Muharram', 'court_type': 'all', 'is_gazetted': true},
    {'date': '2025-08-15', 'name': 'Independence Day', 'court_type': 'all', 'is_gazetted': true},
    {'date': '2025-08-16', 'name': 'Janmashtami', 'court_type': 'all', 'is_gazetted': true},
    {'date': '2025-08-27', 'name': 'Milad-un-Nabi', 'court_type': 'all', 'is_gazetted': true},
    {'date': '2025-10-02', 'name': 'Gandhi Jayanti', 'court_type': 'all', 'is_gazetted': true},
    {'date': '2025-10-20', 'name': 'Diwali', 'court_type': 'all', 'is_gazetted': true},
    {'date': '2025-11-05', 'name': 'Guru Nanak Jayanti', 'court_type': 'all', 'is_gazetted': true},
    {'date': '2025-12-25', 'name': 'Christmas', 'court_type': 'all', 'is_gazetted': true},
  ];
});
