import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/app_scope.dart';
import '../../app/theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/aksi.dart';
import '../../core/widgets/bold.dart';
import '../finance/data/finance_defaults.dart';
import '../finance/data/finance_store.dart';
import '../finance/ui/finance_style.dart';

/// Kerangka lembar bawah: judul, tombol tambah (opsional), tombol tutup, isi.
class _Sheet extends StatelessWidget {
  const _Sheet({required this.title, required this.child, this.onAdd, this.addTooltip, this.actions = const []});

  final String title;
  final Widget child;
  final VoidCallback? onAdd;
  final String? addTooltip;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: AppText.display(22, weight: FontWeight.w600))),
              ...actions,
              if (onAdd != null) ...[
                RoundIconButton(
                    icon: Icons.add_rounded,
                    tooltip: addTooltip ?? 'Tambah',
                    size: 44,
                    background: AppColors.yellow,
                    onPressed: onAdd),
                const SizedBox(width: 8),
              ],
              RoundIconButton(
                  icon: Icons.close_rounded, tooltip: 'Tutup', size: 44, onPressed: () => Navigator.pop(context)),
            ],
          ),
          const SizedBox(height: 14),
          Flexible(child: child),
        ],
      ),
    );
  }
}

Future<void> _bukaSheet(BuildContext context, Widget child) => showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => child,
    );

Widget _label(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: AppText.body(13, weight: FontWeight.w800, color: AppColors.muted)),
    );

/// Pilihan warna bulat.
class _WarnaPilihan extends StatelessWidget {
  const _WarnaPilihan({required this.colors, required this.selected, required this.onSelect});

