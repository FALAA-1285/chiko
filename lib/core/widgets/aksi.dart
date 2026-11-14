import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../data/aturan_error.dart';

/// Menampilkan pesan singkat di bawah layar, menggantikan pesan sebelumnya.
void tampilkanPesan(ScaffoldMessengerState messenger, String pesan, {VoidCallback? onUndo}) {
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(pesan),
      action: onUndo == null ? null : SnackBarAction(label: 'Batal', textColor: AppColors.yellow, onPressed: onUndo),
    ));
}

/// Menjalankan aksi simpan/hapus dengan penanganan kesalahan yang seragam.
///
/// - [AturanError] → pesannya ditampilkan apa adanya.
/// - kesalahan lain (mis. database) → pesan umum, detail dicatat lewat [FlutterError].
///
/// Mengembalikan `true` bila berhasil. Bila [pesanSukses] diisi, pesan itu ditampilkan
/// (dengan tombol "Batal" bila [onUndo] diisi).
Future<bool> jalankanAksi(
  BuildContext context,
  Future<void> Function() aksi, {
  String? pesanSukses,
  Future<void> Function()? onUndo,
}) async {
  // Ambil messenger sebelum await supaya tidak memakai context yang mungkin sudah tidak aktif.
  final messenger = ScaffoldMessenger.of(context);
  try {
    await aksi();
  } on AturanError catch (e) {
    tampilkanPesan(messenger, e.pesan);
    return false;
  } catch (e, st) {
    FlutterError.reportError(FlutterErrorDetails(
        exception: e, stack: st, library: 'chiko', context: ErrorDescription('saat menyimpan data')));
    tampilkanPesan(messenger, 'Gagal menyimpan data. Coba lagi, ya.');
    return false;
  }
  if (pesanSukses != null) {
    tampilkanPesan(
      messenger,
      pesanSukses,
      onUndo: onUndo == null
          ? null
          : () => onUndo().catchError((Object _) => tampilkanPesan(messenger, 'Gagal membatalkan.')),
    );
  }
  return true;
}
