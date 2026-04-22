import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/academic_provider.dart';
import 'login_screen.dart';

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
    _fetchInitialData();
  }

  void _fetchInitialData() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final academic = Provider.of<AcademicProvider>(context, listen: false);
    if (auth.token != null) {
      academic.getMatkuls(auth.token!);
      academic.getMahasiswas(auth.token!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;

    final List<Widget> _pages = [
      _buildDashboard(),
      _buildMahasiswaList(),
      _buildProfile(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sistem Akademik', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.people_outline), label: 'Mahasiswa'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    final academic = Provider.of<AcademicProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    return RefreshIndicator(
      onRefresh: () async {
        if (auth.token != null) {
          await academic.getMatkuls(auth.token!);
        }
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Halo, ${auth.user?.name ?? "Mahasiswa"}!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Berikut adalah jadwal perkuliahan Anda minggu ini'),
            const SizedBox(height: 24),
            if (academic.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (academic.matkuls.isEmpty)
              const Center(child: Text('Tidak ada mata kuliah'))
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: academic.matkuls.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final matkul = academic.matkuls[index];
                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.book_rounded, color: Color(0xFF6366F1)),
                      ),
                      title: Text(matkul.nama, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${matkul.hari ?? "-"} | ${matkul.jamMulai ?? "-"} - ${matkul.jamSelesai ?? "-"}'),
                      trailing: Text(matkul.ruangan ?? "-", style: const TextStyle(color: Colors.blueGrey)),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMahasiswaList() {
    final academic = Provider.of<AcademicProvider>(context);
    return academic.isLoading 
      ? const Center(child: CircularProgressIndicator())
      : ListView.builder(
          itemCount: academic.mahasiswas.length,
          itemBuilder: (context, index) {
            final mhs = academic.mahasiswas[index];
            return ListTile(
              leading: CircleAvatar(child: Text(mhs.nama[0])),
              title: Text(mhs.nama),
              subtitle: Text(mhs.nim),
            );
          },
        );
  }

  Widget _buildProfile() {
    final auth = Provider.of<AuthProvider>(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
          const SizedBox(height: 16),
          Text(auth.user?.name ?? "", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(auth.user?.email ?? ""),
          const SizedBox(height: 32),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              await auth.logout();
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
            child: const Text('Keluar Aplikasi'),
          ),
        ],
      ),
    );
  }
}
