// ============================================
// FILE: lib/viewmodels/competition_viewmodel.dart
// ============================================

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/competition_model.dart';
import '../services/competition_service.dart';

enum CompetitionViewState { initial, loading, loaded, error }

class CompetitionViewModel extends ChangeNotifier {
  CompetitionViewModel({CompetitionService? service})
      : _service = service ?? CompetitionService();

  final CompetitionService _service;

  // Kategori filter default (aligned dengan desain).
  final List<String> categories = const [
    'Semua',
    'Business Case',
    'Business Plan',
    'Business Model Canvas',
    'UI/UX',
    'LKTI',
  ];

  CompetitionViewState _state = CompetitionViewState.initial;
  String? _errorMessage;
  List<CompetitionModel> _competitions = [];
  int _currentPage = 1;
  int _lastPage = 1;
  int _total = 0;
  String _search = '';
  String _activeCategory = 'Semua';
  Timer? _debounce;

  // ===== Getters =====
  CompetitionViewState get state => _state;
  String? get errorMessage => _errorMessage;
  List<CompetitionModel> get competitions => _competitions;
  int get currentPage => _currentPage;
  int get lastPage => _lastPage;
  int get total => _total;
  String get search => _search;
  String get activeCategory => _activeCategory;

  bool get isLoading => _state == CompetitionViewState.loading;
  bool get hasError => _state == CompetitionViewState.error;
  bool get isEmpty =>
      _state == CompetitionViewState.loaded && _competitions.isEmpty;

  /// Entry point — dipanggil saat screen pertama di-mount.
  Future<void> init() async {
    if (_state == CompetitionViewState.initial) {
      await fetchCompetitions(page: 1);
    }
  }

  Future<void> fetchCompetitions({int page = 1}) async {
    _state = CompetitionViewState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _service.fetchCompetitions(
        search: _search,
        category: _activeCategory,
        page: page,
      );
      _competitions = result.data;
      _currentPage = result.currentPage;
      _lastPage = result.lastPage;
      _total = result.total;
      _state = CompetitionViewState.loaded;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _state = CompetitionViewState.error;
    }
    notifyListeners();
  }

  /// Dipanggil tiap TextField berubah. Debounce 400ms agar tidak
  /// memukul API tiap ketikan.
  void onSearchChanged(String value) {
    _search = value;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      fetchCompetitions(page: 1);
    });
  }

  void onCategoryChanged(String category) {
    if (_activeCategory == category) return;
    _activeCategory = category;
    notifyListeners();
    fetchCompetitions(page: 1);
  }

  void goToPage(int page) {
    if (page < 1 || page > _lastPage || page == _currentPage) return;
    fetchCompetitions(page: page);
  }

  Future<void> retry() => fetchCompetitions(page: _currentPage);

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
