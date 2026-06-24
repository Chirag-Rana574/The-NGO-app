import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../domain/cause_list_item.dart';
import 'cause_lists_controller.dart';

class CauseListsScreen extends ConsumerStatefulWidget {
  final String? defaultCourt;
  const CauseListsScreen({super.key, this.defaultCourt});

  @override
  ConsumerState<CauseListsScreen> createState() => _CauseListsScreenState();
}

class _CauseListsScreenState extends ConsumerState<CauseListsScreen> {
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    if (widget.defaultCourt != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(causeListsControllerProvider.notifier).setCourt(widget.defaultCourt);
      });
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      ref.read(causeListsControllerProvider.notifier).setSearchQuery(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final causeListsAsync = ref.watch(causeListsListProvider);
    final courtsAsync = ref.watch(causeListsCourtsProvider);
    final controllerState = ref.watch(causeListsControllerProvider);
    final selectedCourt = controllerState.selectedCourt;
    final selectedDate = controllerState.selectedDate;

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      final formattedDate = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      ref.read(causeListsControllerProvider.notifier).setDate(formattedDate);
    }
  }

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkGround
          : AppColors.marble,
      appBar: AppBar(
        title: Text(
          'Cause Lists',
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

          // Court filter
          if (courtsAsync.hasValue)
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
                        'All Courts',
                        style: AppTextStyles.badge(
                          color: selectedCourt == null
                              ? AppColors.sandXlt
                              : Theme.of(context).brightness == Brightness.dark
                                  ? AppColors.darkTextPri
                                  : AppColors.ink,
                        ),
                      ),
                      selected: selectedCourt == null,
                      onSelected: (_) {
                        ref.read(causeListsControllerProvider.notifier).setCourt(null);
                      },
                      backgroundColor: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkRaised
                          : AppColors.sandXlt,
                      selectedColor: AppColors.lal,
                    ),
                  ),
                  ...courtsAsync.value!.map((court) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(
                          court,
                          style: AppTextStyles.badge(
                            color: selectedCourt == court
                                ? AppColors.sandXlt
                                : Theme.of(context).brightness == Brightness.dark
                                    ? AppColors.darkTextPri
                                    : AppColors.ink,
                          ),
                        ),
                        selected: selectedCourt == court,
                        onSelected: (_) {
                          ref.read(causeListsControllerProvider.notifier).setCourt(court);
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

          // Date filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                FilterChip(
                  label: Text(
                    selectedDate ?? 'All Dates',
                    style: AppTextStyles.badge(
                      color: selectedDate == null
                          ? AppColors.sandXlt
                          : Theme.of(context).brightness == Brightness.dark
                              ? AppColors.darkTextPri
                              : AppColors.ink,
                    ),
                  ),
                  selected: selectedDate != null,
                  onSelected: (_) => selectDate(context),
                  backgroundColor: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkRaised
                      : AppColors.sandXlt,
                  selectedColor: AppColors.lal,
                  avatar: Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: selectedDate == null
                        ? Theme.of(context).brightness == Brightness.dark
                            ? AppColors.darkTextPri
                            : AppColors.ink
                        : AppColors.sandXlt,
                  ),
                ),
                if (selectedDate != null)
                  IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkTextSec
                        : AppColors.dust,
                    onPressed: () {
                      ref.read(causeListsControllerProvider.notifier).setDate(null);
                    },
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Cause lists accordion
          Expanded(
            child: causeListsAsync.when(
              data: (causeLists) {
                if (causeLists.isEmpty) {
                  return Center(
                    child: Text(
                      'No cause lists found',
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
                    final _ = await ref.refresh(causeListsListProvider.future);
                  },
                  child: ListView.builder(
                    itemCount: causeLists.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      final causeList = causeLists[index];
                      return _CauseListAccordion(
                        causeList: causeList,
                        index: index,
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text(
                  'Error loading cause lists: $error',
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

class _CauseListAccordion extends ConsumerWidget {
  final CauseListPayload causeList;
  final int index;

  const _CauseListAccordion({required this.causeList, required this.index});

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
      child: ExpansionTile(
        title: Text(
          '${causeList.court} - ${causeList.date}',
          style: AppTextStyles.body(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkTextPri
                : AppColors.ink,
          ),
        ),
        subtitle: Text(
          '${causeList.totalCases} cases',
          style: AppTextStyles.stat(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkTextSec
                : AppColors.dust,
          ),
        ),
        children: [
          if (causeList.cases.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'No cases listed',
                style: AppTextStyles.bodySmall(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkTextSec
                      : AppColors.dust,
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: causeList.cases.length,
              itemBuilder: (context, caseIndex) {
                final caseItem = causeList.cases[caseIndex];
                return _CaseListItem(
                  caseItem: caseItem,
                  index: caseIndex,
                );
              },
            ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.1, duration: 300.ms, delay: (index * 50).ms);
  }
}

class _CaseListItem extends ConsumerWidget {
  final CauseListItem caseItem;
  final int index;

  const _CaseListItem({required this.caseItem, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            caseItem.caseNo,
            style: AppTextStyles.body(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkTextPri
                  : AppColors.ink,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            caseItem.parties,
            style: AppTextStyles.bodySmall(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkTextSec
                  : AppColors.dust,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${caseItem.courtRoom} - ${caseItem.judge}',
                style: AppTextStyles.stat(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkTextSec
                      : AppColors.dust,
                ),
              ),
              Text(
                caseItem.listedOn,
                style: AppTextStyles.bodySmall(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkTextSec
                      : AppColors.dust,
                ),
              ),
            ],
          ),
          if (index < 10) const Divider(height: 16),
        ],
      ),
    );
  }
}