import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/mahasiswa_model.dart';
import '../providers/auth_provider.dart';
import '../utils/theme.dart';

class DataDiriScreen extends StatefulWidget {
  const DataDiriScreen({super.key});

  @override
  State<DataDiriScreen> createState() => _DataDiriScreenState();
}

class _DataDiriScreenState extends State<DataDiriScreen> {
  MahasiswaModel? _mahasiswa;
  bool _isLoading = true;
  bool _isEditing = false;

  final _namaController    = TextEditingController();
  final _emailController   = TextEditingController();
  final _jurusanController = TextEditingController();
  final _noHpController    = TextEditingController();
  final _alamatController  = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final result = await authProvider.getMahasiswaProfile();
    if (mounted) {
      if (result['success']) {
        final mhs = MahasiswaModel.fromJson(result['data']);
        setState(() {
          _mahasiswa = mhs;
          _namaController.text    = mhs.nama;
          _emailController.text   = mhs.email ?? '';
          _jurusanController.text = mhs.jurusan ?? '';
          _noHpController.text    = mhs.noHp ?? '';
          _alamatController.text  = mhs.alamat ?? '';
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        _showSnackBar(result['message'] ?? 'Gagal memuat data', Colors.redAccent);
      }
    }
  }

  Future<void> _saveProfile() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final messenger = ScaffoldMessenger.of(context);

    final result = await authProvider.updateMahasiswaProfile({
      'nama'   : _namaController.text,
      'email'  : _emailController.text,
      'jurusan': _jurusanController.text,
      'no_hp'  : _noHpController.text,
      'alamat' : _alamatController.text,
    });

    if (result['success']) {
      await _loadProfile();
      setState(() => _isEditing = false);
      messenger.showSnackBar(SnackBar(
        content: const Text('Profil berhasil diperbarui'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    } else {
      messenger.showSnackBar(SnackBar(
        content: Text(result['message'] ?? 'Gagal menyimpan'),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isUpdating = Provider.of<AuthProvider>(context).isLoading;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Data Diri'),
        actions: [
          if (!_isLoading && _mahasiswa != null)
            _isEditing
                ? Row(children: [
                    TextButton(
                      onPressed: () => setState(() => _isEditing = false),
                      child: const Text('Batal', style: TextStyle(color: Colors.white70)),
                    ),
                    TextButton(
                      onPressed: isUpdating ? null : _saveProfile,
                      child: isUpdating
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Simpan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ])
                : IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Colors.white),
                    tooltip: 'Edit Profil',
                    onPressed: () => setState(() => _isEditing = true),
                  ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _mahasiswa == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.person_off_outlined, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('Data mahasiswa tidak ditemukan.', style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: _loadProfile, child: const Text('Coba Lagi')),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      // Header
                      Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(32),
                            bottomRight: Radius.circular(32),
                          ),
                        ),
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white.withAlpha(51), width: 4),
                              ),
                              child: const CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.white24,
                                child: Icon(Icons.person, size: 60, color: Colors.white),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _mahasiswa!.nama,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(25),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'NIM: ${_mahasiswa!.nim}',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Info / Edit fields
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_isEditing) ...[
                              const Text(
                                'Edit Data Diri',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textColor),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'NIM tidak dapat diubah oleh mahasiswa.',
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                              ),
                              const SizedBox(height: 20),
                              _buildEditField('Nama Lengkap', _namaController, Icons.person_outline),
                              const SizedBox(height: 16),
                              _buildEditField('Email', _emailController, Icons.email_outlined, type: TextInputType.emailAddress),
                              const SizedBox(height: 16),
                              _buildEditField('Program Studi / Jurusan', _jurusanController, Icons.school_outlined),
                              const SizedBox(height: 16),
                              _buildEditField('Nomor HP', _noHpController, Icons.phone_outlined, type: TextInputType.phone),
                              const SizedBox(height: 16),
                              _buildEditField('Alamat', _alamatController, Icons.location_on_outlined, maxLines: 3),
                            ] else ...[
                              const Text(
                                'Informasi Mahasiswa',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textColor),
                              ),
                              const SizedBox(height: 16),
                              _buildInfoCard([
                                _buildInfoRow(Icons.badge_outlined, 'NIM', _mahasiswa!.nim),
                                const Divider(height: 28),
                                _buildInfoRow(Icons.school_outlined, 'Program Studi', _mahasiswa!.jurusan ?? '-'),
                                const Divider(height: 28),
                                _buildInfoRow(Icons.email_outlined, 'Email', _mahasiswa!.email ?? '-'),
                                const Divider(height: 28),
                                _buildInfoRow(Icons.phone_outlined, 'Nomor HP', _mahasiswa!.noHp ?? '-'),
                                const Divider(height: 28),
                                _buildInfoRow(Icons.location_on_outlined, 'Alamat', _mahasiswa!.alamat ?? '-'),
                              ]),
                              const SizedBox(height: 24),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withAlpha(12),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppTheme.primaryColor.withAlpha(30)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.info_outline, color: AppTheme.primaryColor, size: 20),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'NIM dan data akademik hanya dapat diubah oleh Admin.',
                                        style: TextStyle(fontSize: 13, color: AppTheme.primaryColor.withAlpha(200)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 80),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withAlpha(12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppTheme.primaryColor, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: AppTheme.textSecondaryColor, fontSize: 12)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textColor)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEditField(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType type = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textColor, fontSize: 14)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: type,
          maxLines: maxLines,
          decoration: InputDecoration(
            prefixIcon: Icon(icon),
            hintText: 'Masukkan $label',
          ),
        ),
      ],
    );
  }
}
