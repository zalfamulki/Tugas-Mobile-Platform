import 'package:flutter/material.dart';
import '../models/mahasiswa_model.dart';
import '../models/matkul_model.dart';

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
  late TextEditingController _userIdController;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.mahasiswa?.nama);
    _nimController = TextEditingController(text: widget.mahasiswa?.nim);
    _jurusanController = TextEditingController(text: widget.mahasiswa?.jurusan);
    _emailController = TextEditingController(text: widget.mahasiswa?.email);
    _userIdController = TextEditingController(text: widget.mahasiswa?.id.toString() ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mahasiswa == null ? 'Tambah Mahasiswa' : 'Edit Mahasiswa'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(labelText: 'Nama Lengkap'),
                validator: (v) => v!.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nimController,
                decoration: const InputDecoration(labelText: 'NIM'),
                validator: (v) => v!.isEmpty ? 'NIM tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _jurusanController,
                decoration: const InputDecoration(labelText: 'Jurusan'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              if (widget.mahasiswa == null)
                TextFormField(
                  controller: _userIdController,
                  decoration: const InputDecoration(labelText: 'User ID (Mapping)'),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'User ID diperlukan' : null,
                ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.pop(context, {
                      'nama': _namaController.text,
                      'nim': _nimController.text,
                      'jurusan': _jurusanController.text,
                      'email': _emailController.text,
                      'user_id': int.tryParse(_userIdController.text),
                    });
                  }
                },
                child: const Text('Simpan Data'),
              ),
            ],
          ),
        ),
      ),
    );
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
  late TextEditingController _hariController;
  late TextEditingController _jamMulaiController;
  late TextEditingController _jamSelesaiController;
  late TextEditingController _ruanganController;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.matkul?.nama);
    _kodeController = TextEditingController(text: widget.matkul?.kode);
    _jurusanController = TextEditingController(text: widget.matkul?.jurusan);
    _hariController = TextEditingController(text: widget.matkul?.hari);
    _jamMulaiController = TextEditingController(text: widget.matkul?.jamMulai);
    _jamSelesaiController = TextEditingController(text: widget.matkul?.jamSelesai);
    _ruanganController = TextEditingController(text: widget.matkul?.ruangan);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.matkul == null ? 'Tambah Matkul' : 'Edit Matkul'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(labelText: 'Nama Mata Kuliah'),
                validator: (v) => v!.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _kodeController,
                decoration: const InputDecoration(labelText: 'Kode Matkul'),
                validator: (v) => v!.isEmpty ? 'Kode tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _jurusanController,
                decoration: const InputDecoration(labelText: 'Jurusan'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _hariController,
                      decoration: const InputDecoration(labelText: 'Hari'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _ruanganController,
                      decoration: const InputDecoration(labelText: 'Ruangan'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _jamMulaiController,
                      decoration: const InputDecoration(labelText: 'Jam Mulai'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _jamSelesaiController,
                      decoration: const InputDecoration(labelText: 'Jam Selesai'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.pop(context, {
                      'nama': _namaController.text,
                      'kode': _kodeController.text,
                      'jurusan': _jurusanController.text,
                      'hari': _hariController.text,
                      'jam_mulai': _jamMulaiController.text,
                      'jam_selesai': _jamSelesaiController.text,
                      'ruangan': _ruanganController.text,
                    });
                  }
                },
                child: const Text('Simpan Data'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GradeForm extends StatefulWidget {
  final String? initialValue;
  const GradeForm({super.key, this.initialValue});

  @override
  State<GradeForm> createState() => _GradeFormState();
}

class _GradeFormState extends State<GradeForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _gradeController;

  @override
  void initState() {
    super.initState();
    _gradeController = TextEditingController(text: widget.initialValue);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Input Nilai'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _gradeController,
          decoration: const InputDecoration(labelText: 'Nilai (A, B, C, D, E)'),
          validator: (v) => v!.isEmpty ? 'Nilai harus diisi' : null,
          textCapitalization: TextCapitalization.characters,
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, _gradeController.text);
            }
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
