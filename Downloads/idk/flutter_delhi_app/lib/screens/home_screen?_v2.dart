import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_text_styles.dart';
import '../theme/context_colors.dart';
import '../shared/widgets/pietra_card.dart';
import '../shared/widgets/fade_slide.dart';
import '../data/providers/news_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: context.ground,
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
                FadeSlide(delay: const Duration(milliseconds: 100), child: _buildStatGrid(context)),
                const SizedBox(height: 16),
                FadeSlide(delay: const Duration(milliseconds: 200), child: _buildSearchBar(context)),
                const SizedBox(height: 16),
                FadeSlide(delay: const Duration(milliseconds: 250), child: _buildQuickAccess(context)),
                const SizedBox(height: 24),
                FadeSlide(delay: const Duration(milliseconds: 300), child: _buildLatestUpdates(context, ref)),
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
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: () => Scaffold.of(context).openDrawer(),
                      child: Icon(Icons.menu, color: isDark ? AppColors.darkSandGlow : AppColors.sandXlt),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text('Legal Assistant PRO',
                        style: AppTextStyles.screenTitle(
                          color: isDark ? AppColors.darkSandGlow : AppColors.sandXlt,
                        ).copyWith(fontSize: 18),
                      ),
                    ),
                    Icon(Icons.notifications_active, color: isDark ? AppColors.darkGold : AppColors.gold),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  _getGreeting(),
                  style: AppTextStyles.displayItalic(
                    color: isDark ? AppColors.darkSandGlow : AppColors.sandXlt,
                  ).copyWith(fontSize: 22),
                ),
                const SizedBox(height: 4),
                Text(
                  _getDateLine(),
                  style: AppTextStyles.bodySmall(
                    color: isDark ? AppColors.darkTextSec : AppColors.sandLt.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 16),
                Row(children: [
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkGoldDim : AppColors.gold,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text('Updates',
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

  String _getGreeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _getDateLine() {
    return DateFormat('E, d MMM · h:mm a').format(DateTime.now());
  }

  Widget _buildStatGrid(BuildContext context) {
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
          onTap: () => context.push('/case_diary'),
          child: const _StatCardContent(
            value: '12',
            label: 'My Cases',
            trend: '↓ 1 new',
            trendPositive: false,
          ),
        ),
        PietraCard(
          accentColor: AppColors.gold,
          child: const _StatCardContent(
            value: '3',
            label: 'Hearings Today',
            trend: '↑ On track',
            trendPositive: true,
          ),
        ),
        PietraCard(
          accentColor: AppColors.gold,
          child: const _StatCardContent(
            value: '7',
            label: 'Alerts',
            trend: '↓ Unread',
            trendPositive: false,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return PietraCard(
      accentColor: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      onTap: () => context.push('/chat'),
      child: Row(
        children: [
          Icon(Icons.search, size: 16, color: context.textSec),
          const SizedBox(width: 8),
          const Expanded(child: Text('Search cases, laws...', style: TextStyle(fontSize: 13))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: context.primary,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text('AI', style: TextStyle(fontSize: 11, color: Colors.white)),
          )
        ],
      ),
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
        _buildNavCard(context, 'Supreme\nCourt', 'Cause list today', Icons.account_balance, '/cause_lists_supreme', 'LIVE'),
        _buildNavCard(context, 'Delhi HC', 'Cause list today', Icons.business, '/cause_lists_high', null),
        _buildNavCard(context, 'Criminal Laws', 'BNS / BNSS / BSA', Icons.menu_book, '/new_criminal_law', 'NEW'),
        _buildNavCard(context, 'Doc Builder', 'Vakalatnama & more', Icons.edit_document, '/document_builder', null),
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
      onTap: () {
        final target = route;
        if (route.contains('_supreme')) {
          context.push('/cause_lists_supreme');
        } else if (route.contains('_high')) {
          context.push('/cause_lists_high');
        } else {
          context.push(route);
        }
      },
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
          Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey), maxLines: 2),
          if (badge != null) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: context.success,
                borderRadius: BorderRadius.circular(2),
              ),
              child: Text(badge, style: const TextStyle(fontSize: 10, color: Colors.white)),
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
            Row(
              children: [
                Text('See all', style: AppTextStyles.sectionLabel()),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward, size: 12, color: context.accentDim),
              ],
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
  const _StatCardContent({required this.value, required this.label, required this.trend, required this.trendPositive});

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
        Text(trend,
          style: AppTextStyles.stat(
            color: trendPositive
              ? (isDark ? AppColors.darkMalachite : AppColors.malachite)
              : (isDark ? AppColors.darkLal : AppColors.lalLt),
          )),
      ],
    );
  }
}
