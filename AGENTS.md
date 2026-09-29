# AGENTS.md — Teleprompter Free Engineering & Design Guidelines

> **Project Mandate**: Aplikasi Teleprompter Android berbasis Flutter yang **ringan**, **100% bebas iklan**, berdesain **minimalis monokrom** (bergaya *"mibu"*), dan memprioritaskan implementasi **mandiri (in-house)** daripada ketergantungan library pihak ketiga.

---

## 1. Core Principles & Philosophy

### 1.1 In-House First (Zero Bloatware)
* **Aturan Keras**: Jangan menambahkan dependensi eksternal jika dapat dibangun sendiri menggunakan kapabilitas bawaan Flutter & Dart SDK.
* **Dependensi yang Diizinkan**:
  - `camera`: Untuk interaksi hardware kamera depan & video recording.
  - `path_provider`: Untuk resolusi path direktori lokal Android.
* **Dilarang**:
  - Jangan menambah library database berat (Hive, Isar, Drift, SQLite). Gunakan Dart `File` + `dart:convert` (JSON storage).
  - Jangan menambah library UI/Widget pack (GetX UI, Fancy Containers, dsb.). Buat custom widget minimalis sendiri.
  - Jangan menambah library animasi/marquee berlebih. Gunakan Flutter `Ticker` / `AnimationController` bawaan.
  - Jangan menambah library state management kompleks (Bloc, Riverpod, Redux). Gunakan `ChangeNotifier` / `ValueNotifier`.

### 1.2 Privacy & Performance Guarantee
* **100% Offline**: Tidak ada request jaringan, analitik, pelacak, atau iklan.
* **Performa 60–120 FPS**: Auto-scrolling teks harus mulus tanpa *frame drop*. Hindari operasi I/O berat di frame render.

---

## 2. Design System Guidelines ("Mibu" Minimalist Aesthetic)

Setiap agen atau pengembang yang memodifikasi UI harus mematuhi panduan estetika berikut:

### 2.1 Palet Warna Monokrom
* **Background Utama**: Pure White (`#FFFFFF`) atau Light Surface (`#FAFAFA`).
* **Background Studio/Prompter**: Pitch Black (`#0A0A0A`) atau Deep Dark (`#121212`) untuk kontras tinggi kamera/bacaan.
* **Primary Foreground**: Jet Black (`#111111`) / Crisp White (`#FFFFFF`).
* **Muted / Secondary**: Neutral Slate (`#71717A` / `#A1A1AA`).
* **Borders**: Thin Solid (`1.5px`) warna `#E4E4E7` (light) atau `#27272A` (dark).
* **Accent (Minimal)**: Gunakan hanya untuk indikator kritis seperti Rekam Aktif (merah minimal `#EF4444`).

### 2.2 Bentuk & Geometri
* **Pill / Capsule Everywhere**: Gunakan `StadiumBorder()` atau `BorderRadius.circular(999)` untuk tombol aksi, filter tag, badge indikator, dan slider knob.
* **Sheet & Dialogs**: `BorderRadius.vertical(top: Radius.circular(24))` dengan garis tepi halus.
* **No Heavy Shadows**: Jangan gunakan drop shadow tebal/berwarna. Pertahankan tampilan flat, bersih, dengan garis tepi tegas (line art / minimal stroke).
* **Whitespace**: Berikan *padding* dan *margin* yang cukup longgar agar UI terasa lega, elegan, dan tidak sesak.

### 2.3 Solusi Eye-Contact Alignment (Kamera Depan)
* Saat membaca skrip di depan kamera depan, jangan gunakan teks selebar layar.
* Teks harus berada di dalam **kolom baca sempit (*narrow reading column*)** yang diposisikan sedekat mungkin ke lubang kamera depan (*punch hole / notch*).
* Hal ini menjaga bola mata tidak bergerak liar ke kiri dan kanan, sehingga di video Anda terlihat menatap langsung ke penonton.

---

## 3. Code Architecture & Conventions

* **`lib/core/`**: Berisi tema (`AppTheme`, `AppColors`), utilitas, dan konstanta.
* **`lib/data/`**: Model data (`ScriptModel`) dan repository lokal berbasis file JSON (`ScriptRepository`).
* **`lib/logic/`**: Controller bisnis (`PrompterController`, `ScriptsProvider`).
* **`lib/ui/`**: Widget mandiri yang dapat digunakan ulang (`PillButton`, `PillSlider`), serta screen (`HomeScreen`, `StudioScreen`).
* **Lint Compliance**: Wajib lolos `flutter analyze` tanpa warning. Selalu gunakan `const` constructor jika memungkinkan.
