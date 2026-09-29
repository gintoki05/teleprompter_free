/// Model naskah teleprompter dengan pengaturan kustom per naskah
class ScriptModel {
  final String id;
  final String title;
  final String content;
  final double scrollSpeed; // Piksel per detik (20 - 150)
  final double fontSize; // Ukuran font (16 - 44)
  final double bgOpacity; // Transparansi latar prompter (0.1 - 1.0)
  final double readingWidthFactor; // Rasio lebar kolom baca (0.5 - 1.0)
  final bool isMirrored; // Mode cermin horizontal
  final int countdownSeconds; // Hitung mundur sebelum start (3, 5, atau 0)
  final DateTime createdAt;
  final DateTime updatedAt;

  const ScriptModel({
    required this.id,
    required this.title,
    required this.content,
    this.scrollSpeed = 45.0,
    this.fontSize = 24.0,
    this.bgOpacity = 0.70,
    this.readingWidthFactor = 0.82,
    this.isMirrored = false,
    this.countdownSeconds = 3,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Jumlah perkiraan kata dalam naskah
  int get wordCount {
    if (content.trim().isEmpty) return 0;
    return content.trim().split(RegExp(r'\s+')).length;
  }

  /// Estimasi waktu baca (rata-rata 130 kata per menit)
  String get estimatedReadTime {
    final words = wordCount;
    if (words == 0) return '0 mnt';
    final minutes = (words / 130).ceil();
    return '$minutes mnt baca';
  }

  ScriptModel copyWith({
    String? id,
    String? title,
    String? content,
    double? scrollSpeed,
    double? fontSize,
    double? bgOpacity,
    double? readingWidthFactor,
    bool? isMirrored,
    int? countdownSeconds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ScriptModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      scrollSpeed: scrollSpeed ?? this.scrollSpeed,
      fontSize: fontSize ?? this.fontSize,
      bgOpacity: bgOpacity ?? this.bgOpacity,
      readingWidthFactor: readingWidthFactor ?? this.readingWidthFactor,
      isMirrored: isMirrored ?? this.isMirrored,
      countdownSeconds: countdownSeconds ?? this.countdownSeconds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'scrollSpeed': scrollSpeed,
      'fontSize': fontSize,
      'bgOpacity': bgOpacity,
      'readingWidthFactor': readingWidthFactor,
      'isMirrored': isMirrored,
      'countdownSeconds': countdownSeconds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ScriptModel.fromMap(Map<String, dynamic> map) {
    return ScriptModel(
      id: map['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: map['title'] as String? ?? 'Tanpa Judul',
      content: map['content'] as String? ?? '',
      scrollSpeed: (map['scrollSpeed'] as num?)?.toDouble() ?? 45.0,
      fontSize: (map['fontSize'] as num?)?.toDouble() ?? 24.0,
      bgOpacity: (map['bgOpacity'] as num?)?.toDouble() ?? 0.70,
      readingWidthFactor: (map['readingWidthFactor'] as num?)?.toDouble() ?? 0.82,
      isMirrored: map['isMirrored'] as bool? ?? false,
      countdownSeconds: (map['countdownSeconds'] as num?)?.toInt() ?? 3,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
