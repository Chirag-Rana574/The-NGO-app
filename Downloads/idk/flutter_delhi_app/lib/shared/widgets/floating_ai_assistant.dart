import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/context_colors.dart';
import '../../widgets/ai_chat_view.dart';

/// Floating AI Assistant widget that appears on all pages
class FloatingAiAssistant extends ConsumerStatefulWidget {
  const FloatingAiAssistant({super.key});

  @override
  ConsumerState<FloatingAiAssistant> createState() => _FloatingAiAssistantState();
}

class _FloatingAiAssistantState extends ConsumerState<FloatingAiAssistant> with SingleTickerProviderStateMixin {
  bool _isOpen = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleChat() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (_isOpen)
          Positioned(
            bottom: 80,
            right: 16,
            child: ScaleTransition(
              scale: _scaleAnimation,
              alignment: Alignment.bottomRight,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                height: MediaQuery.of(context).size.height * 0.5,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: AiChatView(
                    isMini: true,
                    onClose: _toggleChat,
                    onExpand: () {
                      _toggleChat();
                      context.push('/ai_chat');
                    },
                    contextRoute: GoRouterState.of(context).uri.path,
                  ),
                ),
              ),
            ),
          ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: _toggleChat,
            backgroundColor: context.primary,
            elevation: 8,
            child: Icon(
              _isOpen ? Icons.close : Icons.smart_toy_outlined,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}