import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/academic_provider.dart';
import '../models/matkul_model.dart';
import '../models/krs_model.dart';
import '../widgets/state_widgets.dart';
import '../utils/theme.dart';

class KrsScreen extends StatefulWidget {
  const KrsScreen({super.key});

  @override
  State<KrsScreen> createState() => _KrsScreenState();
}

class _KrsScreenState extends State<KrsScreen> {
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
      await academic.refreshKrsData(auth.token!, isAdmin);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final academic = Provider.of<AcademicProvider>(context);
    final isAdmin = auth.user?.role == 'admin';

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Kartu Rencana Studi'),
        elevation: 0,
      ),
      body: academic.isLoading
          ? const LoadingStateWidget()
          : academic.hasError
              ? ErrorStateWidget(
                  message: academic.error ?? 'Terjadi kesalahan',
                  onRetry: _fetchData,
                )
              : isAdmin
                  ? _buildAdminView(academic, auth.token ?? '')
                  : _buildMahasiswaView(academic, auth.token ?? ''),
    );
  }

  Widget _buildAdminView(AcademicProvider academic, String token) {
    final pendingKrs = academic.krsList.where((k) => k.status == 'pending').toList();
    final historyKrs = academic.krsList.where((k) => k.status != 'pending').toList();

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: const TabBar(
              labelColor: AppTheme.primaryColor,
              indicatorColor: AppTheme.primaryColor,
              indicatorWeight: 3,
              tabs: [
                Tab(text: 'Perlu Disetujui'),
                Tab(text: 'Riwayat'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildKrsRequestList(pendingKrs, token, academic, true),
                _buildKrsRequestList(historyKrs, token, academic, false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKrsRequestList(List<KrsModel> list, String token, AcademicProvider academic, bool isActionable) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_turned_in_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(isActionable ? 'Tidak ada permintaan pending' : 'Belum ada riwayat', 
                 style: TextStyle(color: Colors.grey.shade500)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final krs = list[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryColor.withAlpha(25),
                  child: const Icon(Icons.person, color: AppTheme.primaryColor),
                ),
                title: Text(krs.mahasiswa?.nama ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('NIM: ${krs.mahasiswa?.nim ?? '-'}'),
                trailing: _buildStatusBadge(krs.status),
              ),
              const Divider(height: 1, indent: 20, endIndent: 20),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.book_outlined, size: 16, color: AppTheme.textSecondaryColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${krs.matkul?.kode}: ${krs.matkul?.nama}',
                            style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textColor),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 16, color: AppTheme.textSecondaryColor),
                        const SizedBox(width: 8),
                        Text('Semester: ${krs.semester}', style: const TextStyle(color: AppTheme.textSecondaryColor)),
                      ],
                    ),
                    if (isActionable) ...[
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _updateKrsStatus(token, academic, krs.id, 'rejected'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('Tolak'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _updateKrsStatus(token, academic, krs.id, 'approved'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('Setujui'),
                            ),
                          ),
                        ],
                      ),
                    ]
                  ],
                ),
              ),
            ],
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
          Container(
            color: Colors.white,
            child: const TabBar(
              labelColor: AppTheme.primaryColor,
              indicatorColor: AppTheme.primaryColor,
              indicatorWeight: 3,
              tabs: [
                Tab(text: 'KRS Saya'),
                Tab(text: 'Daftar Matkul'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildMahasiswaKrsTab(academic, token),
                _buildAvailableMatkulTab(academic, token),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMahasiswaKrsTab(AcademicProvider academic, String token) {
    if (academic.isLoading) return const LoadingStateWidget();
    if (academic.krsList.isEmpty) {
      return RefreshIndicator(
        onRefresh: _fetchData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: const EmptyStateWidget(message: 'Belum ada KRS yang diambil'),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchData,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        itemCount: academic.krsList.length,
        itemBuilder: (context, index) {
        final krs = academic.krsList[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      krs.matkul?.nama ?? 'Unknown',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textColor),
                    ),
                  ),
                  _buildStatusBadge(krs.status),
                ],
              ),
              const SizedBox(height: 4),
              Text(krs.matkul?.kode ?? '', style: const TextStyle(color: AppTheme.textSecondaryColor, fontSize: 13)),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Semester', style: TextStyle(color: AppTheme.textSecondaryColor, fontSize: 11)),
                      Text(krs.semester, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  if (krs.status == 'pending')
                    TextButton.icon(
                      onPressed: () => _confirmDelete(context, academic, token, krs.id),
                      icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                      label: const Text('Batalkan', style: TextStyle(color: Colors.red)),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    ));
  }

  Widget _buildAvailableMatkulTab(AcademicProvider academic, String token) {
    if (academic.isLoading) return const LoadingStateWidget();
    if (academic.matkuls.isEmpty) {
      return RefreshIndicator(
        onRefresh: _fetchData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: const EmptyStateWidget(message: 'Belum ada mata kuliah yang tersedia'),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchData,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        itemCount: academic.matkuls.length,
        itemBuilder: (context, index) {
        final matkul = academic.matkuls[index];
        final enrollment = academic.krsList.firstWhere((k) => k.matkulId == matkul.id, orElse: () => KrsModel(id: 0, mahasiswaId: 0, matkulId: 0, semester: '', status: 'none'));
        final isEnrolled = enrollment.status != 'none';

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isEnrolled ? Colors.grey.shade50 : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: isEnrolled ? Border.all(color: Colors.grey.shade200) : null,
            boxShadow: isEnrolled ? [] : [
              BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(matkul.nama, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 4),
                    Text('${matkul.kode} • ${matkul.jurusan ?? '-'}', style: const TextStyle(color: AppTheme.textSecondaryColor, fontSize: 12)),
                  ],
                ),
              ),
              if (isEnrolled)
                _buildStatusBadge(enrollment.status)
              else
                ElevatedButton(
                  onPressed: () {
                    if (token.isNotEmpty) {
                      _showTakeMatkulDialog(context, academic, token, matkul);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text('Ambil'),
                ),
            ],
          ),
        );
      },
    ));
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'approved':
        color = Colors.green;
        label = 'Disetujui';
        icon = Icons.check_circle;
        break;
      case 'rejected':
        color = Colors.red;
        label = 'Ditolak';
        icon = Icons.cancel;
        break;
      case 'pending':
      default:
        color = Colors.orange;
        label = 'Pending';
        icon = Icons.hourglass_empty;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Future<void> _updateKrsStatus(String token, AcademicProvider academic, int id, String status) async {
    try {
      await academic.changeKrsStatus(token, id, status);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(status == 'approved' ? 'KRS Disetujui' : 'KRS Ditolak'),
          backgroundColor: status == 'approved' ? Colors.green : Colors.red,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _showTakeMatkulDialog(BuildContext context, AcademicProvider academic, String token, MatkulModel matkul) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Kontrak Matkul'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Anda akan mengambil mata kuliah:', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            const SizedBox(height: 8),
            Text(matkul.nama, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            const Text('Apakah Anda yakin ingin mengajukan KRS ini?'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await academic.addKrs(token, {
                  'matkul_id': matkul.id,
                });
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Berhasil mengajukan KRS')));
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Ambil'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, AcademicProvider academic, String token, int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batalkan KRS?'),
        content: const Text('Apakah Anda yakin ingin membatalkan pengajuan mata kuliah ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tidak')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await academic.removeKrs(token, id);
              } catch (e) {
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: const Text('Ya, Batalkan', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
