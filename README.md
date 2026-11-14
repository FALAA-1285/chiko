# Chiko – frontend Flutter

Isi folder ini:

```
lib/                      → kode app (6 layar + Pengaturan)
assets/chiko/             → 6 ekspresi Chiko (SVG)
pubspec_tambahan.yaml     → potongan yang perlu ditambahkan ke pubspec.yaml
```

## Cara memasang ke project Flutter-mu

1. **Backup `lib/main.dart` milikmu**, karena akan tertimpa.
2. Salin folder `lib/` dan `assets/` ke root project Flutter-mu (sejajar dengan `pubspec.yaml`).
3. Tambahkan package:
   ```bash
   flutter pub add go_router google_fonts flutter_svg
   ```
4. Daftarkan aset di `pubspec.yaml`, di bawah bagian `flutter:` (lihat `pubspec_tambahan.yaml`):
   ```yaml
   flutter:
     uses-material-design: true
     assets:
       - assets/chiko/
   ```
5. Jalankan:
   ```bash
   flutter pub get
   flutter analyze
   flutter run
   ```

Butuh **Flutter 3.24 atau lebih baru** (Dart 3.5+). Cek dengan `flutter --version`.

## Struktur

```
lib/
├── main.dart
├── app/            app.dart · router.dart (go_router, 5 tab) · theme.dart (warna & font)
├── core/
│   ├── mascot/     chiko.dart (widget Chiko) · chiko_mood.dart (hitungMood)
│   ├── utils/      formatters.dart (Rupiah, tanggal) · clock.dart (tanggal contoh)
│   └── widgets/    bold.dart (kartu & tombol khas) · app_shell.dart (navigasi bawah)
└── features/
    ├── onboarding/ sambutan_page.dart
    ├── dashboard/  dashboard_page.dart
    ├── tasks/      data/ (model + store) · ui/ (daftar tugas, task_tile)
    ├── calendar/   data/ (event_store) · ui/ (kalender, event_tile)
    ├── finance/    data/ (model + store) · ui/ (keuangan, tambah transaksi)
    └── settings/   settings_page.dart
```

## Yang sudah jalan

- Navigasi bawah 5 tab; setiap tab ingat posisinya sendiri.
- Centang tugas → progres mingguan, Beranda, dan kalender ikut berubah.
- Filter kategori dan tab Aktif/Selesai di layar Tugas.
- Kalender: ganti bulan, tap tanggal, mode Bulan/Minggu, titik warna per tanggal.
- Tambah transaksi lewat keypad → saldo akun, grafik kategori, dan riwayat langsung ter-update.
- Ekspresi Chiko di Beranda dihitung dari data (`hitungMood`): khawatir kalau ada deadline hari ini/besok,
  kaget kalau saldo Dompet di bawah Rp 50.000, merayakan kalau semua tugas beres, tidur di atas jam 22.00.
- Chiko bergerak naik-turun pelan dan memantul saat disentuh. Di Pengaturan, tap Chiko untuk mengganti ekspresi.

## Yang masih data contoh

- Semua data ada di memori (`TaskStore`, `FinanceStore`, `EventStore`) dan hilang saat app ditutup.
  Langkah berikutnya: buat tabel drift sesuai dokumen rancangan, lalu ganti isi ketiga store itu
  dengan query database. Layar tidak perlu diubah karena memakai method yang sama.
- Tanggal "hari ini" dikunci ke **Senin, 16 November 2026** supaya sama dengan desain.
  Ganti di `lib/core/utils/clock.dart` menjadi `DateTime.now()`.
- Nama "Ahmad" di sapaan ada di `clock.dart` (`namaPengguna`).
- Form tambah tugas, form jadwal, dan isi menu Pengaturan belum dibuat (tombolnya menampilkan pesan "menyusul").

## Catatan

- `google_fonts` mengunduh Fredoka dan Nunito saat pertama kali app dibuka (butuh internet sekali).
  Kalau ingin offline penuh, unduh file font-nya ke `assets/fonts/` dan daftarkan di `pubspec.yaml`.
- Pemilih tanggal masih berbahasa Inggris. Untuk Bahasa Indonesia, tambahkan `flutter_localizations`
  dan `locale: Locale('id')` di `MaterialApp.router`.
- Chiko sekarang memakai SVG. Saat animasi Rive siap, cukup ganti isi `lib/core/mascot/chiko.dart`;
  layar lain tetap memanggil `Chiko(mood: ...)`.
