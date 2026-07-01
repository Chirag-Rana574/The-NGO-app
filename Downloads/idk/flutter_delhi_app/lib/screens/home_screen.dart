import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/context_colors.dart';
import '../shared/widgets/jaali_background.dart';
import '../shared/widgets/single_arch.dart';
import '../shared/widgets/pietra_card.dart';
import '../shared/widgets/fade_slide.dart';
import '../shared/widgets/app_drawer.dart';
import '../data/providers/news_provider.dart';
import '../core/network/network_provider.dart';
import '../data/providers/case_diary_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _activeNewsIndex = 0;
  Timer? _newsTimer;

  @override
  void initState() {
    super.initState();
    _startNewsTimer();
  }

  void _startNewsTimer() {
    _newsTimer?.cancel();
    _newsTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      final newsAsync = ref.read(legalNewsProvider(5));
      newsAsync.whenData((newsList) {
        if (newsList.isNotEmpty) {
          setState(() {
            _activeNewsIndex = (_activeNewsIndex + 1) % newsList.length;
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _newsTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.ground,
      drawer: const AppDrawer(),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildHero(context, ref),
          ),
          SliverToBoxAdapter(
            child: _buildNewsTicker(context),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 16),
                FadeSlide(delay: const Duration(milliseconds: 100), child: _buildWorkspaceSummary(context, ref)),
                const SizedBox(height: 16),
                FadeSlide(delay: const Duration(milliseconds: 150), child: _buildStatGrid(context, ref)),
                const SizedBox(height: 16),
                FadeSlide(delay: const Duration(milliseconds: 300), child: _buildQuickAccess(context)),
                const SizedBox(height: 24),
                FadeSlide(delay: const Duration(milliseconds: 400), child: _buildLatestUpdates(context, ref)),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lal;
    final user = ref.watch(currentUserProvider);

    return Stack(
      children: [
        JaaliBackground(
          opacity: isDark ? 0.12 : 0.07,
          child: Container(
            width: double.infinity,
            color: surfaceColor,
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top nav row
                Row(
                  children: [
                    Builder(
                      builder: (context) => InkWell(
                        onTap: () => Scaffold.of(context).openDrawer(),
                        child: Icon(Icons.menu, color: isDark ? AppColors.darkSandGlow : AppColors.sandXlt),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text('Delhi Legal Assistant Pro',
                        style: AppTextStyles.screenTitle(
                          color: isDark ? AppColors.darkSandGlow : AppColors.sandXlt,
                        ).copyWith(fontSize: 18),
                      ),
                    ),
                    Icon(Icons.notifications_active, color: isDark ? AppColors.darkGold : AppColors.gold),
                  ],
                ),
                const SizedBox(height: 24),
                // Dynamic greeting
                Text(
                  _getGreeting(user),
                  style: AppTextStyles.displayItalic(
                    color: isDark
                      ? AppColors.darkSandGlow
                      : AppColors.sandXlt,
                  ).copyWith(fontSize: 22),
                ),
                const SizedBox(height: 4),
                Text(
                  _getDateLine(),
                  style: AppTextStyles.bodySmall(
                    color: isDark
                      ? AppColors.darkTextSec
                      : AppColors.sandLt.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 16),
                Row(children: [
                  // Live dot
                  Container(
                    width: 8, height: 8,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkMalachite : AppColors.malachiteLt,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('Courts Active',
                    style: AppTextStyles.bodySmall(
                      color: isDark ? AppColors.darkTextPri : AppColors.sandXlt,
                    ).copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(width: 12),
                  // Updates badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkGoldDim : AppColors.gold,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text('5 Updates',
                      style: AppTextStyles.badge(
                        color: isDark ? AppColors.darkGold : AppColors.ink,
                      )),
                  ),
                ]),
              ],
            ),
          ),
        ),
        Positioned(
          left: 0, right: 0, bottom: 18,
          child: Container(
            height: 1.5,
            color: isDark ? AppColors.darkGoldDim : AppColors.gold,
          ),
        ),
        Positioned(
          bottom: -1, left: 0, right: 0,
          child: SingleArch(width: 120, height: 18),
        ),
      ],
    );
  }

  Widget _buildNewsTicker(BuildContext context) {
    final newsAsync = ref.watch(legalNewsProvider(5));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return newsAsync.maybeWhen(
      data: (newsList) {
        if (newsList.isEmpty) return const SizedBox.shrink();
        final currentNews = newsList[_activeNewsIndex % newsList.length];
        
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark 
                  ? [const Color(0xFF991B1B), const Color(0xFF7F1D1D)]
                  : [const Color(0xFFDC2626), const Color(0xFFB91C1C)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'LIVE',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  currentNews.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 12),
            ],
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget _buildWorkspaceSummary(BuildContext context, WidgetRef ref) {
    final cases = ref.watch(caseDiaryProvider);
    final totalCases = cases.length;
    final now = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(now);
    final todayHearings = cases.where((c) {
      final date = DateTime.tryParse(c.nextHearingDate);
      if (date == null) return false;
      return DateFormat('yyyy-MM-dd').format(date) == todayStr;
    }).length;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(context, 'My Cases', '$totalCases', '/case_diary'),
          Container(width: 1, height: 30, color: context.border),
          _buildSummaryItem(context, 'Hearings Today', '$todayHearings', '/case_diary'),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(BuildContext context, String label, String value, String route) {
    return InkWell(
      onTap: () => context.push(route),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.lal)),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.bodySmall(color: context.textSec)),
        ],
      ),
    );
  }

  Widget _buildStatGrid(BuildContext context, WidgetRef ref) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 1.6,
      children: [
        PietraCard(
          accentColor: AppColors.gold,
          onTap: () {},
          child: const _StatCardContent(
            value: '4.5Cr',
            label: 'Pending Cases',
            trend: '↑ 2.3%',
            trendPositive: false,
          ),
        ),
        PietraCard(
          accentColor: AppColors.gold,
          onTap: () {},
          child: const _StatCardContent(
            value: '1.8M',
            label: 'Advocates',
            trend: '↑ 3.5%',
            trendPositive: true,
          ),
        ),
        PietraCard(
          accentColor: AppColors.gold,
          onTap: () {},
          child: const _StatCardContent(
            value: '86K',
            label: 'Daily Disposal',
            trend: '↑ 5.2%',
            trendPositive: true,
          ),
        ),
        PietraCard(
          accentColor: AppColors.gold,
          onTap: () {},
          child: const _StatCardContent(
            value: '25K',
            label: 'Total Courts',
            trend: 'Live updates',
            trendPositive: true,
          ),
        ),
      ],
    );
  }



  Widget _buildQuickAccess(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 1.1,
      children: [
        _buildNavCard(context, 'Supreme\nCourt', 'Judgements &\norders', Icons.account_balance, '/supreme_court', null),
        _buildNavCard(context, 'Delhi HC', 'High court filings', Icons.business, '/delhi_high_court', null),
        _buildNavCard(context, 'Case Diary', 'My cases roster', Icons.book, '/case_diary', null),
        _buildNavCard(context, 'Case Docs', 'Stored pleadings', Icons.folder, '/case_documents', null),
        _buildNavCard(context, 'Judgments', 'Recent case law', Icons.gavel, '/judgments', null),
        _buildNavCard(context, 'Updates', 'Recent legal news', Icons.newspaper, '/legal_updates', null),
        _buildNavCard(context, 'Criminal Laws', 'BNS / BNSS / BSA', Icons.menu_book, '/new_criminal_law', 'NEW'),
        _buildNavCard(context, 'Doc Builder', 'Vakalatnama & more', Icons.edit_document, '/document_selection', null),
        _buildNavCard(context, 'District Courts', '11 complexes', Icons.location_city, '/district_courts', null),
        _buildNavCard(context, 'Police Admin', 'Station directory', Icons.shield, '/police_admin', null),
        _buildNavCard(context, 'Legal Forms', 'Templates', Icons.folder_special, '/legal_forms', null),
        _buildNavCard(context, 'Bare Acts', 'Legal index', Icons.receipt_long, '/bare_acts', null),
        _buildNavCard(context, 'Fee Calc', 'Court fees', Icons.calculate, '/fee_calculator', null),
        _buildNavCard(context, 'Calendar', 'Court Holidays', Icons.calendar_month, '/calendar', null),
      ],
    );
  }

  Widget _buildNavCard(BuildContext context, String title, String subtitle, IconData icon, String route, String? badge) {
    return PietraCard(
      accentColor: Colors.transparent,
      padding: const EdgeInsets.all(12),
      onTap: () => context.push(route),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: context.isDark ? AppColors.darkSurface : AppColors.marble,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(icon, size: 20, color: context.info),
          ),
          const SizedBox(height: 12),
          Text(title, style: AppTextStyles.chatTitle(color: context.textPri)),
          const SizedBox(height: 2),
          Text(subtitle, style: AppTextStyles.bodySmall(color: context.textSec), maxLines: 2),
          if (badge != null) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: context.success,
                borderRadius: BorderRadius.circular(2),
              ),
              child: Text(badge, style: AppTextStyles.badge()),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildLatestUpdates(BuildContext context, WidgetRef ref) {
    final newsAsync = ref.watch(legalNewsProvider(3));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Latest Updates', style: AppTextStyles.screenTitle(color: context.textPri)),
            InkWell(
              onTap: () => context.push('/legal_updates'),
              child: Row(
                children: [
                  Text('See all', style: AppTextStyles.sectionLabel()),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward, size: 12, color: context.accentDim),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        newsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Text('Error loading news', style: AppTextStyles.bodySmall(color: context.danger)),
          data: (newsList) {
            if (newsList.isEmpty) {
              return Text('No updates available at the moment.', style: AppTextStyles.bodySmall(color: context.textSec));
            }
            return Column(
              children: newsList.map((news) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: PietraCard(
                  accentColor: Colors.transparent,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(news.category.toUpperCase(), style: AppTextStyles.sectionLabel(color: context.primary)),
                      const SizedBox(height: 4),
                      Text(news.title, style: AppTextStyles.chatTitle(color: context.textPri)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          if (news.isBreaking) ...[
                            Container(
                              width: 6, height: 6,
                              decoration: BoxDecoration(
                                color: context.danger,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          Text(_formatTimeAgo(news.publishedAt) + (news.isBreaking ? ' · Breaking' : ''), style: AppTextStyles.bodySmall(color: context.textSec)),
                        ],
                      ),
                    ],
                  ),
                ),
              )).toList(),
            );
          },
        ),
      ],
    );
  }

  String _getGreeting(User? user) {
    final h = DateTime.now().hour;
    final name = (user != null && user.displayName != null && user.displayName!.isNotEmpty)
        ? user.displayName!
        : 'Counselor';
    if (h < 12) return 'Good morning, $name';
    if (h < 17) return 'Good afternoon, $name';
    return 'Good evening, $name';
  }

  String _getDateLine() {
    return DateFormat('E, d MMM · h:mm a').format(DateTime.now());
  }

  String _formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(date);
  }
}

class _StatCardContent extends StatelessWidget {
  final String value, label, trend;
  final bool trendPositive;
  const _StatCardContent({
    required this.value, required this.label,
    required this.trend, required this.trendPositive,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(value,
          style: AppTextStyles.statValue(
            color: isDark ? AppColors.darkGold : AppColors.lal,
          )),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.stat()),
        const SizedBox(height: 3),
        Row(
          children: [
            Icon(
              trendPositive ? Icons.trending_up : Icons.trending_down,
              color: trendPositive
                ? (isDark ? AppColors.darkMalachite : AppColors.malachite)
                : (isDark ? AppColors.darkLal : AppColors.lalLt),
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(trend,
              style: AppTextStyles.stat(
                color: trendPositive
                  ? (isDark ? AppColors.darkMalachite : AppColors.malachite)
                  : (isDark ? AppColors.darkLal : AppColors.lalLt),
              )),
          ],
        ),
      ],
    );
  }
}
