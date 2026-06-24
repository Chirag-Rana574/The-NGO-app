import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/providers/admin_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/context_colors.dart';
import '../shared/widgets/fade_slide.dart';
import '../shared/widgets/floating_ai_assistant.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Initialize admin data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAdminAndLoadData();
    });
  }

  Future<void> _checkAdminAndLoadData() async {
    final adminNotifier = ref.read(adminProvider.notifier);
    await adminNotifier.checkAdminStatus();
    
    if (!mounted) return;
    
    final isAdmin = ref.read(isAdminProvider);
    if (!isAdmin) {
      // Redirect non-admin users
      if (mounted) {
        context.go('/home');
      }
      return;
    }
    
    // Load data
    await adminNotifier.fetchTemplates();
    await adminNotifier.fetchCourts();
    await adminNotifier.fetchStatistics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminProvider);
    final statistics = ref.watch(adminStatisticsProvider);
    
    if (!adminState.isAdmin) {
      return Scaffold(
        backgroundColor: context.ground,
        appBar: AppBar(
          backgroundColor: context.surface,
          title: Text('Access Denied', style: AppTextStyles.screenTitle(color: context.textPri)),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, size: 64, color: context.danger),
              const SizedBox(height: 16),
              Text(
                'You do not have admin privileges',
                style: AppTextStyles.body(color: context.textPri),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: context.ground,
      appBar: AppBar(
        backgroundColor: context.surface,
        elevation: 0,
        title: Text('Admin Dashboard', style: AppTextStyles.screenTitle(color: context.textPri)),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Templates'),
            Tab(text: 'Courts'),
          ],
          labelStyle: AppTextStyles.body(color: context.textPri),
          unselectedLabelStyle: AppTextStyles.body(color: context.textSec),
          indicatorColor: AppColors.lazuli,
        ),
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(statistics),
              _buildTemplatesTab(),
              _buildCourtsTab(),
            ],
          ),
          const FloatingAiAssistant(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(AdminStatistics? statistics) {
    if (statistics == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Statistics', style: AppTextStyles.body(color: context.textPri).copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildStatsGrid(statistics),
          const SizedBox(height: 24),
          Text('Quick Actions', style: AppTextStyles.body(color: context.textPri).copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(AdminStatistics statistics) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard(
          'Templates',
          '${statistics.totalTemplates}',
          '${statistics.activeTemplates} active',
          Icons.description,
          AppColors.lazuli,
        ),
        _buildStatCard(
          'Courts',
          '${statistics.totalCourts}',
          '${statistics.activeCourts} active',
          Icons.gavel,
          Colors.purple,
        ),
        _buildStatCard(
          'Users',
          '${statistics.totalUsers}',
          'Registered',
          Icons.people,
          Colors.orange,
        ),
        _buildStatCard(
          'Documents',
          '${statistics.documentsGenerated}',
          'Generated',
          Icons.picture_as_pdf,
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, String subtitle, IconData icon, Color color) {
    return FadeSlide(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 16, color: color),
                ),
                const Spacer(),
                Icon(Icons.chevron_right, size: 16, color: context.textDim),
              ],
            ),
            const Spacer(),
            Text(value, style: AppTextStyles.screenTitle(color: context.textPri).copyWith(fontSize: 24)),
            const SizedBox(height: 4),
            Text(title, style: AppTextStyles.body(color: context.textPri).copyWith(fontWeight: FontWeight.bold)),
            Text(subtitle, style: AppTextStyles.bodySmall(color: context.textSec)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      children: [
        _buildActionTile(
          context,
          icon: Icons.add,
          iconColor: AppColors.lazuli,
          title: 'Add New Template',
          onTap: () => _showAddTemplateDialog(),
        ),
        const SizedBox(height: 12),
        _buildActionTile(
          context,
          icon: Icons.add_location,
          iconColor: Colors.purple,
          title: 'Add New Court',
          onTap: () => _showAddCourtDialog(),
        ),
        const SizedBox(height: 12),
        _buildActionTile(
          context,
          icon: Icons.refresh,
          iconColor: Colors.orange,
          title: 'Refresh Data',
          onTap: () {
            ref.read(adminProvider.notifier).fetchTemplates();
            ref.read(adminProvider.notifier).fetchCourts();
            ref.read(adminProvider.notifier).fetchStatistics();
          },
        ),
      ],
    );
  }

  Widget _buildActionTile(BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return FadeSlide(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.border),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
              const SizedBox(width: 16),
              Text(title, style: AppTextStyles.body(color: context.textPri).copyWith(fontWeight: FontWeight.bold)),
              const Spacer(),
              Icon(Icons.chevron_right, size: 16, color: context.textDim),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTemplatesTab() {
    final templates = ref.watch(templateListProvider);
    final isLoading = ref.watch(adminProvider).isLoading;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (templates.isEmpty) {
      return Center(
        child: Text(
          'No templates found',
          style: AppTextStyles.body(color: context.textSec),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: templates.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final template = templates[index];
        return FadeSlide(
          delay: Duration(milliseconds: 50 * index),
          child: _buildTemplateCard(template),
        );
      },
    );
  }

  Widget _buildTemplateCard(DocumentTemplate template) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  template.name,
                  style: AppTextStyles.body(color: context.textPri).copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Switch(
               value: template.isActive,
               onChanged: (value) {
                 ref.read(adminProvider.notifier).updateTemplate(
                   template.copyWith(isActive: value),
                 );
               },
               activeThumbColor: AppColors.lazuli,
             ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            template.description,
            style: AppTextStyles.bodySmall(color: context.textSec),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.lazuli.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  template.category,
                  style: AppTextStyles.bodySmall(color: AppColors.lazuli),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.edit, size: 18),
                onPressed: () => _showEditTemplateDialog(template),
                color: context.textSec,
              ),
              IconButton(
                icon: const Icon(Icons.delete, size: 18),
                onPressed: () => _showDeleteTemplateDialog(template),
                color: context.danger,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCourtsTab() {
    final courts = ref.watch(courtListProvider);
    final isLoading = ref.watch(adminProvider).isLoading;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (courts.isEmpty) {
      return Center(
        child: Text(
          'No courts found',
          style: AppTextStyles.body(color: context.textSec),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: courts.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final court = courts[index];
        return FadeSlide(
          delay: Duration(milliseconds: 50 * index),
          child: _buildCourtCard(court),
        );
      },
    );
  }

  Widget _buildCourtCard(CourtDirectory court) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  court.name,
                  style: AppTextStyles.body(color: context.textPri).copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Switch(
               value: court.isActive,
               onChanged: (value) {
                 ref.read(adminProvider.notifier).updateCourt(
                   court.copyWith(isActive: value),
                 );
               },
               activeThumbColor: AppColors.lazuli,
             ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            court.type,
            style: AppTextStyles.bodySmall(color: context.textSec),
          ),
          const SizedBox(height: 4),
          Text(
            '${court.city}, ${court.state}',
            style: AppTextStyles.bodySmall(color: context.textDim),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit, size: 18),
                onPressed: () => _showEditCourtDialog(court),
                color: context.textSec,
              ),
              IconButton(
                icon: const Icon(Icons.delete, size: 18),
                onPressed: () => _showDeleteCourtDialog(court),
                color: context.danger,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddTemplateDialog() {
    // TODO: Implement add template dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add template feature coming soon')),
    );
  }

  void _showEditTemplateDialog(DocumentTemplate template) {
    // TODO: Implement edit template dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit template feature coming soon')),
    );
  }

  void _showDeleteTemplateDialog(DocumentTemplate template) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Template'),
        content: Text('Are you sure you want to delete "${template.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(adminProvider.notifier).deleteTemplate(template.id);
            },
            child: Text('Delete', style: TextStyle(color: context.danger)),
          ),
        ],
      ),
    );
  }

  void _showAddCourtDialog() {
    // TODO: Implement add court dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add court feature coming soon')),
    );
  }

  void _showEditCourtDialog(CourtDirectory court) {
    // TODO: Implement edit court dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit court feature coming soon')),
    );
  }

  void _showDeleteCourtDialog(CourtDirectory court) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Court'),
        content: Text('Are you sure you want to delete "${court.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(adminProvider.notifier).deleteCourt(court.id);
            },
            child: Text('Delete', style: TextStyle(color: context.danger)),
          ),
        ],
      ),
    );
  }
}