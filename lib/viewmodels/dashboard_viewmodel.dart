import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../models/course_model.dart';
import '../models/competition_model.dart';

class DashboardViewModel extends ChangeNotifier {
  String _userName = 'User';
  String get userName => _userName;

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  void setBottomNavIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  // Data Dummy Produk Unggulan
  final List<Course> featuredModules = [
    Course(
      title: "Winner Class & Module: Business Case",
      ratingText: "4.9 (1.2k+ Siswa)",
      price: "Rp 149.000",
      imageUrl: "https://images.unsplash.com/photo-1434030216411-0b793f4b4173?w=500", // Placeholder
      badge: "TERPOPULER",
    ),
    Course(
      title: "WOW Case Mastery Class",
      ratingText: "4.8 (800+ Siswa)",
      price: "Rp 299.000",
      imageUrl: "https://images.unsplash.com/photo-1556761175-5973dc0f32e7?w=500", // Placeholder
      badge: "EXCLUSIVE",
    ),
  ];

  // Data Dummy Info Lomba Terbaru
  final List<Competition> competitions = [
    Competition(
      title: "National Business Plan Competition 2026",
      month: "MAR",
      date: "14",
      category: "MAHASISWA",
      prizeInfo: "Prize: Rp 25.000.000",
      imageUrl: "https://images.unsplash.com/photo-1504384308090-c894fdcc538d?w=500", // Placeholder
    ),
    Competition(
      title: "I-START Startup Challenge Asia",
      month: "APR",
      date: "02",
      category: "UMUM",
      prizeInfo: "Free Registration",
      imageUrl: "https://images.unsplash.com/photo-1559136555-9303baea8ebd?w=500", // Placeholder
    ),
  ];

  Future<void> loadUserName() async {
    final name = await StorageService.getUserName();
    if (name != null && name.isNotEmpty) {
      _userName = name.split(' ')[0]; // Ambil nama panggilan
    }
    notifyListeners();
  }
}