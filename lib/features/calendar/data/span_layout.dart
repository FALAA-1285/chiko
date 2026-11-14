import '../../../core/utils/formatters.dart';
import '../../tasks/data/task_model.dart';

/// Potongan blok satu tugas berentang di satu baris minggu kalender.
class SpanBar {
  const SpanBar({
    required this.task,
    required this.startCol,
    required this.endCol,
    required this.lane,
    required this.continuesLeft,
    required this.continuesRight,
  });

  final Task task;

  /// Kolom pertama dan terakhir (0 = Senin, 6 = Minggu), inklusif.
  final int startCol;
  final int endCol;

  /// Lajur ke berapa (0 = paling atas) supaya blok tidak saling tumpang tindih.
  final int lane;

  /// Blok berlanjut dari minggu sebelumnya / ke minggu berikutnya.
  final bool continuesLeft;
  final bool continuesRight;

  bool covers(int col) => col >= startCol && col <= endCol;
}

/// Menata blok tugas berentang untuk satu minggu yang dimulai [weekStart] (Senin).
///
/// Seperti tampilan bulan di Notion: blok yang mulai lebih awal (lalu yang lebih
/// panjang) mendapat lajur paling atas; blok lain mengisi lajur pertama yang
/// masih kosong di kolom-kolomnya.
List<SpanBar> layoutWeek(DateTime weekStart, Iterable<Task> tasks) {
  final items = <(Task, int, int, bool, bool)>[];
  for (final t in tasks) {
    if (!t.hasSpan) continue;
    final from = selisihHari(weekStart, t.startAt!);
    final to = selisihHari(weekStart, t.dueAt);
    if (to < 0 || from > 6 || to < from) continue;
    items.add((t, from.clamp(0, 6), to.clamp(0, 6), from < 0, to > 6));
  }
  // Blok yang bersambung dari minggu lalu didahulukan supaya tetap di lajur atas,
  // lalu yang mulai lebih awal, lalu yang lebih panjang.
  items.sort((a, b) {
    if (a.$4 != b.$4) return a.$4 ? -1 : 1;
    final c = a.$2.compareTo(b.$2);
    return c != 0 ? c : (b.$3 - b.$2).compareTo(a.$3 - a.$2);
  });

  final laneEnds = <int>[];
  final bars = <SpanBar>[];
  for (final (task, start, end, left, right) in items) {
    var lane = laneEnds.indexWhere((e) => e < start);
    if (lane < 0) {
      lane = laneEnds.length;
      laneEnds.add(end);
    } else {
      laneEnds[lane] = end;
    }
    bars.add(SpanBar(
      task: task,
      startCol: start,
      endCol: end,
      lane: lane,
      continuesLeft: left,
      continuesRight: right,
    ));
  }
  return bars;
}
