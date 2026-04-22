class MahasiswaModel {
  final int id;
  final String nim;
  final String nama;
  final String? email;
  final String? jurusan;

  MahasiswaModel({
    required this.id,
    required this.nim,
    required this.nama,
    this.email,
    this.jurusan,
  });

  factory MahasiswaModel.fromJson(Map<String, dynamic> json) {
    return MahasiswaModel(
      id: json['id'],
      nim: json['nim'] ?? '',
      nama: json['nama'] ?? '',
      email: json['email'],
      jurusan: json['jurusan'],
    );
  }
}
