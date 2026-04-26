import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isEmailVerified = false;
  bool _obscurePassword = true;

  void _handleCheckEmail() async {
    if (_emailController.text.isEmpty) {
      _showSnackBar('Email harus diisi', Colors.redAccent);
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final result = await authProvider.forgotPassword(_emailController.text);

    if (mounted) {
      if (result['success']) {
        setState(() {
          _isEmailVerified = true;
        });
        _showSnackBar(result['message'] ?? 'Email terverifikasi', Colors.green);
      } else {
        _showSnackBar(result['message'] ?? 'Email tidak ditemukan', Colors.redAccent);
      }
    }
  }

  void _handleResetPassword() async {
    if (_passwordController.text.isEmpty || _passwordController.text.length < 6) {
      _showSnackBar('Password baru minimal 6 karakter', Colors.redAccent);
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final result = await authProvider.resetPassword(_emailController.text, _passwordController.text);

    if (mounted) {
      if (result['success']) {
        _showSnackBar(result['message'] ?? 'Password berhasil diubah', Colors.green);
        Navigator.pop(context); // Kembali ke login
      } else {
        _showSnackBar(result['message'] ?? 'Gagal mereset password', Colors.redAccent);
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = Provider.of<AuthProvider>(context).isLoading;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background Decoration
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryColor.withAlpha(12),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withAlpha(76),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.lock_reset_rounded, size: 40, color: Colors.white),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    _isEmailVerified ? 'Buat Password Baru' : 'Lupa Password?',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 28,
                          color: AppTheme.textColor,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _isEmailVerified 
                        ? 'Silakan masukkan password baru untuk akun Anda.' 
                        : 'Masukkan email yang terdaftar. Kami akan memverifikasi email Anda sebelum mereset password.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.textSecondaryColor,
                          height: 1.5,
                        ),
                  ),
                  const SizedBox(height: 48),
                  
                  // Email Field
                  Text(
                    'Email',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textColor,
                        ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    enabled: !_isEmailVerified,
                    decoration: InputDecoration(
                      hintText: 'Masukkan email Anda',
                      prefixIcon: const Icon(Icons.alternate_email_rounded),
                      filled: _isEmailVerified,
                      fillColor: _isEmailVerified ? Colors.grey.shade200 : null,
                    ),
                  ),
                  
                  if (_isEmailVerified) ...[
                    const SizedBox(height: 24),
                    // New Password Field
                    Text(
                      'Password Baru',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textColor,
                          ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: 'Masukkan password baru',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                            size: 20,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 48),
                  
                  // Action Button
                  ElevatedButton(
                    onPressed: isLoading 
                        ? null 
                        : (_isEmailVerified ? _handleResetPassword : _handleCheckEmail),
                    style: ElevatedButton.styleFrom(
                      elevation: 8,
                      shadowColor: AppTheme.primaryColor.withAlpha(102),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : Text(_isEmailVerified ? 'Simpan Password Baru' : 'Verifikasi Email'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
