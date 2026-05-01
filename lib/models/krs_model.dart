import 'matkul_model.dart';
import 'mahasiswa_model.dart';

class KrsModel {
  final int id;
  final int mahasiswaId;
  final int matkulId;
  final String semester;
  final String status;
  final MatkulModel? matkul;
  final MahasiswaModel? mahasiswa;

  KrsModel({
    required this.id,
    required this.mahasiswaId,
    required this.matkulId,
    required this.semester,
    required this.status,
    this.matkul,
    this.mahasiswa,
  });

  factory KrsModel.fromJson(Map<String, dynamic> json) {
    return KrsModel(
      id: json['id'],
      mahasiswaId: json['mahasiswa_id'],
      matkulId: json['matkul_id'],
      semester: json['semester'] ?? '',
      status: json['status'] ?? 'pending',
      matkul: json['matkul'] != null ? MatkulModel.fromJson(json['matkul']) : null,
      mahasiswa: json['mahasiswa'] != null ? MahasiswaModel.fromJson(json['mahasiswa']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mahasiswa_id': mahasiswaId,
      'matkul_id': matkulId,
      'semester': semester,
      'status': status,
    };
  }
}
