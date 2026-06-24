import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/document_registry.dart';
import '../theme/app_text_styles.dart';
import '../theme/context_colors.dart';
import '../shared/widgets/lal_app_bar.dart';
import '../shared/widgets/pietra_card.dart';

class DocumentSelectionScreen extends StatelessWidget {
  const DocumentSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = <String, List<RegistryEntry>>{};
    for (final entry in DocumentRegistry.getAll()) {
      final cat = entry.config.category;
      if (!categories.containsKey(cat)) {
        categories[cat] = [];
      }
      categories[cat]!.add(entry);
    }

    return Scaffold(
      appBar: const LalAppBar(
        title: 'Legal Documents',
        showGoldDashes: true,
      ),
      body: DefaultTabController(
        length: categories.length,
        child: Column(
          children: [
            Container(
              color: context.raised,
              child: TabBar(
                isScrollable: true,
                tabs: categories.keys.map((cat) => Tab(text: cat)).toList(),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: categories.entries.map((entry) => _buildCategoryView(context, entry.key, entry.value)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryView(BuildContext context, String category, List<RegistryEntry> forms) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: forms.length,
      itemBuilder: (context, index) {
        final form = forms[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: PietraCard(
            onTap: () {
              context.go('/document_builder', extra: form.config.id);
            },
            child: Row(
              children: [
                Icon(Icons.description, size: 32, color: context.info),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(form.config.title, style: AppTextStyles.chatTitle(color: context.textPri)),
                      const SizedBox(height: 4),
                      Text(
                        form.config.description,
                        style: AppTextStyles.bodySmall(color: context.textSec),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: context.textSec),
              ],
            ),
          ),
        );
      },
    );
  }
}