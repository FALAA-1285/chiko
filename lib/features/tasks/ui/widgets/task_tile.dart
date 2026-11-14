import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/bold.dart';
import '../../data/task_store.dart';

/// Baris tugas dengan kotak centang.
/// [boxed] = kartu sendiri (layar Tugas); false = baris di dalam kartu (Beranda).
class TaskTile extends StatelessWidget {
  const TaskTile({super.key, required this.task, required this.now, required this.onToggle, this.boxed = true});

  final Task task;
  final DateTime now;
  final VoidCallback onToggle;
  final bool boxed;

  @override
  Widget build(BuildContext context) {
    final urgent = task.isUrgent(now);
    final content = MergeSemantics(
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: boxed ? const EdgeInsets.all(12) : const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 30,
                height: 30,
                child: Checkbox(
                  value: task.done,
                  onChanged: (_) => onToggle(),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: AppText.body(boxed ? 16 : 15, weight: FontWeight.w800, height: 1.3).copyWith(
                        color: task.done ? AppColors.muted : AppColors.ink,
                        decoration: task.done ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        TagChip(
                          label: task.category.label,
                          background: task.category.soft,
                          foreground: task.category.ink,
                          outlined: boxed,
                        ),
                        _Meta(
                          icon: Icons.schedule_rounded,
                          text: labelDeadline(task.dueAt, now),
                          color: urgent ? AppColors.expenseInk : AppColors.inkSoft,
                        ),
                        if (boxed)
                          _Meta(icon: Icons.flag_rounded, text: task.priority.label, color: task.priority.color),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (!boxed) return Material(type: MaterialType.transparency, child: content);

    return BoldCard(
      padding: EdgeInsets.zero,
      radius: 18,
      color: urgent ? AppColors.urgentCard : AppColors.white,
      child: Material(type: MaterialType.transparency, child: content),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.text, required this.color});

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 4),
        Text(text, style: AppText.body(13, weight: FontWeight.w700, color: color)),
      ],
    );
  }
}
