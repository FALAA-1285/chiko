/// Model keuangan — Dart murni. Gaya tampilan (ikon, warna) ada di `ui/finance_style.dart`.
enum AccountType {
  bank('Bank'),
  cash('Tunai'),
  ewallet('E-wallet');

  const AccountType(this.label);
  final String label;
}

/// Sesuai tabel `accounts`.
class Account {
  const Account({
    required this.id,
    required this.name,
    required this.type,
    required this.initialBalance,
    required this.colorValue,
  });

  final int id;
  final String name;
  final AccountType type;

  /// Saldo saat mulai memakai app, dalam rupiah.
  final int initialBalance;

  /// Warna kartu (ARGB).
  final int colorValue;

  @override
  bool operator ==(Object other) => other is Account && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

enum TxnKind {
  expense('Pengeluaran'),
  income('Pemasukan'),
  transfer('Transfer');

  const TxnKind(this.label);
  final String label;
}

/// Sesuai tabel `categories`.
class TxnCategory {
  const TxnCategory({
    required this.id,
    required this.name,
    required this.kind,
    required this.iconKey,
    required this.colorValue,
    required this.softValue,
  });

  final int id;
  final String name;
  final TxnKind kind;

  /// Kunci ikon, dipetakan ke ikon di `finance_style.dart`.
  final String iconKey;

  /// Warna di grafik (ARGB).
  final int colorValue;

  /// Warna latar ikon di daftar transaksi (ARGB).
  final int softValue;

  @override
  bool operator ==(Object other) => other is TxnCategory && other.id == id;

  @override
  int get hashCode => id.hashCode;
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
  final int accountId;
  final int? toAccountId;
  final int? categoryId;
  final String note;
  final DateTime date;

  @override
  bool operator ==(Object other) => other is Txn && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
