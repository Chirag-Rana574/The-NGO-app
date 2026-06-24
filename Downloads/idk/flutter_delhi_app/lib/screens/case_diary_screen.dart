import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../theme/app_text_styles.dart';
import '../theme/context_colors.dart';
import '../shared/widgets/lal_app_bar.dart';
import '../shared/widgets/pietra_card.dart';
import '../shared/widgets/fade_slide.dart';
import '../data/providers/case_diary_provider.dart';
import '../data/models/case_diary_model.dart';

class CaseDiaryScreen extends ConsumerStatefulWidget {
  const CaseDiaryScreen({super.key});

  @override
  ConsumerState<CaseDiaryScreen> createState() => _CaseDiaryScreenState();
}

class _CaseDiaryScreenState extends ConsumerState<CaseDiaryScreen> {
  final DateFormat _dateFormat = DateFormat('MMM d, yyyy');
  final _uuid = const Uuid();

  void _showAddEditDialog(BuildContext context, [CaseItem? existingCase]) {
    final titleController = TextEditingController(text: existingCase?.title ?? '');
    final caseNoController = TextEditingController(text: existingCase?.caseNumber ?? '');
    final courtController = TextEditingController(text: existingCase?.court ?? '');
    final notesController = TextEditingController(text: existingCase?.notes ?? '');
    String status = existingCase?.status ?? 'active';
    DateTime selectedDate = existingCase != null 
        ? DateTime.parse(existingCase.nextHearingDate) 
        : DateTime.now();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: context.surface,
              title: Text(existingCase == null ? 'Add New Case' : 'Edit Case', style: AppTextStyles.chatTitle(color: context.textPri)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(labelText: 'Case Title', labelStyle: AppTextStyles.bodySmall(color: context.textSec)),
                    ),
                    TextField(
                      controller: caseNoController,
                      decoration: InputDecoration(labelText: 'Case Number', labelStyle: AppTextStyles.bodySmall(color: context.textSec)),
                    ),
                    TextField(
                      controller: courtController,
                      decoration: InputDecoration(labelText: 'Court', labelStyle: AppTextStyles.bodySmall(color: context.textSec)),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text('Hearing Date: ', style: AppTextStyles.bodySmall(color: context.textSec)),
                        TextButton(
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                            );
                            if (date != null) setState(() => selectedDate = date);
                          },
                          child: Text(_dateFormat.format(selectedDate), style: AppTextStyles.body(color: context.primary)),
                        ),
                      ],
                    ),
                    DropdownButton<String>(
                      value: status,
                      isExpanded: true,
                      dropdownColor: context.surface,
                      items: const [
                        DropdownMenuItem(value: 'active', child: Text('Active')),
                        DropdownMenuItem(value: 'pending', child: Text('Pending')),
                        DropdownMenuItem(value: 'closed', child: Text('Closed')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => status = val);
                      },
                    ),
                    TextField(
                      controller: notesController,
                      decoration: InputDecoration(labelText: 'Notes', labelStyle: AppTextStyles.bodySmall(color: context.textSec)),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: AppTextStyles.bodySmall(color: context.textDim)),
                ),
                TextButton(
                  onPressed: () {
                    final item = CaseItem(
                      id: existingCase?.id ?? _uuid.v4(),
                      title: titleController.text,
                      caseNumber: caseNoController.text,
                      court: courtController.text,
                      nextHearingDate: selectedDate.toIso8601String(),
                      status: status,
                      notes: notesController.text,
                    );
                    if (existingCase == null) {
                      ref.read(caseDiaryProvider.notifier).addCase(item);
                    } else {
                      ref.read(caseDiaryProvider.notifier).updateCase(item);
                    }
                    Navigator.pop(context);
                  },
                  child: Text('Save', style: AppTextStyles.body(color: context.primary)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cases = ref.watch(caseDiaryProvider);
    
    // Sort by next hearing date
    final sortedCases = [...cases]..sort((a, b) => 
      DateTime.parse(a.nextHearingDate).compareTo(DateTime.parse(b.nextHearingDate))
    );

    final upcomingHearings = sortedCases.where((c) => 
      c.status == 'active' && DateTime.parse(c.nextHearingDate).isAfter(DateTime.now().subtract(const Duration(days: 1)))
    );

    return Scaffold(
      backgroundColor: context.ground,
      appBar: const LalAppBar(title: 'Case Diary'),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(context),
        backgroundColor: context.primary,
        child: Icon(Icons.add, color: context.ground),
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (upcomingHearings.isNotEmpty) ...[
                  FadeSlide(
                    child: Text('Upcoming Hearings', style: AppTextStyles.screenTitle(color: context.textPri)),
                  ),
                  const SizedBox(height: 12),
                  FadeSlide(
                    delay: const Duration(milliseconds: 100),
                    child: PietraCard(
                      accentColor: context.info,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: upcomingHearings.take(3).map((c) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(c.title, style: AppTextStyles.body(color: context.textPri).copyWith(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                              ),
                              Text(_dateFormat.format(DateTime.parse(c.nextHearingDate)), style: AppTextStyles.bodySmall(color: context.info)),
                            ],
                          ),
                        )).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                
                FadeSlide(
                  delay: const Duration(milliseconds: 200),
                  child: Text('All Cases', style: AppTextStyles.screenTitle(color: context.textPri)),
                ),
                const SizedBox(height: 12),
                
                if (sortedCases.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Text('No cases yet. Add your first case to get started.', style: AppTextStyles.bodySec(color: context.textSec), textAlign: TextAlign.center),
                    ),
                  )
                else
                  ...sortedCases.map((c) {
                    Color statusColor;
                    if (c.status == 'closed') {
                      statusColor = context.success;
                    } else if (c.status == 'pending') {
                      statusColor = Colors.orange;
                    } else {
                      statusColor = context.info;
                    }

                    return FadeSlide(
                      delay: const Duration(milliseconds: 300),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: PietraCard(
                          accentColor: statusColor,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(child: Text(c.title, style: AppTextStyles.chatTitle(color: context.textPri))),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.edit, size: 16, color: context.textDim),
                                        onPressed: () => _showAddEditDialog(context, c),
                                        constraints: const BoxConstraints(),
                                        padding: EdgeInsets.zero,
                                      ),
                                      const SizedBox(width: 12),
                                      IconButton(
                                        icon: Icon(Icons.delete, size: 16, color: context.danger),
                                        onPressed: () {
                                          ref.read(caseDiaryProvider.notifier).deleteCase(c.id);
                                        },
                                        constraints: const BoxConstraints(),
                                        padding: EdgeInsets.zero,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(c.caseNumber, style: AppTextStyles.bodySmall(color: context.textSec)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today, size: 12, color: context.textDim),
                                  const SizedBox(width: 4),
                                  Text(_dateFormat.format(DateTime.parse(c.nextHearingDate)), style: AppTextStyles.bodySmall(color: context.textSec)),
                                  const SizedBox(width: 12),
                                  Icon(Icons.business, size: 12, color: context.textDim),
                                  const SizedBox(width: 4),
                                  Expanded(child: Text(c.court, style: AppTextStyles.bodySmall(color: context.textSec), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                ],
                              ),
                              if (c.notes.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                const Divider(height: 1),
                                const SizedBox(height: 8),
                                Text(c.notes, style: AppTextStyles.bodySmall(color: context.textSec)),
                              ]
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
