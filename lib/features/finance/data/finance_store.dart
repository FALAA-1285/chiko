import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../../../core/data/app_database.dart';
import '../../../core/data/aturan_error.dart';
import '../../../core/utils/formatters.dart';
import 'finance_defaults.dart';
import 'finance_model.dart';

export 'finance_model.dart';

/// Keuangan: akun, kategori, dan transaksi di database; disalin ke memori untuk dibaca layar.
///
/// Saldo tidak disimpan, tapi dihitung:
/// saldo awal + pemasukan - pengeluaran - transfer keluar + transfer masuk.
class FinanceStore extends ChangeNotifier {
  FinanceStore(this._db);

  final AppDatabase _db;

  static const maxPanjangNama = 40;

  /// Batas nominal satu transaksi (Rp 9.999.999.999).
  static const maxNominal = 9999999999;

  List<Account> _accounts = const [];
  List<TxnCategory> _categories = const [];
  List<Txn> _txns = const [];

  List<Account> get accounts => _accounts;
  List<TxnCategory> get categories => _categories;

  Future<void> load() async {
    _accounts = await (_db.select(_db.accounts)..orderBy([(a) => OrderingTerm.asc(a.id)])).get();
    _categories = await (_db.select(_db.txnCategories)..orderBy([(c) => OrderingTerm.asc(c.id)])).get();
    _txns = await _db.select(_db.txns).get();
    notifyListeners();
  }

  Account? accountById(int? id) {
    for (final a in _accounts) {
      if (a.id == id) return a;
    }
    return null;
  }

  TxnCategory? categoryById(int? id) {
    for (final c in _categories) {
      if (c.id == id) return c;
    }
    return null;
  }

  Txn? txnById(int id) {
    for (final t in _txns) {
      if (t.id == id) return t;
    }
    return null;
  }

  List<TxnCategory> categoriesFor(TxnKind kind) => _categories.where((c) => c.kind == kind).toList();

  /// Akun bawaan untuk form: akun tunai pertama, atau akun pertama.
  Account? get defaultAccount =>
      _accounts.where((a) => a.type == AccountType.cash).firstOrNull ?? _accounts.firstOrNull;

  /// Saldo akun. [excludeTxnId] mengabaikan satu transaksi (dipakai saat mengedit transaksi itu).
  int balanceOf(int accountId, {int? excludeTxnId}) {
    var saldo = accountById(accountId)?.initialBalance ?? 0;
    for (final t in _txns) {
      if (t.id == excludeTxnId) continue;
      switch (t.kind) {
        case TxnKind.income:
          if (t.accountId == accountId) saldo += t.amount;
        case TxnKind.expense:
          if (t.accountId == accountId) saldo -= t.amount;
        case TxnKind.transfer:
          if (t.accountId == accountId) saldo -= t.amount;
          if (t.toAccountId == accountId) saldo += t.amount;
      }
    }
    return saldo;
  }

  int get totalBalance => _accounts.fold(0, (sum, a) => sum + balanceOf(a.id));

  bool _sameMonth(DateTime a, DateTime b) => a.year == b.year && a.month == b.month;

  int incomeInMonth(DateTime month) =>
      _txns.where((t) => t.kind == TxnKind.income && _sameMonth(t.date, month)).fold(0, (s, t) => s + t.amount);

  int expenseInMonth(DateTime month) =>
      _txns.where((t) => t.kind == TxnKind.expense && _sameMonth(t.date, month)).fold(0, (s, t) => s + t.amount);

  int expenseOn(DateTime day) =>
      _txns.where((t) => t.kind == TxnKind.expense && samaHari(t.date, day)).fold(0, (s, t) => s + t.amount);

  /// Pengeluaran per kategori dalam satu bulan, terbesar dulu. Kategori bernilai 0 tidak ikut.
  List<(TxnCategory, int)> expenseByCategory(DateTime month) {
    final result = <(TxnCategory, int)>[];
    for (final c in categoriesFor(TxnKind.expense)) {
      final total = _txns
          .where((t) => t.kind == TxnKind.expense && t.categoryId == c.id && _sameMonth(t.date, month))
          .fold(0, (s, t) => s + t.amount);
      if (total > 0) result.add((c, total));
    }
    result.sort((a, b) => b.$2.compareTo(a.$2));
    return result;
  }

