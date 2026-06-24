import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/legal_update.dart';
import '../data/legal_updates_repository.dart';

// Search query provider with debounce
final legalUpdatesSearchQueryProvider = StateProvider<String>((ref) => '');

// Selected category provider
final legalUpdatesCategoryProvider = StateProvider<String?>((ref) => null);

// Debounced search provider
final debouncedSearchQueryProvider = Provider<String>((ref) {
  final query = ref.watch(legalUpdatesSearchQueryProvider);
  return query;
});

// Legal updates list provider
final legalUpdatesListProvider = FutureProvider.autoDispose<List<LegalUpdate>>((ref) async {
  final repository = ref.watch(legalUpdatesRepositoryProvider);
  final searchQuery = ref.watch(debouncedSearchQueryProvider);
  final category = ref.watch(legalUpdatesCategoryProvider);
  
  return repository.getLegalUpdates(
    limit: 20,
    searchQuery: searchQuery,
    category: category,
  );
});

// Categories provider
final legalUpdatesCategoriesProvider = FutureProvider<List<String>>((ref) async {
  final repository = ref.watch(legalUpdatesRepositoryProvider);
  return repository.getCategories();
});

// Controller for managing state
class LegalUpdatesController extends AutoDisposeNotifier<LegalUpdatesState> {
  @override
  LegalUpdatesState build() {
    return const LegalUpdatesState();
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    ref.read(legalUpdatesSearchQueryProvider.notifier).state = query;
  }

  void setCategory(String? category) {
    state = state.copyWith(selectedCategory: category);
  }

  void clearFilters() {
    state = const LegalUpdatesState();
  }

  Future<void> refresh() async {
    // Trigger a refresh of the future provider
    final _ = await ref.refresh(legalUpdatesListProvider.future);
  }
}

class LegalUpdatesState {
  final String searchQuery;
  final String? selectedCategory;
  final bool isRefreshing;

  const LegalUpdatesState({
    this.searchQuery = '',
    this.selectedCategory,
    this.isRefreshing = false,
  });

  LegalUpdatesState copyWith({
    String? searchQuery,
    String? selectedCategory,
    bool? isRefreshing,
  }) {
    return LegalUpdatesState(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}

final legalUpdatesControllerProvider = AutoDisposeNotifierProvider<LegalUpdatesController, LegalUpdatesState>(() {
  return LegalUpdatesController();
});