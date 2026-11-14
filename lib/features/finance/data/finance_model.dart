import 'package:flutter/material.dart';

import '../../../app/theme.dart';

enum AccountType { bank, cash, ewallet }

/// Sesuai tabel `accounts` di dokumen rancangan.
class Account {
  const Account({
    required this.id,
    required this.name,
    required this.type,
    required this.initialBalance,
    required this.color,
  });

  final String id;
  final String name;
  final AccountType type;

  /// Saldo saat mulai memakai app, dalam rupiah.
  final int initialBalance;
  final Color color;

  IconData get icon => switch (type) {
        AccountType.bank => Icons.account_balance_rounded,
        AccountType.cash => Icons.account_balance_wallet_rounded,
        AccountType.ewallet => Icons.phone_iphone_rounded,
      };
}

enum TxnKind { expense, income, transfer }

extension TxnKindStyle on TxnKind {
  String get label => switch (this) {
        TxnKind.expense => 'Pengeluaran',
        TxnKind.income => 'Pemasukan',
        TxnKind.transfer => 'Transfer',
      };

  Color get soft => switch (this) {
        TxnKind.expense => AppColors.expenseSoft,
        TxnKind.income => AppColors.incomeSoft,
        TxnKind.transfer => AppColors.transferSoft,
      };

  Color get ink => switch (this) {
        TxnKind.expense => AppColors.expenseInk,
        TxnKind.income => AppColors.incomeInk,
        TxnKind.transfer => AppColors.ink,
      };
}

/// Sesuai tabel `categories`.
class TxnCategory {
  const TxnCategory({
    required this.id,
    required this.name,
    required this.kind,
    required this.icon,
    required this.color,
    required this.soft,
  });

  final String id;
  final String name;
  final TxnKind kind;
  final IconData icon;

  /// Warna di grafik.
  final Color color;

  /// Warna latar ikon di daftar transaksi.
  final Color soft;
}

/// Sesuai tabel `transactions`. Nominal selalu positif, dalam rupiah.
class Txn {
  const Txn({
    required this.id,
    required this.kind,
    required this.amount,
    required this.accountId,
    required this.date,
    this.toAccountId,
    this.categoryId,
    this.note = '',
  });

  final int id;
  final TxnKind kind;
  final int amount;
  final String accountId;
  final String? toAccountId;
  final String? categoryId;
  final String note;
  final DateTime date;
}
