import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/academic_provider.dart';
import '../widgets/state_widgets.dart';
import '../utils/theme.dart';

class JadwalScreen extends StatelessWidget {
  const JadwalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final academic = Provider.of<AcademicProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Jadwal Perkuliahan'),
      ),
      body: academic.isLoading
          ? const LoadingStateWidget()
          : academic.hasError
              ? ErrorStateWidget(
                  message: academic.error!,
                  onRetry: () => academic.getAllData(auth.token!, auth.user!.id),
                )
              : academic.schedule.isEmpty
                  ? const EmptyStateWidget(message: 'Jadwal belum tersedia untuk semester ini.')
                  : RefreshIndicator(
                      onRefresh: () => academic.getAllData(auth.token!, auth.user!.id),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(24),
                        itemCount: academic.schedule.length,
                        itemBuilder: (context, index) {
                          final matkul = academic.schedule[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(8),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: IntrinsicHeight(
                              child: Row(
                                children: [
                                  Container(
                                    width: 100,
                                    padding: const EdgeInsets.symmetric(vertical: 20),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryColor.withAlpha(12),
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(24),
                                        bottomLeft: Radius.circular(24),
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          matkul.hari ?? '?',
                                          style: const TextStyle(
                                            color: AppTheme.primaryColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        const Icon(Icons.access_time_rounded, size: 16, color: AppTheme.primaryColor),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            matkul.nama,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.textColor,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              const Icon(Icons.timer_outlined, size: 14, color: AppTheme.textSecondaryColor),
                                              const SizedBox(width: 6),
                                              Text(
                                                '${matkul.jamMulai} - ${matkul.jamSelesai}',
                                                style: const TextStyle(color: AppTheme.textSecondaryColor, fontSize: 13),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              const Icon(Icons.room_rounded, size: 14, color: AppTheme.textSecondaryColor),
                                              const SizedBox(width: 6),
                                              Text(
                                                'Ruang: ${matkul.ruangan ?? '-'}',
                                                style: const TextStyle(color: AppTheme.textSecondaryColor, fontSize: 13),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
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
