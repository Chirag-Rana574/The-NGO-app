import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/context_colors.dart';
import '../shared/widgets/lal_app_bar.dart';
import '../shared/widgets/pietra_card.dart';
import '../shared/widgets/fade_slide.dart';
import '../shared/widgets/app_drawer.dart';

class NewCriminalLawScreen extends StatefulWidget {
  const NewCriminalLawScreen({super.key});

  @override
  State<NewCriminalLawScreen> createState() => _NewCriminalLawScreenState();
}

class _NewCriminalLawScreenState extends State<NewCriminalLawScreen> {
  String? _expandedLaw = 'bns';
  String _searchQuery = '';

  final lawSections = [
    {
      'id': 'bns',
      'title': 'Bharatiya Nyaya Sanhita',
      'subtitle': 'BNS 2023',
      'replaces': 'Indian Penal Code, 1860',
      'sections': '358',
      'effectiveDate': 'July 1, 2024',
      'icon': Icons.gavel,
      'keyChanges': [
        'Sedition replaced with treason provisions',
        'New offense: Organized crime (Section 111)',
        'Mob lynching criminalized (Section 103)',
        'Hit and run provisions strengthened',
        'Community service as punishment',
        'Sexual crimes against women - enhanced penalties'
      ]
    },
    {
      'id': 'bnss',
      'title': 'Bharatiya Nagarik Suraksha Sanhita',
      'subtitle': 'BNSS 2023',
      'replaces': 'Code of Criminal Procedure, 1973',
      'sections': '531',
      'effectiveDate': 'July 1, 2024',
      'icon': Icons.shield,
      'keyChanges': [
        'Zero FIR mandatory across India',
        'Videography of search & seizure mandatory',
        '90 days custody limit (was 60)',
        'Electronic summons valid',
        'Mercy petitions - 30 day time limit',
        'Forensic investigation for 7+ year offenses'
      ]
    },
    {
      'id': 'bsa',
      'title': 'Bharatiya Sakshya Adhiniyam',
      'subtitle': 'BSA 2023',
      'replaces': 'Indian Evidence Act, 1872',
      'sections': '170',
      'effectiveDate': 'July 1, 2024',
      'icon': Icons.description,
      'keyChanges': [
        'Electronic records as primary evidence',
        'DNA, fingerprints admissible',
        'Joint trials provision',
        'Secondary evidence rules updated',
        'Oral evidence through electronic means',
        'Digital signature recognition'
      ]
    }
  ];

