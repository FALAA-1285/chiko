import 'package:flutter/foundation.dart';

DateTime Function() _jam = DateTime.now;

/// Waktu sekarang. Semua logika tanggal memakai fungsi ini (bukan `DateTime.now()`
/// langsung) supaya test bisa memakai jam tetap lewat [aturJam].
DateTime sekarang() => _jam();

/// Khusus test: ganti sumber waktu. Panggil `aturJam(DateTime.now)` untuk mengembalikan.
@visibleForTesting
void aturJam(DateTime Function() jam) => _jam = jam;
