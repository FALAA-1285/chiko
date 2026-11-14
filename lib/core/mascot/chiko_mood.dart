import '../../features/finance/data/finance_store.dart';
import '../../features/tasks/data/task_store.dart';
import '../utils/formatters.dart';
import 'chiko.dart';

/// Apa yang Chiko rasakan dan katakan di Beranda.
class ChikoStatus {
  const ChikoStatus(this.mood, this.message, {this.action, this.route});

  final ChikoMood mood;
  final String message;
  final String? action;
  final String? route;
}

/// Batas saldo Dompet yang dianggap "menipis".
const batasSaldoMenipis = 50000;

/// Menentukan ekspresi Chiko dari data tugas dan keuangan.
/// Urutan prioritas: malam > deadline mepet > saldo menipis > semua beres > baru menyelesaikan tugas > santai.
ChikoStatus hitungMood({required DateTime now, required TaskStore tasks, required FinanceStore finance}) {
  if (now.hour >= 22 || now.hour < 5) {
    return const ChikoStatus(ChikoMood.tidur, 'Sudah malam. Istirahat dulu, besok kita lanjut.');
  }

  final mepet = tasks.active.where((t) => t.isUrgent(now)).toList();
  if (mepet.isNotEmpty) {
    final t = mepet.first;
    final kapan = labelDeadline(t.dueAt, now);
    return ChikoStatus(
      ChikoMood.khawatir,
      '${t.title} dikumpulkan ${kapan[0].toLowerCase()}${kapan.substring(1)}. Kita cicil sekarang?',
      action: 'Mulai kerjakan',
      route: '/tugas',
    );
  }

  final dompet = finance.accounts.where((a) => a.type == AccountType.cash).toList();
  for (final a in dompet) {
    final saldo = finance.balanceOf(a.id);
    if (saldo < batasSaldoMenipis) {
      return ChikoStatus(
        ChikoMood.kaget,
        'Saldo ${a.name} tinggal ${rupiah(saldo)}. Hemat dulu, ya!',
        action: 'Lihat keuangan',
        route: '/keuangan',
      );
    }
  }

  if (tasks.active.isEmpty) {
    return const ChikoStatus(ChikoMood.rayakan, 'Semua tugas beres! Kamu keren hari ini.');
  }

  final selesaiHariIni = tasks.completedOn(now).length;
  if (selesaiHariIni > 0) {
    return ChikoStatus(ChikoMood.senang, 'Mantap, $selesaiHariIni tugas selesai hari ini!');
  }

  return ChikoStatus(
    ChikoMood.santai,
    'Hari ini aman. Ada ${tasks.active.length} tugas yang menunggu.',
    action: 'Lihat tugas',
    route: '/tugas',
  );
}
