// ============================================
// FILE: lib/models/cart_item_model.dart
// ============================================

import 'product_model.dart';

class CartItem {
  final int id; // cart_item id dari server
  final ProductModel product;
  final int quantity;

  const CartItem({
    required this.id,
    required this.product,
    required this.quantity,
  });

  int get lineTotal => product.price * quantity;

  CartItem copyWith({int? quantity}) => CartItem(
        id: id,
        product: product,
        quantity: quantity ?? this.quantity,
      );

  factory CartItem.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is double) return v.toInt();
      return int.tryParse(v.toString().replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    }

    final productRaw = json['product'] ?? json['produk'] ?? json;
    final product = ProductModel.fromJson(
      productRaw is Map<String, dynamic>
          ? productRaw
          : Map<String, dynamic>.from(productRaw as Map),
    );

    return CartItem(
      id: parseInt(json['id'] ?? json['cart_item_id']),
      product: product,
      quantity: parseInt(json['quantity'] ?? json['jumlah'] ?? 1),
    );
  }

  Map<String, dynamic> toJson() => {
        'product_id': product.id,
        'quantity': quantity,
      };
}

class Cart {
  final List<CartItem> items;

  const Cart({required this.items});

  int get totalItems => items.fold(0, (s, i) => s + i.quantity);
  int get subtotal => items.fold(0, (s, i) => s + i.lineTotal);

  factory Cart.fromJson(Map<String, dynamic> json) {
    dynamic source = json;

    // Unwrap nested data from Laravel
    int guard = 0;
    while (source is Map && source['data'] is Map && guard < 4) {
      source = source['data'];
      guard++;
    }

    final List rawList = (source is Map && source['data'] is List)
        ? source['data'] as List
        : (source is Map && source['items'] is List)
            ? source['items'] as List
            : (json['data'] is List
                ? json['data'] as List
                : (json['items'] is List ? json['items'] as List : const []));

    return Cart(
      items: rawList
          .whereType<Map>()
          .map((e) => CartItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  static String rupiah(int value) {
    if (value <= 0) return 'Rp 0';
    final s = value.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final remaining = s.length - i;
      buf.write(s[i]);
      if (remaining > 1 && remaining % 3 == 1) buf.write('.');
    }
    return 'Rp $buf';
  }
}
