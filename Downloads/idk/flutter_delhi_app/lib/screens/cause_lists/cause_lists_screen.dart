import 'package:flutter/material.dart';

import '../../theme/app_text_styles.dart';
import '../../theme/context_colors.dart';
import '../../shared/widgets/lal_app_bar.dart';

class CauseListsScreen extends StatelessWidget {
  final String courtType; // 'supreme' or 'high'
  const CauseListsScreen({super.key, required this.courtType});

  @override
  Widget build(BuildContext context) {
    final isSupreme = courtType == 'supreme';
    final title = isSupreme ? 'Supreme Court' : 'Delhi High Court';

    return Scaffold(
      backgroundColor: context.ground,
      appBar: LalAppBar(title: '$title Cause Lists'),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.event_busy, size: 48, color: context.textDim),
              const SizedBox(height: 16),
              Text(
                'No cause lists available for recent dates',
                style: AppTextStyles.bodySec(color: context.textSec),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Cause lists are fetched from the main Cause Lists tab.\nThis screen is for court-specific browsing.',
                style: AppTextStyles.bodySmall(color: context.textDim),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
