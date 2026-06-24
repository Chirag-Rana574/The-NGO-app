import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/context_colors.dart';
import '../shared/widgets/pietra_card.dart';
import '../shared/widgets/fade_slide.dart';

import '../data/models/police_station.dart';

class PoliceStationDetailScreen extends StatelessWidget {
  final Object? station;

  const PoliceStationDetailScreen({
    super.key, 
    this.station,
  });

  PoliceStation? _getStation() {
    return station is PoliceStation ? station as PoliceStation : null;
  }

  @override
  Widget build(BuildContext context) {
    final station = _getStation();
    return Scaffold(
      backgroundColor: context.ground,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildHero(context, station),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 16),
                _buildQuickActions(context),
                const SizedBox(height: 16),
                _buildAddressCard(context, station),
                const SizedBox(height: 16),
                _buildContactCard(context, station),
                const SizedBox(height: 16),
                _buildSHOCard(context, station),
                const SizedBox(height: 16),
                _buildTimingsCard(context),
                const SizedBox(height: 24),
                Text('Services Available', style: AppTextStyles.screenTitle(color: context.textPri)),
                const SizedBox(height: 12),
                _buildServicesGrid(context),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context, PoliceStation? station) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      color: isDark ? AppColors.darkSurface : AppColors.lal,
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 32),
      child: Column(
        children: [
          Row(
            children: [
              InkWell(
                onTap: () => Navigator.of(context).pop(),
                child: Icon(Icons.arrow_back, color: isDark ? AppColors.darkSandGlow : AppColors.sandXlt),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.malachite, AppColors.malachiteLt],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.malachite.withValues(alpha: 0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(Icons.shield, size: 36, color: isDark ? AppColors.darkSandGlow : Colors.white),
          ),
          const SizedBox(height: 16),
          Text(station?.name ?? 'Unknown Station', style: AppTextStyles.screenTitle(color: isDark ? AppColors.darkSandGlow : Colors.white).copyWith(fontSize: 24), textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text('${station?.district ?? 'Unknown'} District', style: AppTextStyles.bodySmall(color: isDark ? AppColors.darkMalachite : AppColors.malachiteLt).copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return FadeSlide(
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(Icons.navigation, color: Colors.blue[700]),
                  const SizedBox(height: 8),
                  Text('Directions', style: AppTextStyles.bodySmall(color: Colors.blue[700]).copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.purple.withValues(alpha: 0.1),
                border: Border.all(color: Colors.purple.withValues(alpha: 0.2)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(Icons.copy, color: Colors.purple[700]),
                  const SizedBox(height: 8),
                  Text('Copy', style: AppTextStyles.bodySmall(color: Colors.purple[700]).copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(BuildContext context, PoliceStation? station) {
    return FadeSlide(
      delay: const Duration(milliseconds: 50),
      child: PietraCard(
        accentColor: Colors.transparent,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.raised,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.location_on, color: context.textSec),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Address', style: AppTextStyles.body(color: context.textPri).copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(station?.address ?? 'Address not available', style: AppTextStyles.bodySmall(color: context.textSec)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.copy, size: 14),
                          label: const Text('Copy Address'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: context.textPri,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            side: BorderSide(color: context.border),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.open_in_new, size: 14),
                          label: const Text('Open in Maps'),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.blue.withValues(alpha: 0.1),
                            foregroundColor: Colors.blue[700],
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
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
  }

  Widget _buildContactCard(BuildContext context, PoliceStation? station) {
    final List<String> phones = station?.phone ?? [];
    return FadeSlide(
      delay: const Duration(milliseconds: 100),
      child: PietraCard(
        accentColor: Colors.transparent,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.teal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.phone, color: Colors.teal[600]),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Contact Numbers', style: AppTextStyles.body(color: context.textPri).copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...phones.map((phone) {
                    final isMobile = phone.length == 10 && !phone.startsWith('011');
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.teal.withValues(alpha: 0.05),
                        border: Border.all(color: Colors.teal.withValues(alpha: 0.2)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.phone, size: 16, color: Colors.teal[600]),
                          const SizedBox(width: 8),
                          Text(phone, style: AppTextStyles.bodySmall(color: Colors.teal[900]).copyWith(fontWeight: FontWeight.bold)),
                          if (isMobile) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                              child: Text('SHO', style: AppTextStyles.bodySmall(color: Colors.blue[700]).copyWith(fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          ],
                          const Spacer(),
                          Icon(Icons.call_made, size: 16, color: Colors.teal[600]),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSHOCard(BuildContext context, PoliceStation? station) {
    return FadeSlide(
      delay: const Duration(milliseconds: 150),
      child: PietraCard(
        accentColor: Colors.transparent,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.person, color: Colors.orange[600]),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Station House Officer', style: AppTextStyles.body(color: context.textPri).copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(station?.shoName ?? 'Not Available', style: AppTextStyles.bodySmall(color: context.textSec)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimingsCard(BuildContext context) {
    return FadeSlide(
      delay: const Duration(milliseconds: 200),
      child: PietraCard(
        accentColor: Colors.transparent,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.schedule, color: Colors.blue[600]),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Timings', style: AppTextStyles.body(color: context.textPri).copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Open 24 hours', style: AppTextStyles.bodySmall(color: context.textSec)),
                  Text('FIR registration available round the clock', style: AppTextStyles.bodySmall(color: context.textDim)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesGrid(BuildContext context) {
    final services = [
      "FIR Registration",
      "Zero FIR",
      "Character Certificate",
      "Tenant Verification",
      "Passport Verification",
      "Lost & Found",
      "Women's Help Desk",
      "Cyber Crime Help"
    ];

    return FadeSlide(
      delay: const Duration(milliseconds: 250),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 3.5,
        children: services.map((service) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: context.surface,
            border: Border.all(color: context.border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(service, style: AppTextStyles.bodySmall(color: context.textSec), maxLines: 1, overflow: TextOverflow.ellipsis),
        )).toList(),
      ),
    );
  }
}
