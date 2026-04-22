import 'matkul_model.dart';

class GradeModel {
  final int id;
  final int mahasiswaId;
  final int matkulId;
  final String nilai;
  final MatkulModel? matkul;

  GradeModel({
    required this.id,
    required this.mahasiswaId,
    required this.matkulId,
    required this.nilai,
    this.matkul,
  });

  factory GradeModel.fromJson(Map<String, dynamic> json) {
    return GradeModel(
      id: json['id'],
      mahasiswaId: json['mahasiswa_id'],
      matkulId: json['matkul_id'],
      nilai: json['nilai'] ?? '-',
      matkul: json['matkul'] != null ? MatkulModel.fromJson(json['matkul']) : null,
    );
  }
}
