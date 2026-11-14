import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../../app/theme.dart';

/// Geser ke kiri untuk menghapus, dengan latar merah dan ikon tempat sampah.
///
/// Untuk pengguna pembaca layar/yang sulit menggeser, tersedia aksi aksesibilitas
/// "Hapus" ([label]) — selain tombol hapus di layar detail masing-masing.
class SwipeToDelete extends StatelessWidget {
  const SwipeToDelete({
    required Key key,
    required this.child,
    required this.onDelete,
    required this.label,
    this.radius = 0,
  }) : super(key: key);

  final Widget child;
  final VoidCallback onDelete;
  final String label;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      customSemanticsActions: {CustomSemanticsAction(label: label): onDelete},
      child: Dismissible(
        key: key!,
        direction: DismissDirection.endToStart,
        onDismissed: (_) => onDelete(),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(color: AppColors.expenseSoft, borderRadius: BorderRadius.circular(radius)),
          child: const Icon(Icons.delete_outline_rounded, color: AppColors.expenseInk),
        ),
        child: child,
      ),
    );
  }
}
