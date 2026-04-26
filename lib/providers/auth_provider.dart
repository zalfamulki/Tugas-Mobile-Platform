import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  String? _token;
  bool _isLoading = false;

  UserModel? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;

  final AuthService _authService = AuthService();

  // Login Method
  Future<Map<String, dynamic>> login(String login, String password) async {
    _isLoading = true;
    notifyListeners();

    final result = await _authService.login(login, password);

    if (result['success']) {
      _token = result['token'];
      _user = UserModel.fromJson(result['user']);
      
      // Simpan ke SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
      await prefs.setString('user', jsonEncode(_user!.toJson()));
    }

    _isLoading = false;
    notifyListeners();
    return result;
  }

  // Register Method
  Future<Map<String, dynamic>> register(String name, String username, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    final result = await _authService.register(name, username, email, password);

    if (result['success']) {
      _token = result['token'];
      _user = UserModel.fromJson(result['user']);
      
      // Simpan ke SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
      await prefs.setString('user', jsonEncode(_user!.toJson()));
    }

    _isLoading = false;
    notifyListeners();
    return result;
  }

  // Forgot Password Method
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    _isLoading = true;
    notifyListeners();

    final result = await _authService.forgotPassword(email);

    _isLoading = false;
    notifyListeners();
    return result;
  }

  // Reset Password Method
  Future<Map<String, dynamic>> resetPassword(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    final result = await _authService.resetPassword(email, password);

    _isLoading = false;
    notifyListeners();
    return result;
  }

  // Google Login Method
  Future<Map<String, dynamic>> googleLogin(String email, String name) async {
    _isLoading = true;
    notifyListeners();

    final result = await _authService.googleLogin(email, name);

    if (result['success']) {
      _token = result['token'];
      _user = UserModel.fromJson(result['user']);
      
      // Simpan ke SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
      await prefs.setString('user', jsonEncode(_user!.toJson()));
    }

    _isLoading = false;
    notifyListeners();
    return result;
  }

  // Handle Google Sign In
  Future<Map<String, dynamic>> handleGoogleSignIn() async {
    _isLoading = true;
    notifyListeners();

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      
      if (googleUser == null) {
        // User canceled the sign-in
        _isLoading = false;
        notifyListeners();
        return {'success': false, 'message': 'Google Sign In dibatalkan'};
      }

      // We have the user details, now send to backend
      final result = await _authService.googleLogin(
        googleUser.email,
        googleUser.displayName ?? 'Google User',
      );

      if (result['success']) {
        _token = result['token'];
        _user = UserModel.fromJson(result['user']);
        
        // Simpan ke SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        await prefs.setString('user', jsonEncode(_user!.toJson()));
      }

      _isLoading = false;
      notifyListeners();
      return result;

    } catch (error) {
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': 'Google Sign In error: $error'};
    }
  }

  // Auto Login Method
  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('token')) return;

    _token = prefs.getString('token');
    final userData = prefs.getString('user');
    if (userData != null) {
      _user = UserModel.fromJson(jsonDecode(userData));
    }
    notifyListeners();
  }

  // Logout Method
  Future<void> logout() async {
    if (_token != null) {
      await _authService.logout(_token!);
    }
    
    _token = null;
    _user = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    notifyListeners();
  }
}
