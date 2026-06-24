import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';
import '../theme/context_colors.dart';
import '../shared/widgets/pietra_card.dart';
import '../shared/widgets/fade_slide.dart';
import '../shared/widgets/app_drawer.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/providers/calendar_events_provider.dart';
import '../data/models/calendar_event.dart';
import '../data/providers/court_holidays_provider.dart';

class CourtCalendarScreen extends ConsumerStatefulWidget {
  const CourtCalendarScreen({super.key});

  @override
  ConsumerState<CourtCalendarScreen> createState() => _CourtCalendarScreenState();
}

class _CourtCalendarScreenState extends ConsumerState<CourtCalendarScreen> {
  DateTime _currentDate = DateTime.now();

  final List<String> _monthNames = [
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
  ];

  final List<Map<String, dynamic>> _vacations = [
    { 'name': 'Summer Vacation', 'dates': 'May 19 - July 6, 2025', 'duration': '49 days', 'icon': Icons.wb_sunny, 'color': Colors.orange },
    { 'name': 'Dussehra Break', 'dates': 'Oct 1 - Oct 5, 2025', 'duration': '5 days', 'icon': Icons.star, 'color': Colors.red },
    { 'name': 'Diwali Break', 'dates': 'Oct 18 - Oct 22, 2025', 'duration': '5 days', 'icon': Icons.star, 'color': Colors.purple },
    { 'name': 'Winter Vacation', 'dates': 'Dec 22 - Jan 5, 2026', 'duration': '15 days', 'icon': Icons.ac_unit, 'color': Colors.blue },
  ];

