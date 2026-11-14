import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_scope.dart';
import '../../../app/theme.dart';
import '../../../core/utils/clock.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/aksi.dart';
import '../../../core/widgets/bold.dart';
import '../data/finance_store.dart';
import 'finance_style.dart';

/// Tambah transaksi baru, atau ubah/hapus transaksi [editId].
class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key, this.editId});

  final int? editId;

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  late final FinanceStore _store = AppScope.of(context).finance;
  final _note = TextEditingController();

  TxnKind _kind = TxnKind.expense;
  String _amount = '0';
  int? _from;
  int? _to;
  int? _category;
  late DateTime _date = sekarang();
  Txn? _editing;
  bool _saving = false;
  bool _initialized = false;

  bool get _isEdit => _editing != null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final txn = widget.editId == null ? null : _store.txnById(widget.editId!);
    if (txn != null) {
      _editing = txn;
      _kind = txn.kind;
      _amount = '${txn.amount}';
      _from = txn.accountId;
      _to = txn.toAccountId;
      _category = txn.categoryId;
      _date = txn.date;
      _note.text = txn.note;
    } else {
      // Bawaan dari data, bukan ID yang ditulis langsung.
      _from = _store.defaultAccount?.id;
      _category = _store.categoriesFor(_kind).firstOrNull?.id;
    }
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  void _setKind(TxnKind kind) {
    setState(() {
      _kind = kind;
      final cats = _store.categoriesFor(kind);
      if (!cats.any((c) => c.id == _category)) _category = cats.firstOrNull?.id;
      if (kind == TxnKind.transfer) {
        // Bawaan "tarik tunai": dari bank ke akun tunai. Kalau asalnya sudah bank, pertahankan.
        final accounts = _store.accounts;
        final cash = accounts.where((a) => a.type == AccountType.cash).firstOrNull ?? accounts.lastOrNull;
        if (cash != null && accounts.length > 1) {
          if (_from == cash.id) _from = accounts.firstWhere((a) => a.id != cash.id).id;
          _to = cash.id;
        }
      }
    });
  }

  void _press(String key) {
    setState(() {
      var a = _amount == '0' ? '' : _amount;
      if (key == 'hapus') {
        a = a.isEmpty ? '' : a.substring(0, a.length - 1);
      } else if (a.length < 10) {
        a += key;
        if (a.length > 10) a = a.substring(0, 10);
      }
      a = a.replaceFirst(RegExp(r'^0+'), '');
      _amount = a.isEmpty ? '0' : a;
    });
  }

  Future<void> _pickDate() async {
    final now = sekarang();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date.isAfter(now) ? now : _date,
      firstDate: DateTime(now.year - 2),
      // Transaksi masa depan akan langsung mengubah saldo sekarang, jadi dibatasi sampai hari ini.
      lastDate: now,
      helpText: 'Tanggal transaksi',
    );
    if (picked != null) {
      setState(() => _date = DateTime(picked.year, picked.month, picked.day, _date.hour, _date.minute));
    }
  }

  Future<void> _save() async {
    if (_saving) return; // cegah simpan dua kali
    final from = _from;
    if (from == null) {
      tampilkanPesan(ScaffoldMessenger.of(context), 'Tambahkan akun dulu di Pengaturan.');
      return;
    }
    setState(() => _saving = true);
    final amount = int.parse(_amount);
    final router = GoRouter.of(context);
    final ok = await jalankanAksi(
      context,
      () => _store.saveTxn(
        kind: _kind,
        amount: amount,
        accountId: from,
        toAccountId: _kind == TxnKind.transfer ? _to : null,
        categoryId: _kind == TxnKind.transfer ? null : _category,
        note: _note.text,
        date: _date,
        now: sekarang(),
        editingId: _editing?.id,
      ),
      pesanSukses: '${_kind.label} ${rupiah(amount)} ${_isEdit ? 'diperbarui' : 'tersimpan'}.',
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) router.pop();
  }

  Future<void> _delete() async {
    final txn = _editing!;
    final router = GoRouter.of(context);
    final ok = await jalankanAksi(
      context,
      () => _store.deleteTxn(txn),
      pesanSukses: '${txn.kind.label} ${rupiah(txn.amount)} dihapus.',
      onUndo: () => _store.restoreTxn(txn),
    );
    if (ok && mounted) router.pop();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.editId != null && _editing == null) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Transaksi tidak ditemukan.', style: AppText.body(16, weight: FontWeight.w800)),
                const SizedBox(height: 12),
                TextButton(onPressed: () => context.pop(), child: const Text('Kembali')),
              ],
            ),
          ),
        ),
      );
    }
    final now = sekarang();
    final amount = int.parse(_amount);
    final cats = _store.categoriesFor(_kind);
    final fromLabel = switch (_kind) {
      TxnKind.expense => 'Bayar pakai',
      TxnKind.income => 'Masuk ke akun',
      TxnKind.transfer => 'Dari akun',
    };
    final notePlaceholder = switch (_kind) {
      TxnKind.expense => 'Makan siang di kantin',
      TxnKind.income => 'Uang saku bulan ini',
      TxnKind.transfer => 'Tarik tunai',
    };
    final dateLabel = samaHari(_date, now) ? 'Hari ini' : tanggalPendek(_date);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                children: [
                  Row(
                    children: [
                      RoundIconButton(
                          icon: Icons.close_rounded, tooltip: 'Tutup', size: 44, onPressed: () => context.pop()),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(_isEdit ? 'Ubah transaksi' : 'Tambah transaksi',
                            style: AppText.display(22, weight: FontWeight.w600)),
                      ),
                      if (_isEdit)
                        RoundIconButton(
                            icon: Icons.delete_outline_rounded,
                            tooltip: 'Hapus transaksi',
                            size: 44,
                            onPressed: _delete),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SegmentedPills(
                    labels: [for (final k in TxnKind.values) k.label],
                    selectedIndex: _kind.index,
                    selectedColors: [for (final k in TxnKind.values) k.soft],
                    onChanged: (i) => _setKind(TxnKind.values[i]),
                  ),
                  const SizedBox(height: 14),
                  Semantics(
                    liveRegion: true,
                    label: 'Nominal ${rupiah(amount)}',
                    excludeSemantics: true,
                    child: Column(
                      children: [
                        Text('Nominal', style: AppText.body(13, weight: FontWeight.w800, color: AppColors.muted)),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(rupiah(amount), style: AppText.display(42, color: _kind.ink)),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 22, thickness: 2, color: AppColors.line),
                  _Label(fromLabel),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final a in _store.accounts)
                        ChoicePill(
                          label: a.name,
                          selected: _from == a.id,
                          onTap: () => setState(() {
                            _from = a.id;
                            if (_to == _from) _to = _store.accounts.where((x) => x.id != _from).firstOrNull?.id;
                          }),
                        ),
                    ],
                  ),
                  if (_kind == TxnKind.transfer && _store.accounts.length < 2) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Transfer butuh minimal dua akun. Tambahkan akun di Pengaturan › Kelola akun.',
                      style: AppText.body(13, weight: FontWeight.w700, color: AppColors.expenseInk),
                    ),
                  ] else if (_kind == TxnKind.transfer) ...[
                    const SizedBox(height: 12),
                    const _Label('Ke akun'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final a in _store.accounts.where((a) => a.id != _from))
                          ChoicePill(label: a.name, selected: _to == a.id, onTap: () => setState(() => _to = a.id)),
                      ],
                    ),
                  ] else ...[
                    const SizedBox(height: 12),
                    const _Label('Kategori'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final c in cats)
                          ChoicePill(
                            label: c.name,
                            compact: true,
                            selected: _category == c.id,
                            selectedColor: _kind.soft,
                            selectedText: AppColors.ink,
                            onTap: () => setState(() => _category = c.id),
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        onPressed: _pickDate,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.ink,
                          backgroundColor: AppColors.white,
                          side: const BorderSide(color: AppColors.ink, width: 2),
                          minimumSize: const Size(44, 48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          textStyle: AppText.body(14, weight: FontWeight.w800),
                        ),
                        icon: const Icon(Icons.calendar_month_rounded, size: 18),
                        label: Text(dateLabel),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _Label('Catatan'),
                            TextField(
                              controller: _note,
                              textCapitalization: TextCapitalization.sentences,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => FocusScope.of(context).unfocus(),
                              style: AppText.body(14),
                              decoration: InputDecoration(hintText: notePlaceholder, isDense: true),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: Column(
                children: [
                  if (MediaQuery.of(context).viewInsets.bottom == 0) ...[
                    _Keypad(onPress: _press),
                    const SizedBox(height: 12),
                  ],
                  BoldButton(
                    label: _saving ? 'Menyimpan…' : 'Simpan ${_kind.label.toLowerCase()}',
                    onPressed: _saving ? null : _save,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: AppText.body(13, weight: FontWeight.w800, color: AppColors.muted)),
    );
  }
}

class _Keypad extends StatelessWidget {
  const _Keypad({required this.onPress});

  final ValueChanged<String> onPress;

  static const _keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '000', '0', 'hapus'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var r = 0; r < 4; r++) ...[
          if (r > 0) const SizedBox(height: 8),
          Row(
            children: [
              for (var c = 0; c < 3; c++) ...[
                if (c > 0) const SizedBox(width: 8),
                Expanded(child: _Key(value: _keys[r * 3 + c], onPress: onPress)),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({required this.value, required this.onPress});

  final String value;
  final ValueChanged<String> onPress;

  @override
  Widget build(BuildContext context) {
    final isBack = value == 'hapus';
    return Semantics(
      button: true,
      label: isBack ? 'Hapus angka' : value,
      excludeSemantics: true,
      child: Material(
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.ink, width: 2),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => onPress(value),
          child: SizedBox(
            height: 45,
            child: Center(
              child: isBack
                  ? const Icon(Icons.backspace_outlined, size: 22, color: AppColors.ink)
                  : Text(value, style: AppText.display(22, weight: FontWeight.w600)),
            ),
          ),
        ),
      ),
    );
  }
}
