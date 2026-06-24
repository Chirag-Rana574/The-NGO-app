import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/context_colors.dart';
import '../shared/widgets/lal_app_bar.dart';
import '../widgets/ai_chat_view.dart';

class AiChatScreen extends ConsumerWidget {
  const AiChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: context.ground,
      appBar: const LalAppBar(
        title: 'Legal AI Assistant',
        showGoldDashes: true,
      ),
      body: AiChatView(
        contextRoute: GoRouterState.of(context).uri.path,
      ),
    );
  }
}
