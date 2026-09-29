import 'package:flutter_test/flutter_test.dart';
import 'package:teleprompter_free/data/models/script_model.dart';

void main() {
  group('ScriptModel Tests', () {
    test('Calculates word count correctly', () {
      final script = ScriptModel(
        id: '1',
        title: 'Judul Uji Coba',
        content: 'Halo teman-teman selamat datang di channel ini',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(script.wordCount, equals(7));
      expect(script.estimatedReadTime, equals('1 mnt baca'));
    });

    test('Serialization toMap and fromMap works seamlessly', () {
      final now = DateTime.now();
      final script = ScriptModel(
        id: 'script_123',
        title: 'Naskah YouTube',
        content: 'Konten naskah testing',
        scrollSpeed: 55.0,
        fontSize: 26.0,
        bgOpacity: 0.8,
        readingWidthFactor: 0.9,
        isMirrored: true,
        countdownSeconds: 5,
        createdAt: now,
        updatedAt: now,
      );

      final map = script.toMap();
      final restored = ScriptModel.fromMap(map);

      expect(restored.id, equals('script_123'));
      expect(restored.title, equals('Naskah YouTube'));
      expect(restored.content, equals('Konten naskah testing'));
      expect(restored.scrollSpeed, equals(55.0));
      expect(restored.fontSize, equals(26.0));
      expect(restored.bgOpacity, equals(0.8));
      expect(restored.readingWidthFactor, equals(0.9));
      expect(restored.isMirrored, isTrue);
      expect(restored.countdownSeconds, equals(5));
    });

    test('copyWith updates properties properly', () {
      final original = ScriptModel(
        id: '1',
        title: 'Old Title',
        content: 'Old Content',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final updated = original.copyWith(title: 'New Title', scrollSpeed: 60.0);
      expect(updated.title, equals('New Title'));
      expect(updated.scrollSpeed, equals(60.0));
      expect(updated.content, equals('Old Content'));
    });
  });
}
