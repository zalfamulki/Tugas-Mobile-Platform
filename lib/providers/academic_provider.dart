import 'package:flutter/material.dart';
import '../models/matkul_model.dart';
import '../models/mahasiswa_model.dart';
import '../services/academic_service.dart';
import '../models/krs_model.dart';
import '../models/presensi_model.dart';
import '../models/bimbingan_model.dart';
import '../models/user_model.dart';

class AcademicProvider with ChangeNotifier {
  List<MatkulModel> _matkuls = [];
  List<MahasiswaModel> _mahasiswas = [];

  List<KrsModel> _krsList = [];
  List<PresensiModel> _presensiList = [];
  List<BimbinganModel> _bimbinganList = [];
  List<UserModel> _dosenList = [];
  List<MatkulModel> _schedule = [];
  
  bool _isLoading = false;
  String? _error;

  List<MatkulModel> get matkuls => _matkuls;
  List<MahasiswaModel> get mahasiswas => _mahasiswas;

  List<KrsModel> get krsList => _krsList;
  List<PresensiModel> get presensiList => _presensiList;
  List<BimbinganModel> get bimbinganList => _bimbinganList;
  List<UserModel> get dosenList => _dosenList;
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

  Future<void> getAllData(String token, int userId, bool isAdmin) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Fetch matkuls first as they are needed by almost everything
      try {
        _matkuls = await _academicService.fetchMatkuls(token);
      } catch (e) {
        debugPrint("Error fetching matkuls: $e");
      }

      // Parallel fetch for the rest
      await Future.wait([
        _academicService.fetchMahasiswas(token).then((v) => _mahasiswas = v).catchError((e) {
          debugPrint("Error fetchMahasiswas: $e");
          return <MahasiswaModel>[];
        }),
        _academicService.fetchSchedule(token).then((v) => _schedule = v).catchError((e) {
          debugPrint("Error fetchSchedule: $e");
          return <MatkulModel>[];
        }),
        _academicService.fetchKrs(token, isAdmin).then((v) => _krsList = v).catchError((e) {
          debugPrint("Error fetchKrs: $e");
          return <KrsModel>[];
        }),
        _academicService.fetchPresensi(token, isAdmin).then((v) => _presensiList = v).catchError((e) {
          debugPrint("Error fetchPresensi: $e");
          return <PresensiModel>[];
        }),
        _academicService.fetchBimbingan(token, isAdmin).then((v) => _bimbinganList = v).catchError((e) {
          debugPrint("Error fetchBimbingan: $e");
          return <BimbinganModel>[];
        }),
      ]);
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
      if (newMatkul.hari != null) {
        _schedule.add(newMatkul);
      }
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
        // Update schedule as well
        final sIndex = _schedule.indexWhere((s) => s.id == id);
        if (updated.hari != null) {
          if (sIndex != -1) {
            _schedule[sIndex] = updated;
          } else {
            _schedule.add(updated);
          }
        } else if (sIndex != -1) {
          _schedule.removeAt(sIndex);
        }
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> getSchedule(String token) async {
    try {
      _schedule = await _academicService.fetchSchedule(token);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
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

  // KRS
  Future<void> refreshKrsData(String token, bool isAdmin) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      if (isAdmin) {
        _krsList = await _academicService.fetchKrs(token, true);
      } else {
        // Fetch matkuls and KRS
        _matkuls = await _academicService.fetchMatkuls(token);
        
        try {
          _krsList = await _academicService.fetchKrs(token, false);
        } catch (e) {
          debugPrint("Error fetching KRS (likely no mahasiswa record): $e");
          _krsList = [];
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getKrs(String token, bool isAdmin) async {
    _isLoading = true;
    notifyListeners();
    try {
      _krsList = await _academicService.fetchKrs(token, isAdmin);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addKrs(String token, Map<String, dynamic> data) async {
    try {
      final newKrs = await _academicService.storeKrs(token, data);
      _krsList.add(newKrs);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeKrs(String token, int id) async {
    try {
      await _academicService.deleteKrs(token, id);
      _krsList.removeWhere((k) => k.id == id);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> changeKrsStatus(String token, int id, String status) async {
    try {
      final updated = await _academicService.updateKrsStatus(token, id, status);
      final index = _krsList.indexWhere((k) => k.id == id);
      if (index != -1) {
        _krsList[index] = updated;
        // If status becomes approved, we might need to refresh schedule in some cases,
        // but for students it's better to just re-fetch the schedule from backend
        // to ensure it matches the server filtering.
        await getSchedule(token); 
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  // Presensi
  Future<void> getPresensi(String token, bool isAdmin) async {
    _isLoading = true;
    notifyListeners();
    try {
      _presensiList = await _academicService.fetchPresensi(token, isAdmin);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addPresensi(String token, Map<String, dynamic> data, bool isAdmin) async {
    try {
      final newP = await _academicService.storePresensi(token, data, isAdmin);
      // Replace if exists (updateOrCreate logic backend)
      final index = _presensiList.indexWhere((p) => p.matkulId == newP.matkulId && p.tanggal == newP.tanggal && p.mahasiswaId == newP.mahasiswaId);
      if (index != -1) {
        _presensiList[index] = newP;
      } else {
        _presensiList.add(newP);
      }
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updatePresensiStatus(String token, int id, Map<String, dynamic> data) async {
    try {
      final updated = await _academicService.updatePresensi(token, id, data);
      final index = _presensiList.indexWhere((p) => p.id == id);
      if (index != -1) {
        _presensiList[index] = updated;
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removePresensi(String token, int id) async {
    try {
      await _academicService.deletePresensi(token, id);
      _presensiList.removeWhere((p) => p.id == id);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Bimbingan
  Future<void> getBimbingan(String token, bool isAdmin) async {
    _isLoading = true;
    notifyListeners();
    try {
      _bimbinganList = await _academicService.fetchBimbingan(token, isAdmin);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getDosens(String token) async {
    _isLoading = true;
    notifyListeners();
    try {
      _dosenList = await _academicService.fetchDosens(token);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addBimbingan(String token, Map<String, dynamic> data) async {
    try {
      final newB = await _academicService.storeBimbingan(token, data);
      _bimbinganList.insert(0, newB);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> replyBimbingan(String token, int id, Map<String, dynamic> data) async {
    try {
      final updated = await _academicService.updateBimbingan(token, id, data);
      final index = _bimbinganList.indexWhere((b) => b.id == id);
      if (index != -1) {
        _bimbinganList[index] = updated;
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeBimbingan(String token, int id) async {
    try {
      await _academicService.deleteBimbingan(token, id);
      _bimbinganList.removeWhere((b) => b.id == id);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  void clearData() {
    _matkuls = [];
    _mahasiswas = [];
    _krsList = [];
    _presensiList = [];
    _bimbinganList = [];
    _dosenList = [];
    _schedule = [];
    _error = null;
    notifyListeners();
  }
}