  /// Semua transaksi di bulan [month], dikelompokkan per hari (hari terbaru dulu).
  List<(DateTime, List<Txn>)> byDayInMonth(DateTime month) {
    final sorted = _txns.where((t) => _sameMonth(t.date, month)).toList()..sort((a, b) => b.date.compareTo(a.date));
    final groups = <(DateTime, List<Txn>)>[];
    for (final t in sorted) {
      final day = tanpaJam(t.date);
      if (groups.isEmpty || groups.last.$1 != day) {
        groups.add((day, [t]));
      } else {
        groups.last.$2.add(t);
      }
    }
    return groups;
  }

  // ---------------------------------------------------------------- transaksi

  /// Memeriksa aturan transaksi. Mengembalikan pesan kesalahan, atau `null` bila valid.
  ///
  /// Aturan:
  /// - nominal harus lebih dari 0 dan tidak melebihi [maxNominal],
  /// - akun harus ada; transfer butuh akun tujuan yang berbeda,
  /// - pemasukan/pengeluaran wajib punya kategori yang jenisnya cocok,
  /// - tanggal tidak boleh di masa depan (saldo dihitung dari semua transaksi),
  /// - pengeluaran/transfer tidak boleh melebihi saldo akun asal
  ///   (saat mengedit, transaksi lama [editingId] tidak dihitung).
  String? validate({
    required TxnKind kind,
    required int amount,
    required int accountId,
    required DateTime date,
    required DateTime now,
    int? toAccountId,
    int? categoryId,
    int? editingId,
  }) {
    if (amount <= 0) return 'Isi nominalnya dulu, ya.';
    if (amount > maxNominal) return 'Nominal terlalu besar.';
    if (accountById(accountId) == null) return 'Akun tidak ditemukan.';
    if (kind == TxnKind.transfer) {
      if (toAccountId == null || accountById(toAccountId) == null) return 'Pilih akun tujuan.';
      if (toAccountId == accountId) return 'Akun asal dan tujuan tidak boleh sama.';
    } else {
      final cat = categoryById(categoryId);
      if (cat == null || cat.kind != kind) return 'Pilih kategorinya dulu.';
    }
    if (tanpaJam(date).isAfter(tanpaJam(now))) return 'Tanggal transaksi tidak boleh di masa depan.';
    if (kind != TxnKind.income) {
      final saldo = balanceOf(accountId, excludeTxnId: editingId);
      if (amount > saldo) {
        return 'Saldo ${accountById(accountId)!.name} tidak cukup (tersisa ${rupiah(saldo)}).';
      }
    }
    return null;
  }

  /// Menyimpan transaksi baru, atau mengubah transaksi [editingId]. Melempar [AturanError] bila tidak valid.
  Future<void> saveTxn({
    required TxnKind kind,
    required int amount,
    required int accountId,
    required DateTime date,
    required DateTime now,
    int? toAccountId,
    int? categoryId,
    String note = '',
    int? editingId,
  }) async {
    final error = validate(
      kind: kind,
      amount: amount,
      accountId: accountId,
      date: date,
      now: now,
      toAccountId: toAccountId,
      categoryId: categoryId,
      editingId: editingId,
    );
    if (error != null) throw AturanError(error);
    final data = TxnsCompanion(
      kind: Value(kind),
      amount: Value(amount),
      accountId: Value(accountId),
      toAccountId: Value(kind == TxnKind.transfer ? toAccountId : null),
      categoryId: Value(kind == TxnKind.transfer ? null : categoryId),
      note: Value(note.trim()),
      date: Value(date),
    );
    if (editingId == null) {
      await _db.into(_db.txns).insert(data);
    } else {
      await (_db.update(_db.txns)..where((t) => t.id.equals(editingId))).write(data);
    }
    await load();
  }

  /// Menghapus transaksi. Ditolak bila menghapusnya membuat saldo akun tujuan transfer
  /// menjadi minus (uangnya sudah terpakai).
  Future<void> deleteTxn(Txn txn) async {
    final masukKe = switch (txn.kind) {
      TxnKind.income => txn.accountId,
      TxnKind.transfer => txn.toAccountId,
      TxnKind.expense => null,
    };
    if (masukKe != null && balanceOf(masukKe, excludeTxnId: txn.id) < 0) {
      throw AturanError('Tidak bisa dihapus: saldo ${accountById(masukKe)?.name ?? 'akun'} akan minus. '
          'Hapus dulu pengeluaran yang memakai uang ini.');
    }
    await (_db.delete(_db.txns)..where((t) => t.id.equals(txn.id))).go();
    await load();
  }

  /// Mengembalikan transaksi yang baru dihapus.
  Future<void> restoreTxn(Txn txn) async {
    await _db.into(_db.txns).insert(txn.toInsertable(), mode: InsertMode.insertOrIgnore);
    await load();
  }

