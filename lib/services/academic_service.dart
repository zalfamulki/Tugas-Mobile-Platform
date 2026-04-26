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

  // Matkul CRUD
  Future<MatkulModel> storeMatkul(String token, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse(AppConstants.matkul),
      headers: _headers(token),
      body: jsonEncode(data),
    );
    if (response.statusCode == 201) {
      return MatkulModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal menambah mata kuliah: ${response.body}');
    }
  }

  Future<MatkulModel> updateMatkul(String token, int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('${AppConstants.matkul}/$id'),
      headers: _headers(token),
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      return MatkulModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal update mata kuliah: ${response.body}');
    }
  }

  Future<void> deleteMatkul(String token, int id) async {
    final response = await http.delete(
      Uri.parse('${AppConstants.matkul}/$id'),
      headers: _headers(token),
    );
    if (response.statusCode != 204) {
      throw Exception('Gagal menghapus mata kuliah: ${response.body}');
    }
  }

  // Mahasiswa CRUD
  Future<MahasiswaModel> storeMahasiswa(String token, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse(AppConstants.mahasiswa),
      headers: _headers(token),
      body: jsonEncode(data),
    );
    if (response.statusCode == 201) {
      return MahasiswaModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal menambah mahasiswa: ${response.body}');
    }
  }

  Future<MahasiswaModel> updateMahasiswa(String token, int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('${AppConstants.mahasiswa}/$id'),
      headers: _headers(token),
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      return MahasiswaModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal update mahasiswa: ${response.body}');
    }
  }

  Future<void> deleteMahasiswa(String token, int id) async {
    final response = await http.delete(
      Uri.parse('${AppConstants.mahasiswa}/$id'),
      headers: _headers(token),
    );
    if (response.statusCode != 204) {
      throw Exception('Gagal menghapus mahasiswa: ${response.body}');
    }
  }

  // Grade CRUD
  Future<GradeModel> storeGrade(String token, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse(AppConstants.grade),
      headers: _headers(token),
      body: jsonEncode(data),
    );
    if (response.statusCode == 201) {
      return GradeModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal menambah nilai: ${response.body}');
    }
  }

  Future<GradeModel> updateGrade(String token, int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('${AppConstants.grade}/$id'),
      headers: _headers(token),
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      return GradeModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal update nilai: ${response.body}');
    }
  }

  Future<void> deleteGrade(String token, int id) async {
    final response = await http.delete(
      Uri.parse('${AppConstants.grade}/$id'),
      headers: _headers(token),
    );
    if (response.statusCode != 204) {
      throw Exception('Gagal menghapus nilai: ${response.body}');
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
