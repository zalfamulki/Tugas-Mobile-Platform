class MatkulModel {
  final int id;
  final String kode;
  final String nama;
  final String? jurusan;
  final String? hari;
  final String? jamMulai;
  final String? jamSelesai;
  final String? ruangan;

  MatkulModel({
    required this.id,
    required this.kode,
    required this.nama,
    this.jurusan,
    this.hari,
    this.jamMulai,
    this.jamSelesai,
    this.ruangan,
  });

  factory MatkulModel.fromJson(Map<String, dynamic> json) {
    return MatkulModel(
      id: json['id'],
      kode: json['kode'] ?? '',
      nama: json['nama'] ?? '',
      jurusan: json['jurusan'],
      hari: json['hari'],
      jamMulai: json['jam_mulai'],
      jamSelesai: json['jam_selesai'],
      ruangan: json['ruangan'],
    );
  }
}
