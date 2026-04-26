import 'package:flutter/material.dart';
import '../models/mahasiswa_model.dart';
import '../utils/theme.dart';
import 'nilai_screen.dart';

class DetailMahasiswaScreen extends StatelessWidget {
  final MahasiswaModel mahasiswa;

  const DetailMahasiswaScreen({super.key, required this.mahasiswa});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Profil Mahasiswa'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
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
                    mahasiswa.nama,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
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
                      mahasiswa.nim,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoSection(context),
                  const SizedBox(height: 32),
                  const Text(
                    'Pencapaian Akademik',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textColor),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildStatusCard('Semester', '6', Colors.blue),
                      const SizedBox(width: 16),
                      _buildStatusCard('IPK', '3.85', Colors.green),
                    ],
                  ),
                  if (true) // Just to make sure logic is visible, usually check role here too if passed
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NilaiScreen(
                                userId: mahasiswa.id, // Using mahasiswa.id as target userId
                                studentName: mahasiswa.nama,
                              ),
                            ),
                          ),
                          icon: const Icon(Icons.grade_rounded),
                          label: const Text('Lihat & Kelola Nilai'),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.school_outlined, 'Program Studi', mahasiswa.jurusan ?? '-'),
          const Divider(height: 32),
          _buildInfoRow(Icons.email_outlined, 'Email Institusi', mahasiswa.email ?? '-'),
          const Divider(height: 32),
          _buildInfoRow(Icons.phone_android_rounded, 'Nomor Telepon', '+62 812-XXXX-XXXX'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
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
              Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textColor)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withAlpha(12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withAlpha(25)),
        ),
        child: Column(
          children: [
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}
