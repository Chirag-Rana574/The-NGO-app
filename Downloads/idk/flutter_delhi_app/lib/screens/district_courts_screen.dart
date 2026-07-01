import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/context_colors.dart';
import '../shared/widgets/lal_app_bar.dart';
import '../shared/widgets/pietra_card.dart';
import '../shared/widgets/fade_slide.dart';
import '../shared/widgets/inlay_chip.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/providers/district_courts_provider.dart';

class DistrictCourtsScreen extends ConsumerStatefulWidget {
  const DistrictCourtsScreen({super.key});

  @override
  ConsumerState<DistrictCourtsScreen> createState() => _DistrictCourtsScreenState();
}

class _DistrictCourtsScreenState extends ConsumerState<DistrictCourtsScreen> {
  bool _showNotifications = false;
  bool _showMagistrate = false;

  final List<Map<String, String>> mockNotifications = [];

  final List<Map<String, String>> mockMagistrateRoster = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.ground,
      appBar: const LalAppBar(title: 'District Courts'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FadeSlide(
            delay: const Duration(milliseconds: 200),
            child: _buildExpandableCard(
              title: 'Notifications & Circulars',
              subtitle: 'Recent updates from all court complexes',
              icon: Icons.notifications,
              isExpanded: _showNotifications,
              onTap: () => setState(() => _showNotifications = !_showNotifications),
              child: _buildNotificationsList(context),
            ),
          ),
          const SizedBox(height: 12),
          FadeSlide(
            delay: const Duration(milliseconds: 300),
            child: _buildExpandableCard(
              title: 'Duty Magistrate Roster',
              subtitle: 'Current duty magistrates for urgent matters',
              icon: Icons.calendar_month,
              isExpanded: _showMagistrate,
              onTap: () => setState(() => _showMagistrate = !_showMagistrate),
              child: _buildMagistrateList(context),
            ),
          ),
          const SizedBox(height: 24),
          FadeSlide(
            delay: const Duration(milliseconds: 400),
            child: Text('Court Complexes', style: AppTextStyles.screenTitle(color: context.textPri)),
          ),
          const SizedBox(height: 12),
          ...ref.watch(districtCourtsProvider).asMap().entries.map((entry) {
            final index = entry.key;
            final court = entry.value;
            return FadeSlide(
              delay: Duration(milliseconds: 500 + (index * 100)),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: InkWell(
                  onTap: () {
                    context.push('/district_court_detail', extra: court);
                  },
                  child: PietraCard(
                  accentColor: Colors.transparent,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: context.isDark ? context.surface : AppColors.marble,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.location_city, color: context.accentDim),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(court.name, style: AppTextStyles.chatTitle(color: context.textPri)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.location_on, size: 12, color: context.textSec),
                                const SizedBox(width: 4),
                                Text(court.location, style: AppTextStyles.bodySmall(color: context.textSec)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: context.textDim),
                    ],
                  ), // Row
                ), // PietraCard
              ), // InkWell
              ), // Padding
            ); // FadeSlide
          }),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildExpandableCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isExpanded,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return PietraCard(
      accentColor: isExpanded ? context.primary : Colors.transparent,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(icon, color: context.textSec),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: AppTextStyles.chatTitle(color: context.textPri)),
                        const SizedBox(height: 2),
                        Text(subtitle, style: AppTextStyles.bodySmall(color: context.textSec)),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: context.textDim,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: context.border, width: 0.5)),
              ),
              padding: const EdgeInsets.all(16),
              child: child,
            ),
        ],
      ),
    );
  }



  Widget _buildNotificationsList(BuildContext context) {
    if (mockNotifications.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Center(
          child: Text(
            'No notifications available yet.\nData will appear once connected to the court API.',
            style: AppTextStyles.bodySmall(color: context.textDim),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return Column(
      children: mockNotifications.map((notif) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 8, height: 8,
                margin: const EdgeInsets.only(top: 6),
                decoration: BoxDecoration(
                  color: notif['type'] == 'holiday' ? context.danger : context.info,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(notif['title']!, style: AppTextStyles.body(color: context.textPri)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(notif['date']!, style: AppTextStyles.bodySmall(color: context.textSec)),
                        const SizedBox(width: 8),
                        Text('· ${notif['district']}', style: AppTextStyles.bodySmall(color: context.accentDim)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMagistrateList(BuildContext context) {
    if (mockMagistrateRoster.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Center(
          child: Text(
            'No duty magistrate data available yet.\nData will appear once connected to the court API.',
            style: AppTextStyles.bodySmall(color: context.textDim),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return Column(
      children: mockMagistrateRoster.map((mag) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: context.surface,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(mag['date']!.split('-').last, style: AppTextStyles.badge()),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(mag['magistrate']!, style: AppTextStyles.body(color: context.textPri).copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text('Court: ${mag['court']}', style: AppTextStyles.bodySmall(color: context.textSec)),
                  ],
                ),
              ),
              InlayChip(
                status: mag['shift'] == 'Morning' ? InlayStatus.processing : InlayStatus.soon,
                label: mag['shift'],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
