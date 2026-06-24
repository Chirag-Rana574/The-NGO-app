import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/cause_list_item.dart';
import 'cause_lists_service.dart';

final causeListsRepositoryProvider = Provider<CauseListsRepository>((ref) {
  final service = ref.watch(causeListsServiceProvider);
  return CauseListsRepository(service);
});

class CauseListsRepository {
  final CauseListsService _service;

  CauseListsRepository(this._service);

  Future<List<CauseListPayload>> getCauseLists({
    String? court,
    String? date,
    String? searchQuery,
  }) {
    return _service.fetchCauseLists(
      court: court,
      date: date,
      searchQuery: searchQuery,
    );
  }

  Future<List<String>> getCourts() {
    return _service.fetchCourts();
  }
}