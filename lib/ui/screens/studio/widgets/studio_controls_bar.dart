import 'package:flutter/material.dart';
import 'package:teleprompter_free/core/theme/app_colors.dart';
import 'package:teleprompter_free/logic/prompter_controller.dart';
import 'package:teleprompter_free/ui/common/pill_button.dart';

class StudioControlsBar extends StatelessWidget {
  final PrompterController controller;
  final bool isRecording;
  final String recordingDurationText;
  final bool hasCamera;
  final VoidCallback onToggleRecord;
  final VoidCallback onOpenSettings;

  const StudioControlsBar({
    super.key,
    required this.controller,
    required this.isRecording,
    required this.recordingDurationText,
    required this.hasCamera,
    required this.onToggleRecord,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final isPlaying = controller.isPlaying;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.studioSurface.withValues(alpha: 0.90),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.studioBorder, width: 1.2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Rewind / Reset button
              IconButton(
                onPressed: () => controller.reset(),
                icon: const Icon(Icons.replay, color: AppColors.textWhite, size: 20),
                tooltip: 'Ulang dari Awal',
                visualDensity: VisualDensity.compact,
              ),

              const SizedBox(width: 4),

              // Play / Pause Prompter Button
              PillButton(
                onPressed: () => controller.togglePlayPause(),
                label: isPlaying ? 'Jeda' : 'Mulai',
                icon: Icon(
                  isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  size: 18,
                  color: AppColors.pureBlack,
                ),
                customBgColor: AppColors.pureWhite,
                customTextColor: AppColors.pureBlack,
                isSmall: true,
              ),

              const SizedBox(width: 8),

              // Camera Record Button (if camera hardware is present)
              if (hasCamera) ...[
                PillButton(
                  onPressed: onToggleRecord,
                  label: isRecording ? recordingDurationText : 'Rekam',
                  icon: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: isRecording ? AppColors.pureWhite : AppColors.recordRed,
                      shape: isRecording ? BoxShape.rectangle : BoxShape.circle,
                      borderRadius: isRecording ? BorderRadius.circular(2) : null,
                    ),
                  ),
                  customBgColor: isRecording ? AppColors.recordRed : Colors.white.withValues(alpha: 0.12),
                  customTextColor: AppColors.pureWhite,
                  isSmall: true,
                ),
                const SizedBox(width: 4),
              ],

              // Settings button
              IconButton(
                onPressed: onOpenSettings,
                icon: const Icon(Icons.tune, color: AppColors.textWhite, size: 20),
                tooltip: 'Pengaturan Prompter',
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        );
      },
    );
  }
}
