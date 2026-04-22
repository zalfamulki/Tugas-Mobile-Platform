import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../models/matkul_model.dart';
import '../models/mahasiswa_model.dart';

import '../models/grade_model.dart';

class AcademicService {
  Map<String, String> _headers(String token) => {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

  Future<List<MatkulModel>> fetchMatkuls(String token) async {
    try {
      final response = await http
          .get(Uri.parse(AppConstants.matkul), headers: _headers(token))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        List jsonResponse = jsonDecode(response.body);
        return jsonResponse.map((data) => MatkulModel.fromJson(data)).toList();
      } else {
        throw Exception('Gagal memuat mata kuliah (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Koneksi bermasalah: $e');
    }
  }

  Future<List<MahasiswaModel>> fetchMahasiswas(String token) async {
    try {
      final response = await http
          .get(Uri.parse(AppConstants.mahasiswa), headers: _headers(token))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        List jsonResponse = jsonDecode(response.body);
        return jsonResponse.map((data) => MahasiswaModel.fromJson(data)).toList();
      } else {
        throw Exception('Gagal memuat data mahasiswa (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Koneksi bermasalah: $e');
    }
  }

  Future<List<GradeModel>> fetchGrades(String token, int userId) async {
    try {
      // Endpoint depends on roles, but for students we use getByMahasiswa
      final response = await http
          .get(Uri.parse('${AppConstants.grade}/mahasiswa/$userId'), headers: _headers(token))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        List jsonResponse = jsonDecode(response.body);
        return jsonResponse.map((data) => GradeModel.fromJson(data)).toList();
      } else {
        throw Exception('Gagal memuat nilai (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Koneksi bermasalah: $e');
    }
  }

  Future<List<MatkulModel>> fetchSchedule(String token) async {
    try {
      final response = await http
          .get(Uri.parse(AppConstants.schedule), headers: _headers(token))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        List jsonResponse = jsonDecode(response.body);
        return jsonResponse.map((data) => MatkulModel.fromJson(data)).toList();
      } else {
        throw Exception('Gagal memuat jadwal (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Koneksi bermasalah: $e');
    }
  }
}
