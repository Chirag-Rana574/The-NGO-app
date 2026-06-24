import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/legal_update.dart';
import 'legal_updates_service.dart';

final legalUpdatesRepositoryProvider = Provider<LegalUpdatesRepository>((ref) {
  final service = ref.watch(legalUpdatesServiceProvider);
  return LegalUpdatesRepository(service);
});

class LegalUpdatesRepository {
  final LegalUpdatesService _service;

  LegalUpdatesRepository(this._service);

  Future<List<LegalUpdate>> getLegalUpdates({
    int limit = 20,
    String? searchQuery,
    String? category,
  }) {
    return _service.fetchLegalUpdates(
      limit: limit,
      searchQuery: searchQuery,
      category: category,
    );
  }

  Future<List<String>> getCategories() {
    return _service.fetchCategories();
  }
}