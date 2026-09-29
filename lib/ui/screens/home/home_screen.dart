import 'package:flutter/material.dart';
import 'package:teleprompter_free/core/theme/app_colors.dart';
import 'package:teleprompter_free/data/models/script_model.dart';
import 'package:teleprompter_free/logic/scripts_provider.dart';
import 'package:teleprompter_free/ui/common/pill_badge.dart';
import 'package:teleprompter_free/ui/common/pill_button.dart';
import 'package:teleprompter_free/ui/screens/studio/studio_screen.dart';
import 'widgets/script_editor_sheet.dart';
import 'widgets/script_tile.dart';

class HomeScreen extends StatefulWidget {
  final ScriptsProvider provider;

  const HomeScreen({
    super.key,
    required this.provider,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.provider.loadScripts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openEditor([ScriptModel? script]) {
    ScriptEditorSheet.show(
      context,
      initialScript: script,
      onSave: (savedScript) {
        widget.provider.saveScript(savedScript);
      },
    );
  }

  void _openStudio(ScriptModel script) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StudioScreen(
          script: script,
          onScriptUpdated: (updatedScript) {
            widget.provider.saveScript(updatedScript);
          },
        ),
      ),
    );
  }

  void _confirmDelete(ScriptModel script) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Hapus Naskah?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Naskah "${script.title}" akan dihapus permanen dari penyimpanan HP Anda.',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          PillButton.outline(
            onPressed: () => Navigator.of(ctx).pop(),
            label: 'Batal',
            isSmall: true,
          ),
          PillButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              widget.provider.deleteScript(script.id);
            },
            label: 'Hapus',
            customBgColor: AppColors.recordRed,
            isSmall: true,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: widget.provider,
          builder: (context, _) {
            final scripts = widget.provider.filteredScripts;
            final totalCount = widget.provider.scripts.length;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top App Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Branding & Count Pill
                      Row(
                        children: [
                          const Text(
                            'teleprompter.',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.8,
                              color: AppColors.pureBlack,
                            ),
                          ),
                          const SizedBox(width: 10),
                          PillBadge(text: '$totalCount naskah'),
                        ],
                      ),
                      // Search Toggle
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _isSearching = !_isSearching;
                            if (!_isSearching) {
                              _searchController.clear();
                              widget.provider.setSearchQuery('');
                            }
                          });
                        },
                        icon: Icon(
                          _isSearching ? Icons.close : Icons.search,
                          color: AppColors.textPrimary,
                        ),
                        tooltip: 'Cari Naskah',
                      ),
                    ],
                  ),
                ),

                // Search Bar Input (When expanded)
                if (_isSearching)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: TextField(
                        controller: _searchController,
                        autofocus: true,
                        onChanged: (val) => widget.provider.setSearchQuery(val),
                        decoration: const InputDecoration(
                          hintText: 'Cari judul atau isi naskah...',
                          hintStyle: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          icon: Icon(Icons.search, size: 18, color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                  ),

                // Quick Action Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Daftar Naskah',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                      PillButton(
                        onPressed: () => _openEditor(),
                        label: 'Naskah Baru',
                        icon: const Icon(Icons.add, size: 16, color: AppColors.pureWhite),
                        isSmall: true,
                      ),
                    ],
                  ),
                ),

                // Content / List of Scripts
                Expanded(
                  child: widget.provider.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.pureBlack,
                          ),
                        )
                      : scripts.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                              itemCount: scripts.length,
                              itemBuilder: (context, index) {
                                final script = scripts[index];
                                return ScriptTile(
                                  script: script,
                                  onTap: () => _openStudio(script),
                                  onEdit: () => _openEditor(script),
                                  onDelete: () => _confirmDelete(script),
                                );
                              },
                            ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.surfaceElevated,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.menu_book_outlined,
                size: 36,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Belum Ada Naskah',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Ketik naskah YouTube Anda atau tempel dari clipboard untuk mulai rekaman.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            PillButton(
              onPressed: () => _openEditor(),
              label: 'Buat Naskah Pertama',
              icon: const Icon(Icons.add, size: 16, color: AppColors.pureWhite),
            ),
          ],
        ),
      ),
    );
  }
}
