import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/academic_provider.dart';
import 'login_screen.dart';
import 'jadwal_screen.dart';
import 'nilai_screen.dart';
import 'detail_mahasiswa_screen.dart';
import 'admin_forms.dart';
import '../widgets/state_widgets.dart';
import '../utils/theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchInitialData();
    });
  }

  void _fetchInitialData() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final academic = Provider.of<AcademicProvider>(context, listen: false);
    if (auth.token != null && auth.user != null) {
      academic.getAllData(auth.token!, auth.user!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final isAdmin = auth.user?.role == 'admin';

    final pages = [
      _buildDashboard(context),
      _buildMahasiswaTab(context),
      _buildProfile(context),
    ];

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: pages[_currentIndex],
      floatingActionButton: (isAdmin && (_currentIndex == 0 || _currentIndex == 1))
          ? FloatingActionButton(
              backgroundColor: AppTheme.primaryColor,
              onPressed: () => _currentIndex == 0 ? _showMatkulForm() : _showMahasiswaForm(),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(12),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          backgroundColor: Colors.white,
          indicatorColor: AppTheme.primaryColor.withAlpha(25),
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) => setState(() => _currentIndex = index),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard, color: AppTheme.primaryColor),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.group_outlined),
              selectedIcon: Icon(Icons.group, color: AppTheme.primaryColor),
              label: 'Mahasiswa',
            ),
            NavigationDestination(
              icon: Icon(Icons.account_circle_outlined),
              selectedIcon: Icon(Icons.account_circle, color: AppTheme.primaryColor),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final academic = Provider.of<AcademicProvider>(context);
    final isAdmin = auth.user?.role == 'admin';

    return RefreshIndicator(
      onRefresh: () async => academic.getAllData(auth.token!, auth.user!.id),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
              decoration: const BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selamat Datang,',
                            style: TextStyle(color: Colors.white.withAlpha(204), fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            auth.user?.name ?? 'Mahasiswa',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withAlpha(51), width: 2),
                        ),
                        child: const CircleAvatar(
                          radius: 26,
                          backgroundColor: Colors.white24,
                          child: Icon(Icons.person, color: Colors.white, size: 30),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(25),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildQuickAction(context, Icons.calendar_today_rounded, 'Jadwal', Colors.blue, const JadwalScreen()),
                        _buildQuickAction(context, Icons.grade_rounded, 'Nilai', Colors.orange, const NilaiScreen()),
                        _buildQuickAction(context, Icons.description_rounded, 'KRS', Colors.green, null),
                        _buildQuickAction(context, Icons.info_outline_rounded, 'Info', Colors.purple, null),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const Text(
                  'Aktivitas Akademik',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textColor),
                ),
                const SizedBox(height: 16),
                
                if (academic.isLoading)
                  const LoadingStateWidget()
                else if (academic.hasError)
                  ErrorStateWidget(message: academic.error!, onRetry: _fetchInitialData)
                else if (academic.matkuls.isEmpty)
                  const EmptyStateWidget(message: 'Belum ada aktivitas akademik.')
                else
                  ...academic.matkuls.take(5).map((matkul) => _buildMatkulCard(matkul, isAdmin, auth, academic)),
                
                const SizedBox(height: 24),
                const Text(
                  'Statistik Mahasiswa',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textColor),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildStatCard('IPK', '3.85', Icons.trending_up, Colors.green)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildStatCard('SKS', '84', Icons.book, Colors.blue)),
                  ],
                ),
                const SizedBox(height: 100), // Spacing for bottom nav
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(BuildContext context, IconData icon, String label, Color color, Widget? target) {
    return InkWell(
      onTap: () {
        if (target != null) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => target));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fitur $label akan segera hadir')));
        }
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textColor)),
        ],
      ),
    );
  }

  Widget _buildMatkulCard(dynamic matkul, bool isAdmin, AuthProvider auth, AcademicProvider academic) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withAlpha(12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.book_outlined, color: AppTheme.primaryColor),
        ),
        title: Text(matkul.nama, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Text(matkul.kode, style: const TextStyle(fontSize: 13)),
        trailing: isAdmin
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.blue),
                    onPressed: () => _showMatkulForm(matkul),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Colors.red),
                    onPressed: () => _confirmDelete(matkul.nama, () => academic.removeMatkul(auth.token!, matkul.id)),
                  ),
                ],
              )
            : const Icon(Icons.chevron_right_rounded, color: Colors.grey),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textColor)),
          Text(title, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildMahasiswaTab(BuildContext context) {
    final academic = Provider.of<AcademicProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final isAdmin = auth.user?.role == 'admin';

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Daftar Mahasiswa'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            child: TextField(
              onChanged: (v) => academic.setSearchQuery(v),
              decoration: const InputDecoration(
                hintText: 'Cari nama atau NIM...',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
          ),
        ),
      ),
      body: academic.isLoading
          ? const LoadingStateWidget()
          : RefreshIndicator(
              onRefresh: () async => academic.getMahasiswas(auth.token!),
              child: ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: academic.filteredMahasiswas.length,
                itemBuilder: (context, index) {
                  final mhs = academic.filteredMahasiswas[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(5),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: CircleAvatar(
                        radius: 28,
                        backgroundColor: AppTheme.primaryColor.withAlpha(25),
                        child: Text(
                          mhs.nama[0].toUpperCase(),
                          style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(mhs.nama, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(mhs.nim),
                      trailing: isAdmin
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.blue),
                                  onPressed: () => _showMahasiswaForm(mhs),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Colors.red),
                                  onPressed: () => _confirmDelete(mhs.nama, () => academic.removeMahasiswa(auth.token!, mhs.id)),
                                ),
                              ],
                            )
                          : const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DetailMahasiswaScreen(mahasiswa: mhs)),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildProfile(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(title: const Text('Profil Saya')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.primaryColor.withAlpha(51), width: 4),
                  ),
                  child: const CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 80, color: AppTheme.primaryColor),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(color: AppTheme.primaryColor, shape: BoxShape.circle),
                    child: const Icon(Icons.edit_rounded, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(auth.user?.name ?? '', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(auth.user?.email ?? '', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
            const SizedBox(height: 40),
            _buildProfileItem(Icons.security_rounded, 'Keamanan Akun', Colors.blue),
            _buildProfileItem(Icons.notifications_outlined, 'Notifikasi', Colors.orange),
            _buildProfileItem(Icons.language_rounded, 'Bahasa', Colors.green),
            _buildProfileItem(Icons.info_outline_rounded, 'Tentang Aplikasi', Colors.purple),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade50,
                foregroundColor: Colors.red,
                elevation: 0,
                side: BorderSide(color: Colors.red.shade100),
              ),
              onPressed: () async {
                await auth.logout();
                if (!context.mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout_rounded),
                  SizedBox(width: 12),
                  Text('Keluar Aplikasi', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String title, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withAlpha(25), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.chevron_right_rounded, size: 20),
        onTap: () {},
      ),
    );
  }

  void _showMahasiswaForm([dynamic mahasiswa]) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final academic = Provider.of<AcademicProvider>(context, listen: false);
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MahasiswaForm(mahasiswa: mahasiswa)),
    );

    if (result != null) {
      try {
        if (mahasiswa == null) {
          await academic.addMahasiswa(auth.token!, result);
        } else {
          await academic.editMahasiswa(auth.token!, mahasiswa.id, result);
        }
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data berhasil disimpan')));
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _showMatkulForm([dynamic matkul]) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final academic = Provider.of<AcademicProvider>(context, listen: false);
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MatkulForm(matkul: matkul)),
    );

    if (result != null) {
      try {
        if (matkul == null) {
          await academic.addMatkul(auth.token!, result);
        } else {
          await academic.editMatkul(auth.token!, matkul.id, result);
        }
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data berhasil disimpan')));
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _confirmDelete(String title, VoidCallback onDelete) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Apakah Anda yakin ingin menghapus $title?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(context);
              onDelete();
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
