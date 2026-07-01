import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'document_controller.dart';
import '../../../data/document_registry.dart';

class DocumentSelectionScreen extends ConsumerWidget {
  const DocumentSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documentConfigs = DocumentRegistry.forms.values.map((e) => e.config).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkGround
          : AppColors.marble,
      appBar: AppBar(
        title: Text(
          'Select Document',
          style: AppTextStyles.screenTitle(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkTextPri
                : AppColors.sandXlt,
          ),
        ),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkSurface
            : AppColors.lal,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: ListView.builder(
        itemCount: documentConfigs.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final config = documentConfigs[index];
          return _DocumentCard(
            config: config,
            index: index,
          )
              .animate()
              .fadeIn(duration: 300.ms)
              .slideX(begin: 0.1, duration: 300.ms, delay: (index * 50).ms);
        },
      ),
    );
  }
}

class _DocumentCard extends ConsumerWidget {
  final DocumentConfig config;
  final int index;

  const _DocumentCard({required this.config, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkRaised
          : AppColors.sandXlt,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkBorder
              : AppColors.sandLt,
          width: 0.5,
        ),
      ),
      child: ListTile(
        title: Text(
          config.title,
          style: AppTextStyles.body(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkTextPri
                : AppColors.ink,
          ),
        ),
        subtitle: Text(
          config.description,
          style: AppTextStyles.bodySmall(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkTextSec
                : AppColors.dust,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkTextSec
              : AppColors.dust,
        ),
        onTap: () {
          ref.read(selectedDocumentConfigProvider.notifier).state = config;
          ref.read(documentFormDataProvider.notifier).state = {};
          // Navigate to document builder screen
          context.push('/document_builder', extra: config.id);
        },
      ),
    );
  }
}