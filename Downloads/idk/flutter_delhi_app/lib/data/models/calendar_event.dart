import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class CalendarEvent {
  final String id;
  final DateTime date;
  final String title;
  final String? notes;
  final TimeOfDay? time;

  CalendarEvent({
    String? id,
    required this.date,
    required this.title,
    this.notes,
    this.time,
  }) : id = id ?? const Uuid().v4();

  // Create a copy of the event with modified fields
  CalendarEvent copyWith({
    String? id,
    DateTime? date,
    String? title,
    String? notes,
    TimeOfDay? time,
  }) {
    return CalendarEvent(
      id: id ?? this.id,
      date: date ?? this.date,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      time: time ?? this.time,
    );
  }
}
