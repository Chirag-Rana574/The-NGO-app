import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/context_colors.dart';
import '../shared/widgets/pietra_card.dart';
import '../shared/widgets/fade_slide.dart';
import '../shared/widgets/jaali_background.dart';
import '../shared/widgets/single_arch.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../shared/widgets/app_drawer.dart';

class SupremeCourtScreen extends StatefulWidget {
  const SupremeCourtScreen({super.key});

  @override
  State<SupremeCourtScreen> createState() => _SupremeCourtScreenState();
}

class _SupremeCourtScreenState extends State<SupremeCourtScreen> {
  String _searchQuery = '';

  final List<Map<String, dynamic>> _courtStats = [
    {'label': 'Total Judges', 'value': '34', 'subtext': 'Sanctioned strength'},
    {'label': 'Chief Justice', 'value': 'Justice D.Y. Chandrachud', 'subtext': '50th CJI'},
    {'label': 'Pending Cases', 'value': '82,000+', 'subtext': 'As of Jan 2024'},
    {'label': 'Established', 'value': '1950', 'subtext': 'January 28'},
  ];



  final List<Map<String, dynamic>> _services = [
    {'label': 'Cause List', 'desc': 'Daily board of matters', 'icon': Icons.list_alt, 'color': Colors.blue, 'url': 'https://www.sci.gov.in/cause-list/'},
    {'label': 'Case Status', 'desc': 'Track case updates', 'icon': Icons.search, 'color': Colors.green, 'url': 'https://www.sci.gov.in/case-status/'},
    {'label': 'Daily Orders', 'desc': 'Recent orders', 'icon': Icons.description, 'color': Colors.purple, 'url': 'https://www.sci.gov.in/daily-order/'},
    {'label': 'Judgments', 'desc': 'Search decisions', 'icon': Icons.gavel, 'color': Colors.teal, 'url': 'https://www.sci.gov.in/judgements-case-no/'},
    {'label': 'Live Streaming', 'desc': 'Watch proceedings live', 'icon': Icons.video_call, 'color': Colors.red, 'badge': 'LIVE', 'url': 'https://www.sci.gov.in/live-streaming/'},
    {'label': 'E-Filing', 'desc': 'File cases electronically', 'icon': Icons.upload_file, 'color': Colors.orange, 'url': 'https://efiling.sci.gov.in/'},
  ];

