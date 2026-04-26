// ============================================
// FILE: lib/services/review_service.dart
// ============================================

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/api_config.dart';
import '../models/review_model.dart';
import 'api_service.dart';

class ReviewService {
  static final _dio = ApiService.dio;

  /// GET /api/products/{id}/reviews?page=N&per_page=10
  /// Response includes summary + paginated reviews.
  static Future<PaginatedReviews> fetchReviews(
    int productId, {
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final res = await _dio.get(
        ApiConfig.productReviews(productId),
        queryParameters: {'page': page, 'per_page': perPage},
      );
      if (kDebugMode) {
        debugPrint('[ReviewService] fetchReviews p$page: ${res.data}');
      }
      return PaginatedReviews.fromJson(_asMap(res.data));
    } on DioException catch (e) {
      throw _message(e);
    }
  }

  /// POST /api/products/{id}/reviews
  /// Body: { "rating": 5, "comment": "..." }
  static Future<ReviewModel> submitReview(
    int productId, {
    required int rating,
    required String comment,
  }) async {
    try {
      final res = await _dio.post(
        ApiConfig.productReviews(productId),
        data: {'rating': rating, 'comment': comment},
      );
      if (kDebugMode) debugPrint('[ReviewService] submitReview: ${res.data}');
      final raw = _unwrap(res.data);
      return ReviewModel.fromJson(raw);
    } on DioException catch (e) {
      throw _message(e);
    }
  }

  /// DELETE /api/reviews/{reviewId}
  static Future<void> deleteReview(int reviewId) async {
    try {
      await _dio.delete(ApiConfig.reviewById(reviewId));
    } on DioException catch (e) {
      throw _message(e);
    }
  }

  // ─── helpers ────────────────────────────────────────────────────────────────

  static Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return {};
  }

  static Map<String, dynamic> _unwrap(dynamic data) {
    var m = _asMap(data);
    int g = 0;
    while (m['data'] is Map && g < 4) {
      m = Map<String, dynamic>.from(m['data'] as Map);
      g++;
    }
    return m;
  }

  static String _message(DioException e) {
    final body = e.response?.data;
    if (body is Map) {
      final msg = body['message'] ?? body['error'] ?? body['pesan'];
      if (msg != null) return msg.toString();
    }
    return e.message ?? 'Terjadi kesalahan jaringan';
  }
}