  final List<Color> colors;
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (var i = 0; i < colors.length; i++)
          Semantics(
            label: 'Warna ${i + 1}',
            selected: i == selected,
            button: true,
            child: InkWell(
              onTap: () => onSelect(i),
              customBorder: const CircleBorder(),
              child: SizedBox(
                width: 44,
                height: 44,
                child: Center(
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: colors[i],
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.ink, width: i == selected ? 3 : 1.5),
                    ),
                    child: i == selected ? const Icon(Icons.check_rounded, size: 18, color: AppColors.ink) : null,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// =================================================================== AKUN

Future<void> bukaKelolaAkun(BuildContext context) => _bukaSheet(context, const _DaftarAkun());

class _DaftarAkun extends StatelessWidget {
  const _DaftarAkun();

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context).finance;
    return _Sheet(
      title: 'Kelola Akun',
      addTooltip: 'Tambah akun',
      onAdd: () => _bukaSheet(context, const _FormAkun()),
      child: ListenableBuilder(
        listenable: store,
        builder: (context, _) => ListView(
          shrinkWrap: true,
          children: [
            for (final acc in store.accounts) ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                onTap: () => _bukaSheet(context, _FormAkun(account: acc)),
                leading: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: acc.color,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.ink, width: 1.5),
                  ),
                  child: Icon(acc.icon, color: AppColors.ink, size: 20),
                ),
                title: Text(acc.name, style: AppText.body(15, weight: FontWeight.w800)),
                subtitle: Text(
                  '${acc.type.label} · saldo awal ${rupiah(acc.initialBalance)}',
                  style: AppText.body(12, color: AppColors.muted),
                ),
                trailing: Text(rupiah(store.balanceOf(acc.id)), style: AppText.body(15, weight: FontWeight.w900)),
              ),
              const Divider(height: 1),
            ],
            const SizedBox(height: 12),
            Center(
              child: Text(
                'Saldo dihitung dari saldo awal + transaksi. Ketuk akun untuk mengubah.',
                textAlign: TextAlign.center,
                style: AppText.body(12, color: AppColors.muted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormAkun extends StatefulWidget {
  const _FormAkun({this.account});

  final Account? account;

  @override
  State<_FormAkun> createState() => _FormAkunState();
}

class _FormAkunState extends State<_FormAkun> {
  late final _nama = TextEditingController(text: widget.account?.name);
  late final _saldo = TextEditingController(text: widget.account == null ? '' : '${widget.account!.initialBalance}');
  late AccountType _type = widget.account?.type ?? AccountType.bank;
  late int _warna =
      widget.account == null ? 0 : paletAkun.indexOf(widget.account!.colorValue).clamp(0, paletAkun.length - 1);
  bool _saving = false;

  @override
  void dispose() {
    _nama.dispose();
    _saldo.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    final store = AppScope.of(context).finance;
    final navigator = Navigator.of(context);
    final ok = await jalankanAksi(
      context,
      () => store.saveAccount(
        name: _nama.text,
        type: _type,
        initialBalance: int.tryParse(_saldo.text) ?? 0,
        colorValue: paletAkun[_warna],
        editingId: widget.account?.id,
      ),
      pesanSukses: 'Akun "${_nama.text.trim()}" disimpan.',
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) navigator.pop();
  }

  Future<void> _delete() async {
    final acc = widget.account!;
    final store = AppScope.of(context).finance;
    final navigator = Navigator.of(context);
    final ok = await jalankanAksi(context, () => store.deleteAccount(acc), pesanSukses: 'Akun "${acc.name}" dihapus.');
    if (ok && mounted) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.account != null;
    return _Sheet(
      title: isEdit ? 'Ubah Akun' : 'Tambah Akun',
      actions: [
        if (isEdit) ...[
          RoundIconButton(icon: Icons.delete_outline_rounded, tooltip: 'Hapus akun', size: 44, onPressed: _delete),
          const SizedBox(width: 8),
        ],
      ],
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('Nama akun'),
            TextField(
              controller: _nama,
              autofocus: !isEdit,
              maxLength: FinanceStore.maxPanjangNama,
              textCapitalization: TextCapitalization.words,
              style: AppText.body(15),
              decoration: const InputDecoration(hintText: 'Misal: BRI, GoPay, Dompet', counterText: ''),
            ),
            const SizedBox(height: 14),
            _label('Jenis'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final t in AccountType.values)
                  ChoicePill(label: t.label, selected: _type == t, onTap: () => setState(() => _type = t)),
              ],
            ),
            const SizedBox(height: 14),
            _label('Saldo awal (saat mulai memakai Chiko)'),
            TextField(
              controller: _saldo,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
              style: AppText.body(15),
              decoration: const InputDecoration(prefixText: 'Rp ', hintText: '0'),
            ),
            const SizedBox(height: 14),
            _label('Warna kartu'),
            _WarnaPilihan(
              colors: [for (final c in paletAkun) Color(c)],
              selected: _warna,
              onSelect: (i) => setState(() => _warna = i),
            ),
            const SizedBox(height: 20),
            BoldButton(label: _saving ? 'Menyimpan…' : 'Simpan Akun', onPressed: _saving ? null : _save),
          ],
        ),
      ),
    );
  }
}

// =================================================================== KATEGORI

Future<void> bukaKelolaKategori(BuildContext context) => _bukaSheet(context, const _DaftarKategori());

class _DaftarKategori extends StatelessWidget {
  const _DaftarKategori();

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context).finance;
    Widget bagian(TxnKind kind) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(kind.label.toUpperCase(), style: AppText.body(12, weight: FontWeight.w900, color: AppColors.muted)),
            const SizedBox(height: 4),
            for (final c in store.categoriesFor(kind))
              ListTile(
                contentPadding: EdgeInsets.zero,
                onTap: () => _bukaSheet(context, _FormKategori(category: c)),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: c.soft, shape: BoxShape.circle),
                  child: Icon(c.icon, color: AppColors.ink, size: 20),
                ),
                title: Text(c.name, style: AppText.body(14, weight: FontWeight.w800)),
                trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.ink),
              ),
          ],
        );

    return _Sheet(
      title: 'Kelola Kategori',
      addTooltip: 'Tambah kategori',
      onAdd: () => _bukaSheet(context, const _FormKategori()),
      child: ListenableBuilder(
        listenable: store,
        builder: (context, _) => ListView(
          shrinkWrap: true,
          children: [
            bagian(TxnKind.expense),
            const SizedBox(height: 14),
            bagian(TxnKind.income),
          ],
        ),
      ),
    );
  }
}

