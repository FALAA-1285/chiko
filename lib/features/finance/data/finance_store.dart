import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../core/utils/formatters.dart';
import 'finance_model.dart';

export 'finance_model.dart';

/// Penyimpanan keuangan sementara (di memori) berisi data contoh.
/// Nanti diganti repository drift; layar tetap memakai method yang sama.
///
/// Saldo tidak disimpan, tapi dihitung:
/// saldo awal + pemasukan - pengeluaran - transfer keluar + transfer masuk.
class FinanceStore extends ChangeNotifier {
  FinanceStore._();

  static final FinanceStore instance = FinanceStore._();

  final List<Account> accounts = const [
    Account(id: 'btn', name: 'BTN', type: AccountType.bank, initialBalance: 300000, color: AppColors.kuliahSoft),
    Account(id: 'bri', name: 'BRI', type: AccountType.bank, initialBalance: 120000, color: AppColors.yellowSoft),
    Account(id: 'dompet', name: 'Dompet', type: AccountType.cash, initialBalance: 50000, color: AppColors.incomeSoft),
  ];

  final List<TxnCategory> categories = const [
    TxnCategory(id: 'makan', name: 'Makan', kind: TxnKind.expense, icon: Icons.restaurant_rounded, color: AppColors.orange, soft: AppColors.yellowSoft),
    TxnCategory(id: 'transport', name: 'Transport', kind: TxnKind.expense, icon: Icons.two_wheeler_rounded, color: Color(0xFF5B8DEF), soft: AppColors.kuliahSoft),
    TxnCategory(id: 'kuliah', name: 'Kuliah', kind: TxnKind.expense, icon: Icons.menu_book_rounded, color: Color(0xFF8B6CF0), soft: AppColors.kerjaSoft),
    TxnCategory(id: 'hiburan', name: 'Hiburan', kind: TxnKind.expense, icon: Icons.headphones_rounded, color: AppColors.pink, soft: AppColors.pribadiSoft),
    TxnCategory(id: 'belanja', name: 'Belanja', kind: TxnKind.expense, icon: Icons.shopping_bag_rounded, color: Color(0xFF6CC79A), soft: AppColors.incomeSoft),
    TxnCategory(id: 'lainnya', name: 'Lainnya', kind: TxnKind.expense, icon: Icons.more_horiz_rounded, color: Color(0xFFCFC6B2), soft: AppColors.transferSoft),
    TxnCategory(id: 'uang_saku', name: 'Uang saku', kind: TxnKind.income, icon: Icons.savings_rounded, color: AppColors.incomeInk, soft: AppColors.incomeSoft),
    TxnCategory(id: 'honor', name: 'Honor kerja', kind: TxnKind.income, icon: Icons.work_rounded, color: AppColors.incomeInk, soft: AppColors.incomeSoft),
    TxnCategory(id: 'masuk_lain', name: 'Lainnya', kind: TxnKind.income, icon: Icons.more_horiz_rounded, color: AppColors.incomeInk, soft: AppColors.incomeSoft),
  ];

  int _nextId = 100;

