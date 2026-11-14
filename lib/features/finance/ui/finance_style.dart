import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../data/finance_model.dart';

/// Ikon untuk setiap kunci di `kunciIkonKategori`.
IconData ikonKategori(String key) => switch (key) {
      'makan' => Icons.restaurant_rounded,
      'transport' => Icons.two_wheeler_rounded,
      'kuliah' => Icons.menu_book_rounded,
      'hiburan' => Icons.headphones_rounded,
      'belanja' => Icons.shopping_bag_rounded,
      'tabungan' => Icons.savings_rounded,
      'kerja' => Icons.work_rounded,
      'kesehatan' => Icons.medical_services_rounded,
      'tagihan' => Icons.receipt_long_rounded,
      'hadiah' => Icons.card_giftcard_rounded,
      'rumah' => Icons.home_rounded,
      _ => Icons.more_horiz_rounded,
    };

extension TxnKindStyle on TxnKind {
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

extension AccountTypeStyle on AccountType {
  IconData get icon => switch (this) {
        AccountType.bank => Icons.account_balance_rounded,
        AccountType.cash => Icons.account_balance_wallet_rounded,
        AccountType.ewallet => Icons.phone_iphone_rounded,
      };
}

extension AccountStyle on Account {
  IconData get icon => type.icon;
  Color get color => Color(colorValue);
}

extension TxnCategoryStyle on TxnCategory {
  IconData get icon => ikonKategori(iconKey);
  Color get color => Color(colorValue);
  Color get soft => Color(softValue);
}
