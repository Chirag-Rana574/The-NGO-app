import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../domain/judgment.dart';
import 'judgments_controller.dart';

class JudgmentsScreen extends ConsumerStatefulWidget {
  const JudgmentsScreen({super.key});

  @override
  ConsumerState<JudgmentsScreen> createState() => _JudgmentsScreenState();
}

class _JudgmentsScreenState extends ConsumerState<JudgmentsScreen> {
  final ScrollController _scrollController = ScrollController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(judgmentsControllerProvider.notifier).loadMore();
    }
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      ref.read(judgmentsControllerProvider.notifier).setSearchQuery(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final judgmentsAsync = ref.watch(judgmentsListProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkGround
          : AppColors.marble,
      appBar: AppBar(
        title: Text(
          'Judgments',
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
                hintText: 'Search by case number...',
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

          // Judgments list
          Expanded(
            child: judgmentsAsync.when(
              data: (judgments) {
                if (judgments.isEmpty) {
                  return Center(
                    child: Text(
                      'No judgments found',
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
                    ref.read(judgmentsControllerProvider.notifier).refresh();
                  },
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: judgments.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      final judgment = judgments[index];
                      return _JudgmentCard(
                        judgment: judgment,
                        index: index,
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text(
                  'Error loading judgments: $error',
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

class _JudgmentCard extends ConsumerWidget {
  final Judgment judgment;
  final int index;

  const _JudgmentCard({required this.judgment, required this.index});

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
        onTap: judgment.pdfUrl != null
            ? () async {
                final uri = Uri.parse(judgment.pdfUrl!);
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
              Text(
                judgment.caseNumber,
                style: AppTextStyles.body(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkTextPri
                      : AppColors.ink,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                judgment.parties,
                style: AppTextStyles.bodySmall(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkTextSec
                      : AppColors.dust,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    judgment.court,
                    style: AppTextStyles.stat(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkTextSec
                          : AppColors.dust,
                    ),
                  ),
                  Text(
                    '${judgment.date.day}/${judgment.date.month}/${judgment.date.year}',
                    style: AppTextStyles.bodySmall(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkTextSec
                          : AppColors.dust,
                    ),
                  ),
                ],
              ),
              if (judgment.summary != null) ...[
                const SizedBox(height: 8),
                Text(
                  judgment.summary!,
                  style: AppTextStyles.bodySmall(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkTextSec
                        : AppColors.dust,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
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