import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// Kartu khas app: garis hitam tebal, sudut bulat, bayangan pekat opsional.
class BoldCard extends StatelessWidget {
  const BoldCard({
    super.key,
    required this.child,
    this.color = AppColors.white,
    this.radius = 20,
    this.padding = const EdgeInsets.all(14),
    this.shadow = false,
  });

  final Widget child;
  final Color color;
  final double radius;
  final EdgeInsetsGeometry padding;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColors.ink, width: 2),
        boxShadow: shadow ? const [BoxShadow(color: AppColors.ink, offset: Offset(0, 4))] : null,
      ),
      child: child,
    );
  }
}

/// Tombol utama kuning lebar penuh.
class BoldButton extends StatelessWidget {
  const BoldButton({super.key, required this.label, required this.onPressed, this.color = AppColors.yellow});

  final String label;
  final VoidCallback? onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: AppColors.ink, offset: Offset(0, 4))],
      ),
      child: Material(
        color: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.ink, width: 2),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: SizedBox(
            height: 56,
            width: double.infinity,
            child: Center(child: Text(label, style: AppText.display(19, weight: FontWeight.w600))),
          ),
        ),
      ),
    );
  }
}

/// Tombol ikon bulat putih bergaris (notifikasi, cari, tutup, panah bulan).
class RoundIconButton extends StatelessWidget {
  const RoundIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.size = 46,
    this.background = AppColors.white,
    this.badge = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final double size;
  final Color background;
  final bool badge;

  @override
  Widget build(BuildContext context) {
    // Tombol nonaktif (onPressed null) dibuat pudar supaya terlihat tidak bisa diketuk.
    return Tooltip(
      message: tooltip,
      child: Opacity(
        opacity: onPressed == null ? 0.35 : 1,
        child: Material(
          color: background,
          shape: const CircleBorder(side: BorderSide(color: AppColors.ink, width: 2)),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            child: SizedBox(
              width: size,
              height: size,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(icon, size: size * 0.48, color: AppColors.ink),
                  if (badge)
                    Positioned(
                      top: size * 0.18,
                      right: size * 0.2,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppColors.danger,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Tombol tambah bulat kuning di pojok kanan bawah.
class AddFab extends StatelessWidget {
  const AddFab({super.key, required this.tooltip, required this.onPressed});

  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: AppColors.ink, offset: Offset(0, 4))],
        ),
        child: Material(
          color: AppColors.yellow,
          shape: const CircleBorder(side: BorderSide(color: AppColors.ink, width: 2)),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            child: const SizedBox(
              width: 60,
              height: 60,
              child: Icon(Icons.add_rounded, size: 32, color: AppColors.ink),
            ),
          ),
        ),
      ),
    );
  }
}

/// Judul bagian + tautan di kanan ("Lihat semua").
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.action, this.onAction, this.trailing});

  final String title;
  final String? action;
  final VoidCallback? onAction;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: AppText.display(20, weight: FontWeight.w600))),
        if (trailing != null) Text(trailing!, style: AppText.body(14, weight: FontWeight.w800, color: AppColors.muted)),
        if (action != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.ink,
              minimumSize: const Size(44, 44),
              padding: const EdgeInsets.symmetric(horizontal: 6),
            ),
            child: Text(
              action!,
              style: AppText.body(14, weight: FontWeight.w800).copyWith(decoration: TextDecoration.underline),
            ),
          ),
      ],
    );
  }
}

/// Label kecil berbentuk pil (kategori tugas, jenis jadwal).
class TagChip extends StatelessWidget {
  const TagChip(
      {super.key, required this.label, required this.background, required this.foreground, this.outlined = false});

  final String label;
  final Color background;
  final Color foreground;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: outlined ? Border.all(color: AppColors.ink, width: 1.5) : null,
      ),
      child: Text(label, style: AppText.body(12, weight: FontWeight.w800, color: foreground)),
    );
  }
}

/// Pil yang bisa dipilih (filter kategori, pilihan akun).
class ChoicePill extends StatelessWidget {
  const ChoicePill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.selectedColor = AppColors.ink,
    this.selectedText = AppColors.white,
    this.compact = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color selectedColor;
  final Color selectedText;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? selectedColor : AppColors.white,
        shape: const StadiumBorder(side: BorderSide(color: AppColors.ink, width: 2)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: compact ? 36 : 40),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 14),
              child: Center(
                widthFactor: 1,
                child: Text(
                  label,
                  style: AppText.body(compact ? 13 : 14,
                      weight: FontWeight.w800, color: selected ? selectedText : AppColors.ink),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Tab bersegmen dalam kotak putih bergaris (Aktif/Selesai, Bulan/Minggu).
class SegmentedPills extends StatelessWidget {
  const SegmentedPills({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
    this.selectedColors,
    this.expand = true,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final List<Color>? selectedColors;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];
    for (var i = 0; i < labels.length; i++) {
      final selected = i == selectedIndex;
      final color = selectedColors?[i] ?? AppColors.yellow;
      final tab = Semantics(
        selected: selected,
        button: true,
        child: GestureDetector(
          onTap: () => onChanged(i),
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: selected ? color : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: selected ? AppColors.ink : Colors.transparent, width: 2),
            ),
            alignment: Alignment.center,
            child: Text(
              labels[i],
              style: AppText.body(14,
                  weight: selected ? FontWeight.w900 : FontWeight.w700,
                  color: selected ? AppColors.ink : AppColors.inkSoft),
            ),
          ),
        ),
      );
      items.add(expand ? Expanded(child: tab) : tab);
      if (i < labels.length - 1) items.add(const SizedBox(width: 4));
    }
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.ink, width: 2),
      ),
      child: Row(mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min, children: items),
    );
  }
}

/// Bilah progres bergaris.
class BoldProgressBar extends StatelessWidget {
  const BoldProgressBar({super.key, required this.value, this.fill = AppColors.ink, this.track = AppColors.white});

  final double value;
  final Color fill;
  final Color track;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 14,
      decoration: BoxDecoration(
        color: track,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: AppColors.ink, width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: value.clamp(0.0, 1.0),
        heightFactor: 1,
        child: ColoredBox(color: fill),
      ),
    );
  }
}
