import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../models/matkul_model.dart';
import '../models/mahasiswa_model.dart';
import '../models/krs_model.dart';
import '../models/presensi_model.dart';
import '../models/bimbingan_model.dart';
import '../models/user_model.dart';

class AcademicService {
  Map<String, String> _headers(String token) => {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

  Future<List<MatkulModel>> fetchMatkuls(String token) async {
    try {
      debugPrint("Fetching Matkuls from: ${AppConstants.matkul}");
      final response = await http
          .get(Uri.parse(AppConstants.matkul), headers: _headers(token))
          .timeout(const Duration(seconds: 10));

      debugPrint("Matkuls Response Status: ${response.statusCode}");
      if (response.statusCode == 200) {
        debugPrint("Matkuls Response Body: ${response.body}");
        List jsonResponse = jsonDecode(response.body);
        return jsonResponse.map((data) => MatkulModel.fromJson(data)).toList();
      } else {
        debugPrint("Matkuls Error Body: ${response.body}");
        throw Exception('Gagal memuat mata kuliah (${response.statusCode})');
      }
    } catch (e) {
      debugPrint("Exception in fetchMatkuls: $e");
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

  // KRS
  Future<List<KrsModel>> fetchKrs(String token, bool isAdmin) async {
    try {
      final url = isAdmin ? AppConstants.allKrs : AppConstants.krs;
      final response = await http
          .get(Uri.parse(url), headers: _headers(token))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final body = response.body;
        List jsonResponse = jsonDecode(body);
        return jsonResponse.map((data) => KrsModel.fromJson(data)).toList();
      } else {
        throw Exception('Gagal memuat KRS (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      throw Exception('Gagal memuat KRS: $e');
    }
  }

  Future<KrsModel> storeKrs(String token, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse(AppConstants.krs),
      headers: _headers(token),
      body: jsonEncode(data),
    );
    final responseData = jsonDecode(response.body);
    if (response.statusCode == 201) {
      return KrsModel.fromJson(responseData);
    } else {
      String errorMsg = 'Gagal daftar KRS';
      if (responseData['errors'] != null) {
          final errors = responseData['errors'] as Map<String, dynamic>;
          errorMsg = errors.values.first[0];
      } else if (responseData['error'] != null) {
          errorMsg = responseData['error'];
      } else if (responseData['message'] != null) {
          errorMsg = responseData['message'];
      }
      throw Exception(errorMsg);
    }
  }

  Future<void> deleteKrs(String token, int id) async {
    final response = await http.delete(Uri.parse('${AppConstants.krs}/$id'), headers: _headers(token));
    if (response.statusCode != 204) throw Exception('Gagal hapus KRS');
  }

  Future<KrsModel> updateKrsStatus(String token, int id, String status) async {
    final response = await http.put(
      Uri.parse('${AppConstants.krs}/$id/status'),
      headers: _headers(token),
      body: jsonEncode({'status': status}),
    );
    if (response.statusCode == 200) {
      return KrsModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal update status KRS');
    }
  }

  // Presensi
  Future<List<PresensiModel>> fetchPresensi(String token, bool isAdmin) async {
    final url = isAdmin ? AppConstants.allPresensi : AppConstants.presensi;
    final response = await http.get(Uri.parse(url), headers: _headers(token));
    if (response.statusCode == 200) {
      List jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((data) => PresensiModel.fromJson(data)).toList();
    } else {
      throw Exception('Gagal memuat Presensi');
    }
  }

  Future<PresensiModel> storePresensi(String token, Map<String, dynamic> data, bool isAdmin) async {
    final url = isAdmin ? AppConstants.adminPresensi : AppConstants.presensi;
    final response = await http.post(
      Uri.parse(url),
      headers: _headers(token),
      body: jsonEncode(data),
    );
    if (response.statusCode == 201) {
      return PresensiModel.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body)['error'] ?? 'Gagal update presensi';
      throw Exception(error);
    }
  }

  Future<PresensiModel> updatePresensi(String token, int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('${AppConstants.presensi}/$id'),
      headers: _headers(token),
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      return PresensiModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal update presensi');
    }
  }

  Future<void> deletePresensi(String token, int id) async {
    final response = await http.delete(Uri.parse('${AppConstants.presensi}/$id'), headers: _headers(token));
    if (response.statusCode != 204) throw Exception('Gagal hapus Presensi');
  }

  // Bimbingan
  Future<List<BimbinganModel>> fetchBimbingan(String token, bool isAdmin) async {
    final url = isAdmin ? AppConstants.allBimbingan : AppConstants.bimbingan;
    final response = await http.get(Uri.parse(url), headers: _headers(token));
    if (response.statusCode == 200) {
      List jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((data) => BimbinganModel.fromJson(data)).toList();
    } else {
      throw Exception('Gagal memuat Bimbingan');
    }
  }

  Future<List<UserModel>> fetchDosens(String token) async {
    final response = await http.get(Uri.parse(AppConstants.bimbinganDosens), headers: _headers(token));
    if (response.statusCode == 200) {
      List jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((data) => UserModel.fromJson(data)).toList();
    } else {
      throw Exception('Gagal memuat daftar dosen');
    }
  }

  Future<BimbinganModel> storeBimbingan(String token, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse(AppConstants.bimbingan),
      headers: _headers(token),
      body: jsonEncode(data),
    );
    if (response.statusCode == 201) {
      return BimbinganModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal kirim bimbingan');
    }
  }

  Future<BimbinganModel> updateBimbingan(String token, int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('${AppConstants.bimbingan}/$id'),
      headers: _headers(token),
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      return BimbinganModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal merespon bimbingan');
    }
  }

  Future<void> deleteBimbingan(String token, int id) async {
    final response = await http.delete(Uri.parse('${AppConstants.bimbingan}/$id'), headers: _headers(token));
    if (response.statusCode != 204) throw Exception('Gagal hapus bimbingan');
  }
}
