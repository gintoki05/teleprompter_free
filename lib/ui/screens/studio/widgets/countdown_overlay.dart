import 'package:flutter/material.dart';
import 'package:teleprompter_free/core/theme/app_colors.dart';

class CountdownOverlay extends StatelessWidget {
  final int count;

  const CountdownOverlay({
    super.key,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.65),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.pureWhite, width: 3),
              ),
              child: Center(
                child: Text(
                  '$count',
                  style: const TextStyle(
                    color: AppColors.pureWhite,
                    fontSize: 54,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Bersiap Menghadap Kamera...',
              style: TextStyle(
                color: AppColors.pureWhite,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
