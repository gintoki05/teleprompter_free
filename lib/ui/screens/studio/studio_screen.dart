import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:teleprompter_free/core/theme/app_colors.dart';
import 'package:teleprompter_free/data/models/script_model.dart';
import 'package:teleprompter_free/logic/prompter_controller.dart';
import 'package:teleprompter_free/ui/common/pill_badge.dart';
import 'package:teleprompter_free/ui/common/pill_slider.dart';
import 'widgets/countdown_overlay.dart';
import 'widgets/prompter_overlay.dart';
import 'widgets/studio_controls_bar.dart';

class StudioScreen extends StatefulWidget {
  final ScriptModel script;
  final ValueChanged<ScriptModel>? onScriptUpdated;

  const StudioScreen({
    super.key,
    required this.script,
    this.onScriptUpdated,
  });

  @override
  State<StudioScreen> createState() => _StudioScreenState();
}

class _StudioScreenState extends State<StudioScreen> with SingleTickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final PrompterController _prompterController;
  late ScriptModel _currentScript;

  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _hasCamera = false;
  String? _cameraErrorMessage;

  // Recording State
  bool _isRecording = false;
  Timer? _recordingTimer;
  int _recordingSeconds = 0;

  // Countdown State
  bool _isCountingDown = false;
  int _currentCountdown = 3;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _currentScript = widget.script;
    _scrollController = ScrollController();
    _prompterController = PrompterController(
      scrollController: _scrollController,
      initialSpeed: _currentScript.scrollSpeed,
      initialFontSize: _currentScript.fontSize,
      initialBgOpacity: _currentScript.bgOpacity,
      initialMirrored: _currentScript.isMirrored,
      initialCountdown: _currentScript.countdownSeconds,
      vsync: this,
    );

    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _hasCamera = false;
          _cameraErrorMessage = 'Tidak ada sensor kamera terdeteksi.';
        });
        return;
      }

      // Prioritas: Kamera Depan (Front Camera)
      final frontCamera = cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: true,
      );

      await controller.initialize();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _cameraController = controller;
        _isCameraInitialized = true;
        _hasCamera = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasCamera = false;
        _cameraErrorMessage = 'Kamera tidak aktif atau izin belum diberikan.';
      });
      debugPrint('Camera init error: $e');
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _recordingTimer?.cancel();
    _prompterController.dispose();
    _scrollController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  void _triggerStartWithCountdown() {
    if (_isCountingDown) return;

    if (_currentScript.countdownSeconds <= 0) {
      _startRecordingAndPrompter();
      return;
    }

    setState(() {
      _isCountingDown = true;
      _currentCountdown = _currentScript.countdownSeconds;
    });

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_currentCountdown > 1) {
        setState(() {
          _currentCountdown--;
        });
      } else {
        timer.cancel();
        setState(() {
          _isCountingDown = false;
        });
        _startRecordingAndPrompter();
      }
    });
  }

  Future<void> _startRecordingAndPrompter() async {
    if (_hasCamera && _cameraController != null && _cameraController!.value.isInitialized) {
      try {
        await _cameraController!.startVideoRecording();
        setState(() {
          _isRecording = true;
          _recordingSeconds = 0;
        });

        _recordingTimer?.cancel();
        _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
          if (!mounted) return;
          setState(() {
            _recordingSeconds++;
          });
        });
      } catch (e) {
        debugPrint('Error starting video recording: $e');
      }
    }

    // Mulai auto-scroll prompter
    _prompterController.play();
  }

  Future<void> _stopRecording() async {
    _recordingTimer?.cancel();

    if (_isRecording && _cameraController != null && _cameraController!.value.isRecordingVideo) {
      try {
        final video = await _cameraController!.stopVideoRecording();
        setState(() {
          _isRecording = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.pureBlack,
              content: Text(
                'Video tersimpan: ${video.name}',
                style: const TextStyle(color: AppColors.pureWhite),
              ),
              action: SnackBarAction(
                label: 'OK',
                textColor: AppColors.pureWhite,
                onPressed: () {},
              ),
            ),
          );
        }
      } catch (e) {
        debugPrint('Error stopping video recording: $e');
      }
    } else {
      setState(() {
        _isRecording = false;
      });
    }

    _prompterController.pause();
  }

  String get _formattedRecordingDuration {
    final minutes = (_recordingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_recordingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _openSettingsModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            decoration: const BoxDecoration(
              color: AppColors.studioSurface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(top: BorderSide(color: AppColors.studioBorder, width: 1.5)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.studioBorder,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pengaturan Studio',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textWhite,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                PillSlider(
                  label: 'Kecepatan Gulir',
                  valueDisplay: '${_prompterController.speed.toInt()} px/s',
                  value: _prompterController.speed,
                  min: 20,
                  max: 120,
                  divisions: 20,
                  isDark: true,
                  onChanged: (val) {
                    _prompterController.setSpeed(val);
                    setModalState(() {});
                    _persistSettings();
                  },
                ),
                const SizedBox(height: 14),
                PillSlider(
                  label: 'Ukuran Font Teks',
                  valueDisplay: '${_prompterController.fontSize.toInt()} pt',
                  value: _prompterController.fontSize,
                  min: 16,
                  max: 42,
                  divisions: 13,
                  isDark: true,
                  onChanged: (val) {
                    _prompterController.setFontSize(val);
                    setModalState(() {});
                    _persistSettings();
                  },
                ),
                const SizedBox(height: 14),
                PillSlider(
                  label: 'Transparansi Kotak Naskah',
                  valueDisplay: '${(_prompterController.bgOpacity * 100).toInt()}%',
                  value: _prompterController.bgOpacity,
                  min: 0.2,
                  max: 1.0,
                  divisions: 8,
                  isDark: true,
                  onChanged: (val) {
                    _prompterController.setBgOpacity(val);
                    setModalState(() {});
                    _persistSettings();
                  },
                ),
                const SizedBox(height: 16),
                // Mirror mode toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Mode Cermin (Mirror Glass)',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textWhiteMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Switch(
                      value: _prompterController.isMirrored,
                      activeThumbColor: AppColors.pureWhite,
                      activeTrackColor: AppColors.pureBlack,
                      onChanged: (val) {
                        _prompterController.toggleMirror();
                        setModalState(() {});
                        _persistSettings();
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _persistSettings() {
    _currentScript = _currentScript.copyWith(
      scrollSpeed: _prompterController.speed,
      fontSize: _prompterController.fontSize,
      bgOpacity: _prompterController.bgOpacity,
      isMirrored: _prompterController.isMirrored,
    );
    widget.onScriptUpdated?.call(_currentScript);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.studioBackground,
      body: Stack(
        children: [
          // Layer 1: Camera Preview or Dark Backdrop fallback
          Positioned.fill(
            child: _hasCamera && _isCameraInitialized && _cameraController != null
                ? CameraPreview(_cameraController!)
                : _buildNoCameraBackdrop(),
          ),

          // Layer 2: Prompter Text Overlay (Anchored near camera lens)
          Positioned.fill(
            child: SafeArea(
              child: PrompterOverlay(
                script: _currentScript,
                controller: _prompterController,
              ),
            ),
          ),

          // Layer 3: Top Navigation Bar (Close button & Status badge)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () {
                          if (_isRecording) {
                            _stopRecording();
                          }
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.arrow_back, color: AppColors.pureWhite),
                        tooltip: 'Kembali',
                      ),
                    ),
                    // Eye-Contact / Camera Badge
                    PillBadge(
                      text: _hasCamera ? 'Kamera Depan Aktif' : 'Prompter Standalone',
                      icon: Icon(
                        _hasCamera ? Icons.videocam_outlined : Icons.remove_red_eye_outlined,
                        size: 13,
                        color: AppColors.pureWhite,
                      ),
                      isDark: true,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Layer 4: Bottom Floating Controls Bar
          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: SafeArea(
              child: Center(
                child: StudioControlsBar(
                  controller: _prompterController,
                  isRecording: _isRecording,
                  recordingDurationText: _formattedRecordingDuration,
                  hasCamera: _hasCamera,
                  onToggleRecord: () {
                    if (_isRecording) {
                      _stopRecording();
                    } else {
                      _triggerStartWithCountdown();
                    }
                  },
                  onOpenSettings: _openSettingsModal,
                ),
              ),
            ),
          ),

          // Layer 5: Countdown Overlay (if active)
          if (_isCountingDown)
            Positioned.fill(
              child: CountdownOverlay(count: _currentCountdown),
            ),
        ],
      ),
    );
  }

  Widget _buildNoCameraBackdrop() {
    return Container(
      color: AppColors.studioBackground,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.studioSurface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt_outlined,
                color: AppColors.textWhiteMuted,
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _cameraErrorMessage ?? 'Mode Prompter Standalone',
              style: const TextStyle(
                color: AppColors.textWhiteMuted,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