  final comparisonHighlights = [
    {
      'topic': 'FIR Filing',
      'old': 'Section 154 CrPC - Physical FIR',
      'new': 'Section 173 BNSS - Zero FIR + Electronic FIR'
    },
    {
      'topic': 'Arrest Procedure',
      'old': 'Section 41 CrPC - General provisions',
      'new': 'Section 35 BNSS - Mandatory grounds disclosure + family notification'
    },
    {
      'topic': 'Bail Hearing',
      'old': 'Section 437 CrPC - No timeline',
      'new': 'Section 480 BNSS - Hearing within 30 days'
    },
    {
      'topic': 'Sedition',
      'old': 'Section 124A IPC - Sedition offense',
      'new': 'Removed - replaced by Section 152 BNS'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredLawSections = _searchQuery.isEmpty
        ? lawSections
        : lawSections.where((law) {
            final title = (law['title'] as String).toLowerCase();
            final subtitle = (law['subtitle'] as String).toLowerCase();
            final replaces = (law['replaces'] as String).toLowerCase();
            final changes = (law['keyChanges'] as List<String>).any((c) => c.toLowerCase().contains(_searchQuery.toLowerCase()));
            final query = _searchQuery.toLowerCase();
            return title.contains(query) || subtitle.contains(query) || replaces.contains(query) || changes;
          }).toList();

    final filteredComparison = _searchQuery.isEmpty
        ? comparisonHighlights
        : comparisonHighlights.where((item) {
            final topic = item['topic']!.toLowerCase();
            final oldVal = item['old']!.toLowerCase();
            final newVal = item['new']!.toLowerCase();
            final query = _searchQuery.toLowerCase();
            return topic.contains(query) || oldVal.contains(query) || newVal.contains(query);
          }).toList();

    return Scaffold(
      backgroundColor: context.ground,
      drawer: const AppDrawer(),
      appBar: const LalAppBar(title: 'New Criminal Law'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FadeSlide(
            delay: const Duration(milliseconds: 100),
            child: _buildAlertBanner(context),
          ),
          const SizedBox(height: 16),
          FadeSlide(
            delay: const Duration(milliseconds: 200),
            child: _buildSearch(context),
          ),
          const SizedBox(height: 16),
          if (filteredLawSections.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Text('No laws found matching "$_searchQuery"', style: AppTextStyles.bodySmall(color: context.textSec)),
              ),
            )
          else
            ...filteredLawSections.asMap().entries.map((entry) {
              return FadeSlide(
                key: ValueKey(entry.value['id']),
                delay: Duration(milliseconds: 300 + (entry.key * 100)),
                child: _buildLawCard(context, entry.value),
              );
            }),
          const SizedBox(height: 24),
          FadeSlide(
            delay: const Duration(milliseconds: 600),
            child: _buildComparison(context, filteredComparison),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildAlertBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.isDark ? context.raised : const Color(0xFFFFF8E1),
        border: Border.all(color: context.isDark ? context.border : const Color(0xFFFFD54F)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, size: 20, color: context.isDark ? context.accent : Colors.amber[800]),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Important Update', style: AppTextStyles.chatTitle(color: context.isDark ? context.textPri : Colors.amber[900])),
                const SizedBox(height: 4),
                Text('These laws are now in force. All new cases are registered under BNS/BNSS. Old cases continue under IPC/CrPC.',
                  style: AppTextStyles.bodySmall(color: context.isDark ? context.textSec : Colors.amber[900]),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSearch(BuildContext context) {
    return TextField(
      onChanged: (val) {
        setState(() {
          _searchQuery = val;
        });
      },
      decoration: const InputDecoration(
        hintText: 'Search sections or topics...',
        prefixIcon: Icon(Icons.search, size: 20),
      ),
      style: AppTextStyles.body(color: context.textPri),
    );
  }

  Widget _buildLawCard(BuildContext context, Map<String, dynamic> law) {
    final isExpanded = _expandedLaw == law['id'];
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: PietraCard(
        accentColor: context.info,
        padding: const EdgeInsets.all(0),
        child: Column(
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  _expandedLaw = isExpanded ? null : law['id'] as String;
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: context.isDark ? context.surface : AppColors.marble,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(law['icon'] as IconData, color: context.info),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(law['title'] as String, style: AppTextStyles.chatTitle(color: context.textPri)),
                          const SizedBox(height: 2),
                          Text(law['subtitle'] as String, style: AppTextStyles.bodySmall(color: context.info).copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          Text('Replaces: ${law['replaces']}', style: AppTextStyles.bodySmall(color: context.textSec)),
                        ],
                      ),
                    ),
                    Icon(
                      isExpanded ? Icons.keyboard_arrow_down : Icons.chevron_right,
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
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.description, size: 14, color: context.textSec),
                        const SizedBox(width: 4),
                        Text('${law['sections']} Sections', style: AppTextStyles.bodySmall(color: context.textSec)),
                        const SizedBox(width: 16),
                        Icon(Icons.calendar_today, size: 14, color: context.textSec),
                        const SizedBox(width: 4),
                        Text('${law['effectiveDate']}', style: AppTextStyles.bodySmall(color: context.textSec)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text('Key Changes:', style: AppTextStyles.chatTitle(color: context.textPri)),
                    const SizedBox(height: 8),
                    ...(law['keyChanges'] as List<String>).map((change) => Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check_circle, size: 14, color: context.success),
                          const SizedBox(width: 8),
                          Expanded(child: Text(change, style: AppTextStyles.bodySmall(color: context.textSec))),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparison(BuildContext context, List<Map<String, String>> filteredComparison) {
    if (filteredComparison.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.compare_arrows, color: context.primary),
            const SizedBox(width: 8),
            Text('Quick Comparison', style: AppTextStyles.displayItalic().copyWith(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 12),
        ...filteredComparison.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: PietraCard(
            accentColor: Colors.transparent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['topic']!, style: AppTextStyles.chatTitle(color: context.textPri)),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(color: context.danger.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(2)),
                      child: Text('OLD', style: AppTextStyles.badge(color: context.danger)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(item['old']!, style: AppTextStyles.bodySmall(color: context.textSec))),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(color: context.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(2)),
                      child: Text('NEW', style: AppTextStyles.badge(color: context.success)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(item['new']!, style: AppTextStyles.body(color: context.textPri))),
                  ],
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }
}
