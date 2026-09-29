import 'package:flutter/material.dart';
import 'package:teleprompter_free/core/theme/app_colors.dart';
import 'package:teleprompter_free/data/models/script_model.dart';
import 'package:teleprompter_free/ui/common/pill_badge.dart';

class ScriptTile extends StatelessWidget {
  final ScriptModel script;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ScriptTile({
    super.key,
    required this.script,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1.2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header bar (Title + Action menu)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        script.title.isEmpty ? 'Tanpa Judul' : script.title,
                        style: const TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Action Buttons (Edit & Delete)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: onEdit,
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          color: AppColors.textSecondary,
                          tooltip: 'Edit Naskah',
                        ),
                        IconButton(
                          onPressed: onDelete,
                          icon: const Icon(Icons.delete_outline, size: 18),
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          color: AppColors.textMuted,
                          tooltip: 'Hapus',
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Snippet of content
                Text(
                  script.content.trim().isEmpty
                      ? 'Naskah kosong...'
                      : script.content.trim().replaceAll('\n', ' '),
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 14),
                // Bottom Badges & Play Action Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Wrap(
                      spacing: 6,
                      children: [
                        PillBadge(
                          text: '${script.wordCount} kata',
                          icon: const Icon(Icons.article_outlined, size: 12, color: AppColors.textSecondary),
                        ),
                        PillBadge(
                          text: script.estimatedReadTime,
                          icon: const Icon(Icons.timer_outlined, size: 12, color: AppColors.textSecondary),
                        ),
                        PillBadge(
                          text: '${script.scrollSpeed.toInt()} px/s',
                          icon: const Icon(Icons.speed, size: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    // Minimal Play Icon Indicator
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.pureBlack,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: AppColors.pureWhite,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
