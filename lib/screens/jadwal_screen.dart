import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/academic_provider.dart';
import '../widgets/state_widgets.dart';

class JadwalScreen extends StatelessWidget {
  const JadwalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final academic = Provider.of<AcademicProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Jadwal Kuliah')),
      body: academic.isLoading
          ? const LoadingStateWidget()
          : academic.hasError
              ? ErrorStateWidget(
                  message: academic.error!,
                  onRetry: () => academic.getAllData(auth.token!, auth.user!.id),
                )
              : academic.schedule.isEmpty
                  ? const EmptyStateWidget(message: 'Jadwal belum tersedia atau KRS belum disetujui')
                  : RefreshIndicator(
                      onRefresh: () => academic.getAllData(auth.token!, auth.user!.id),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: academic.schedule.length,
                        itemBuilder: (context, index) {
                          final matkul = academic.schedule[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF6366F1).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          matkul.hari ?? '-',
                                          style: const TextStyle(
                                            color: Color(0xFF6366F1),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        const Icon(Icons.access_time_rounded, size: 16, color: Color(0xFF6366F1)),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          matkul.nama,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${matkul.jamMulai} - ${matkul.jamSelesai}',
                                          style: TextStyle(color: Colors.grey.shade600),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.room_outlined, size: 14, color: Colors.grey),
                                            const SizedBox(width: 4),
                                            Text(
                                              matkul.ruangan ?? '-',
                                              style: const TextStyle(color: Colors.grey, fontSize: 13),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
