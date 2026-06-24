import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/cause_list_item.dart';
import '../data/cause_lists_repository.dart';

// Search query provider
final causeListsSearchQueryProvider = StateProvider<String>((ref) => '');

// Selected court provider
final causeListsCourtProvider = StateProvider<String?>((ref) => null);

// Selected date provider
final causeListsDateProvider = StateProvider<String?>((ref) => null);

// Cause lists list provider
final causeListsListProvider = FutureProvider.autoDispose<List<CauseListPayload>>((ref) async {
  final repository = ref.watch(causeListsRepositoryProvider);
  final controllerState = ref.watch(causeListsControllerProvider);

  return repository.getCauseLists(
    searchQuery: controllerState.searchQuery,
    court: controllerState.selectedCourt,
    date: controllerState.selectedDate,
  );
});

// Courts provider
final causeListsCourtsProvider = FutureProvider<List<String>>((ref) async {
  final repository = ref.watch(causeListsRepositoryProvider);
  return repository.getCourts();
});

// Controller
class CauseListsController extends AutoDisposeNotifier<CauseListsState> {
  @override
  CauseListsState build() {
    return const CauseListsState();
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setCourt(String? court) {
    state = state.copyWith(selectedCourt: court);
  }

  void setDate(String? date) {
    state = state.copyWith(selectedDate: date);
  }

  void clearFilters() {
    state = const CauseListsState();
  }
}

class CauseListsState {
  final String searchQuery;
  final String? selectedCourt;
  final String? selectedDate;

  const CauseListsState({
    this.searchQuery = '',
    this.selectedCourt,
    this.selectedDate,
  });

  CauseListsState copyWith({
    String? searchQuery,
    String? selectedCourt,
    String? selectedDate,
  }) {
    return CauseListsState(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCourt: selectedCourt ?? this.selectedCourt,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }
}

final causeListsControllerProvider = AutoDisposeNotifierProvider<CauseListsController, CauseListsState>(() {
  return CauseListsController();
});