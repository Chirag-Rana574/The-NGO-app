import 'package:flutter/material.dart';
import '../../core/theme/context_colors.dart';
import '../../core/theme/motifs.dart';

/// Minimal Layout for `/minimal/*` routes
/// Features: clean design, Pietra cards, Jaali motifs, no shadows
class MinimalLayout extends StatelessWidget {
  final Widget child;
  final String? title;
  final bool showBack;
  final Widget? bottomNavigationBar;

  const MinimalLayout({
    super.key,
    required this.child,
    this.title,
    this.showBack = false,
    this.bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    // Use MediaQuery to check for web/desktop - avoid SafeArea padding on larger screens
    final isWideScreen = MediaQuery.of(context).size.width > 600;
    
    return Scaffold(
      backgroundColor: context.ground,
      appBar: title != null
          ? AppBar(
              title: Text(
                title!,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: context.textPri,
                ),
              ),
              backgroundColor: context.surface,
              foregroundColor: context.textPri,
              elevation: 0,
              leading: showBack
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    )
                  : null,
            )
          : null,
      body: Stack(
        children: [
          // Subtle Jaali pattern in background
          if (Theme.of(context).brightness == Brightness.dark)
            Positioned.fill(
              child: Opacity(
                opacity: 0.05,
                child: JaaliPattern(darkOpacity: 0.1),
              ),
            ),
          // On web/desktop, skip SafeArea to avoid unwanted padding
          if (isWideScreen)
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: child,
              ),
            )
          else
            SafeArea(
              child: child,
            ),
        ],
      ),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}