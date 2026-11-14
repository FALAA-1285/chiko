import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../core/utils/clock.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/bold.dart';
import '../data/finance_store.dart';

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _store = FinanceStore.instance;
  final _note = TextEditingController();

  TxnKind _kind = TxnKind.expense;
  String _amount = '0';
  String _from = 'dompet';
  String _to = 'dompet';
  String? _category = 'makan';
  late DateTime _date = sekarang();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  void _setKind(TxnKind kind) {
    setState(() {
      _kind = kind;
      final cats = _store.categoriesFor(kind);
      _category = cats.isEmpty ? null : cats.first.id;
      if (kind == TxnKind.transfer) {
        _from = 'bri';
        _to = 'dompet';
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
      }
      a = a.replaceFirst(RegExp(r'^0+'), '');
      _amount = a.isEmpty ? '0' : a;
    });
  }

  Future<void> _pickDate() async {
    final now = sekarang();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
      helpText: 'Tanggal transaksi',
    );
    if (picked != null) setState(() => _date = DateTime(picked.year, picked.month, picked.day, _date.hour, _date.minute));
  }

  void _save() {
    final amount = int.parse(_amount);
    final messenger = ScaffoldMessenger.of(context);
    if (amount <= 0) {
      messenger.showSnackBar(const SnackBar(content: Text('Isi nominalnya dulu, ya.')));
      return;
    }
    if (_kind == TxnKind.transfer && _from == _to) {
      messenger.showSnackBar(const SnackBar(content: Text('Akun asal dan tujuan tidak boleh sama.')));
      return;
    }
    _store.add(
      kind: _kind,
      amount: amount,
      accountId: _from,
      toAccountId: _kind == TxnKind.transfer ? _to : null,
      categoryId: _kind == TxnKind.transfer ? null : _category,
      note: _note.text.trim(),
      date: _date,
    );
    messenger.showSnackBar(SnackBar(content: Text('${_kind.label} ${rupiah(amount)} tersimpan.')));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
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
                      RoundIconButton(icon: Icons.close_rounded, tooltip: 'Tutup', size: 44, onPressed: () => context.pop()),
                      const SizedBox(width: 12),
                      Text('Tambah transaksi', style: AppText.display(22, weight: FontWeight.w600)),
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
                            if (_to == _from) _to = _store.accounts.firstWhere((x) => x.id != _from).id;
                          }),
                        ),
                    ],
                  ),
                  if (_kind == TxnKind.transfer) ...[
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
                  BoldButton(label: 'Simpan ${_kind.label.toLowerCase()}', onPressed: _save),
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
