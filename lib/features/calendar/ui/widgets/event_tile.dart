import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/bold.dart';
import '../../data/event_model.dart';
import '../event_style.dart';

/// Satu acara di agenda: jam di kiri, kartu berwarna kategori di kanan.
class EventTile extends StatelessWidget {
  const EventTile({super.key, required this.event, this.onTap});

  final CalendarEvent event;

  /// Membuka detail (ubah/hapus). Null = tidak bisa diketuk.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tile = IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 52,
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(jam(event.start), style: AppText.body(15, weight: FontWeight.w900)),
                  if (event.end != null)
                    Text(jam(event.end!), style: AppText.body(13, weight: FontWeight.w700, color: AppColors.muted)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: BoldCard(
              color: event.type.soft,
              radius: 18,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TagChip(
                      label: event.type.label, background: AppColors.white, foreground: event.type.ink, outlined: true),
                  const SizedBox(height: 6),
                  Text(event.title, style: AppText.body(16, weight: FontWeight.w800, height: 1.3)),
                  if (event.place.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(event.place, style: AppText.body(13, color: AppColors.inkSoft)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
    if (onTap == null) return tile;
    return Semantics(
      button: true,
      hint: 'Ketuk untuk melihat atau mengubah',
      child: GestureDetector(onTap: onTap, behavior: HitTestBehavior.opaque, child: tile),
    );
  }
}
