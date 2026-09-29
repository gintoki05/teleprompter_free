import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class PillBadge extends StatelessWidget {
  final String text;
  final Widget? icon;
  final bool isDark;

  const PillBadge({
    super.key,
    required this.text,
    this.icon,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.studioBorder : AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isDark ? Colors.white12 : AppColors.border,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            icon!,
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.textWhiteMuted : AppColors.textSecondary,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}
