// ============================================
// FILE: lib/services/cart_service.dart
// ============================================

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/api_config.dart';
import '../models/cart_item_model.dart';
import 'api_service.dart';

class CartService {
  static final _dio = ApiService.dio;

  static Future<Cart> fetchCart() async {
    try {
      final res = await _dio.get(ApiConfig.cart);
      if (kDebugMode) debugPrint('[CartService] fetchCart: ${res.data}');
      return Cart.fromJson(_asMap(res.data));
    } on DioException catch (e) {
      throw _message(e);
    }
  }

  /// Tambah item ke keranjang. Jika produk sudah ada, server increment quantity.
  static Future<CartItem> addItem(int productId, {int quantity = 1}) async {
    try {
      final res = await _dio.post(ApiConfig.cart, data: {
        'product_id': productId,
        'quantity': quantity,
      });
      if (kDebugMode) debugPrint('[CartService] addItem: ${res.data}');
      final raw = _unwrapSingle(res.data);
      return CartItem.fromJson(raw);
    } on DioException catch (e) {
      throw _message(e);
    }
  }

  static Future<CartItem> updateQuantity(int cartItemId, int quantity) async {
    try {
      final res = await _dio.patch(
        '${ApiConfig.cart}/$cartItemId',
        data: {'quantity': quantity},
      );
      if (kDebugMode) debugPrint('[CartService] updateQuantity: ${res.data}');
      final raw = _unwrapSingle(res.data);
      return CartItem.fromJson(raw);
    } on DioException catch (e) {
      throw _message(e);
    }
  }

  static Future<void> removeItem(int cartItemId) async {
    try {
      await _dio.delete('${ApiConfig.cart}/$cartItemId');
    } on DioException catch (e) {
      throw _message(e);
    }
  }

  static Future<void> clearCart() async {
    try {
      await _dio.delete('${ApiConfig.cart}/clear');
    } on DioException catch (e) {
      throw _message(e);
    }
  }

  // ===== helpers =====

  static Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return {};
  }

  static Map<String, dynamic> _unwrapSingle(dynamic data) {
    var m = _asMap(data);
    int guard = 0;
    while (m['data'] is Map && guard < 4) {
      m = Map<String, dynamic>.from(m['data'] as Map);
      guard++;
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
