import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/judgment.dart';
import 'judgments_service.dart';

final judgmentsRepositoryProvider = Provider<JudgmentsRepository>((ref) {
  final service = ref.watch(judgmentsServiceProvider);
  return JudgmentsRepository(service);
});

class JudgmentsRepository {
  final JudgmentsService _service;

  JudgmentsRepository(this._service);

  Future<List<Judgment>> getJudgments({
    int limit = 20,
    int offset = 0,
    String? searchQuery,
  }) {
    return _service.fetchJudgments(
      limit: limit,
      offset: offset,
      searchQuery: searchQuery,
    );
  }

  Future<int> getTotalCount({String? searchQuery}) {
    return _service.fetchTotalCount(searchQuery: searchQuery);
  }
}