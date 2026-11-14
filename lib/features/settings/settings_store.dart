import 'package:flutter/foundation.dart';

import '../../core/data/app_database.dart';
import '../../core/data/aturan_error.dart';

/// Pengaturan pengguna (tabel `settings`, kunci → nilai).
class SettingsStore extends ChangeNotifier {
  SettingsStore(this._db);

  final AppDatabase _db;

  static const _kNama = 'nama_pengguna';
  static const _kOnboarding = 'onboarding_selesai';
  static const maxPanjangNama = 30;

  Map<String, String> _values = const {};

  Future<void> load() async {
    final rows = await _db.select(_db.settings).get();
    _values = {for (final r in rows) r.key: r.value};
    notifyListeners();
  }

  /// Nama panggilan untuk sapaan di Beranda. Kosong bila belum diisi.
  String get namaPengguna => _values[_kNama] ?? '';

  /// Sudah melewati layar Sambutan?
  bool get onboardingSelesai => _values[_kOnboarding] == '1';

  Future<void> _set(String key, String value) async {
    await _db.into(_db.settings).insertOnConflictUpdate(SettingsCompanion.insert(key: key, value: value));
    await load();
  }

  Future<void> setNamaPengguna(String nama) async {
    final rapi = nama.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (rapi.length > maxPanjangNama) throw const AturanError('Nama maksimal $maxPanjangNama huruf.');
    await _set(_kNama, rapi);
  }

  Future<void> selesaikanOnboarding() => _set(_kOnboarding, '1');
}
