// ============================================
// FILE: lib/viewmodels/auth_viewmodel.dart
// ============================================

import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ================= FUNGSI LOGIN (SUDAH KONEK API) =================
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // 1. Panggil API melalui AuthService
    var result = await _authService.login(email, password);

    _isLoading = false;

    if (result['success'] == true) {
      // 2. Simpan token ke HP melalui StorageService buatan tim Anda
      await StorageService.saveToken(result['token']);

      // 3. Simpan nama dan email ke HP
      // Mengambil nama dari respons JSON Laravel, jika kosong pakai default
      String name = result['user']?['name'] ?? 'User Mark-Up';
      await StorageService.saveUserInfo(name, email);

      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'];
      notifyListeners();
      return false;
    }
  }

  // ================= FUNGSI REGISTER (SUDAH KONEK API) =================
  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    var result = await _authService.register(name, email, password, 'student');

    _isLoading = false;

    if (result['success'] == true) {
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'];
      notifyListeners();
      return false;
    }
  }

  // ================= FUNGSI LOGOUT (SUDAH KONEK API) =================
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    // 1. Beritahu Laravel untuk menghancurkan Token
    await _authService.logout();

    // 2. Kosongkan brankas di HP
    await StorageService.clearAll();

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> checkLoginStatus() async {
    return await StorageService.isLoggedIn();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
