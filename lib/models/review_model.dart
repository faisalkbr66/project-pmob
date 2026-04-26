// ============================================
// FILE: lib/models/review_model.dart
// ============================================

class ReviewModel {
  final int id;
  final int userId;
  final int rating; // 1–5
  final String comment;
  final String userName;
  final String createdAt; // raw ISO string
  final bool canDelete; // true kalau review milik user yang login

  const ReviewModel({
    required this.id,
    required this.userId,
    required this.rating,
    required this.comment,
    required this.userName,
    required this.createdAt,
    this.canDelete = false,
  });

  String get initials {
    final parts = userName.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  String get formattedDate {
    try {
      final dt = DateTime.parse(createdAt).toLocal();
      const months = [
        'Jan','Feb','Mar','Apr','Mei','Jun',
        'Jul','Ags','Sep','Okt','Nov','Des',
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return createdAt;
    }
  }

  List<List<int>> get _palettes => const [
        [0xFFA600B2, 0xFF6B0075],
        [0xFF001261, 0xFF002196],
        [0xFF002196, 0xFF1D4ED8],
        [0xFF16A34A, 0xFF065F46],
        [0xFF7C3AED, 0xFF4F46E5],
      ];

  List<int> get avatarGradientRaw => _palettes[userId % _palettes.length];

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic v, {int fallback = 0}) {
      if (v is int) return v;
      if (v is double) return v.toInt();
      return int.tryParse('${v ?? ''}') ?? fallback;
    }

    final user = json['user'] is Map ? json['user'] as Map : {};
    final userName = (user['name'] ??
            user['nama'] ??
            json['user_name'] ??
            json['reviewer'] ??
            'Anonim')
        .toString();

    return ReviewModel(
      id: parseInt(json['id']),
      userId: parseInt(json['user_id'] ?? user['id']),
      rating: parseInt(json['rating'] ?? json['stars'] ?? json['bintang']),
      comment: (json['comment'] ?? json['komentar'] ?? json['body'] ?? '')
          .toString(),
      userName: userName,
      createdAt: (json['created_at'] ?? json['tanggal'] ?? '').toString(),
      canDelete: (() {
        final v = json['can_delete'] ?? json['is_mine'];
        if (v == null) return false;
        if (v is bool) return v;
        return v.toString() == 'true' || v.toString() == '1';
      })(),
    );
  }
}

class ReviewSummary {
  final double ratingAvg;
  final int total;
  final List<int> distribution; // [% bintang 5, 4, 3, 2, 1]

  const ReviewSummary({
    required this.ratingAvg,
    required this.total,
    required this.distribution,
  });

  factory ReviewSummary.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic v) {
      if (v is num) return v.toDouble();
      return double.tryParse('$v') ?? 0;
    }

    int parseInt(dynamic v) {
      if (v is int) return v;
      if (v is double) return v.toInt();
      return int.tryParse('$v') ?? 0;
    }

    final distRaw = json['distribution'] ?? json['distribusi'];
    List<int> dist;
    if (distRaw is List) {
      dist = distRaw.map((e) => parseInt(e)).toList();
    } else {
      dist = [0, 0, 0, 0, 0];
    }
    while (dist.length < 5) {
      dist.add(0);
    }

    return ReviewSummary(
      ratingAvg: parseDouble(json['rating_avg'] ?? json['average'] ?? json['rating']),
      total: parseInt(json['total'] ?? json['count'] ?? json['total_reviews']),
      distribution: dist,
    );
  }

  static ReviewSummary empty() =>
      const ReviewSummary(ratingAvg: 0, total: 0, distribution: [0, 0, 0, 0, 0]);
}

class PaginatedReviews {
  final List<ReviewModel> data;
  final ReviewSummary summary;
  final int currentPage;
  final int lastPage;
  final int total;

  const PaginatedReviews({
    required this.data,
    required this.summary,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  bool get hasMore => currentPage < lastPage;

  factory PaginatedReviews.fromJson(Map<String, dynamic> json) {
    // Unwrap nested data from Laravel
    Map<String, dynamic> source = json;
    int guard = 0;
    while (source['data'] is Map && guard < 4) {
      source = Map<String, dynamic>.from(source['data'] as Map);
      guard++;
    }

    final List rawList = source['data'] is List
        ? source['data'] as List
        : (json['data'] is List ? json['data'] as List : const []);

    final meta = source['meta'] is Map
        ? Map<String, dynamic>.from(source['meta'] as Map)
        : source;

    int asInt(dynamic v, {int fallback = 0}) {
      if (v is int) return v;
      if (v is double) return v.toInt();
      return int.tryParse('${v ?? ''}') ?? fallback;
    }

    final summaryRaw = json['summary'] ?? json['statistik'] ?? {};
    final summary = summaryRaw is Map
        ? ReviewSummary.fromJson(Map<String, dynamic>.from(summaryRaw))
        : ReviewSummary.empty();

    return PaginatedReviews(
      data: rawList
          .whereType<Map>()
          .map((e) => ReviewModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      summary: summary,
      currentPage: asInt(meta['current_page'], fallback: 1),
      lastPage: asInt(meta['last_page'], fallback: 1),
      total: asInt(meta['total'], fallback: rawList.length),
    );
  }
}
