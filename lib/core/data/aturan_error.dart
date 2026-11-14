/// Pelanggaran aturan bisnis (validasi). [pesan] siap ditampilkan ke pengguna.
class AturanError implements Exception {
  const AturanError(this.pesan);

  final String pesan;

  @override
  String toString() => 'AturanError: $pesan';
}
