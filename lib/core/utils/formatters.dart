const _hari = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
const _hariPendek = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
const _bulan = [
  'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
  'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
];
const _bulanPendek = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];

/// Singkatan hari Senin–Minggu, untuk kepala kalender.
const hariPendekList = _hariPendek;

/// 1250000 -> "Rp 1.250.000"
String rupiah(int n) {
  final s = n.abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return 'Rp $buf';
}

/// 45000 -> "45rb", 1500000 -> "1,5jt"
String rupiahSingkat(int n) {
  if (n >= 1000000) {
    final jt = (n / 1000000).toStringAsFixed(1).replaceAll('.0', '').replaceAll('.', ',');
    return '${jt}jt';
  }
  if (n >= 1000) return '${n ~/ 1000}rb';
  return '$n';
}

String namaHari(DateTime d) => _hari[d.weekday - 1];
String namaBulan(int month) => _bulan[month - 1];

/// "Senin, 16 November"
String tanggalPanjang(DateTime d) => '${namaHari(d)}, ${d.day} ${namaBulan(d.month)}';

/// "Rab, 18 Nov"
String tanggalPendek(DateTime d) => '${_hariPendek[d.weekday - 1]}, ${d.day} ${_bulanPendek[d.month - 1]}';

/// "07.00"
String jam(DateTime d) => '${d.hour.toString().padLeft(2, '0')}.${d.minute.toString().padLeft(2, '0')}';

DateTime tanpaJam(DateTime d) => DateTime(d.year, d.month, d.day);

bool samaHari(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

/// "Hari ini, 23.59" / "Besok, 23.59" / "Kemarin" / "Rab, 18 Nov"
String labelDeadline(DateTime due, DateTime now) {
  final selisih = tanpaJam(due).difference(tanpaJam(now)).inDays;
  if (selisih == 0) return 'Hari ini, ${jam(due)}';
  if (selisih == 1) return 'Besok, ${jam(due)}';
  if (selisih == -1) return 'Kemarin';
  return tanggalPendek(due);
}

/// "Hari ini" / "Kemarin" / "12 November"
String labelHariTransaksi(DateTime d, DateTime now) {
  final selisih = tanpaJam(now).difference(tanpaJam(d)).inDays;
  if (selisih == 0) return 'Hari ini';
  if (selisih == 1) return 'Kemarin';
  return '${d.day} ${namaBulan(d.month)}';
}
