import 'package:flutter/material.dart';
import 'package:teleprompter_free/core/theme/app_colors.dart';
import 'package:teleprompter_free/data/models/script_model.dart';
import 'package:teleprompter_free/logic/prompter_controller.dart';

class PrompterOverlay extends StatelessWidget {
  final ScriptModel script;
  final PrompterController controller;

  const PrompterOverlay({
    super.key,
    required this.script,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;

        // Narrow column calculation for eye-contact alignment near camera lens
        final readingWidth = (screenWidth * script.readingWidthFactor).clamp(260.0, 480.0);
        final boxHeight = screenHeight * 0.48; // Upper 48% of screen

        Widget textWidget = SingleChildScrollView(
          controller: controller.scrollController,
          physics: const NeverScrollableScrollPhysics(), // dikontrol oleh ticker prompter
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 120),
          child: Text(
            script.content,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textWhite,
              fontSize: controller.fontSize,
              fontWeight: FontWeight.w600,
              height: 1.45,
              letterSpacing: -0.3,
            ),
          ),
        );

        if (controller.isMirrored) {
          textWidget = Transform(
            alignment: Alignment.center,
            transform: Matrix4.diagonal3Values(-1.0, 1.0, 1.0),
            child: textWidget,
          );
        }

        return Align(
          alignment: Alignment.topCenter,
          child: Container(
            width: readingWidth,
            height: boxHeight,
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: controller.bgOpacity),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
                width: 1.2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  // Prompter text content
                  Positioned.fill(child: textWidget),

                  // Eye-contact Guide (garis halus penanda titik tatap mata)
                  Positioned(
                    top: 60,
                    left: 12,
                    right: 12,
                    child: IgnorePointer(
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.white38,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 1,
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              color: Colors.white.withValues(alpha: 0.12),
                            ),
                          ),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.white38,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Top & bottom gradient fades for smooth text emergence
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 24,
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: controller.bgOpacity),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 48,
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: controller.bgOpacity),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
