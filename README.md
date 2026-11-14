# Chiko

Aplikasi Flutter untuk mahasiswa yang juga bekerja: **tugas** (dengan rentang mulai–selesai), **kalender** jadwal
kuliah/kerja, dan **keuangan** (akun, transaksi, kategori) — ditemani maskot Chiko yang ekspresinya mengikuti data.

Semua data disimpan **di perangkat** (SQLite lewat [drift](https://drift.simonbinder.eu/)), tanpa akun online.

## Menjalankan

Butuh Flutter 3.24+ (Dart 3.5+).

```bash
flutter pub get
flutter run
```

Setelah mengubah tabel di `lib/core/data/app_database.dart`, buat ulang kode drift:

```bash
dart run build_runner build
```

## Pemeriksaan & test

```bash
flutter analyze
dart format --set-exit-if-changed lib test integration_test
flutter test                                   # unit + widget test (database di memori)
flutter test integration_test -d windows       # ujung-ke-ujung di desktop / -d <id HP>
```

Test memakai jam tetap (Senin, 16 November 2026, 10.00) lewat `aturJam()` dan data contoh di
`test/helpers/test_app.dart`. Aplikasi sungguhan memakai `DateTime.now()`.

## Struktur

```
lib/
├── main.dart              buka database → AppServices → ChikoApp
├── app/                   app.dart · router.dart · theme.dart · app_scope.dart (AppServices + AppScope)
├── core/
│   ├── data/              app_database.dart (tabel drift + data bawaan) · aturan_error.dart
│   ├── mascot/            chiko.dart (widget maskot)
│   ├── utils/             formatters.dart (Rupiah, tanggal) · clock.dart (sekarang())
│   └── widgets/           bold.dart · app_shell.dart · aksi.dart (simpan/hapus + pesan) · swipe_to_delete.dart
└── features/
    ├── onboarding/        sambutan_page.dart (hanya muncul sekali)
    ├── dashboard/         dashboard_page.dart · chiko_mood.dart (hitungMood)
    ├── tasks/             data/ (model, store) · ui/ (daftar, form tugas, gaya warna)
    ├── calendar/          data/ (model, store, span_layout) · ui/ (kalender, form jadwal)
    ├── finance/           data/ (model, store, data bawaan) · ui/ (keuangan, form transaksi, gaya)
    └── settings/          settings_page.dart · settings_store.dart · kelola_keuangan.dart
```

**Alur data:** setiap fitur punya *store* (`ChangeNotifier`) yang membaca tabelnya ke memori. Layar membaca
store secara sinkron lewat `AppScope.of(context)` dan `ListenableBuilder`. Perubahan ditulis ke database lalu
store dimuat ulang. Aturan bisnis dicek di store dan dilempar sebagai `AturanError` (pesannya ditampilkan ke
pengguna oleh `jalankanAksi`).

Model data (`*_model.dart`) adalah Dart murni; warna dan ikon ada di file `*_style.dart` di lapisan UI.

## Rilis

- ID aplikasi: `com.chiko.app` (Android `applicationId`, iOS bundle ID, Linux). **Ganti sebelum rilis pertama
  bila kamu punya domain sendiri** — setelah terbit di toko aplikasi, ID tidak bisa diubah.
- Ikon dibuat dari `assets/icon/` dengan `dart run flutter_launcher_icons`.
- Font Fredoka & Nunito dibundel di `assets/fonts/` (lisensi SIL OFL 1.1, lihat `OFL-*.txt`).

### Tanda tangan Android

1. Buat keystore (sekali saja, simpan baik-baik — kalau hilang, update aplikasi tidak bisa diterbitkan):
   ```bash
   keytool -genkey -v -keystore %USERPROFILE%\chiko-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
2. Buat `android/key.properties` (sudah di-`.gitignore`, **jangan di-commit**):
   ```properties
   storePassword=...
   keyPassword=...
   keyAlias=upload
   storeFile=C:/Users/<kamu>/chiko-upload.jks
   ```
3. Build untuk Play Store: `flutter build appbundle` (ukuran per perangkat lebih kecil daripada APK universal).

Tanpa `key.properties`, build rilis tetap jalan tetapi ditandatangani kunci debug (ada peringatan di log) —
cukup untuk mencoba, tidak untuk diunggah.

Bila build rilis gagal dengan `package dev.flutter.plugins.integration_test does not exist` (biasanya setelah
menjalankan integration test), jalankan `flutter clean && flutter pub get` lalu build lagi.

### Web

Penyimpanan drift di web membutuhkan file `sqlite3.wasm` dan `drift_worker.js` di folder `web/`
(lihat dokumentasi drift_flutter). Target utama aplikasi ini adalah Android/iOS.

## Belum ada

- Notifikasi pengingat deadline (butuh `flutter_local_notifications` + izin notifikasi).
- Ekspor/impor (backup) data.