  // ---------------------------------------------------------------- akun

  String _namaValid(String name, String jenis) {
    final nama = name.trim();
    if (nama.isEmpty) throw AturanError('Nama $jenis tidak boleh kosong.');
    if (nama.length > maxPanjangNama) throw AturanError('Nama $jenis maksimal $maxPanjangNama huruf.');
    return nama;
  }

  /// Menambah akun, atau mengubah akun [editingId].
  Future<void> saveAccount({
    required String name,
    required AccountType type,
    required int initialBalance,
    required int colorValue,
    int? editingId,
  }) async {
    final nama = _namaValid(name, 'akun');
    if (initialBalance < 0) throw const AturanError('Saldo awal tidak boleh minus.');
    if (initialBalance > maxNominal) throw const AturanError('Saldo awal terlalu besar.');
    final kembar = _accounts.any((a) => a.id != editingId && a.name.toLowerCase() == nama.toLowerCase());
    if (kembar) throw AturanError('Akun "$nama" sudah ada.');

    if (editingId != null) {
      // Saldo awal yang diturunkan tidak boleh membuat saldo sekarang minus.
      final lama = accountById(editingId);
      if (lama == null) throw const AturanError('Akun tidak ditemukan.');
      final saldoBaru = balanceOf(editingId) - lama.initialBalance + initialBalance;
      if (saldoBaru < 0) {
        throw AturanError('Saldo awal terlalu kecil: saldo ${lama.name} akan menjadi ${rupiah(saldoBaru)}.');
      }
    }
    final data = AccountsCompanion(
      name: Value(nama),
      type: Value(type),
      initialBalance: Value(initialBalance),
      colorValue: Value(colorValue),
    );
    if (editingId == null) {
      await _db.into(_db.accounts).insert(data);
    } else {
      await (_db.update(_db.accounts)..where((a) => a.id.equals(editingId))).write(data);
    }
    await load();
  }

  bool accountInUse(int id) => _txns.any((t) => t.accountId == id || t.toAccountId == id);

  Future<void> deleteAccount(Account account) async {
    if (_accounts.length <= 1) throw const AturanError('Minimal harus ada satu akun.');
    if (accountInUse(account.id)) {
      throw AturanError('Akun ${account.name} masih dipakai transaksi, jadi tidak bisa dihapus.');
    }
    await (_db.delete(_db.accounts)..where((a) => a.id.equals(account.id))).go();
    await load();
  }

  // ---------------------------------------------------------------- kategori

  Future<void> saveCategory({
    required String name,
    required TxnKind kind,
    required String iconKey,
    required int paletIndex,
    int? editingId,
  }) async {
    if (kind == TxnKind.transfer) throw const AturanError('Transfer tidak memakai kategori.');
    final nama = _namaValid(name, 'kategori');
    final kembar = _categories.any(
      (c) => c.id != editingId && c.kind == kind && c.name.toLowerCase() == nama.toLowerCase(),
    );
    if (kembar) throw AturanError('Kategori "$nama" sudah ada.');
    if (editingId != null) {
      final lama = categoryById(editingId);
      if (lama == null) throw const AturanError('Kategori tidak ditemukan.');
      if (lama.kind != kind && categoryInUse(editingId)) {
        throw const AturanError('Jenis kategori yang sudah dipakai transaksi tidak bisa diubah.');
      }
    }
    final (warna, latar) = paletKategori[paletIndex.clamp(0, paletKategori.length - 1)];
    final data = TxnCategoriesCompanion(
      name: Value(nama),
      kind: Value(kind),
      iconKey: Value(kunciIkonKategori.contains(iconKey) ? iconKey : 'lainnya'),
      colorValue: Value(warna),
      softValue: Value(latar),
    );
    if (editingId == null) {
      await _db.into(_db.txnCategories).insert(data);
    } else {
      await (_db.update(_db.txnCategories)..where((c) => c.id.equals(editingId))).write(data);
    }
    await load();
  }

  bool categoryInUse(int id) => _txns.any((t) => t.categoryId == id);

  Future<void> deleteCategory(TxnCategory category) async {
    if (categoryInUse(category.id)) {
      throw AturanError('Kategori ${category.name} masih dipakai transaksi, jadi tidak bisa dihapus.');
    }
    if (categoriesFor(category.kind).length <= 1) {
      throw AturanError('Minimal harus ada satu kategori ${category.kind.label.toLowerCase()}.');
    }
    await (_db.delete(_db.txnCategories)..where((c) => c.id.equals(category.id))).go();
    await load();
  }
}
