import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/context_colors.dart';
import 'jaali_background.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lal;
    final currentRoute = GoRouterState.of(context).uri.path;

    return Drawer(
      backgroundColor: context.ground,
      child: Column(
        children: [
          // Drawer Header
          SizedBox(
            height: 180,
            child: Stack(
              children: [
                JaaliBackground(
                  opacity: isDark ? 0.12 : 0.07,
                  child: Container(
                    width: double.infinity,
                    color: surfaceColor,
                    padding: const EdgeInsets.fromLTRB(24, 64, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 48, height: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark ? AppColors.darkLalDim : AppColors.gold,
                              ),
                              child: Center(
                                child: Text('A', style: AppTextStyles.screenTitle(color: isDark ? AppColors.darkSandGlow : AppColors.lal)),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Aditi Sharma', style: AppTextStyles.screenTitle(color: context.sandGlow)),
                                  const SizedBox(height: 2),
                                  Text('Advocate, Delhi High Court', style: AppTextStyles.bodySmall(color: context.sandGlow.withValues(alpha: 0.8))),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 0, right: 0, bottom: 0,
                  child: Container(
                    height: 2,
                    color: isDark ? AppColors.darkGoldDim : AppColors.gold,
                  ),
                ),
              ],
            ),
          ),
          
          // Drawer Body
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                _buildSectionTitle(context, 'COURTS'),
                _buildDrawerItem(context, 'Supreme Court', Icons.account_balance, '/supreme_court', currentRoute),
                _buildDrawerItem(context, 'Delhi High Court', Icons.business, '/delhi_high_court', currentRoute),
                _buildDrawerItem(context, 'District Courts', Icons.location_city, '/district_courts', currentRoute),
                _buildDrawerItem(context, 'Police Admin', Icons.shield, '/police_admin', currentRoute),
                
                const SizedBox(height: 16),
                _buildSectionTitle(context, 'LEGAL REFERENCE'),
                _buildDrawerItem(context, 'New Criminal Laws', Icons.menu_book, '/new_criminal_law', currentRoute),
                _buildDrawerItem(context, 'Bare Acts', Icons.receipt_long, '/bare_acts', currentRoute),
                
                const SizedBox(height: 16),
                _buildSectionTitle(context, 'MY WORKSPACE'),
                _buildDrawerItem(context, 'My Profile', Icons.person, '/profile', currentRoute),
                _buildDrawerItem(context, 'Case Diary', Icons.book, '/case_diary', currentRoute),
                _buildDrawerItem(context, 'Case Documents', Icons.folder, '/case_documents', currentRoute),
                _buildDrawerItem(context, 'Document Builder', Icons.edit_document, '/document_builder', currentRoute),
                _buildDrawerItem(context, 'Legal Forms', Icons.folder_special, '/legal_forms', currentRoute),
                _buildDrawerItem(context, 'Court Fee Calculator', Icons.calculate, '/fee_calculator', currentRoute),
                _buildDrawerItem(context, 'Court Calendar', Icons.calendar_today, '/court_calendar', currentRoute),
              ],
            ),
          ),
          
          // Drawer Footer
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primary,
                foregroundColor: context.sandGlow,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              onPressed: () => context.go('/login'),
              child: const Text('Sign Out'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Text(
        title,
        style: AppTextStyles.label(color: context.textSec),
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, String title, IconData icon, String route, String currentRoute) {
    final isActive = currentRoute == route;
    return InkWell(
      onTap: () {
        context.pop(); // close drawer
        context.go(route);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? context.primary.withValues(alpha: 0.1) : Colors.transparent,
          border: isActive ? Border(left: BorderSide(color: context.primary, width: 4)) : null,
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: isActive ? context.primary : context.textSec),
            const SizedBox(width: 16),
            Text(title, style: AppTextStyles.body(color: isActive ? context.primary : context.textPri)),
          ],
        ),
      ),
    );
  }
}
