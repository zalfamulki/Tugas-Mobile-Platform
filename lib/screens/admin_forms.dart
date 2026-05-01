import 'package:flutter/material.dart';
import '../models/mahasiswa_model.dart';
import '../models/matkul_model.dart';
import '../utils/theme.dart';

class MahasiswaForm extends StatefulWidget {
  final MahasiswaModel? mahasiswa;
  const MahasiswaForm({super.key, this.mahasiswa});

  @override
  State<MahasiswaForm> createState() => _MahasiswaFormState();
}

class _MahasiswaFormState extends State<MahasiswaForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _nimController;
  late TextEditingController _jurusanController;
  late TextEditingController _emailController;
  late TextEditingController _noHpController;
  late TextEditingController _alamatController;
  late TextEditingController _userIdController;
  String _selectedStatus = 'Aktif';

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.mahasiswa?.nama);
    _nimController = TextEditingController(text: widget.mahasiswa?.nim);
    _jurusanController = TextEditingController(text: widget.mahasiswa?.jurusan);
    _emailController = TextEditingController(text: widget.mahasiswa?.email);
    _noHpController = TextEditingController(text: widget.mahasiswa?.noHp);
    _alamatController = TextEditingController(text: widget.mahasiswa?.alamat);
    _userIdController = TextEditingController(text: widget.mahasiswa?.userId?.toString() ?? '');
    _selectedStatus = widget.mahasiswa?.status ?? 'Aktif';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(widget.mahasiswa == null ? 'Tambah Mahasiswa' : 'Edit Mahasiswa'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Informasi Pribadi'),
              _buildTextField(_namaController, 'Nama Lengkap', Icons.person_outline),
              const SizedBox(height: 16),
              _buildTextField(_nimController, 'NIM', Icons.badge_outlined),
              const SizedBox(height: 16),
              _buildTextField(_jurusanController, 'Program Studi / Jurusan', Icons.school_outlined),
              
              const SizedBox(height: 32),
              _buildSectionTitle('Kontak & Status'),
              _buildTextField(_emailController, 'Email', Icons.email_outlined, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),
              _buildTextField(_noHpController, 'Nomor HP', Icons.phone_outlined, keyboardType: TextInputType.phone),
              const SizedBox(height: 16),
              _buildTextField(_alamatController, 'Alamat', Icons.location_on_outlined, maxLines: 3),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                initialValue: _selectedStatus,
                decoration: InputDecoration(
                  labelText: 'Status Mahasiswa',
                  prefixIcon: const Icon(Icons.info_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: ['Aktif', 'Cuti', 'Lulus', 'Drop Out', 'Non-Aktif']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedStatus = v!),
              ),

              const SizedBox(height: 32),
              _buildSectionTitle('Sistem'),
              TextFormField(
                controller: _userIdController,
                decoration: InputDecoration(
                  labelText: 'User ID (Mapping Akun)',
                  helperText: 'ID ini menghubungkan data mahasiswa dengan akun login',
                  prefixIcon: const Icon(Icons.link),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                readOnly: widget.mahasiswa != null,
                enabled: widget.mahasiswa == null,
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'User ID diperlukan' : null,
              ),

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text('Simpan Data Mahasiswa', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (v) => v!.isEmpty && label != 'Alamat' ? '$label tidak boleh kosong' : null,
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, {
        'nama': _namaController.text,
        'nim': _nimController.text,
        'jurusan': _jurusanController.text,
        'email': _emailController.text,
        'no_hp': _noHpController.text,
        'alamat': _alamatController.text,
        'status': _selectedStatus,
        'user_id': int.tryParse(_userIdController.text),
      });
    }
  }
}

class MatkulForm extends StatefulWidget {
  final MatkulModel? matkul;
  const MatkulForm({super.key, this.matkul});

  @override
  State<MatkulForm> createState() => _MatkulFormState();
}

class _MatkulFormState extends State<MatkulForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _kodeController;
  late TextEditingController _jurusanController;
  late TextEditingController _jamMulaiController;
  late TextEditingController _jamSelesaiController;
  late TextEditingController _ruanganController;
  String? _selectedHari;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.matkul?.nama);
    _kodeController = TextEditingController(text: widget.matkul?.kode);
    _jurusanController = TextEditingController(text: widget.matkul?.jurusan);
    _jamMulaiController = TextEditingController(text: widget.matkul?.jamMulai);
    _jamSelesaiController = TextEditingController(text: widget.matkul?.jamSelesai);
    _ruanganController = TextEditingController(text: widget.matkul?.ruangan);
    _selectedHari = widget.matkul?.hari;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(widget.matkul == null ? 'Tambah Matkul' : 'Edit Matkul'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Data Mata Kuliah'),
              _buildTextField(_namaController, 'Nama Mata Kuliah', Icons.book_outlined),
              const SizedBox(height: 16),
              _buildTextField(_kodeController, 'Kode Matkul', Icons.code),
              const SizedBox(height: 16),
              _buildTextField(_jurusanController, 'Program Studi / Jurusan', Icons.school_outlined),
              
              const SizedBox(height: 32),
              _buildSectionTitle('Jadwal & Ruangan'),
              DropdownButtonFormField<String>(
                initialValue: _selectedHari,
                decoration: InputDecoration(
                  labelText: 'Hari',
                  prefixIcon: const Icon(Icons.calendar_today_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu']
                    .map((h) => DropdownMenuItem(value: h, child: Text(h)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedHari = v),
              ),
              const SizedBox(height: 16),
              _buildTextField(_ruanganController, 'Ruangan', Icons.room_outlined),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTimeField(_jamMulaiController, 'Jam Mulai'),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTimeField(_jamSelesaiController, 'Jam Selesai'),
                  ),
                ],
              ),

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text('Simpan Data Matkul', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (v) => v!.isEmpty && label != 'Jurusan' ? '$label tidak boleh kosong' : null,
    );
  }

  Widget _buildTimeField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (time != null) {
          setState(() {
            controller.text = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
          });
        }
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.access_time),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, {
        'nama': _namaController.text,
        'kode': _kodeController.text,
        'jurusan': _jurusanController.text,
        'hari': _selectedHari,
        'jam_mulai': _jamMulaiController.text,
        'jam_selesai': _jamSelesaiController.text,
        'ruangan': _ruanganController.text,
      });
    }
  }
}
