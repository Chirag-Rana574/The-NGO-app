import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/calendar_event.dart';

// State is a map from normalized DateTime (at midnight) to a list of events.
class CalendarEventsNotifier extends StateNotifier<Map<DateTime, List<CalendarEvent>>> {
  CalendarEventsNotifier() : super({});

  void addEvent(CalendarEvent event) {
    // Normalize date to midnight to use as a reliable key
    final normalizedDate = DateTime(event.date.year, event.date.month, event.date.day);
    
    final currentEvents = state[normalizedDate] ?? [];
    
    state = {
      ...state,
      normalizedDate: [...currentEvents, event],
    };
  }

  void removeEvent(String eventId, DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    
    final currentEvents = state[normalizedDate] ?? [];
    final updatedEvents = currentEvents.where((e) => e.id != eventId).toList();
    
    if (updatedEvents.isEmpty) {
      final newState = Map<DateTime, List<CalendarEvent>>.from(state);
      newState.remove(normalizedDate);
      state = newState;
    } else {
      state = {
        ...state,
        normalizedDate: updatedEvents,
      };
    }
  }

  List<CalendarEvent> getEventsForDay(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    return state[normalizedDate] ?? [];
  }
}

final calendarEventsProvider = StateNotifierProvider<CalendarEventsNotifier, Map<DateTime, List<CalendarEvent>>>((ref) {
  return CalendarEventsNotifier();
});
