import 'package:flutter_riverpod/flutter_riverpod.dart';

// Home screen state
class HomeState {
  final bool isLoading;
  final String? error;

  const HomeState({
    this.isLoading = false,
    this.error,
  });

  HomeState copyWith({
    bool? isLoading,
    String? error,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Home controller
class HomeController extends AutoDisposeNotifier<HomeState> {
  @override
  HomeState build() {
    return const HomeState();
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    // Simulate data refresh
    await Future.delayed(const Duration(milliseconds: 500));
    state = const HomeState();
  }
}

final homeControllerProvider = AutoDisposeNotifierProvider<HomeController, HomeState>(() {
  return HomeController();
});
