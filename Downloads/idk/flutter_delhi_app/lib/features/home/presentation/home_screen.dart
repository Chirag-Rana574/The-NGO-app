import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/jaali_background.dart';
import '../../../shared/widgets/pietra_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkGround
          : AppColors.marble,
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
                _buildStatGrid(context, ref),
                const SizedBox(height: 16),
                _buildQuickAccess(context),
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
                    Icon(Icons.menu, color: isDark ? AppColors.darkSandGlow : AppColors.sandXlt),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Delhi Legal Assistant Pro',
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
                ).animate().fadeIn(duration: const Duration(milliseconds: 500)).slideX(),
                const SizedBox(height: 4),
                Text(
                  _getDateLine(),
                  style: AppTextStyles.bodySmall(
                    color: isDark ? AppColors.darkTextSec : AppColors.sandLt,
                  ),
                ).animate().fadeIn(delay: const Duration(milliseconds: 200), duration: const Duration(milliseconds: 500)).slideX(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatGrid(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: PietraCard(
            onTap: () => context.push('/documents'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.description, color: AppColors.lal),
                const SizedBox(height: 8),
                Text(
                  'Documents',
                  style: AppTextStyles.body(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkTextPri
                        : AppColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '12 Active',
                  style: AppTextStyles.bodySmall(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkTextSec
                        : AppColors.dust,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: PietraCard(
            onTap: () => context.push('/judgments'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.gavel, color: AppColors.lal),
                const SizedBox(height: 8),
                Text(
                  'Judgments',
                  style: AppTextStyles.body(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkTextPri
                        : AppColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'View Latest',
                  style: AppTextStyles.bodySmall(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkTextSec
                        : AppColors.dust,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAccess(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Access',
          style: AppTextStyles.feedSectionTitle(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkTextPri
                : AppColors.ink,
          ),
        ).animate().fadeIn(delay: const Duration(milliseconds: 500), duration: const Duration(milliseconds: 500)).slideX(),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickAccessTile(
                title: 'Cause Lists',
                icon: Icons.list_alt,
                onTap: () => context.push('/cause-lists'),
              ).animate().fadeIn(delay: const Duration(milliseconds: 600), duration: const Duration(milliseconds: 500)).scale(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickAccessTile(
                title: 'Legal Updates',
                icon: Icons.newspaper,
                onTap: () => context.push('/legal-updates'),
              ).animate().fadeIn(delay: const Duration(milliseconds: 700), duration: const Duration(milliseconds: 500)).scale(),
            ),
          ],
        ),
      ],
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _getDateLine() {
    final now = DateTime.now();
    final formatter = DateFormat('MMMM dd, yyyy');
    return formatter.format(now);
  }
}

class _QuickAccessTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickAccessTile({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      color: isDark ? AppColors.darkRaised : AppColors.sandXlt,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(
          color: isDark ? AppColors.darkBorder : AppColors.sandLt,
          width: 0.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppColors.lal),
              const SizedBox(height: 8),
              Text(
                title,
                style: AppTextStyles.body(
                  color: isDark ? AppColors.darkTextPri : AppColors.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
