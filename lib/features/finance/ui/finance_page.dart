import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../core/utils/clock.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/bold.dart';
import '../data/finance_store.dart';

class FinancePage extends StatelessWidget {
  const FinancePage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = FinanceStore.instance;
    return Scaffold(
      floatingActionButton: AddFab(
        tooltip: 'Tambah transaksi',
        onPressed: () => context.push('/tambah-transaksi'),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: store,
          builder: (context, _) {
            final now = sekarang();
            final bulan = DateTime(now.year, now.month);
            final masuk = store.incomeInMonth(bulan);
            final keluar = store.expenseInMonth(bulan);
            final perKategori = store.expenseByCategory(bulan);
            final hariTransaksi = store.recentByDay();

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
              children: [
                Row(
                  children: [
                    Expanded(child: Text('Keuangan', style: AppText.display(30))),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.ink,
                        backgroundColor: AppColors.white,
                        side: const BorderSide(color: AppColors.ink, width: 2),
                        minimumSize: const Size(44, 44),
                        shape: const StadiumBorder(),
                        textStyle: AppText.body(14, weight: FontWeight.w800),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${namaBulan(bulan.month)} ${bulan.year}'),
                          const SizedBox(width: 4),
                          const Icon(Icons.expand_more_rounded, size: 20),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _BalanceCard(total: store.totalBalance, masuk: masuk, keluar: keluar),
                const SizedBox(height: 20),
                SectionHeader(title: 'Akun', action: 'Kelola', onAction: () => context.go('/pengaturan')),
                const SizedBox(height: 4),
                Row(
                  children: [
                    for (var i = 0; i < store.accounts.length; i++) ...[
                      if (i > 0) const SizedBox(width: 10),
                      Expanded(
                        child: _AccountCard(
                          account: store.accounts[i],
                          balance: store.balanceOf(store.accounts[i].id),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 20),
                _CategoryCard(items: perKategori, total: keluar),
                const SizedBox(height: 20),
                Text('Transaksi terakhir', style: AppText.display(20, weight: FontWeight.w600)),
                const SizedBox(height: 10),
                for (final (day, txns) in hariTransaksi) ...[
                  Text(
                    labelHariTransaksi(day, now).toUpperCase(),
                    style: AppText.body(13, weight: FontWeight.w900, color: AppColors.muted).copyWith(letterSpacing: 0.8),
                  ),
                  const SizedBox(height: 6),
                  BoldCard(
                    radius: 18,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                    child: Column(
                      children: [
                        for (var i = 0; i < txns.length; i++) ...[
                          _TxnRow(txn: txns[i], store: store),
                          if (i < txns.length - 1) const Divider(height: 1, thickness: 1.5, color: AppColors.line),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.total, required this.masuk, required this.keluar});

  final int total;
  final int masuk;
  final int keluar;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: AppColors.ink, borderRadius: BorderRadius.circular(26)),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -56,
            top: -56,
            child: Container(
              width: 140,
              height: 140,
              decoration: const BoxDecoration(color: Color(0x29FFD12F), shape: BoxShape.circle),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total saldo', style: AppText.body(13, weight: FontWeight.w700, color: AppColors.darkMuted)),
              const SizedBox(height: 2),
              Text(rupiah(total), style: AppText.display(36, color: AppColors.yellow)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _FlowStat(
                      label: 'Masuk',
                      value: rupiah(masuk),
                      icon: Icons.arrow_upward_rounded,
                      color: AppColors.incomeOnDark,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _FlowStat(
                      label: 'Keluar',
                      value: rupiah(keluar),
                      icon: Icons.arrow_downward_rounded,
                      color: AppColors.expenseOnDark,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FlowStat extends StatelessWidget {
  const _FlowStat({required this.label, required this.value, required this.icon, required this.color});

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, size: 18, color: AppColors.ink),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppText.body(12, weight: FontWeight.w700, color: AppColors.darkMuted)),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(value, style: AppText.body(15, weight: FontWeight.w900, color: AppColors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.account, required this.balance});

  final Account account;
  final int balance;

  @override
  Widget build(BuildContext context) {
    return BoldCard(
      color: account.color,
      radius: 18,
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.ink, width: 2),
            ),
            child: Icon(account.icon, size: 18, color: AppColors.ink),
          ),
          const SizedBox(height: 10),
          Text(account.name, style: AppText.body(13, weight: FontWeight.w800, color: AppColors.inkSoft)),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(rupiah(balance), style: AppText.body(15, weight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.items, required this.total});

  final List<(TxnCategory, int)> items;
  final int total;

  @override
  Widget build(BuildContext context) {
    final ringkasan = items.map((e) => '${e.$1.name} ${(e.$2 / total * 100).round()}%').join(', ');
    return BoldCard(
      radius: 22,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('Pengeluaran per kategori', style: AppText.display(18, weight: FontWeight.w600))),
              Text(rupiah(total), style: AppText.body(13, weight: FontWeight.w800, color: AppColors.muted)),
            ],
          ),
          const SizedBox(height: 14),
          if (items.isEmpty)
            Text('Belum ada pengeluaran bulan ini.', style: AppText.body(14, color: AppColors.inkSoft))
          else ...[
            Semantics(
              label: 'Pengeluaran: $ringkasan',
              excludeSemantics: true,
              child: SizedBox(
                height: 18,
                child: Row(
                  children: [
                    for (var i = 0; i < items.length; i++) ...[
                      if (i > 0) const SizedBox(width: 3),
                      Expanded(
                        flex: items[i].$2,
                        child: Container(
                          decoration: BoxDecoration(
                            color: items[i].$1.color,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.ink, width: 1.5),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            for (final (cat, amount) in items)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: cat.color,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.ink, width: 1.5),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(cat.name, style: AppText.body(14, weight: FontWeight.w700))),
                    SizedBox(
                      width: 44,
                      child: Text(
                        '${(amount / total * 100).round()}%',
                        textAlign: TextAlign.right,
                        style: AppText.body(14, weight: FontWeight.w700, color: AppColors.muted),
                      ),
                    ),
                    SizedBox(
                      width: 104,
                      child: Text(rupiah(amount), textAlign: TextAlign.right, style: AppText.body(14, weight: FontWeight.w900)),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _TxnRow extends StatelessWidget {
  const _TxnRow({required this.txn, required this.store});

  final Txn txn;
  final FinanceStore store;

  @override
  Widget build(BuildContext context) {
    final cat = store.categoryById(txn.categoryId);
    final akun = store.accountById(txn.accountId);
    final (sub, icon, soft, sign) = switch (txn.kind) {
      TxnKind.transfer => (
          'Transfer · ${akun.name} ke ${store.accountById(txn.toAccountId!).name}',
          Icons.swap_horiz_rounded,
          AppColors.transferSoft,
          '',
        ),
      TxnKind.income => (
          'Pemasukan · ${akun.name}',
          cat?.icon ?? Icons.south_west_rounded,
          AppColors.incomeSoft,
          '+',
        ),
      TxnKind.expense => (
          '${cat?.name ?? 'Pengeluaran'} · ${akun.name}',
          cat?.icon ?? Icons.north_east_rounded,
          cat?.soft ?? AppColors.expenseSoft,
          '−',
        ),
    };
    final judul = txn.note.isNotEmpty ? txn.note : (cat?.name ?? txn.kind.label);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: soft,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.ink, width: 2),
            ),
            child: Icon(icon, size: 20, color: AppColors.ink),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(judul, style: AppText.body(15, weight: FontWeight.w800)),
                Text(sub, style: AppText.body(13, color: AppColors.muted)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$sign${rupiah(txn.amount)}',
            style: AppText.body(15, weight: FontWeight.w900, color: txn.kind.ink),
          ),
        ],
      ),
    );
  }
}
