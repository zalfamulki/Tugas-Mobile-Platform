class MahasiswaModel {
  final int id;
  final int? userId;
  final String nim;
  final String nama;
  final String? email;
  final String? jurusan;
  final String? noHp;
  final String? alamat;
  final String? status;

  MahasiswaModel({
    required this.id,
    this.userId,
    required this.nim,
    required this.nama,
    this.email,
    this.jurusan,
    this.noHp,
    this.alamat,
    this.status,
  });

  factory MahasiswaModel.fromJson(Map<String, dynamic> json) {
    return MahasiswaModel(
      id: json['id'],
      userId: json['user_id'],
      nim: json['nim'] ?? '',
      nama: json['nama'] ?? '',
      email: json['email'],
      jurusan: json['jurusan'],
      noHp: json['no_hp'],
      alamat: json['alamat'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'nim': nim,
      'nama': nama,
      'email': email,
      'jurusan': jurusan,
      'no_hp': noHp,
      'alamat': alamat,
      'status': status,
    };
  }
}