  Future<void> _launchUrl(String urlString) async {
    final url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredServices = _services.where((s) => 
      (s['label'] as String).toLowerCase().contains(_searchQuery.toLowerCase()) || 
      (s['desc'] as String).toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();

    return Scaffold(
      backgroundColor: context.ground,
      drawer: const AppDrawer(),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildHero(context),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 16),
                _buildStatsGrid(context),
                const SizedBox(height: 16),
                _buildSearchBar(context),
                const SizedBox(height: 24),
                Text('Services', style: AppTextStyles.screenTitle(color: context.textPri)),
                const SizedBox(height: 12),
                _buildServicesGrid(context, filteredServices),
                const SizedBox(height: 24),
                _buildContactInfo(context),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lal;

    return Stack(
      children: [
        JaaliBackground(
          opacity: isDark ? 0.12 : 0.07,
          child: Container(
            width: double.infinity,
            color: surfaceColor,
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (Navigator.of(context).canPop())
                      InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        child: Icon(Icons.arrow_back, color: isDark ? AppColors.darkSandGlow : AppColors.sandXlt),
                      )
                    else
                      InkWell(
                        onTap: () => Scaffold.of(context).openDrawer(),
                        child: Icon(Icons.menu, color: isDark ? AppColors.darkSandGlow : AppColors.sandXlt),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkLazuli.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isDark ? AppColors.darkLazuli.withValues(alpha: 0.3) : AppColors.gold.withValues(alpha: 0.2)),
                      ),
                      child: Icon(Icons.balance, size: 28, color: isDark ? AppColors.darkSandGlow : Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Supreme Court', style: AppTextStyles.screenTitle(color: isDark ? AppColors.darkSandGlow : Colors.white).copyWith(fontSize: 22)),
                          Text('of India', style: AppTextStyles.bodySmall(color: isDark ? AppColors.darkTextSec : Colors.white.withValues(alpha: 0.8))),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('"यतो धर्मस्ततो जयः" - Where there is Dharma, there is Victory',
                  style: AppTextStyles.displayItalic(color: isDark ? AppColors.darkTextSec : Colors.white.withValues(alpha: 0.8)).copyWith(fontSize: 14)),
              ],
            ),
          ),
        ),
        Positioned(
          left: 0, right: 0, bottom: 18,
          child: Container(height: 1.5, color: isDark ? AppColors.darkGoldDim : AppColors.gold),
        ),
        Positioned(bottom: -1, left: 0, right: 0, child: const SingleArch(width: 120, height: 18)),
      ],
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    return FadeSlide(
      delay: const Duration(milliseconds: 100),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 2.2,
        children: _courtStats.map((stat) {
          return PietraCard(
            accentColor: Colors.transparent,
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(stat['label'] as String, style: AppTextStyles.bodySmall(color: context.primary).copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(stat['value'] as String, style: AppTextStyles.statValue()),
                const SizedBox(height: 2),
                Text(stat['subtext'] as String, style: AppTextStyles.bodySmall(color: context.textSec)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return FadeSlide(
      delay: const Duration(milliseconds: 200),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search services...',
          hintStyle: AppTextStyles.bodySec(color: context.textSec),
          prefixIcon: Icon(Icons.search, size: 20, color: context.textSec),
          filled: true,
          fillColor: context.raised,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
        style: AppTextStyles.body(color: context.textPri),
        onChanged: (val) => setState(() => _searchQuery = val),
      ),
    );
  }

  Widget _buildServicesGrid(BuildContext context, List<Map<String, dynamic>> services) {
    if (services.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(child: Text('No services found matching "$_searchQuery"', style: AppTextStyles.bodySmall(color: context.textSec))),
      );
    }
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.1,
      children: services.map((service) => FadeSlide(
        child: InkWell(
          onTap: () {
            if (service['label'] == 'Cause List') {
              context.push('/cause_lists_supreme');
            } else if (service['url'] != null) {
              _launchUrl(service['url'] as String);
            }
          },
          child: PietraCard(
            accentColor: Colors.transparent,
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (service['badge'] != null)
                  Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: service['badge'] == 'LIVE' ? context.danger.withValues(alpha: 0.1) : context.danger,
                        borderRadius: BorderRadius.circular(12),
                        border: service['badge'] == 'LIVE' ? Border.all(color: context.danger, width: 0.8) : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (service['badge'] == 'LIVE') ...[
                            const _PulsingDot(color: Colors.red),
                            const SizedBox(width: 4),
                          ],
                          Text(service['badge'] as String, style: AppTextStyles.badge(color: service['badge'] == 'LIVE' ? context.danger : context.sandGlow)),
                        ],
                      ),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (service['color'] as Color).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(service['icon'] as IconData, color: service['color'] as Color, size: 24),
                ),
                const Spacer(),
                Text(service['label'] as String, style: AppTextStyles.chatTitle(color: context.textPri)),
                Text(service['desc'] as String, style: AppTextStyles.bodySmall(color: context.textSec), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ),
      )).toList(),
    );
  }



  Widget _buildContactInfo(BuildContext context) {
    return FadeSlide(
      child: PietraCard(
        accentColor: context.info,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: context.primary),
                const SizedBox(width: 8),
                Text('Contact Information', style: AppTextStyles.chatTitle(color: context.textPri)),
              ],
            ),
            const SizedBox(height: 12),
            _buildContactRow(context, 'Address:', 'Tilak Marg, New Delhi - 110001'),
            _buildContactRow(context, 'Phone:', '011-23388922-24', icon: Icons.phone),
            _buildContactRow(context, 'Website:', 'main.sci.gov.in', icon: Icons.language),
            _buildContactRow(context, 'Timings:', 'Mon-Fri: 10:30 AM - 4:00 PM', icon: Icons.access_time),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow(BuildContext context, String label, String value, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: context.textSec),
            const SizedBox(width: 6),
          ] else
            const SizedBox(width: 20),
          Text(label, style: AppTextStyles.bodySmall(color: context.textPri).copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: AppTextStyles.bodySmall(color: context.textSec))),
        ],
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  final Color color;
  const _PulsingDot({required this.color});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.3, end: 1.0).animate(_controller),
      child: Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
