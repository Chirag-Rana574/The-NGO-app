import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class LalAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showGoldDashes; // The repeating gold dash line

  const LalAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showGoldDashes = true,
  });

  @override
  Size get preferredSize => Size.fromHeight(
    showGoldDashes ? kToolbarHeight + 4.5 : kToolbarHeight + 1.5,
  );

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lal;
    final goldColor    = isDark ? AppColors.darkGoldDim : AppColors.gold;

    return AppBar(
      title: Text(title, style: AppTextStyles.screenTitle(
        color: isDark ? AppColors.darkSandGlow : AppColors.sandXlt,
      )),
      leading: leading ?? (Navigator.canPop(context) ? const BackButton() : null),
      actions: actions,
      backgroundColor: surfaceColor,
      iconTheme: IconThemeData(color: isDark ? AppColors.darkSandGlow : AppColors.sandXlt),
      actionsIconTheme: IconThemeData(color: isDark ? AppColors.darkSandGlow : AppColors.sandXlt),
      bottom: _LalAppBarBottom(
        goldColor: goldColor,
        surfaceColor: surfaceColor,
        showGoldDashes: showGoldDashes,
      ),
    );
  }
}

class _LalAppBarBottom extends StatelessWidget implements PreferredSizeWidget {
  final Color goldColor;
  final Color surfaceColor;
  final bool showGoldDashes;

  const _LalAppBarBottom({
    required this.goldColor,
    required this.surfaceColor,
    required this.showGoldDashes,
  });

  @override
  Size get preferredSize => Size.fromHeight(showGoldDashes ? 4.5 : 1.5);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 1.5,
          color: goldColor,
        ),
        if (showGoldDashes)
          Container(
            height: 3,
            color: surfaceColor,
            child: CustomPaint(
              painter: _DashedGoldPainter(color: goldColor),
              size: Size(MediaQuery.of(context).size.width, 3),
            ),
          ),
      ],
    );
  }
}

class _DashedGoldPainter extends CustomPainter {
  final Color color;
  _DashedGoldPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..strokeWidth = 1.5;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, size.height / 2), Offset(x + 6, size.height / 2), paint);
      x += 10;
    }
  }

  @override
  bool shouldRepaint(_DashedGoldPainter old) => old.color != color;
}
