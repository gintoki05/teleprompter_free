import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum PillButtonVariant { solid, outline, darkGhost }

/// Tombol kapsul minimalis sesuai panduan desain Mibu
class PillButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget? icon;
  final String label;
  final PillButtonVariant variant;
  final bool isSmall;
  final Color? customBgColor;
  final Color? customTextColor;

  const PillButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.variant = PillButtonVariant.solid,
    this.isSmall = false,
    this.customBgColor,
    this.customTextColor,
  });

  const PillButton.outline({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.isSmall = false,
    this.customBgColor,
    this.customTextColor,
  }) : variant = PillButtonVariant.outline;

  const PillButton.darkGhost({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.isSmall = false,
    this.customBgColor,
    this.customTextColor,
  }) : variant = PillButtonVariant.darkGhost;

  @override
  Widget build(BuildContext context) {
    final vPadding = isSmall ? 8.0 : 13.0;
    final hPadding = isSmall ? 14.0 : 20.0;
    final fontSize = isSmall ? 13.0 : 14.5;

    Color bgColor;
    Color fgColor;
    Border? border;

    switch (variant) {
      case PillButtonVariant.solid:
        bgColor = customBgColor ?? AppColors.pureBlack;
        fgColor = customTextColor ?? AppColors.pureWhite;
        border = null;
        break;
      case PillButtonVariant.outline:
        bgColor = customBgColor ?? Colors.transparent;
        fgColor = customTextColor ?? AppColors.textPrimary;
        border = Border.all(color: AppColors.border, width: 1.5);
        break;
      case PillButtonVariant.darkGhost:
        bgColor = customBgColor ?? Colors.white.withValues(alpha: 0.15);
        fgColor = customTextColor ?? AppColors.pureWhite;
        border = Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1.0);
        break;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: vPadding),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(999),
            border: border,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                icon!,
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: TextStyle(
                  color: fgColor,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
