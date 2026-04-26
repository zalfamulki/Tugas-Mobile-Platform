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

  // Matkul Actions
  Future<void> addMatkul(String token, Map<String, dynamic> data) async {
    try {
      final newMatkul = await _academicService.storeMatkul(token, data);
      _matkuls.add(newMatkul);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> editMatkul(String token, int id, Map<String, dynamic> data) async {
    try {
      final updated = await _academicService.updateMatkul(token, id, data);
      final index = _matkuls.indexWhere((m) => m.id == id);
      if (index != -1) {
        _matkuls[index] = updated;
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeMatkul(String token, int id) async {
    try {
      await _academicService.deleteMatkul(token, id);
      _matkuls.removeWhere((m) => m.id == id);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Mahasiswa Actions
  Future<void> addMahasiswa(String token, Map<String, dynamic> data) async {
    try {
      final newMhs = await _academicService.storeMahasiswa(token, data);
      _mahasiswas.add(newMhs);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> editMahasiswa(String token, int id, Map<String, dynamic> data) async {
    try {
      final updated = await _academicService.updateMahasiswa(token, id, data);
      final index = _mahasiswas.indexWhere((m) => m.id == id);
      if (index != -1) {
        _mahasiswas[index] = updated;
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeMahasiswa(String token, int id) async {
    try {
      await _academicService.deleteMahasiswa(token, id);
      _mahasiswas.removeWhere((m) => m.id == id);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Grade Actions
  Future<void> addGrade(String token, Map<String, dynamic> data) async {
    try {
      final newGrade = await _academicService.storeGrade(token, data);
      _grades.add(newGrade);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> editGrade(String token, int id, Map<String, dynamic> data) async {
    try {
      final updated = await _academicService.updateGrade(token, id, data);
      final index = _grades.indexWhere((g) => g.id == id);
      if (index != -1) {
        _grades[index] = updated;
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeGrade(String token, int id) async {
    try {
      await _academicService.deleteGrade(token, id);
      _grades.removeWhere((g) => g.id == id);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
