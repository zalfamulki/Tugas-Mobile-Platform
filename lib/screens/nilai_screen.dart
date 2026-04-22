import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/academic_provider.dart';
import '../widgets/state_widgets.dart';

class NilaiScreen extends StatelessWidget {
  const NilaiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final academic = Provider.of<AcademicProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Nilai Mahasiswa')),
      body: academic.isLoading
          ? const LoadingStateWidget()
          : academic.hasError
              ? ErrorStateWidget(
                  message: academic.error!,
                  onRetry: () => academic.getAllData(auth.token!, auth.user!.id),
                )
              : academic.grades.isEmpty
                  ? const EmptyStateWidget(message: 'Belum ada nilai yang keluar')
                  : RefreshIndicator(
                      onRefresh: () => academic.getAllData(auth.token!, auth.user!.id),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: academic.grades.length,
                        itemBuilder: (context, index) {
                          final grade = academic.grades[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              title: Text(
                                grade.matkul?.nama ?? 'Mata Kuliah',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(grade.matkul?.kode ?? '-'),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: _getGradeColor(grade.nilai).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  grade.nilai,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: _getGradeColor(grade.nilai),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }

  Color _getGradeColor(String grade) {
    if (grade.startsWith('A')) return Colors.green;
    if (grade.startsWith('B')) return Colors.blue;
    if (grade.startsWith('C')) return Colors.orange;
    if (grade.startsWith('D')) return Colors.deepOrange;
    return Colors.red;
  }
}
