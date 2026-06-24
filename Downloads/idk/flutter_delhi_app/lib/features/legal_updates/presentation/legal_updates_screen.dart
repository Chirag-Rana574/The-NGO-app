import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../domain/legal_update.dart';
import 'legal_updates_controller.dart';

class LegalUpdatesScreen extends ConsumerStatefulWidget {
  const LegalUpdatesScreen({super.key});

  @override
  ConsumerState<LegalUpdatesScreen> createState() => _LegalUpdatesScreenState();
}

class _LegalUpdatesScreenState extends ConsumerState<LegalUpdatesScreen> {
  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      ref.read(legalUpdatesControllerProvider.notifier).setSearchQuery(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final updatesAsync = ref.watch(legalUpdatesListProvider);
    final categoriesAsync = ref.watch(legalUpdatesCategoriesProvider);
    final selectedCategory = ref.watch(legalUpdatesCategoryProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkGround
          : AppColors.marble,
      appBar: AppBar(
        title: Text(
          'Legal Updates',
          style: AppTextStyles.screenTitle(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkTextPri
                : AppColors.sandXlt,
          ),
        ),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkSurface
            : AppColors.lal,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search legal updates...',
                hintStyle: AppTextStyles.searchPlaceholder(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkTextDim
                      : AppColors.dust,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkTextDim
                      : AppColors.dust,
                ),
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkRaised
                    : AppColors.sandXlt,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(3),
                  borderSide: BorderSide(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkBorder
                        : AppColors.sandLt,
                    width: 0.5,
                  ),
                ),
              ),
              style: AppTextStyles.body(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkTextPri
                    : AppColors.ink,
              ),
              onChanged: _onSearchChanged,
            ),
          ),

          // Category filter
          if (categoriesAsync.hasValue)
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(
                        'All',
                        style: AppTextStyles.badge(
                          color: selectedCategory == null
                              ? AppColors.sandXlt
                              : Theme.of(context).brightness == Brightness.dark
                                  ? AppColors.darkTextPri
                                  : AppColors.ink,
                        ),
                      ),
                      selected: selectedCategory == null,
                      onSelected: (_) {
                        ref.read(legalUpdatesCategoryProvider.notifier).state = null;
                      },
                      backgroundColor: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkRaised
                          : AppColors.sandXlt,
                      selectedColor: AppColors.lal,
                    ),
                  ),
                  ...categoriesAsync.value!.map((category) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(
                          category,
                          style: AppTextStyles.badge(
                            color: selectedCategory == category
                                ? AppColors.sandXlt
                                : Theme.of(context).brightness == Brightness.dark
                                    ? AppColors.darkTextPri
                                    : AppColors.ink,
                          ),
                        ),
                        selected: selectedCategory == category,
                        onSelected: (_) {
                          ref.read(legalUpdatesCategoryProvider.notifier).state = category;
                        },
                        backgroundColor: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.darkRaised
                            : AppColors.sandXlt,
                        selectedColor: AppColors.lal,
                      ),
                    );
                  }),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // Updates list
          Expanded(
            child: updatesAsync.when(
              data: (updates) {
                if (updates.isEmpty) {
                  return Center(
                    child: Text(
                      'No legal updates found',
                      style: AppTextStyles.body(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.darkTextSec
                            : AppColors.dust,
                      ),
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    final _ = await ref.refresh(legalUpdatesListProvider.future);
                  },
                  child: ListView.builder(
                    itemCount: updates.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      final update = updates[index];
                      return _LegalUpdateCard(
                        update: update,
                        index: index,
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text(
                  'Error loading updates: $error',
                  style: AppTextStyles.body(color: AppColors.lalLt),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegalUpdateCard extends ConsumerWidget {
  final LegalUpdate update;
  final int index;

  const _LegalUpdateCard({required this.update, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkRaised
          : AppColors.sandXlt,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkBorder
              : AppColors.sandLt,
          width: 0.5,
        ),
      ),
      child: InkWell(
        onTap: update.sourceUrl != null
            ? () async {
                final uri = Uri.parse(update.sourceUrl!);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                }
              }
            : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (update.isBreaking)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.lalLt,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Text(
                    'BREAKING',
                    style: AppTextStyles.badge(),
                  ),
                ),
              if (update.isBreaking) const SizedBox(height: 8),
              Text(
                update.title,
                style: AppTextStyles.body(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkTextPri
                      : AppColors.ink,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    update.category,
                    style: AppTextStyles.stat(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkTextSec
                          : AppColors.dust,
                    ),
                  ),
                  Text(
                    '${update.publishedAt.day}/${update.publishedAt.month}/${update.publishedAt.year}',
                    style: AppTextStyles.bodySmall(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkTextSec
                          : AppColors.dust,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.1, duration: 300.ms, delay: (index * 50).ms);
  }
}