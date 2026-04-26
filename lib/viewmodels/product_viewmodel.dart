// ============================================
// FILE: lib/viewmodels/product_viewmodel.dart
// ============================================

import 'dart:async';
import 'package:flutter/foundation.dart';

import '../models/mentor_model.dart';
import '../models/product_model.dart';
import '../services/mentor_service.dart';
import '../services/product_service.dart';

enum ProductTab { semua, modul, kelas, bootcamp, mentoring }

extension ProductTabX on ProductTab {
  String get label {
    switch (this) {
      case ProductTab.semua:
        return 'Semua';
      case ProductTab.modul:
        return 'Modul';
      case ProductTab.kelas:
        return 'Kelas';
      case ProductTab.bootcamp:
        return 'Bootcamp';
      case ProductTab.mentoring:
        return 'Mentoring';
    }
  }

  /// Nilai yang dikirim ke API (`type` query param). Null = jangan kirim.
  String? get apiType {
    switch (this) {
      case ProductTab.semua:
      case ProductTab.mentoring:
        return null;
      case ProductTab.modul:
        return 'modul';
      case ProductTab.kelas:
        return 'kelas';
      case ProductTab.bootcamp:
        return 'bootcamp';
    }
  }
}

enum ProductSort { terpopuler, terbaru, termurah }

extension ProductSortX on ProductSort {
  String get label {
    switch (this) {
      case ProductSort.terpopuler:
        return 'Terpopuler';
      case ProductSort.terbaru:
        return 'Terbaru';
      case ProductSort.termurah:
        return 'Termurah';
    }
  }

  String get apiValue => name; // 'terpopuler' | 'terbaru' | 'termurah'
}

enum ProductSectionState { initial, loading, loaded, error }

class ProductViewModel extends ChangeNotifier {
  ProductViewModel({
    ProductService? productService,
    MentorService? mentorService,
  })  : _productService = productService ?? ProductService(),
        _mentorService = mentorService ?? MentorService();

  final ProductService _productService;
  final MentorService _mentorService;

  // ===== State produk =====
  ProductSectionState _productState = ProductSectionState.initial;
  String? _productError;
  List<ProductModel> _products = [];

  // ===== State mentor =====
  ProductSectionState _mentorState = ProductSectionState.initial;
  String? _mentorError;
  List<MentorModel> _mentors = [];

  // ===== State filter / search =====
  ProductTab _activeTab = ProductTab.semua;
  ProductSort _sort = ProductSort.terpopuler;
  String _search = '';
  Timer? _debounce;

  // ===== Getters =====
  ProductSectionState get productState => _productState;
  String? get productError => _productError;
  List<ProductModel> get products => _products;

  ProductSectionState get mentorState => _mentorState;
  String? get mentorError => _mentorError;
  List<MentorModel> get mentors => _mentors;

  ProductTab get activeTab => _activeTab;
  ProductSort get sort => _sort;
  String get search => _search;

  bool get isProductLoading => _productState == ProductSectionState.loading;
  bool get isMentorLoading => _mentorState == ProductSectionState.loading;

  /// Tab yang menampilkan grid produk.
  bool get showProducts => _activeTab != ProductTab.mentoring;

  /// Tab yang menampilkan section mentoring.
  bool get showMentoring =>
      _activeTab == ProductTab.semua || _activeTab == ProductTab.mentoring;

  /// Produk yang ditampilkan di grid.
  List<ProductModel> get gridProducts {
    if (!showProducts) return const [];
    return _products;
  }

  /// Total mentor aktif untuk badge "X mentor aktif" di section header.
  int get availableMentorCount =>
      _mentors.where((m) => m.available).length;

  /// Mentor unggulan untuk featured card di slot atas.
  /// Kriteria: rating tertinggi & available.
  MentorModel? get featuredMentor {
    if (_mentors.isEmpty) return null;
    final available = _mentors.where((m) => m.available).toList();
    final pool = available.isNotEmpty ? available : _mentors;
    final sorted = [...pool]..sort((a, b) => b.rating.compareTo(a.rating));
    return sorted.first;
  }

  // ===== Actions =====

  /// Dipanggil sekali saat screen pertama kali dibuka.
  Future<void> init() async {
    if (_productState == ProductSectionState.initial) {
      await Future.wait([
        fetchProducts(),
        fetchMentors(),
      ]);
    }
  }

  Future<void> fetchProducts() async {
    _productState = ProductSectionState.loading;
    _productError = null;
    notifyListeners();
    try {
      final result = await _productService.fetchProducts(
        search: _search,
        type: _activeTab.apiType,
        sort: _sort.apiValue,
      );
      _products = result.data;
      _productState = ProductSectionState.loaded;
    } catch (e) {
      _productError = e.toString().replaceFirst('Exception: ', '');
      _productState = ProductSectionState.error;
    }
    notifyListeners();
  }

  Future<void> fetchMentors() async {
    _mentorState = ProductSectionState.loading;
    _mentorError = null;
    notifyListeners();
    try {
      _mentors = await _mentorService.fetchMentors();
      _mentorState = ProductSectionState.loaded;
    } catch (e) {
      _mentorError = e.toString().replaceFirst('Exception: ', '');
      _mentorState = ProductSectionState.error;
    }
    notifyListeners();
  }

  void setActiveTab(ProductTab tab) {
    if (tab == _activeTab) return;
    _activeTab = tab;
    notifyListeners();
    // Tab Mentoring tidak butuh refetch produk (mereka di-cache).
    if (tab != ProductTab.mentoring) fetchProducts();
  }

  void setSort(ProductSort sort) {
    if (sort == _sort) return;
    _sort = sort;
    notifyListeners();
    fetchProducts();
  }

  void onSearchChanged(String value) {
    _search = value;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), fetchProducts);
  }

  Future<void> retryProducts() => fetchProducts();
  Future<void> retryMentors() => fetchMentors();

  Future<void> refresh() async {
    await Future.wait([fetchProducts(), fetchMentors()]);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
