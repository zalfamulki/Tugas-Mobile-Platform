import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../models/matkul_model.dart';
import '../models/mahasiswa_model.dart';

class AcademicService {
  Future<List<MatkulModel>> fetchMatkuls(String token) async {
    final response = await http.get(
      Uri.parse(AppConstants.matkul),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((data) => MatkulModel.fromJson(data)).toList();
    } else {
      throw Exception('Gagal memuat mata kuliah');
    }
  }

  Future<List<MahasiswaModel>> fetchMahasiswas(String token) async {
    final response = await http.get(
      Uri.parse(AppConstants.mahasiswa),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((data) => MahasiswaModel.fromJson(data)).toList();
    } else {
      throw Exception('Gagal memuat data mahasiswa');
    }
  }
}
