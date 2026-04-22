import 'package:flutter/material.dart';
import '../models/matkul_model.dart';
import '../models/mahasiswa_model.dart';
import '../services/academic_service.dart';

class AcademicProvider with ChangeNotifier {
  List<MatkulModel> _matkuls = [];
  List<MahasiswaModel> _mahasiswas = [];
  bool _isLoading = false;
  String? _error;

  List<MatkulModel> get matkuls => _matkuls;
  List<MahasiswaModel> get mahasiswas => _mahasiswas;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final AcademicService _academicService = AcademicService();

  Future<void> getMatkuls(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _matkuls = await _academicService.fetchMatkuls(token);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getMahasiswas(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _mahasiswas = await _academicService.fetchMahasiswas(token);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
