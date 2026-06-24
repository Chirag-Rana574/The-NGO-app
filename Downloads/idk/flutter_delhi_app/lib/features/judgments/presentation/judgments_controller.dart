import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/judgment.dart';
import '../data/judgments_repository.dart';

// Search query provider
final judgmentsSearchQueryProvider = StateProvider<String>((ref) => '');

// Pagination state
class JudgmentsState {
  final int offset;
  final bool hasMore;
  final bool isLoading;

  const JudgmentsState({
    this.offset = 0,
    this.hasMore = true,
    this.isLoading = false,
  });

  JudgmentsState copyWith({int? offset, bool? hasMore, bool? isLoading}) {
    return JudgmentsState(
      offset: offset ?? this.offset,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final judgmentsStateProvider = StateProvider<JudgmentsState>((ref) {
  return const JudgmentsState();
});

// Judgments list with pagination
final judgmentsListProvider = FutureProvider.autoDispose<List<Judgment>>((ref) async {
  final repository = ref.watch(judgmentsRepositoryProvider);
  final searchQuery = ref.watch(judgmentsSearchQueryProvider);
  final state = ref.watch(judgmentsStateProvider);

  return repository.getJudgments(
    limit: 20,
    offset: state.offset,
    searchQuery: searchQuery,
  );
});

// Total count provider
final judgmentsCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final repository = ref.watch(judgmentsRepositoryProvider);
  final searchQuery = ref.watch(judgmentsSearchQueryProvider);
  return repository.getTotalCount(searchQuery: searchQuery);
});

// Controller
class JudgmentsController extends AutoDisposeNotifier<JudgmentsState> {
  @override
  JudgmentsState build() {
    return const JudgmentsState();
  }

  void setSearchQuery(String query) {
    ref.read(judgmentsSearchQueryProvider.notifier).state = query;
    // Reset pagination on search
    state = const JudgmentsState();
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true);

    final repository = ref.read(judgmentsRepositoryProvider);
    final searchQuery = ref.read(judgmentsSearchQueryProvider);
    final count = await repository.getTotalCount(searchQuery: searchQuery);

    final hasMore = state.offset + 20 < count;
    final newOffset = state.offset + 20;

    state = JudgmentsState(
      offset: newOffset,
      hasMore: hasMore,
      isLoading: false,
    );

    // Refresh the list
    final _ = await ref.refresh(judgmentsListProvider.future);
  }

  Future<void> refresh() async {
    state = const JudgmentsState();
    final _ = await ref.refresh(judgmentsListProvider.future);
  }
}

final judgmentsControllerProvider = AutoDisposeNotifierProvider<JudgmentsController, JudgmentsState>(() {
  return JudgmentsController();
});