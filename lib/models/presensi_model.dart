import 'matkul_model.dart';
import 'mahasiswa_model.dart';

class PresensiModel {
  final int id;
  final int mahasiswaId;
  final int matkulId;
  final String tanggal;
  final String status;
  final MatkulModel? matkul;
  final MahasiswaModel? mahasiswa;

  PresensiModel({
    required this.id,
    required this.mahasiswaId,
    required this.matkulId,
    required this.tanggal,
    required this.status,
    this.matkul,
    this.mahasiswa,
  });

  factory PresensiModel.fromJson(Map<String, dynamic> json) {
    return PresensiModel(
      id: json['id'],
      mahasiswaId: json['mahasiswa_id'],
      matkulId: json['matkul_id'],
      tanggal: json['tanggal'],
      status: json['status'],
      matkul: json['matkul'] != null ? MatkulModel.fromJson(json['matkul']) : null,
      mahasiswa: json['mahasiswa'] != null ? MahasiswaModel.fromJson(json['mahasiswa']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mahasiswa_id': mahasiswaId,
      'matkul_id': matkulId,
      'tanggal': tanggal,
      'status': status,
    };
  }
}