class _FormKategori extends StatefulWidget {
  const _FormKategori({this.category});

  final TxnCategory? category;

  @override
  State<_FormKategori> createState() => _FormKategoriState();
}

class _FormKategoriState extends State<_FormKategori> {
  late final _nama = TextEditingController(text: widget.category?.name);
  late TxnKind _kind = widget.category?.kind ?? TxnKind.expense;
  late String _ikon = widget.category?.iconKey ?? kunciIkonKategori.first;
  late int _warna = widget.category == null
      ? 0
      : paletKategori.indexWhere((p) => p.$1 == widget.category!.colorValue).clamp(0, paletKategori.length - 1);
  bool _saving = false;

  @override
  void dispose() {
    _nama.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    final store = AppScope.of(context).finance;
    final navigator = Navigator.of(context);
    final ok = await jalankanAksi(
      context,
      () => store.saveCategory(
        name: _nama.text,
        kind: _kind,
        iconKey: _ikon,
        paletIndex: _warna,
        editingId: widget.category?.id,
      ),
      pesanSukses: 'Kategori "${_nama.text.trim()}" disimpan.',
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) navigator.pop();
  }

  Future<void> _delete() async {
    final cat = widget.category!;
    final store = AppScope.of(context).finance;
    final navigator = Navigator.of(context);
    final ok =
        await jalankanAksi(context, () => store.deleteCategory(cat), pesanSukses: 'Kategori "${cat.name}" dihapus.');
    if (ok && mounted) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.category != null;
    final (warna, latar) = paletKategori[_warna];
    return _Sheet(
      title: isEdit ? 'Ubah Kategori' : 'Tambah Kategori',
      actions: [
        if (isEdit) ...[
          RoundIconButton(icon: Icons.delete_outline_rounded, tooltip: 'Hapus kategori', size: 44, onPressed: _delete),
          const SizedBox(width: 8),
        ],
      ],
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('Nama kategori'),
            TextField(
              controller: _nama,
              autofocus: !isEdit,
              maxLength: FinanceStore.maxPanjangNama,
              textCapitalization: TextCapitalization.sentences,
              style: AppText.body(15),
              decoration: const InputDecoration(hintText: 'Misal: Kos, Pulsa, Beasiswa', counterText: ''),
            ),
            const SizedBox(height: 14),
            _label('Jenis'),
            Wrap(
              spacing: 8,
              children: [
                for (final k in [TxnKind.expense, TxnKind.income])
                  ChoicePill(label: k.label, selected: _kind == k, onTap: () => setState(() => _kind = k)),
              ],
            ),
            const SizedBox(height: 14),
            _label('Ikon'),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final key in kunciIkonKategori)
                  Semantics(
                    label: 'Ikon $key',
                    selected: key == _ikon,
                    button: true,
                    child: InkWell(
                      onTap: () => setState(() => _ikon = key),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: key == _ikon ? Color(latar) : AppColors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.ink, width: key == _ikon ? 2.5 : 1.5),
                        ),
                        child: Icon(ikonKategori(key), color: AppColors.ink, size: 22),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            _label('Warna di grafik'),
            _WarnaPilihan(
              colors: [for (final p in paletKategori) Color(p.$1)],
              selected: _warna,
              onSelect: (i) => setState(() => _warna = i),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color(latar),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.ink, width: 2),
                  ),
                  child: Icon(ikonKategori(_ikon), size: 20, color: AppColors.ink),
                ),
                const SizedBox(width: 10),
                Container(
                    width: 60,
                    height: 14,
                    decoration: BoxDecoration(color: Color(warna), borderRadius: BorderRadius.circular(6))),
                const SizedBox(width: 10),
                Text('Pratinjau', style: AppText.body(12, color: AppColors.muted)),
              ],
            ),
            const SizedBox(height: 20),
            BoldButton(label: _saving ? 'Menyimpan…' : 'Simpan Kategori', onPressed: _saving ? null : _save),
          ],
        ),
      ),
    );
  }
}
