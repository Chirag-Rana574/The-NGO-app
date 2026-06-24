import 'package:flutter/material.dart';

/// @deprecated Court API logic has been migrated to feature-specific services.
/// Use `legal_updates_service.dart`, `judgments_service.dart`, or `cause_lists_service.dart` instead.
class CourtApiService {
  CourtApiService._();

  static void deprecationWarning() {
    debugPrint('CourtApiService is deprecated. Use feature-specific services instead.');
  }
}
