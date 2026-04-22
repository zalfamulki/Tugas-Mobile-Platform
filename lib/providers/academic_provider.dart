import 'package:flutter/material.dart';
import '../models/matkul_model.dart';
import '../models/mahasiswa_model.dart';
import '../services/academic_service.dart';

import '../models/grade_model.dart';

class AcademicProvider with ChangeNotifier {
  List<MatkulModel> _matkuls = [];
  List<MahasiswaModel> _mahasiswas = [];
  List<GradeModel> _grades = [];
  List<MatkulModel> _schedule = [];
  
  bool _isLoading = false;
  String? _error;

  List<MatkulModel> get matkuls => _matkuls;
  List<MahasiswaModel> get mahasiswas => _mahasiswas;
  List<GradeModel> get grades => _grades;
  List<MatkulModel> get schedule => _schedule;
  
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;
  bool get isEmpty => !isLoading && !hasError && _matkuls.isEmpty && _mahasiswas.isEmpty;

  final AcademicService _academicService = AcademicService();

  // Search logic
  String _searchQuery = '';
  List<MahasiswaModel> get filteredMahasiswas => _mahasiswas
      .where((m) => m.nama.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                   m.nim.contains(_searchQuery))
      .toList();

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> getAllData(String token, int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Parallel fetching for better performance
      final results = await Future.wait([
        _academicService.fetchMatkuls(token),
        _academicService.fetchMahasiswas(token),
        _academicService.fetchGrades(token, userId),
        _academicService.fetchSchedule(token),
      ]);

      _matkuls = results[0] as List<MatkulModel>;
      _mahasiswas = results[1] as List<MahasiswaModel>;
      _grades = results[2] as List<GradeModel>;
      _schedule = results[3] as List<MatkulModel>;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

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
