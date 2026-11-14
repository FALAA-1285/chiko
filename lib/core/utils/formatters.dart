const _hari = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
const _hariPendek = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
const _bulan = [
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'Desember',
];
const _bulanPendek = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];

/// Singkatan hari Senin–Minggu, untuk kepala kalender.
const hariPendekList = _hariPendek;

/// 1250000 -> "Rp 1.250.000", -5000 -> "-Rp 5.000"
String rupiah(int n) {
  final s = n.abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return '${n < 0 ? '-' : ''}Rp $buf';
}

/// 45000 -> "45rb", 1500000 -> "1,5jt", -45000 -> "-45rb"
String rupiahSingkat(int n) {
  final tanda = n < 0 ? '-' : '';
  final a = n.abs();
  if (a >= 1000000) {
    var jt = (a / 1000000).toStringAsFixed(1);
    if (jt.endsWith('.0')) jt = jt.substring(0, jt.length - 2);
    return '$tanda${jt.replaceAll('.', ',')}jt';
  }
  if (a >= 1000) return '$tanda${a ~/ 1000}rb';
  return '$tanda$a';
}

String namaHari(DateTime d) => _hari[d.weekday - 1];
String namaBulan(int month) => _bulan[month - 1];

/// "Senin, 16 November"
String tanggalPanjang(DateTime d) => '${namaHari(d)}, ${d.day} ${namaBulan(d.month)}';

/// "Rab, 18 Nov"
String tanggalPendek(DateTime d) => '${_hariPendek[d.weekday - 1]}, ${d.day} ${_bulanPendek[d.month - 1]}';

/// "07.00"
String jam(DateTime d) => '${d.hour.toString().padLeft(2, '0')}.${d.minute.toString().padLeft(2, '0')}';

/// "9–20 Nov" / "28 Okt – 3 Nov" / "28 Des 2026 – 3 Jan 2027"
String rentangTanggal(DateTime a, DateTime b) {
  if (a.year != b.year) {
    return '${a.day} ${_bulanPendek[a.month - 1]} ${a.year} – ${b.day} ${_bulanPendek[b.month - 1]} ${b.year}';
  }
  if (a.month != b.month) return '${a.day} ${_bulanPendek[a.month - 1]} – ${b.day} ${_bulanPendek[b.month - 1]}';
  if (a.day == b.day) return '${a.day} ${_bulanPendek[a.month - 1]}';
  return '${a.day}–${b.day} ${_bulanPendek[a.month - 1]}';
}

DateTime tanpaJam(DateTime d) => DateTime(d.year, d.month, d.day);

bool samaHari(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

/// Selisih hari kalender dari [from] ke [to] (aman dari pergeseran jam/DST).
int selisihHari(DateTime from, DateTime to) =>
    DateTime.utc(to.year, to.month, to.day).difference(DateTime.utc(from.year, from.month, from.day)).inDays;

/// Senin pada minggu yang sama dengan [d], jam 00.00.
DateTime awalMinggu(DateTime d) => DateTime(d.year, d.month, d.day - (d.weekday - 1));

/// "Hari ini, 23.59" / "Besok, 23.59" / "Kemarin" / "Rab, 18 Nov"
String labelDeadline(DateTime due, DateTime now) {
  final selisih = selisihHari(now, due);
  if (selisih == 0) return 'Hari ini, ${jam(due)}';
  if (selisih == 1) return 'Besok, ${jam(due)}';
  if (selisih == -1) return 'Kemarin';
  return tanggalPendek(due);
}

/// "Hari ini" / "Kemarin" / "12 November"
String labelHariTransaksi(DateTime d, DateTime now) {
  final selisih = selisihHari(d, now);
  if (selisih == 0) return 'Hari ini';
  if (selisih == 1) return 'Kemarin';
  return '${d.day} ${namaBulan(d.month)}';
}
