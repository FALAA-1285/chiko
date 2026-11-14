import 'finance_model.dart';

/// Pasangan warna kategori (warna grafik, warna latar ikon) dalam ARGB.
/// Dipakai saat mengisi kategori bawaan dan di pemilih warna Kelola kategori.
const paletKategori = <(int, int)>[
  (0xFFF9A11B, 0xFFFFF0B3), // oranye
  (0xFF5B8DEF, 0xFFE4EDFF), // biru
  (0xFF8B6CF0, 0xFFEEE8FF), // ungu
  (0xFFF7A6AE, 0xFFFDE7EA), // pink
  (0xFF6CC79A, 0xFFDDF3E8), // hijau muda
  (0xFFCFC6B2, 0xFFF1ECE0), // krem
  (0xFF1A7A50, 0xFFDDF3E8), // hijau tua
];

/// Warna kartu akun (ARGB).
const paletAkun = <int>[0xFFE4EDFF, 0xFFFFF0B3, 0xFFDDF3E8, 0xFFFDE7EA, 0xFFEEE8FF, 0xFFF1ECE0];

/// Kunci ikon kategori yang tersedia. Dipetakan ke ikon Material di `finance_style.dart`.
const kunciIkonKategori = [
  'makan',
  'transport',
  'kuliah',
  'hiburan',
  'belanja',
  'lainnya',
  'tabungan',
  'kerja',
  'kesehatan',
  'tagihan',
  'hadiah',
  'rumah',
];

/// Kategori bawaan saat database pertama kali dibuat: (nama, jenis, ikon, indeks palet).
const kategoriBawaan = <(String, TxnKind, String, int)>[
  ('Makan', TxnKind.expense, 'makan', 0),
  ('Transport', TxnKind.expense, 'transport', 1),
  ('Kuliah', TxnKind.expense, 'kuliah', 2),
  ('Hiburan', TxnKind.expense, 'hiburan', 3),
  ('Belanja', TxnKind.expense, 'belanja', 4),
  ('Lainnya', TxnKind.expense, 'lainnya', 5),
  ('Uang saku', TxnKind.income, 'tabungan', 6),
  ('Honor kerja', TxnKind.income, 'kerja', 6),
  ('Lainnya', TxnKind.income, 'lainnya', 6),
];

/// Akun bawaan: satu dompet tunai bersaldo 0. Pengguna menambah/mengubah di Pengaturan.
const akunBawaan = ('Dompet', AccountType.cash, 0);
