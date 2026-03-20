// ============================================
// FILE: lib/services/auth_service.dart
// ============================================

import 'package:dio/dio.dart';
import 'api_service.dart';

class AuthService {
  // ================= REGISTER =================
  Future<Map<String, dynamic>> register(
      String name, String email, String password, String role) async {
    try {
      // Dio otomatis menggabungkan ApiConfig.baseUrl dengan '/register'
      final response = await ApiService.dio.post(
        '/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'role': role,
        },
      );

      // Status 201 artinya Created (Berhasil Dibuat)
      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true, 'message': 'Registrasi berhasil'};
      }
      return {'success': false, 'message': 'Terjadi kesalahan tidak terduga'};
    } on DioException catch (e) {
      // Menangkap error validasi dari Laravel (misal 422 Unprocessable Entity jika email sudah ada)
      String errorMessage = 'Gagal mendaftar';
      if (e.response != null && e.response?.data != null) {
        errorMessage = e.response?.data['message'] ?? errorMessage;
      }
      return {'success': false, 'message': errorMessage};
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server'};
    }
  }

  // ================= LOGIN =================
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await ApiService.dio.post(
        '/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'token': response.data['access_token'], // Token dari Laravel Sanctum
          'user': response.data['user'], // Data user (nama, email, role)
        };
      }
      return {'success': false, 'message': 'Login gagal'};
    } on DioException catch (e) {
      String errorMessage = 'Email atau password salah';
      if (e.response != null && e.response?.data != null) {
        errorMessage = e.response?.data['message'] ?? errorMessage;
      }
      return {'success': false, 'message': errorMessage};
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan jaringan'};
    }
  }

  // ================= LOGOUT =================
  Future<bool> logout() async {
    try {
      // Kita tidak perlu mengirim header Authorization manual di sini!
      // Interceptor dari api_service.dart otomatis menempelkan Token-nya.
      final response = await ApiService.dio.post('/logout');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
