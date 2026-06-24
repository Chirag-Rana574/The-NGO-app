import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_text_styles.dart';
import '../theme/context_colors.dart';
import '../shared/widgets/lal_app_bar.dart';
import '../shared/widgets/pietra_card.dart';
import '../shared/widgets/fade_slide.dart';
import '../shared/widgets/app_drawer.dart';
import '../data/providers/bare_acts_provider.dart';

class BareActsScreen extends ConsumerStatefulWidget {
  const BareActsScreen({super.key});

  @override
  ConsumerState<BareActsScreen> createState() => _BareActsScreenState();
}

class _BareActsScreenState extends ConsumerState<BareActsScreen> {
  String _activeCategory = 'All';
  final categories = ['All', 'Criminal', 'Civil', 'Corporate', 'Labor'];
  String _searchQuery = '';
  final Map<String, bool> _expandedState = {
    'criminal': true,
    'civil': true,
    'corporate': true,
    'labor': true,
    'other': true,
  };

  @override
  Widget build(BuildContext context) {
    final acts = ref.watch(bareActsListingProvider);
    
    // Apply search query filter
    final filteredActs = _searchQuery.isEmpty
        ? acts
        : acts.where((a) => a.name.toLowerCase().contains(_searchQuery.toLowerCase()) || a.category.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    
    // Apply horizontal filter category click
    final displayActs = _activeCategory == 'All'
        ? filteredActs
        : filteredActs.where((a) {
            String searchCat = _activeCategory.toLowerCase();
            if (searchCat == 'corporate') searchCat = 'company';
            if (searchCat == 'labor') searchCat = 'labour';
            return a.category.toLowerCase() == searchCat;
          }).toList();

    // Group display acts by category for the accordion
    final Map<String, List<BareAct>> groupedActs = {
      'criminal': [],
      'civil': [],
      'corporate': [],
      'labor': [],
      'other': [],
    };

    for (final act in displayActs) {
      final cat = act.category.toLowerCase();
      if (cat.contains('crim')) {
        groupedActs['criminal']!.add(act);
      } else if (cat.contains('civil') || cat.contains('procedure')) {
        groupedActs['civil']!.add(act);
      } else if (cat.contains('corp') || cat.contains('company') || cat.contains('contract')) {
        groupedActs['corporate']!.add(act);
      } else if (cat.contains('lab') || cat.contains('work')) {
        groupedActs['labor']!.add(act);
      } else {
        groupedActs['other']!.add(act);
      }
    }

    return Scaffold(
      backgroundColor: context.ground,
      drawer: const AppDrawer(),
      appBar: const LalAppBar(title: 'Bare Acts & Rules'),
      body: Column(
        children: [
          FadeSlide(
            delay: const Duration(milliseconds: 100),
            child: _buildSearchBar(context),
          ),
          FadeSlide(
            delay: const Duration(milliseconds: 200),
            child: _buildCategoryFilters(context),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: displayActs.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    children: [
                      if (groupedActs['criminal']!.isNotEmpty)
                        _buildCategorySection(context, 'Criminal Law', 'criminal', Icons.gavel, Colors.red, groupedActs['criminal']!),
                      if (groupedActs['civil']!.isNotEmpty)
                        _buildCategorySection(context, 'Civil Law', 'civil', Icons.balance, Colors.blue, groupedActs['civil']!),
                      if (groupedActs['corporate']!.isNotEmpty)
                        _buildCategorySection(context, 'Corporate Law', 'corporate', Icons.business, Colors.indigo, groupedActs['corporate']!),
                      if (groupedActs['labor']!.isNotEmpty)
                        _buildCategorySection(context, 'Labor Law', 'labor', Icons.work, Colors.orange, groupedActs['labor']!),
                      if (groupedActs['other']!.isNotEmpty)
                        _buildCategorySection(context, 'Other Regulations', 'other', Icons.receipt_long, Colors.grey, groupedActs['other']!),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: (val) => setState(() => _searchQuery = val),
        decoration: InputDecoration(
          hintText: 'Search bare acts, rules...',
          hintStyle: AppTextStyles.bodySec(color: context.textSec),
          prefixIcon: Icon(Icons.search, size: 20, color: context.textSec),
          filled: true,
          fillColor: context.raised,
        ),
        style: AppTextStyles.body(color: context.textPri),
      ),
    );
  }

  Widget _buildCategoryFilters(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: categories.map((cat) {
          final isActive = cat == _activeCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              onTap: () => setState(() => _activeCategory = cat),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? context.primary : context.raised,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive ? context.primary : context.border,
                  ),
                ),
                child: Text(
                  cat,
                  style: AppTextStyles.bodySmall(
                    color: isActive ? context.sandGlow : context.textPri,
                  ).copyWith(fontWeight: isActive ? FontWeight.bold : FontWeight.normal),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategorySection(
    BuildContext context, 
    String title, 
    String key, 
    IconData icon, 
    Color color, 
    List<BareAct> acts
  ) {
    final isExpanded = _expandedState[key] ?? true;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: context.border, width: 0.5),
        ),
        child: Column(
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  _expandedState[key] = !isExpanded;
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(icon, size: 20, color: color),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: AppTextStyles.chatTitle(color: context.textPri).copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${acts.length} acts available',
                            style: AppTextStyles.bodySmall(color: context.textSec),
                          ),
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Column(
                  children: acts.map((act) => _buildActCard(context, act, color)).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActCard(BuildContext context, BareAct act, Color themeColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
      child: InkWell(
        onTap: () {
          final nav = GoRouter.of(context);
          nav.push('/bare_act_detail', extra: act);
        },
        child: PietraCard(
          accentColor: act.isActive ? context.success : Colors.transparent,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      act.name,
                      style: AppTextStyles.chatTitle(color: context.textPri).copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: themeColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            act.year.toString(),
                            style: TextStyle(color: themeColor, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '· ${act.sectionsCount > 0 ? act.sectionsCount : "350+"} Sections',
                          style: AppTextStyles.bodySmall(color: context.textSec),
                        ),
                        const SizedBox(width: 8),
                        _buildStatusBadge(act.isActive),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              if (act.fullTextUrl != null && act.fullTextUrl!.isNotEmpty)
                IconButton(
                  onPressed: () async {
                    final url = Uri.parse(act.fullTextUrl!);
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    }
                  },
                  icon: Icon(Icons.open_in_new, size: 18, color: context.textSec),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isActive ? 'In Force' : 'Repealed',
        style: TextStyle(
          color: isActive ? Colors.green : Colors.red,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
