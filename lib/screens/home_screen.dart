import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/academic_provider.dart';
import 'login_screen.dart';
import 'jadwal_screen.dart';
import 'nilai_screen.dart';
import 'detail_mahasiswa_screen.dart';
import '../widgets/state_widgets.dart';

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
    
    final List<Widget> _pages = [
      _buildDashboard(context),
      _buildMahasiswaTab(context),
      _buildProfile(context),
    ];

    return Scaffold(
      appBar: _currentIndex == 1 ? null : AppBar(
        title: const Text('Sistem Akademik', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'Mahasiswa'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }

  Widget _buildDashboard(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final academic = Provider.of<AcademicProvider>(context);

    return RefreshIndicator(
      onRefresh: () async => academic.getAllData(auth.token!, auth.user!.id),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Selamat Datang,', style: TextStyle(fontSize: 16)),
                      Text(
                        auth.user?.name ?? 'Mahasiswa',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const CircleAvatar(radius: 25, child: Icon(Icons.person)),
              ],
            ),
            const SizedBox(height: 30),
            
            // Menu Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              mainAxisSpacing: 20,
              crossAxisSpacing: 10,
              children: [
                _buildMenuItem(context, Icons.calendar_month_rounded, 'Jadwal', Colors.blue, const JadwalScreen()),
                _buildMenuItem(context, Icons.assignment_turned_in_rounded, 'Nilai', Colors.green, const NilaiScreen()),
                _buildMenuItem(context, Icons.edit_note_rounded, 'KRS', Colors.orange, null),
                _buildMenuItem(context, Icons.book_rounded, 'Matkul', Colors.purple, null),
              ],
            ),
            
            const SizedBox(height: 40),
            const Text(
              'Mata Kuliah Anda',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            if (academic.isLoading)
              const LoadingStateWidget()
            else if (academic.hasError)
              ErrorStateWidget(message: academic.error!, onRetry: _fetchInitialData)
            else if (academic.matkuls.isEmpty)
              const EmptyStateWidget(message: 'Belum mengambil mata kuliah')
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: academic.matkuls.length > 3 ? 3 : academic.matkuls.length,
                itemBuilder: (context, index) {
                  final matkul = academic.matkuls[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(matkul.nama, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(matkul.kode),
                      trailing: const Icon(Icons.chevron_right),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String label, Color color, Widget? target) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            if (target != null) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => target));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fitur $label akan segera hadir')));
            }
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildMahasiswaTab(BuildContext context) {
    final academic = Provider.of<AcademicProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    return Column(
      children: [
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (v) => academic.setSearchQuery(v),
              decoration: InputDecoration(
                hintText: 'Cari Mahasiswa...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: academic.isLoading
              ? const LoadingStateWidget()
              : RefreshIndicator(
                  onRefresh: () async => academic.getMahasiswas(auth.token!),
                  child: ListView.builder(
                    itemCount: academic.filteredMahasiswas.length,
                    itemBuilder: (context, index) {
                      final mhs = academic.filteredMahasiswas[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF6366F1).withOpacity(0.1),
                          child: Text(mhs.nama[0], style: const TextStyle(color: Color(0xFF6366F1))),
                        ),
                        title: Text(mhs.nama, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(mhs.nim),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => DetailMahasiswaScreen(mahasiswa: mhs)),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildProfile(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const SizedBox(height: 20),
          const CircleAvatar(radius: 60, child: Icon(Icons.person, size: 60)),
          const SizedBox(height: 20),
          Text(auth.user?.name ?? '', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text(auth.user?.email ?? '', style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 40),
          _buildProfileItem(Icons.settings_outlined, 'Pengaturan Akun'),
          _buildProfileItem(Icons.help_outline_rounded, 'Pusat Bantuan'),
          const Spacer(),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red,
              minimumSize: const Size(double.infinity, 60),
            ),
            onPressed: () async {
              await auth.logout();
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('Keluar Aplikasi', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: () {},
    );
  }
}
