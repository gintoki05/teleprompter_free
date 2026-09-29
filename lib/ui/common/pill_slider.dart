import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class PillSlider extends StatelessWidget {
  final String label;
  final String valueDisplay;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<double> onChanged;
  final bool isDark;

  const PillSlider({
    super.key,
    required this.label,
    required this.valueDisplay,
    required this.value,
    required this.min,
    required this.max,
    this.divisions,
    required this.onChanged,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? AppColors.textWhite : AppColors.textPrimary;
    final secondaryColor = isDark ? AppColors.textWhiteMuted : AppColors.textSecondary;
    final trackColor = isDark ? const Color(0xFF27272A) : AppColors.border;
    final activeColor = isDark ? AppColors.pureWhite : AppColors.pureBlack;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: secondaryColor,
                letterSpacing: -0.2,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF27272A) : AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                valueDisplay,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: activeColor,
            inactiveTrackColor: trackColor,
            thumbColor: activeColor,
            overlayColor: activeColor.withValues(alpha: 0.1),
            trackHeight: 3.5,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
          ),
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
