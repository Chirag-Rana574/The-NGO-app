import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/context_colors.dart';
import '../shared/widgets/pietra_card.dart';
import '../shared/widgets/fade_slide.dart';
import '../shared/widgets/inlay_chip.dart';
import '../shared/widgets/jaali_background.dart';
import '../shared/widgets/single_arch.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../shared/widgets/app_drawer.dart';

class DelhiHighCourtScreen extends StatefulWidget {
  const DelhiHighCourtScreen({super.key});

  @override
  State<DelhiHighCourtScreen> createState() => _DelhiHighCourtScreenState();
}

class _DelhiHighCourtScreenState extends State<DelhiHighCourtScreen> {
  String _searchQuery = '';

  final List<Map<String, dynamic>> _courtStats = [
    {'label': 'Judges', 'value': '47', 'trend': '+2'},
    {'label': 'Pending', 'value': '1.2L', 'trend': '-5%'},
    {'label': 'Daily Filing', 'value': '450+', 'trend': ''},
    {'label': 'Disposal', 'value': '380/day', 'trend': '+12%'},
  ];

  final List<Map<String, dynamic>> _updates = [
    {'title': 'E-Filing mandatory for all fresh matters from Feb 2025', 'date': 'Jan 25, 2025'},
    {'title': 'Revised court fee structure effective Jan 1, 2025', 'date': 'Jan 1, 2025'},
    {'title': 'Virtual hearing available for outstation advocates', 'date': 'Dec 15, 2024'},
  ];

