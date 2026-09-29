import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:teleprompter_free/core/theme/app_colors.dart';
import 'package:teleprompter_free/data/models/script_model.dart';
import 'package:teleprompter_free/ui/common/pill_badge.dart';
import 'package:teleprompter_free/ui/common/pill_button.dart';
import 'package:teleprompter_free/ui/common/pill_slider.dart';

class ScriptEditorSheet extends StatefulWidget {
  final ScriptModel? initialScript;
  final ValueChanged<ScriptModel> onSave;

  const ScriptEditorSheet({
    super.key,
    this.initialScript,
    required this.onSave,
  });

  static Future<void> show(
    BuildContext context, {
    ScriptModel? initialScript,
    required ValueChanged<ScriptModel> onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ScriptEditorSheet(
        initialScript: initialScript,
        onSave: onSave,
      ),
    );
  }

  @override
  State<ScriptEditorSheet> createState() => _ScriptEditorSheetState();
}

class _ScriptEditorSheetState extends State<ScriptEditorSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late double _scrollSpeed;
  late double _fontSize;
  late double _bgOpacity;
  late bool _isMirrored;
  late int _countdownSeconds;

  @override
  void initState() {
    super.initState();
    final script = widget.initialScript;
    _titleController = TextEditingController(text: script?.title ?? '');
    _contentController = TextEditingController(text: script?.content ?? '');
    _scrollSpeed = script?.scrollSpeed ?? 45.0;
    _fontSize = script?.fontSize ?? 24.0;
    _bgOpacity = script?.bgOpacity ?? 0.70;
    _isMirrored = script?.isMirrored ?? false;
    _countdownSeconds = script?.countdownSeconds ?? 3;

    _contentController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  int get _wordCount {
    final text = _contentController.text.trim();
    if (text.isEmpty) return 0;
    return text.split(RegExp(r'\s+')).length;
  }

  String get _estimatedTime {
    final words = _wordCount;
    if (words == 0) return '0 mnt';
    final mins = (words / 130).ceil();
    return '$mins mnt';
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.isNotEmpty) {
      final currentPos = _contentController.selection.baseOffset;
      if (currentPos >= 0) {
        final currentText = _contentController.text;
        final newText = currentText.substring(0, currentPos) +
            data.text! +
            currentText.substring(_contentController.selection.extentOffset);
        _contentController.text = newText;
        _contentController.selection = TextSelection.collapsed(
          offset: currentPos + data.text!.length,
        );
      } else {
        _contentController.text = _contentController.text + data.text!;
      }
    }
  }

  void _handleSave() {
    final title = _titleController.text.trim().isEmpty
        ? 'Naskah Baru'
        : _titleController.text.trim();
    final content = _contentController.text.trim();

    final script = ScriptModel(
      id: widget.initialScript?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      content: content,
      scrollSpeed: _scrollSpeed,
      fontSize: _fontSize,
      bgOpacity: _bgOpacity,
      readingWidthFactor: widget.initialScript?.readingWidthFactor ?? 0.85,
      isMirrored: _isMirrored,
      countdownSeconds: _countdownSeconds,
      createdAt: widget.initialScript?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    widget.onSave(script);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          // Header Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.initialScript == null ? 'Tulis Naskah' : 'Edit Naskah',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.4,
                  ),
                ),
                Row(
                  children: [
                    PillButton.outline(
                      onPressed: _pasteFromClipboard,
                      label: 'Tempel',
                      icon: const Icon(Icons.content_paste_outlined, size: 14),
                      isSmall: true,
                    ),
                    const SizedBox(width: 8),
                    PillButton(
                      onPressed: _handleSave,
                      label: 'Simpan',
                      isSmall: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),
          // Content Editor
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomInset),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Input
                  TextField(
                    controller: _titleController,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Judul Naskah...',
                      hintStyle: TextStyle(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Word count / read time pills
                  Row(
                    children: [
                      PillBadge(text: '$_wordCount kata'),
                      const SizedBox(width: 6),
                      PillBadge(text: 'Est. $_estimatedTime'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  // Script Body Input
                  TextField(
                    controller: _contentController,
                    maxLines: null,
                    minLines: 8,
                    style: TextStyle(
                      fontSize: _fontSize * 0.75, // preview scale
                      height: 1.5,
                      color: AppColors.textPrimary,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Mulai ketik naskah atau tempel teks skrip YouTube Anda di sini...',
                      hintStyle: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 15,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  // Prompter Default Settings for this script
                  const Text(
                    'Pengaturan Naskah',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  PillSlider(
                    label: 'Kecepatan Gulir',
                    valueDisplay: '${_scrollSpeed.toInt()} px/s',
                    value: _scrollSpeed,
                    min: 20,
                    max: 120,
                    divisions: 20,
                    onChanged: (val) => setState(() => _scrollSpeed = val),
                  ),
                  const SizedBox(height: 12),
                  PillSlider(
                    label: 'Ukuran Font Prompter',
                    valueDisplay: '${_fontSize.toInt()} pt',
                    value: _fontSize,
                    min: 16,
                    max: 42,
                    divisions: 13,
                    onChanged: (val) => setState(() => _fontSize = val),
                  ),
                  const SizedBox(height: 12),
                  PillSlider(
                    label: 'Transparansi Latar Teks',
                    valueDisplay: '${(_bgOpacity * 100).toInt()}%',
                    value: _bgOpacity,
                    min: 0.2,
                    max: 1.0,
                    divisions: 8,
                    onChanged: (val) => setState(() => _bgOpacity = val),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
