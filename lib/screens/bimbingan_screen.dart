import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/academic_provider.dart';
import '../models/user_model.dart';
import '../widgets/state_widgets.dart';
import '../utils/theme.dart';

class BimbinganScreen extends StatefulWidget {
  const BimbinganScreen({super.key});

  @override
  State<BimbinganScreen> createState() => _BimbinganScreenState();
}

class _BimbinganScreenState extends State<BimbinganScreen> {
  final _pesanController = TextEditingController();
  UserModel? _selectedDosen;

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
      await academic.getBimbingan(auth.token!, isAdmin);
      if (!isAdmin) {
        await academic.getDosens(auth.token!);
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
      appBar: AppBar(title: const Text('Bimbingan Dosen Wali')),
      floatingActionButton: !isAdmin
          ? FloatingActionButton(
              onPressed: () => _showAddBimbinganDialog(context, academic, auth.token!),
              backgroundColor: AppTheme.primaryColor,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      body: academic.isLoading
          ? const LoadingStateWidget()
          : academic.bimbinganList.isEmpty
              ? const EmptyStateWidget(message: 'Belum ada riwayat bimbingan')
              : ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: academic.bimbinganList.length,
                  itemBuilder: (context, index) {
                    final bimbingan = academic.bimbinganList[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    isAdmin ? (bimbingan.mahasiswa?.nama ?? 'Mahasiswa') : (bimbingan.dosen?.name ?? 'Dosen'),
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                ),
                                Chip(
                                  label: Text(bimbingan.status, style: const TextStyle(fontSize: 12)),
                                  backgroundColor: bimbingan.status == 'pending' ? Colors.orange.shade50 : Colors.green.shade50,
                                ),
                              ],
                            ),
                            const Divider(),
                            Text(isAdmin ? 'Pesan Mahasiswa:' : 'Pesan Anda:', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            const SizedBox(height: 4),
                            Text(bimbingan.pesan),
                            const SizedBox(height: 12),
                            if (bimbingan.jawaban != null) ...[
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Balasan Dosen:', style: TextStyle(fontSize: 12, color: Colors.blue)),
                                    const SizedBox(height: 4),
                                    Text(bimbingan.jawaban!),
                                  ],
                                ),
                              ),
                            ] else if (isAdmin) ...[
                              ElevatedButton(
                                onPressed: () => _showReplyDialog(context, academic, auth.token!, bimbingan.id),
                                child: const Text('Balas'),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  void _showAddBimbinganDialog(BuildContext context, AcademicProvider academic, String token) {
    _pesanController.clear();
    _selectedDosen = academic.dosenList.isNotEmpty ? academic.dosenList.first : null;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateSB) {
            return AlertDialog(
              title: const Text('Ajukan Bimbingan'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<UserModel>(
                    decoration: const InputDecoration(labelText: 'Pilih Dosen'),
                    initialValue: _selectedDosen,
                    items: academic.dosenList
                        .map((d) => DropdownMenuItem(value: d, child: Text(d.name)))
                        .toList(),
                    onChanged: (v) => setStateSB(() => _selectedDosen = v),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _pesanController,
                    decoration: const InputDecoration(labelText: 'Pesan'),
                    maxLines: 3,
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
                ElevatedButton(
                  onPressed: () {
                    if (_selectedDosen != null && _pesanController.text.isNotEmpty) {
                      academic.addBimbingan(token, {
                        'dosen_id': _selectedDosen!.id,
                        'pesan': _pesanController.text,
                      }).then((_) {
                        if (context.mounted) Navigator.pop(context);
                      }).catchError((e) {
                        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                      });
                    }
                  },
                  child: const Text('Kirim'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  void _showReplyDialog(BuildContext context, AcademicProvider academic, String token, int id) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Balas Bimbingan'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Jawaban'),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                academic.replyBimbingan(token, id, {'jawaban': controller.text}).then((_) {
                  if (context.mounted) Navigator.pop(context);
                }).catchError((e) {
                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                });
              }
            },
            child: const Text('Kirim'),
          ),
        ],
      ),
    );
  }
}
