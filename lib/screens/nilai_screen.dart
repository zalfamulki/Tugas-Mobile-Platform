import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/academic_provider.dart';
import '../widgets/state_widgets.dart';
import '../utils/theme.dart';
import 'admin_forms.dart';

class NilaiScreen extends StatelessWidget {
  final int? userId;
  final String? studentName;

  const NilaiScreen({super.key, this.userId, this.studentName});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final academic = Provider.of<AcademicProvider>(context);
    final isAdmin = auth.user?.role == 'admin';
    final targetUserId = userId ?? auth.user!.id;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(studentName != null ? 'Nilai: $studentName' : 'Hasil Studi'),
        actions: [
          if (isAdmin && studentName != null)
            IconButton(
              icon: const Icon(Icons.add_chart_rounded),
              onPressed: () => _showAddGrade(context),
            )
        ],
      ),
      body: academic.isLoading
          ? const LoadingStateWidget()
          : academic.hasError
              ? ErrorStateWidget(
                  message: academic.error!,
                  onRetry: () => academic.getAllData(auth.token!, targetUserId),
                )
              : academic.grades.isEmpty
                  ? const EmptyStateWidget(message: 'Belum ada nilai yang dipublikasikan.')
                  : RefreshIndicator(
                      onRefresh: () => academic.getAllData(auth.token!, targetUserId),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(24),
                        itemCount: academic.grades.length,
                        itemBuilder: (context, index) {
                          final grade = academic.grades[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
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
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        grade.matkul?.nama ?? 'Mata Kuliah',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: AppTheme.textColor,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        grade.matkul?.kode ?? '-',
                                        style: const TextStyle(color: AppTheme.textSecondaryColor, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: _getGradeColor(grade.nilai).withAlpha(25),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    grade.nilai,
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: _getGradeColor(grade.nilai),
                                    ),
                                  ),
                                ),
                                if (isAdmin)
                                  PopupMenuButton(
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(value: 'edit', child: Text('Edit Nilai')),
                                      const PopupMenuItem(value: 'delete', child: Text('Hapus')),
                                    ],
                                    onSelected: (val) {
                                      if (val == 'edit') {
                                        _showEditGrade(context, grade);
                                      } else {
                                        _deleteGrade(context, grade.id);
                                      }
                                    },
                                  )
                              ],
                            ),
                          );
                        },
                      ),
                    ),
    );
  }

  void _showAddGrade(BuildContext context) async {
    // Logic for adding grade
    final newValue = await showDialog<String>(
      context: context,
      builder: (context) => const GradeForm(),
    );

    if (newValue != null) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih mata kuliah terlebih dahulu')));
    }
  }

  void _showEditGrade(BuildContext context, dynamic grade) async {
    final academic = Provider.of<AcademicProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    
    final newValue = await showDialog<String>(
      context: context,
      builder: (context) => GradeForm(initialValue: grade.nilai),
    );

    if (newValue != null) {
      try {
        await academic.editGrade(auth.token!, grade.id, {
          'mahasiswa_id': grade.mahasiswaId,
          'matkul_id': grade.matkulId,
          'nilai': newValue,
        });
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nilai diperbarui')));
      } catch (e) {
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _deleteGrade(BuildContext context, int id) async {
    final academic = Provider.of<AcademicProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    try {
      await academic.removeGrade(auth.token!, id);
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nilai dihapus')));
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Color _getGradeColor(String grade) {
    if (grade.startsWith('A')) return Colors.green.shade600;
    if (grade.startsWith('B')) return AppTheme.primaryColor;
    if (grade.startsWith('C')) return Colors.orange.shade700;
    if (grade.startsWith('D')) return Colors.deepOrange;
    return Colors.red.shade600;
  }
}
