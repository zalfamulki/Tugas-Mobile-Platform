import 'mahasiswa_model.dart';
import 'user_model.dart';

class BimbinganModel {
  final int id;
  final int mahasiswaId;
  final int dosenId;
  final String pesan;
  final String? jawaban;
  final String status;
  final String createdAt;
  final MahasiswaModel? mahasiswa;
  final UserModel? dosen;

  BimbinganModel({
    required this.id,
    required this.mahasiswaId,
    required this.dosenId,
    required this.pesan,
    this.jawaban,
    required this.status,
    required this.createdAt,
    this.mahasiswa,
    this.dosen,
  });

  factory BimbinganModel.fromJson(Map<String, dynamic> json) {
    return BimbinganModel(
      id: json['id'],
      mahasiswaId: json['mahasiswa_id'],
      dosenId: json['dosen_id'],
      pesan: json['pesan'],
      jawaban: json['jawaban'],
      status: json['status'],
      createdAt: json['created_at'],
      mahasiswa: json['mahasiswa'] != null ? MahasiswaModel.fromJson(json['mahasiswa']) : null,
      dosen: json['dosen'] != null ? UserModel.fromJson(json['dosen']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mahasiswa_id': mahasiswaId,
      'dosen_id': dosenId,
      'pesan': pesan,
      'jawaban': jawaban,
      'status': status,
    };
  }
}