  @override
  Widget build(BuildContext context) {
    final year = _currentDate.year;
    final month = _currentDate.month - 1; // 0-11
    final monthName = _monthNames[month];
    
    final holidaysAsync = ref.watch(courtHolidaysProvider);
    final holidays = holidaysAsync.maybeWhen(
      data: (list) {
        return list.where((h) {
          final dateStr = h['date'] as String;
          try {
            final date = DateTime.parse(dateStr);
            return date.year == year && date.month == (month + 1);
          } catch (_) {
            return false;
          }
        }).toList();
      },
      orElse: () => <Map<String, dynamic>>[],
    );
    
    String? vacationName;
    if (month == 5) vacationName = "Summer Vacation"; // June

    return Scaffold(
      backgroundColor: context.ground,
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: context.ground,
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.calendar_month, color: context.textSec, size: 24),
            const SizedBox(width: 8),
            Text('Court Calendar', style: AppTextStyles.screenTitle(color: context.textPri)),
          ],
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildMonthNavigator(context, monthName, year, vacationName),
                const SizedBox(height: 16),
                _buildCalendarGrid(context, year, month, holidays),
                const SizedBox(height: 16),
                _buildMonthHolidays(context, holidays, vacationName),
                const SizedBox(height: 24),
                Text('2025 Court Vacations', style: AppTextStyles.screenTitle(color: context.textPri)),
                const SizedBox(height: 12),
                _buildVacationPeriods(context),
                const SizedBox(height: 24),
                _buildCourtTimings(context),
                const SizedBox(height: 32),
              ]),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMonthNavigator(BuildContext context, String monthName, int year, String? vacation) {
    return FadeSlide(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.chevron_left, color: context.textPri),
              onPressed: () {
                setState(() {
                  _currentDate = DateTime(_currentDate.year, _currentDate.month - 1, 1);
                });
              },
            ),
            Column(
              children: [
                Text('$monthName $year', style: AppTextStyles.chatTitle(color: context.textPri).copyWith(fontSize: 18)),
                if (vacation != null)
                  Text(vacation, style: AppTextStyles.bodySmall(color: context.danger).copyWith(fontWeight: FontWeight.bold))
                else
                  Text('21 working days', style: AppTextStyles.bodySmall(color: context.textSec)),
              ],
            ),
            IconButton(
              icon: Icon(Icons.chevron_right, color: context.textPri),
              onPressed: () {
                setState(() {
                  _currentDate = DateTime(_currentDate.year, _currentDate.month + 1, 1);
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarGrid(BuildContext context, int year, int month, List<Map<String, dynamic>> holidays) {
    final daysInMonth = DateTime(year, month + 2, 0).day;
    final firstDayOfMonth = DateTime(year, month + 1, 1).weekday; // 1 (Mon) to 7 (Sun)
    
    // Adjust so Sunday is 0, Monday is 1, etc.
    final offset = firstDayOfMonth == 7 ? 0 : firstDayOfMonth;

    final today = DateTime.now();

    final holidayDates = holidays.map((h) => h['date'] as String).toList();

    return FadeSlide(
      child: Container(
        decoration: BoxDecoration(
          color: context.surface,
          border: Border.all(color: context.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            // Weekday headers
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: context.raised,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'].map((day) {
                  return Text(
                    day,
                    style: AppTextStyles.bodySmall(color: context.textSec).copyWith(
                      color: day == 'Sun' || day == 'Sat' ? context.danger : context.textDim,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList(),
              ),
            ),
            // Calendar Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 0.8,
              ),
              itemCount: 42, // 6 weeks * 7 days
              itemBuilder: (context, index) {
                final dayNumber = index - offset + 1;
                final isCurrentMonth = dayNumber > 0 && dayNumber <= daysInMonth;
                final dayOfWeek = index % 7;
                final isWeekend = dayOfWeek == 0 || dayOfWeek == 6;
                
                // Vacation logic for 2025 based on our mock data
                final isVacation = isCurrentMonth && (
                    (month == 4 && dayNumber >= 19) || // May 19 onwards
                    (month == 5) || // June
                    (month == 6 && dayNumber <= 6) || // July 1-6
                    (month == 9 && dayNumber >= 1 && dayNumber <= 5) || // Oct 1-5
                    (month == 9 && dayNumber >= 18 && dayNumber <= 22) || // Oct 18-22
                    (month == 11 && dayNumber >= 22) // Dec 22 onwards
                );

                if (!isCurrentMonth) {
                  return Container(
                    decoration: BoxDecoration(
                      color: context.raised.withValues(alpha: 0.5),
                      border: Border.all(color: context.border.withValues(alpha: 0.5), width: 0.5),
                    ),
                  );
                }

                // Format date to match 'YYYY-MM-DD'
                final formattedMonth = (month + 1).toString().padLeft(2, '0');
                final formattedDay = dayNumber.toString().padLeft(2, '0');
                final dateString = '$year-$formattedMonth-$formattedDay';
                final hasHoliday = holidayDates.contains(dateString);

                final isToday = today.year == year && today.month == month + 1 && today.day == dayNumber;

                final dateObj = DateTime(year, month + 1, dayNumber);
                final allEvents = ref.watch(calendarEventsProvider);
                final dayEvents = allEvents[DateTime(year, month + 1, dayNumber)] ?? [];

                return InkWell(
                  onTap: () => _showDayEventsModal(context, dateObj),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isVacation 
                        ? Colors.orange.withValues(alpha: 0.05) 
                        : (isWeekend ? context.danger.withValues(alpha: 0.02) : context.surface),
                      border: Border.all(color: context.border.withValues(alpha: 0.5), width: 0.5),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: isToday ? context.primary : Colors.transparent,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                dayNumber.toString(),
                                style: AppTextStyles.bodySmall(color: context.textSec).copyWith(
                                  color: isToday 
                                    ? context.surface 
                                    : (hasHoliday || isWeekend ? context.danger : context.textPri),
                                  fontWeight: isToday || hasHoliday ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                            if (hasHoliday)
                              Container(
                                margin: const EdgeInsets.only(top: 2),
                                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                                decoration: BoxDecoration(
                                  color: context.danger.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: Text('Holiday', style: AppTextStyles.bodySmall(color: context.danger).copyWith(fontSize: 8)),
                              ),
                            if (isVacation && !hasHoliday)
                              Text('Vacation', style: AppTextStyles.bodySmall(color: Colors.orange).copyWith(fontSize: 8, fontStyle: FontStyle.italic)),
                          ],
                        ),
                        if (dayEvents.isNotEmpty)
                          Positioned(
                            bottom: 2,
                            right: 2,
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: context.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        if (hasHoliday)
                          Positioned(
                            bottom: 2,
                            left: 2,
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: context.danger,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDayEventsModal(BuildContext context, DateTime date) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return _DayEventsSheet(
          date: date,
          parentRef: ref,
        );
      },
    );
  }

  Widget _buildMonthHolidays(BuildContext context, List<Map<String, dynamic>> holidays, String? vacation) {
    if (vacation != null) {
      return FadeSlide(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.1),
            border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(Icons.beach_access, size: 48, color: Colors.orange),
              const SizedBox(height: 12),
              Text('Court Vacation', style: AppTextStyles.chatTitle(color: context.textPri).copyWith(color: Colors.orange)),
              Text('Courts are closed during $vacation', style: AppTextStyles.bodySmall(color: Colors.orange)),
            ],
          ),
        ),
      );
    }

    if (holidays.isEmpty) {
      return FadeSlide(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: context.raised,
            border: Border.all(color: context.border),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(Icons.schedule, size: 48, color: context.textDim),
              const SizedBox(height: 12),
              Text('No holidays this month', style: AppTextStyles.chatTitle(color: context.textPri)),
              Text('Regular court functioning', style: AppTextStyles.bodySmall(color: context.textSec)),
            ],
          ),
        ),
      );
    }

    return FadeSlide(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star, size: 16, color: context.primary),
              const SizedBox(width: 8),
              Text('Holidays', style: AppTextStyles.chatTitle(color: context.textPri)),
            ],
          ),
          const SizedBox(height: 12),
          ...holidays.map((holiday) {
            final dateParts = (holiday['date'] as String).split('-');
            final day = dateParts[2];
            final isGazetted = holiday['is_gazetted'] as bool;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: PietraCard(
                accentColor: Colors.transparent,
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        color: context.danger.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(day, style: AppTextStyles.chatTitle(color: context.textPri).copyWith(color: context.danger, fontSize: 18)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(holiday['name'] as String, style: AppTextStyles.body(color: context.textPri).copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isGazetted ? context.danger.withValues(alpha: 0.1) : context.raised,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(isGazetted ? 'Gazetted' : 'Restricted', 
                                  style: AppTextStyles.bodySmall(color: isGazetted ? context.danger : context.textSec).copyWith(fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildVacationPeriods(BuildContext context) {
    return FadeSlide(
      child: Column(
        children: _vacations.map((vacation) {
          final color = vacation['color'] as Color;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: PietraCard(
              accentColor: Colors.transparent,
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(vacation['icon'] as IconData, color: color),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(vacation['name'] as String, style: AppTextStyles.body(color: context.textPri).copyWith(fontWeight: FontWeight.bold)),
                        Text(vacation['dates'] as String, style: AppTextStyles.bodySmall(color: context.textSec)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: context.info.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(vacation['duration'] as String, style: AppTextStyles.bodySmall(color: context.info).copyWith(fontWeight: FontWeight.bold, fontSize: 11)),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCourtTimings(BuildContext context) {
    return FadeSlide(
      child: PietraCard(
        accentColor: context.primary,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: context.primary),
                const SizedBox(width: 8),
                Text('Court Timings', style: AppTextStyles.chatTitle(color: context.textPri)),
              ],
            ),
            const SizedBox(height: 16),
            _buildTimingRow(context, 'Supreme Court', '10:30 AM - 4:00 PM'),
            const Divider(height: 16),
            _buildTimingRow(context, 'Delhi High Court', '10:30 AM - 4:00 PM'),
            const Divider(height: 16),
            _buildTimingRow(context, 'District Courts', '10:00 AM - 5:00 PM'),
          ],
        ),
      ),
    );
  }

  Widget _buildTimingRow(BuildContext context, String court, String timing) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(court, style: AppTextStyles.bodySmall(color: context.textSec)),
        Text(timing, style: AppTextStyles.body(color: context.textPri).copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _DayEventsSheet extends ConsumerStatefulWidget {
  final DateTime date;
  final WidgetRef parentRef;
  const _DayEventsSheet({required this.date, required this.parentRef});
  @override
  ConsumerState<_DayEventsSheet> createState() => _DayEventsSheetState();
}

class _DayEventsSheetState extends ConsumerState<_DayEventsSheet> {
  bool _isAdding = false;
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  TimeOfDay? _selectedTime;

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _addEvent() {
    if (_titleController.text.trim().isEmpty) return;
    
    final event = CalendarEvent(
      date: widget.date,
      title: _titleController.text.trim(),
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      time: _selectedTime,
    );
    
    widget.parentRef.read(calendarEventsProvider.notifier).addEvent(event);
    
    setState(() {
      _isAdding = false;
      _titleController.clear();
      _notesController.clear();
      _selectedTime = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final allEvents = ref.watch(calendarEventsProvider);
    final normalizedDate = DateTime(widget.date.year, widget.date.month, widget.date.day);
    final events = allEvents[normalizedDate] ?? [];
    final formattedDate = "${widget.date.day.toString().padLeft(2, '0')}/${widget.date.month.toString().padLeft(2, '0')}/${widget.date.year}";

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: context.ground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Events for $formattedDate', style: AppTextStyles.screenTitle(color: context.textPri)),
              IconButton(
                icon: Icon(Icons.close, color: context.textSec),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (!_isAdding) ...[
            if (events.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text('No events for this date.', style: AppTextStyles.body(color: context.textSec)),
                ),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return PietraCard(
                      accentColor: context.primary,
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(event.title, style: AppTextStyles.body(color: context.textPri).copyWith(fontWeight: FontWeight.bold)),
                                if (event.time != null) ...[
                                  const SizedBox(height: 4),
                                  Text(event.time!.format(context), style: AppTextStyles.bodySmall(color: context.primary)),
                                ],
                                if (event.notes != null) ...[
                                  const SizedBox(height: 4),
                                  Text(event.notes!, style: AppTextStyles.bodySmall(color: context.textSec)),
                                ],
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete_outline, color: context.danger, size: 20),
                            onPressed: () {
                              widget.parentRef.read(calendarEventsProvider.notifier).removeEvent(event.id, widget.date);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => setState(() => _isAdding = true),
              icon: const Icon(Icons.add),
              label: const Text('Add Event'),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primary,
                foregroundColor: context.surface,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ] else ...[
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Event Title',
                labelStyle: AppTextStyles.bodySmall(color: context.textSec),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              style: AppTextStyles.body(color: context.textPri),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: 'Notes / Reminders (Optional)',
                labelStyle: AppTextStyles.bodySmall(color: context.textSec),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              maxLines: 3,
              style: AppTextStyles.body(color: context.textPri),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                      if (time != null) {
                        setState(() => _selectedTime = time);
                      }
                    },
                    icon: const Icon(Icons.access_time),
                    label: Text(_selectedTime?.format(context) ?? 'Set Time (Optional)'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: context.textPri,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _isAdding = false),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _addEvent,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.primary,
                      foregroundColor: context.surface,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Save Event'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
