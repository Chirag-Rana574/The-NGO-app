import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/context_colors.dart';
import '../shared/widgets/pietra_card.dart';
import '../shared/widgets/fade_slide.dart';
import '../data/models/district_court.dart';
import 'package:url_launcher/url_launcher.dart';

class DistrictCourtDetailScreen extends StatelessWidget {
  final Object? court;

  const DistrictCourtDetailScreen({super.key, this.court});

  DistrictCourt? _getCourt() {
    return court is DistrictCourt ? court as DistrictCourt : null;
  }

  Future<void> _launchUrl(String urlString) async {
    final url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    final court = _getCourt();
    if (court == null) {
      return Scaffold(
        backgroundColor: context.ground,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Court Not Found', style: AppTextStyles.screenTitle(color: context.textPri)),
              const SizedBox(height: 8),
              Text('The requested court information is not available.', style: AppTextStyles.bodySmall(color: context.textSec)),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to District Courts'),
              )
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: context.ground,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildHero(context, court),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 16),
                _buildAddressCard(context, court),
                const SizedBox(height: 16),
                _buildContactCard(context, court),
                const SizedBox(height: 16),
                _buildBenchDetails(context, court),
                const SizedBox(height: 16),
                _buildJurisdictions(context, court),
                const SizedBox(height: 16),
                _buildCourtTypes(context, court),
                const SizedBox(height: 16),
                _buildTimingsCard(context, court),
                const SizedBox(height: 24),
                Text('Services Available', style: AppTextStyles.screenTitle(color: context.textPri)),
                const SizedBox(height: 12),
                _buildServicesGrid(context, court),
                const SizedBox(height: 16),
                _buildWebsiteCard(context, court),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context, DistrictCourt court) {
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
                colors: [AppColors.sandstone, AppColors.stone],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.sandstone.withValues(alpha: 0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(Icons.account_balance, size: 36, color: isDark ? AppColors.darkSandGlow : Colors.white),
          ),
          const SizedBox(height: 16),
          Text(court.name, style: AppTextStyles.screenTitle(color: isDark ? AppColors.darkSandGlow : Colors.white).copyWith(fontSize: 24), textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(court.description, style: AppTextStyles.bodySmall(color: isDark ? AppColors.darkTextSec : Colors.white70), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildAddressCard(BuildContext context, DistrictCourt court) {
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
                  Text(court.address, style: AppTextStyles.bodySmall(color: context.textSec)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.copy, size: 14),
                          label: const Text('Copy'),
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
                          icon: const Icon(Icons.directions, size: 14),
                          label: const Text('Directions'),
                          style: TextButton.styleFrom(
                            backgroundColor: context.primary.withValues(alpha: 0.1),
                            foregroundColor: context.primary,
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

  Widget _buildContactCard(BuildContext context, DistrictCourt court) {
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
                  Text('Contact', style: AppTextStyles.body(color: context.textPri).copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Container(
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
                        Text(court.phone, style: AppTextStyles.bodySmall(color: Colors.teal[900]).copyWith(fontWeight: FontWeight.bold)),
                        const Spacer(),
                        Icon(Icons.call_made, size: 16, color: Colors.teal[600]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenchDetails(BuildContext context, DistrictCourt court) {
    return FadeSlide(
      delay: const Duration(milliseconds: 150),
      child: PietraCard(
        accentColor: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.group, color: context.textSec, size: 20),
                const SizedBox(width: 8),
                Text('Bench Details', style: AppTextStyles.body(color: context.textPri).copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildStatBlock(context, court.benchDetails.judgeCount.toString(), 'Judges')),
                const SizedBox(width: 8),
                Expanded(child: _buildStatBlock(context, court.benchDetails.courtrooms.toString(), 'Courtrooms')),
                const SizedBox(width: 8),
                Expanded(child: _buildStatBlock(context, court.benchDetails.established, 'Established')),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatBlock(BuildContext context, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.border),
      ),
      child: Column(
        children: [
          Text(value, style: AppTextStyles.screenTitle(color: context.textPri).copyWith(fontSize: 20)),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.bodySmall(color: context.textDim)),
        ],
      ),
    );
  }

  Widget _buildJurisdictions(BuildContext context, DistrictCourt court) {
    return FadeSlide(
      delay: const Duration(milliseconds: 180),
      child: PietraCard(
        accentColor: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.map, color: context.textSec, size: 20),
                const SizedBox(width: 8),
                Text('Jurisdictions', style: AppTextStyles.body(color: context.textPri).copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: court.jurisdictions.map((j) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: context.raised,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(j, style: AppTextStyles.bodySmall(color: context.textSec)),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourtTypes(BuildContext context, DistrictCourt court) {
    return FadeSlide(
      delay: const Duration(milliseconds: 200),
      child: PietraCard(
        accentColor: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.gavel, color: context.textSec, size: 20),
                const SizedBox(width: 8),
                Text('Court Types Available', style: AppTextStyles.body(color: context.textPri).copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: court.courts.map((c) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: context.surface,
                  border: Border.all(color: context.border),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(c, style: AppTextStyles.bodySmall(color: context.textSec)),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimingsCard(BuildContext context, DistrictCourt court) {
    return FadeSlide(
      delay: const Duration(milliseconds: 220),
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
                  const SizedBox(height: 12),
                  _buildTimingRow('Mon - Fri', court.timings.weekdays, context),
                  const SizedBox(height: 8),
                  _buildTimingRow('Saturday', court.timings.saturday, context),
                  const SizedBox(height: 8),
                  _buildTimingRow('Sunday', court.timings.sunday, context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimingRow(String day, String time, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(day, style: AppTextStyles.bodySmall(color: context.textSec)),
        Text(time, style: AppTextStyles.bodySmall(color: context.textPri)),
      ],
    );
  }

  Widget _buildServicesGrid(BuildContext context, DistrictCourt court) {
    return FadeSlide(
      delay: const Duration(milliseconds: 250),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 3.5,
        children: court.services.map((service) => InkWell(
          onTap: () => _launchUrl('https://services.ecourts.gov.in/ecourtindia_v6/'),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color: context.surface,
              border: Border.all(color: context.border),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(service, style: AppTextStyles.bodySmall(color: context.textSec), maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        )).toList(),
      ),
    );
  }
  
  Widget _buildWebsiteCard(BuildContext context, DistrictCourt court) {
    return FadeSlide(
      delay: const Duration(milliseconds: 280),
      child: PietraCard(
        accentColor: Colors.transparent,
        padding: const EdgeInsets.all(16),
        onTap: () => _launchUrl('https://delhidistrictcourts.nic.in'),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Official Website', style: AppTextStyles.body(color: context.textPri).copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('delhidistrictcourts.nic.in', style: AppTextStyles.bodySmall(color: context.textSec)),
                ],
              ),
            ),
            Icon(Icons.open_in_new, color: context.textSec, size: 20),
          ],
        ),
      ),
    );
  }
}