  final List<Map<String, dynamic>> _services = [
    {'id': 'regular', 'label': 'Regular Court', 'desc': 'Live case status & updates', 'icon': Icons.gavel, 'color': Colors.blue, 'url': 'https://delhihighcourt.nic.in'},
    {'id': 'display', 'label': 'Digital Display Board', 'desc': 'Real-time court proceedings', 'icon': Icons.video_call, 'color': Colors.red, 'badge': 'LIVE', 'url': 'https://delhihighcourt.nic.in/display_board'},
    {'id': 'filing', 'label': 'E-Filing', 'desc': 'File cases electronically', 'icon': Icons.upload_file, 'color': Colors.green, 'url': 'https://efiling.delhicourts.nic.in'},
    {'id': 'causelist', 'label': 'Cause List', 'desc': 'Daily board of matters', 'icon': Icons.list_alt, 'color': Colors.orange, 'url': 'https://delhihighcourt.nic.in/causelist'},
    {'id': 'orders', 'label': 'Orders & Judgments', 'desc': 'Search past decisions', 'icon': Icons.description, 'color': Colors.teal, 'url': 'https://delhihighcourt.nic.in/judgments'},
    {'id': 'certified', 'label': 'Certified Copies', 'desc': 'Apply for copies', 'icon': Icons.verified_user, 'color': Colors.purple, 'url': 'https://delhihighcourt.nic.in'},
    {'id': 'registrar', 'label': 'Registrar Courts', 'desc': 'Registrar cause lists', 'icon': Icons.group, 'color': Colors.blueGrey, 'url': 'https://delhihighcourt.nic.in/causelist'},
    {'id': 'egate', 'label': 'E-Gate Pass', 'desc': 'Apply for entry pass', 'icon': Icons.vpn_key, 'color': Colors.amber, 'url': 'https://delhihighcourt.nic.in'},
    {'id': 'history', 'label': 'Case History', 'desc': 'Case status history search', 'icon': Icons.history, 'color': Colors.brown, 'url': 'https://delhihighcourt.nic.in'},
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
                _buildLiveUpdates(context),
                const SizedBox(height: 16),
                _buildLiveCauseList(context),
                const SizedBox(height: 16),
                _buildStatsGrid(context),
                const SizedBox(height: 16),
                _buildSearchBar(context),
                const SizedBox(height: 24),
                Text('Recent Updates', style: AppTextStyles.screenTitle(color: context.textPri)),
                const SizedBox(height: 12),
                _buildRecentUpdates(context),
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
                      child: Icon(Icons.account_balance, size: 28, color: isDark ? AppColors.darkSandGlow : Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Delhi High Court', style: AppTextStyles.screenTitle(color: isDark ? AppColors.darkSandGlow : Colors.white).copyWith(fontSize: 22)),
                          Text('Established 1966', style: AppTextStyles.bodySmall(color: isDark ? AppColors.darkTextSec : Colors.white.withValues(alpha: 0.8))),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('"सत्यमेव जयते" - Truth Alone Triumphs',
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

  Widget _buildLiveUpdates(BuildContext context) {
    return FadeSlide(
      child: PietraCard(
        accentColor: context.danger,
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: context.danger.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(Icons.notifications_active, color: context.danger, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Court Update', style: AppTextStyles.bodySmall(color: context.danger).copyWith(fontWeight: FontWeight.bold)),
                  Text('Item No. 45 in Court 1 is currently being heard.', style: AppTextStyles.bodySmall(color: context.textSec)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveCauseList(BuildContext context) {
    return FadeSlide(
      delay: const Duration(milliseconds: 100),
      child: PietraCard(
        accentColor: context.info,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.list_alt, size: 16, color: context.info),
                const SizedBox(width: 8),
                Text('Live Cause List', style: AppTextStyles.chatTitle(color: context.textPri)),
                const Spacer(),
                InlayChip(status: InlayStatus.live),
              ],
            ),
            const SizedBox(height: 12),
            _buildCauseListItem(context, 'Court 1', 'Hon\'ble Chief Justice', 'Item 45', true),
            _buildCauseListItem(context, 'Court 2', 'Hon\'ble Mr. Justice Sanjeev Sachdeva', 'Item 12', false),
          ],
        ),
      ),
    );
  }

  Widget _buildCauseListItem(BuildContext context, String court, String judge, String item, bool isActive) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Container(
            width: 4, height: 4,
            decoration: BoxDecoration(color: isActive ? context.success : context.textDim, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(court, style: AppTextStyles.bodySmall(color: context.textSec).copyWith(fontWeight: FontWeight.bold)),
                Text(judge, style: AppTextStyles.bodySmall(color: context.textSec)),
              ],
            ),
          ),
          Text(item, style: AppTextStyles.badge(color: isActive ? context.success : context.textPri)),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    return FadeSlide(
      delay: const Duration(milliseconds: 200),
      child: GridView.count(
        crossAxisCount: 4,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.8,
        children: _courtStats.map((stat) {
          final isUp = stat['trend'].toString().startsWith('+');
          return PietraCard(
            accentColor: Colors.transparent,
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(stat['value'] as String, style: AppTextStyles.statValue(color: context.primary).copyWith(fontSize: 16)),
                const SizedBox(height: 4),
                Text(stat['label'] as String, style: AppTextStyles.bodySmall(color: context.textSec).copyWith(fontSize: 10), textAlign: TextAlign.center),
                if ((stat['trend'] as String).isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(stat['trend'] as String, style: AppTextStyles.bodySmall(color: isUp ? context.success : context.danger).copyWith(fontSize: 10)),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return FadeSlide(
      delay: const Duration(milliseconds: 300),
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

  Widget _buildRecentUpdates(BuildContext context) {
    return Column(
      children: _updates.map((update) => FadeSlide(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: PietraCard(
            accentColor: Colors.transparent,
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(update['title'] as String, style: AppTextStyles.body(color: context.textPri)),
                const SizedBox(height: 4),
                Text(update['date'] as String, style: AppTextStyles.bodySmall(color: context.textSec)),
              ],
            ),
          ),
        ),
      )).toList(),
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
              context.push('/cause_lists_high');
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
            _buildContactRow(context, 'Address:', 'Sher Shah Road, New Delhi - 110003'),
            _buildContactRow(context, 'Phone:', '011-23386688', icon: Icons.phone),
            _buildContactRow(context, 'Website:', 'delhihighcourt.nic.in', icon: Icons.language),
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
