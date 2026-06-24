import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

enum InlayStatus { live, newFeature, processing, soon }

class InlayChip extends StatefulWidget {
  final InlayStatus status;
  final String? label;

  const InlayChip({super.key, required this.status, this.label});

  @override
  State<InlayChip> createState() => _InlayChipState();
}

class _InlayChipState extends State<InlayChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulse = Tween<double>(begin: 1.0, end: 1.35).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );

    if (widget.status == InlayStatus.live) {
      _ctrl.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cfg = _config(isDark);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: cfg.fill,
        border: Border.all(color: cfg.border, width: 1),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.status == InlayStatus.live) ...[
            AnimatedBuilder(
              animation: _pulse,
              builder: (_, __) => Transform.scale(
                scale: _pulse.value,
                child: Container(
                  width: 5, height: 5,
                  decoration: BoxDecoration(
                    color: cfg.dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 5),
          ],
          Text(
            cfg.label,
            style: AppTextStyles.badge(color: cfg.textColor),
          ),
        ],
      ),
    );
  }

  _ChipConfig _config(bool isDark) {
    switch (widget.status) {
      case InlayStatus.live:
        return _ChipConfig(
          label:     widget.label ?? 'LIVE',
          fill:      isDark ? AppColors.darkLalDim : AppColors.lalLt.withValues(alpha: 0.15),
          border:    isDark ? AppColors.darkLal : AppColors.lalLt,
          textColor: isDark ? AppColors.darkSandGlow : AppColors.lalLt,
          dotColor:  isDark ? AppColors.darkLal : AppColors.lalLt,
        );
      case InlayStatus.newFeature:
        return _ChipConfig(
          label:     widget.label ?? 'NEW',
          fill:      isDark ? AppColors.darkMalDim : AppColors.malachite.withValues(alpha: 0.12),
          border:    isDark ? AppColors.darkMalachite : AppColors.malachite,
          textColor: isDark ? AppColors.darkMalachite : AppColors.malachite,
        );
      case InlayStatus.processing:
        return _ChipConfig(
          label:     widget.label ?? 'Processing',
          fill:      isDark ? AppColors.darkLazDim : AppColors.lazuli.withValues(alpha: 0.1),
          border:    isDark ? AppColors.darkLazuli : AppColors.lazuli,
          textColor: isDark ? AppColors.darkLazuli : AppColors.lazuli,
        );
      case InlayStatus.soon:
        return _ChipConfig(
          label:     widget.label ?? 'SOON',
          fill:      isDark ? AppColors.darkBorder : AppColors.sandLt,
          border:    isDark ? AppColors.darkBorder2 : AppColors.sandstone,
          textColor: isDark ? AppColors.darkTextSec : AppColors.dust,
        );
    }
  }
}

class _ChipConfig {
  final String label;
  final Color fill, border, textColor;
  final Color? dotColor;
  _ChipConfig({required this.label, required this.fill,
    required this.border, required this.textColor, this.dotColor});
}
