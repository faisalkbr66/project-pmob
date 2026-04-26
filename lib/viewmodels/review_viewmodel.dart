// ============================================
// FILE: lib/viewmodels/review_viewmodel.dart
// ============================================

import 'package:flutter/foundation.dart';

import '../models/review_model.dart';
import '../services/review_service.dart';

enum ReviewState { idle, loading, error }

class ReviewViewModel extends ChangeNotifier {
  List<ReviewModel> _reviews = [];
  ReviewSummary _summary = ReviewSummary.empty();
  ReviewState _state = ReviewState.idle;
  String? _error;

  bool _isSubmitting = false;
  String? _submitError;

  int _currentPage = 0;
  int _lastPage = 1;
  bool _isLoadingMore = false;

  // ── Public getters ──────────────────────────────────────────────────────────

  List<ReviewModel> get reviews => _reviews;
  ReviewSummary get summary => _summary;
  ReviewState get state => _state;
  String? get error => _error;
  bool get isLoading => _state == ReviewState.loading;
  bool get isSubmitting => _isSubmitting;
  String? get submitError => _submitError;
  bool get hasMore => _currentPage < _lastPage;
  bool get isLoadingMore => _isLoadingMore;
  bool get isEmpty => _reviews.isEmpty && _state == ReviewState.idle;

  // ── Load / pagination ────────────────────────────────────────────────────────

  Future<void> load(int productId) async {
    _state = ReviewState.loading;
    _error = null;
    _currentPage = 0;
    _reviews = [];
    notifyListeners();

    try {
      final page = await ReviewService.fetchReviews(productId, page: 1);
      _summary = page.summary;
      _reviews = page.data;
      _currentPage = page.currentPage;
      _lastPage = page.lastPage;
      _state = ReviewState.idle;
    } catch (e) {
      _error = e.toString();
      _state = ReviewState.error;
    }
    notifyListeners();
  }

  Future<void> loadMore(int productId) async {
    if (_isLoadingMore || !hasMore) return;
    _isLoadingMore = true;
    notifyListeners();

    try {
      final page = await ReviewService.fetchReviews(
        productId,
        page: _currentPage + 1,
      );
      _reviews = [..._reviews, ...page.data];
      _currentPage = page.currentPage;
      _lastPage = page.lastPage;
    } catch (_) {
      // loadMore failures are silent — user can retry via "Lihat Lebih Banyak"
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> retry(int productId) => load(productId);

  // ── Submit ────────────────────────────────────────────────────────────────────

  /// Returns true on success. On failure, sets [submitError] and returns false.
  Future<bool> submit(int productId, int rating, String comment) async {
    _isSubmitting = true;
    _submitError = null;
    notifyListeners();

    try {
      final newReview = await ReviewService.submitReview(
        productId,
        rating: rating,
        comment: comment,
      );
      // Prepend to list so user sees their review immediately
      _reviews = [newReview, ..._reviews];

      // Recompute summary locally (optimistic)
      _rebuildSummary(rating);

      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _submitError = e.toString();
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  // ── Delete ────────────────────────────────────────────────────────────────────

  Future<bool> deleteReview(int reviewId) async {
    final snapshot = List<ReviewModel>.from(_reviews);
    _reviews = _reviews.where((r) => r.id != reviewId).toList();
    notifyListeners();

    try {
      await ReviewService.deleteReview(reviewId);
      return true;
    } catch (e) {
      _reviews = snapshot; // rollback
      notifyListeners();
      return false;
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────────

  void _rebuildSummary(int newRating) {
    final n = _summary.total + 1;
    final newAvg = ((_summary.ratingAvg * _summary.total) + newRating) / n;

    final dist = List<int>.from(_summary.distribution);
    final idx = 5 - newRating; // index 0 = 5 stars
    if (idx >= 0 && idx < dist.length) {
      // Rough pct update
      final prev = dist[idx] * _summary.total / 100;
      dist[idx] = ((prev + 1) / n * 100).round();
    }

    _summary = ReviewSummary(
      ratingAvg: newAvg,
      total: n,
      distribution: dist,
    );
  }
}
