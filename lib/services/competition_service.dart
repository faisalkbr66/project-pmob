// ============================================
// FILE: lib/services/competition_service.dart
// ============================================

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../models/competition_model.dart';
import 'api_service.dart';

class CompetitionService {
  /// Fetch daftar lomba dengan dukungan search, filter kategori,
  /// dan pagination Laravel.
  ///
  /// [category] boleh null atau 'Semua' untuk menampilkan semua kategori.
  Future<PaginatedCompetitions> fetchCompetitions({
    String? search,
    String? category,
    int page = 1,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
      };
      if (search != null && search.trim().isNotEmpty) {
        queryParameters['search'] = search.trim();
      }
      if (category != null &&
          category.isNotEmpty &&
          category.toLowerCase() != 'semua') {
        queryParameters['category'] = category;
      }

      final response = await ApiService.dio.get(
        ApiConfig.competitions,
        queryParameters: queryParameters,
      );

      if (kDebugMode) {
        debugPrint('[CompetitionService] GET ${ApiConfig.competitions} '
            '?$queryParameters → ${response.statusCode}');
        debugPrint('[CompetitionService] body: ${response.data}');
      }

      if (response.statusCode == 200) {
        final body = response.data;
        if (body is Map<String, dynamic>) {
          final result = PaginatedCompetitions.fromJson(body);
          if (kDebugMode) {
            debugPrint('[CompetitionService] parsed ${result.data.length} '
                'item(s), page ${result.currentPage}/${result.lastPage}');
          }
          return result;
        }
        if (body is List) {
          // Kalau API ternyata return raw array, bungkus jadi 1 halaman.
          return PaginatedCompetitions.fromJson({'data': body});
        }
        throw Exception('Format respons tidak dikenal');
      }
      throw Exception('Gagal memuat data lomba (${response.statusCode})');
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint('[CompetitionService] DioException: ${e.type} '
            '${e.response?.statusCode} ${e.response?.data}');
      }
      throw Exception(_readableError(e));
    }
  }

  String _readableError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'Koneksi timeout, coba lagi.';
      case DioExceptionType.connectionError:
        return 'Tidak dapat terhubung ke server.';
      default:
        break;
    }
    final data = e.response?.data;
    if (data is Map && data['message'] is String) return data['message'];
    return 'Terjadi kesalahan, silakan coba lagi.';
  }
}