  final List<Txn> _txns = [
    Txn(id: 1, kind: TxnKind.transfer, amount: 150000, accountId: 'btn', toAccountId: 'dompet', note: 'Tarik tunai', date: DateTime(2026, 11, 2, 9)),
    Txn(id: 2, kind: TxnKind.expense, amount: 150000, accountId: 'btn', categoryId: 'makan', note: 'Belanja makanan mingguan', date: DateTime(2026, 11, 3, 18)),
    Txn(id: 3, kind: TxnKind.expense, amount: 45000, accountId: 'dompet', categoryId: 'kuliah', note: 'Print dan jilid laporan', date: DateTime(2026, 11, 4, 14)),
    Txn(id: 4, kind: TxnKind.expense, amount: 130000, accountId: 'btn', categoryId: 'transport', note: 'Servis motor', date: DateTime(2026, 11, 5, 10)),
    Txn(id: 5, kind: TxnKind.expense, amount: 80000, accountId: 'bri', categoryId: 'lainnya', note: 'Pulsa dan kuota', date: DateTime(2026, 11, 6, 8)),
    Txn(id: 6, kind: TxnKind.expense, amount: 85000, accountId: 'bri', categoryId: 'makan', note: 'Makan bareng teman', date: DateTime(2026, 11, 7, 19)),
    Txn(id: 7, kind: TxnKind.expense, amount: 55000, accountId: 'bri', categoryId: 'hiburan', note: 'Nonton bioskop', date: DateTime(2026, 11, 8, 20)),
    Txn(id: 8, kind: TxnKind.expense, amount: 75000, accountId: 'btn', categoryId: 'kuliah', note: 'Buku referensi', date: DateTime(2026, 11, 9, 13)),
    Txn(id: 9, kind: TxnKind.expense, amount: 60000, accountId: 'dompet', categoryId: 'makan', note: 'Jajan dan kopi', date: DateTime(2026, 11, 10, 16)),
    Txn(id: 10, kind: TxnKind.income, amount: 1500000, accountId: 'btn', categoryId: 'uang_saku', note: 'Uang saku', date: DateTime(2026, 11, 12, 8)),
    Txn(id: 11, kind: TxnKind.income, amount: 500000, accountId: 'bri', categoryId: 'honor', note: 'Honor kerja', date: DateTime(2026, 11, 12, 9)),
    Txn(id: 12, kind: TxnKind.transfer, amount: 100000, accountId: 'bri', toAccountId: 'dompet', note: 'Tarik tunai', date: DateTime(2026, 11, 15, 11)),
    Txn(id: 13, kind: TxnKind.expense, amount: 30000, accountId: 'bri', categoryId: 'hiburan', note: 'Langganan musik', date: DateTime(2026, 11, 15, 12)),
    Txn(id: 14, kind: TxnKind.expense, amount: 20000, accountId: 'dompet', categoryId: 'transport', note: 'Bensin motor', date: DateTime(2026, 11, 16, 7, 30)),
    Txn(id: 15, kind: TxnKind.expense, amount: 25000, accountId: 'dompet', categoryId: 'makan', note: 'Makan siang', date: DateTime(2026, 11, 16, 9, 45)),
  ];

  Account accountById(String id) => accounts.firstWhere((a) => a.id == id);

  TxnCategory? categoryById(String? id) {
    if (id == null) return null;
    for (final c in categories) {
      if (c.id == id) return c;
    }
    return null;
  }

  List<TxnCategory> categoriesFor(TxnKind kind) => categories.where((c) => c.kind == kind).toList();

  int balanceOf(String accountId) {
    var saldo = accountById(accountId).initialBalance;
    for (final t in _txns) {
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

  int get totalBalance => accounts.fold(0, (sum, a) => sum + balanceOf(a.id));

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

  /// Transaksi terbaru, dikelompokkan per hari (hari terbaru dulu).
  List<(DateTime, List<Txn>)> recentByDay({int days = 3}) {
    final sorted = [..._txns]..sort((a, b) => b.date.compareTo(a.date));
    final groups = <(DateTime, List<Txn>)>[];
    for (final t in sorted) {
      final day = tanpaJam(t.date);
      if (groups.isEmpty || groups.last.$1 != day) {
        if (groups.length == days) break;
        groups.add((day, [t]));
      } else {
        groups.last.$2.add(t);
      }
    }
    return groups;
  }

  void add({
    required TxnKind kind,
    required int amount,
    required String accountId,
    required DateTime date,
    String? toAccountId,
    String? categoryId,
    String note = '',
  }) {
    _txns.add(Txn(
      id: _nextId++,
      kind: kind,
      amount: amount,
      accountId: accountId,
      toAccountId: toAccountId,
      categoryId: categoryId,
      note: note,
      date: date,
    ));
    notifyListeners();
  }
}
