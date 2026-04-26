// ============================================
// FILE: lib/viewmodels/cart_viewmodel.dart
// ============================================

import 'package:flutter/foundation.dart';

import '../models/cart_item_model.dart';
import '../models/product_model.dart';
import '../services/cart_service.dart';

enum CartState { idle, loading, error }

class CartViewModel extends ChangeNotifier {
  List<CartItem> _items = [];
  CartState _state = CartState.idle;
  String? _error;

  // Per-item action state: itemId → true while busy (increment/decrement/remove)
  final Map<int, bool> _busyItems = {};

  List<CartItem> get items => _items;
  CartState get state => _state;
  String? get error => _error;
  bool get isEmpty => _items.isEmpty;
  bool get isLoading => _state == CartState.loading;

  int get totalItems => _items.fold(0, (s, i) => s + i.quantity);
  int get subtotal => _items.fold(0, (s, i) => s + i.lineTotal);
  String get formattedSubtotal => Cart.rupiah(subtotal);

  bool isBusy(int itemId) => _busyItems[itemId] == true;

  // ─── Load ───────────────────────────────────────────────────────────────────

  Future<void> loadCart() async {
    _state = CartState.loading;
    _error = null;
    notifyListeners();

    try {
      final cart = await CartService.fetchCart();
      _items = cart.items;
      _state = CartState.idle;
    } catch (e) {
      _error = e.toString();
      _state = CartState.error;
    }
    notifyListeners();
  }

  Future<void> refresh() => loadCart();

  // ─── Add ────────────────────────────────────────────────────────────────────

  /// Returns true if added successfully. Throws string message on failure.
  Future<bool> addProduct(ProductModel product, {int quantity = 1}) async {
    // Optimistic: check if already in cart
    final existing = _findByProductId(product.id);
    if (existing != null) {
      // Just increment locally while we wait
      _optimisticUpdate(
        existing.id,
        existing.copyWith(quantity: existing.quantity + quantity),
      );
    } else {
      // Add a placeholder so badge updates immediately
      final placeholder = CartItem(
        id: _placeholderId(),
        product: product,
        quantity: quantity,
      );
      _items = [..._items, placeholder];
      notifyListeners();
    }

    try {
      final item = await CartService.addItem(product.id, quantity: quantity);
      // Replace placeholder / stale entry with real server item
      _replaceOrInsert(product.id, item);
      notifyListeners();
      return true;
    } catch (e) {
      // Rollback
      await loadCart();
      rethrow;
    }
  }

  // ─── Quantity stepper ────────────────────────────────────────────────────────

  Future<void> increment(CartItem item) async {
    if (isBusy(item.id)) return;
    _setBusy(item.id, true);
    _optimisticUpdate(item.id, item.copyWith(quantity: item.quantity + 1));

    try {
      final updated =
          await CartService.updateQuantity(item.id, item.quantity + 1);
      _replaceById(item.id, updated);
    } catch (_) {
      _optimisticUpdate(item.id, item); // rollback
    } finally {
      _setBusy(item.id, false);
    }
  }

  Future<void> decrement(CartItem item) async {
    if (isBusy(item.id)) return;
    if (item.quantity <= 1) {
      await removeItem(item);
      return;
    }
    _setBusy(item.id, true);
    _optimisticUpdate(item.id, item.copyWith(quantity: item.quantity - 1));

    try {
      final updated =
          await CartService.updateQuantity(item.id, item.quantity - 1);
      _replaceById(item.id, updated);
    } catch (_) {
      _optimisticUpdate(item.id, item);
    } finally {
      _setBusy(item.id, false);
    }
  }

  // ─── Remove / Clear ─────────────────────────────────────────────────────────

  Future<void> removeItem(CartItem item) async {
    if (isBusy(item.id)) return;
    _setBusy(item.id, true);

    final snapshot = List<CartItem>.from(_items);
    _items = _items.where((i) => i.id != item.id).toList();
    _busyItems.remove(item.id);
    notifyListeners();

    try {
      await CartService.removeItem(item.id);
    } catch (_) {
      _items = snapshot; // rollback
      notifyListeners();
    }
  }

  Future<void> clearCart() async {
    final snapshot = List<CartItem>.from(_items);
    _items = [];
    notifyListeners();

    try {
      await CartService.clearCart();
    } catch (_) {
      _items = snapshot;
      notifyListeners();
    }
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────────

  CartItem? _findByProductId(int productId) {
    try {
      return _items.firstWhere((i) => i.product.id == productId);
    } catch (_) {
      return null;
    }
  }

  void _optimisticUpdate(int itemId, CartItem updated) {
    _items = _items.map((i) => i.id == itemId ? updated : i).toList();
    notifyListeners();
  }

  void _replaceById(int itemId, CartItem updated) {
    _items = _items.map((i) => i.id == itemId ? updated : i).toList();
    notifyListeners();
  }

  void _replaceOrInsert(int productId, CartItem serverItem) {
    final idx = _items.indexWhere((i) => i.product.id == productId);
    if (idx >= 0) {
      final list = List<CartItem>.from(_items);
      list[idx] = serverItem;
      _items = list;
    } else {
      _items = [..._items, serverItem];
    }
  }

  void _setBusy(int itemId, bool busy) {
    busy ? _busyItems[itemId] = true : _busyItems.remove(itemId);
    notifyListeners();
  }

  // Negative placeholder ids won't clash with server ids
  int _placeholderId() => -(DateTime.now().millisecondsSinceEpoch % 100000);
}
