import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../models/script_model.dart';

/// Repository mandiri berbasis file JSON lokal (Zero Database Bloat)
class ScriptRepository {
  static const String _fileName = 'teleprompter_scripts.json';

  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  /// Membaca semua naskah dari penyimpanan lokal
  Future<List<ScriptModel>> getAllScripts() async {
    try {
      final file = await _getFile();
      if (!await file.exists()) {
        final initialScripts = _getStarterScripts();
        await _saveToFile(file, initialScripts);
        return initialScripts;
      }

      final content = await file.readAsString();
      if (content.trim().isEmpty) {
        return [];
      }

      final List<dynamic> decoded = jsonDecode(content) as List<dynamic>;
      return decoded
          .map((item) => ScriptModel.fromMap(item as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    } catch (e) {
      debugPrint('Error reading scripts: $e');
      return _getStarterScripts();
    }
  }

  /// Menyimpan naskah baru atau memperbarui naskah yang sudah ada
  Future<void> saveScript(ScriptModel script) async {
    final file = await _getFile();
    List<ScriptModel> currentScripts = [];
    if (await file.exists()) {
      try {
        final content = await file.readAsString();
        if (content.isNotEmpty) {
          final List<dynamic> decoded = jsonDecode(content) as List<dynamic>;
          currentScripts = decoded
              .map((item) => ScriptModel.fromMap(item as Map<String, dynamic>))
              .toList();
        }
      } catch (e) {
        debugPrint('Error reading for save: $e');
      }
    }

    final index = currentScripts.indexWhere((s) => s.id == script.id);
    if (index >= 0) {
      currentScripts[index] = script.copyWith(updatedAt: DateTime.now());
    } else {
      currentScripts.insert(0, script);
    }

    await _saveToFile(file, currentScripts);
  }

  /// Menghapus naskah berdasarkan ID
  Future<void> deleteScript(String id) async {
    final file = await _getFile();
    if (!await file.exists()) return;

    final currentScripts = await getAllScripts();
    currentScripts.removeWhere((s) => s.id == id);
    await _saveToFile(file, currentScripts);
  }

  Future<void> _saveToFile(File file, List<ScriptModel> scripts) async {
    final rawList = scripts.map((s) => s.toMap()).toList();
    final jsonString = jsonEncode(rawList);
    await file.writeAsString(jsonString);
  }

  /// Contoh naskah pembuka saat pertama kali aplikasi diinstall
  List<ScriptModel> _getStarterScripts() {
    final now = DateTime.now();
    return [
      ScriptModel(
        id: 'starter_1',
        title: 'Tips Eye-Contact Kamera Depan',
        content: '''Halo semuanya! Selamat datang di Teleprompter Free.

Ini adalah contoh naskah untuk menguji posisi mata Anda saat rekaman.

Perhatikan bahwa teks ini berada tepat di bagian atas layar, sedekat mungkin dengan lubang kamera depan HP Anda.

Dengan posisi ini, mata Anda tidak perlu melirik ke bawah atau ke samping. Pandangan Anda akan terlihat 100% alami menatap langsung ke penonton YouTube Anda!

Coba atur kecepatan gulir (speed) dan ukuran huruf sesuai kenyamanan Anda di panel bawah.

Selamat berkarya dan semoga konten YouTube Anda sukses besar!''',
        scrollSpeed: 42.0,
        fontSize: 24.0,
        bgOpacity: 0.75,
        readingWidthFactor: 0.85,
        isMirrored: false,
        countdownSeconds: 3,
        createdAt: now,
        updatedAt: now,
      ),
      ScriptModel(
        id: 'starter_2',
        title: 'Formula Hook 10 Detik Pertama Video',
        content: '''Banyak kreator pemula bingung bagaimana cara membuka video YouTube agar penonton tidak kabur.

Inilah formula 3 langkah:

Langkah 1: Jangan mulai dengan basa-basi atau perkenalan panjang. Langsung sebutkan masalah utama yang dihadapi penonton.

Langkah 2: Berikan janji solusi yang akan mereka dapatkan di video ini.

Langkah 3: Tunjukkan bukti singkat atau cuplikan hasil akhir.

Mari kita bahas langkah pertamanya sekarang juga!''',
        scrollSpeed: 45.0,
        fontSize: 24.0,
        bgOpacity: 0.70,
        readingWidthFactor: 0.85,
        isMirrored: false,
        countdownSeconds: 3,
        createdAt: now.subtract(const Duration(hours: 1)),
        updatedAt: now.subtract(const Duration(hours: 1)),
      ),
    ];
  }
}
