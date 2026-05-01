import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/academic_provider.dart';
import '../models/matkul_model.dart';
import '../models/mahasiswa_model.dart';
import '../widgets/state_widgets.dart';
import '../utils/theme.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

class PresensiScreen extends StatefulWidget {
  const PresensiScreen({super.key});

  @override
  State<PresensiScreen> createState() => _PresensiScreenState();
}

class _PresensiScreenState extends State<PresensiScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  Future<void> _fetchData() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final academic = Provider.of<AcademicProvider>(context, listen: false);
    final isAdmin = auth.user?.role == 'admin';
    if (auth.token != null) {
      await academic.getPresensi(auth.token!, isAdmin);
      if (isAdmin) {
        await academic.getMahasiswas(auth.token!);
        await academic.getMatkuls(auth.token!);
      } else {
        await academic.getKrs(auth.token!, false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final academic = Provider.of<AcademicProvider>(context);
    final isAdmin = auth.user?.role == 'admin';

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(title: const Text('Presensi')),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: () => _showAdminPresensiForm(context, academic, auth.token!),
              backgroundColor: AppTheme.primaryColor,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      body: academic.isLoading
          ? const LoadingStateWidget()
          : isAdmin
              ? _buildAdminView(academic, auth.token!)
              : _buildMahasiswaView(academic, auth.token!),
    );
  }

  Widget _buildAdminView(AcademicProvider academic, String token) {
    if (academic.presensiList.isEmpty) {
      return const EmptyStateWidget(message: 'Belum ada data presensi');
    }
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: academic.presensiList.length,
      itemBuilder: (context, index) {
        final presensi = academic.presensiList[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(presensi.mahasiswa?.nama ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${presensi.matkul?.nama ?? '-'} • ${presensi.tanggal}'),
            trailing: DropdownButton<String>(
              value: presensi.status,
              items: ['Hadir', 'Izin', 'Sakit', 'Alfa']
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  academic.updatePresensiStatus(token, presensi.id, {'status': val}).catchError((e) {
                    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                  });
                }
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildMahasiswaView(AcademicProvider academic, String token) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'Presensi Hari Ini'),
              Tab(text: 'Riwayat'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildTodayPresensi(academic, token),
                _buildRiwayatPresensi(academic),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayPresensi(AcademicProvider academic, String token) {
    final today = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(today);
    
    // Matkul yang diambil di KRS (Hanya yang sudah disetujui)
    final myMatkuls = academic.krsList
        .where((k) => k.status == 'approved')
        .map((k) => k.matkul)
        .where((m) => m != null)
        .toList();

    if (myMatkuls.isEmpty) {
      return const EmptyStateWidget(message: 'Anda belum mendaftar KRS');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: myMatkuls.length,
      itemBuilder: (context, index) {
        final matkul = myMatkuls[index];
        if (matkul == null) return const SizedBox.shrink();
        // Check if already presensi today
        final presensiHariIni = academic.presensiList.where((p) => p.matkulId == matkul.id && p.tanggal == todayStr).firstOrNull;

        return Card(
          child: ListTile(
            title: Text(matkul.nama, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(matkul.kode),
            trailing: presensiHariIni != null
                ? Chip(label: Text(presensiHariIni.status), backgroundColor: Colors.green.shade50)
                : ElevatedButton(
                    onPressed: () {
                      academic.addPresensi(token, {
                        'matkul_id': matkul.id,
                        'tanggal': todayStr,
                        'status': 'Hadir',
                      }, false).catchError((e) {
                        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                      });
                    },
                    child: const Text('Hadir'),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildRiwayatPresensi(AcademicProvider academic) {
    if (academic.presensiList.isEmpty) {
      return const EmptyStateWidget(message: 'Belum ada riwayat presensi');
    }
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: academic.presensiList.length,
      itemBuilder: (context, index) {
        final presensi = academic.presensiList[index];
        return Card(
          child: ListTile(
            title: Text(presensi.matkul?.nama ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(presensi.tanggal),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor(presensi.status).withAlpha(25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                presensi.status,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _getStatusColor(presensi.status),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAdminPresensiForm(BuildContext context, AcademicProvider academic, String token) {
    MahasiswaModel? selectedMhs;
    MatkulModel? selectedMatkul;
    String status = 'Hadir';
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateSB) {
            return AlertDialog(
              title: const Text('Input Presensi Manual'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<MatkulModel>(
                      decoration: const InputDecoration(labelText: 'Mata Kuliah'),
                      initialValue: selectedMatkul,
                      items: academic.matkuls
                          .map((m) => DropdownMenuItem(value: m, child: Text(m.nama)))
                          .toList(),
                      onChanged: (v) {
                        setStateSB(() {
                          selectedMatkul = v;
                          selectedMhs = null; // Reset mahasiswa when matkul changes
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<MahasiswaModel>(
                      key: ValueKey(selectedMatkul?.id),
                      decoration: InputDecoration(
                        labelText: 'Mahasiswa (Terdaftar KRS)',
                        hintText: selectedMatkul == null ? 'Pilih Matkul terlebih dahulu' : 'Pilih Mahasiswa',
                      ),
                      initialValue: selectedMhs,
                      items: academic.krsList
                          .where((k) => k.matkulId == selectedMatkul?.id && k.status == 'approved')
                          .map((k) => k.mahasiswa)
                          .where((m) => m != null)
                          .map((m) => DropdownMenuItem(value: m, child: Text(m?.nama ?? '')))
                          .toList(),
                      onChanged: (v) => setStateSB(() => selectedMhs = v),
                    ),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Status'),
                      initialValue: status,
                      items: ['Hadir', 'Izin', 'Sakit', 'Alfa']
                          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (v) => setStateSB(() => status = v ?? 'Hadir'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
                ElevatedButton(
                  onPressed: () {
                    if (selectedMhs != null && selectedMatkul != null) {
                      academic.addPresensi(token, {
                        'mahasiswa_id': selectedMhs!.id,
                        'matkul_id': selectedMatkul!.id,
                        'tanggal': todayStr,
                        'status': status,
                      }, true).then((_) {
                        if (context.mounted) Navigator.pop(context);
                      }).catchError((e) {
                        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                      });
                    }
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          }
        );
      },
    );
  }
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Hadir':
        return Colors.green;
      case 'Izin':
      case 'Sakit':
        return Colors.orange;
      case 'Alfa':
      default:
        return Colors.red;
    }
  }
}
