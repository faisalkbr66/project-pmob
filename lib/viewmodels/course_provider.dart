// ============================================
// FILE: lib/viewmodels/course_provider.dart
// ============================================

import 'package:flutter/material.dart';
import '../models/course_model.dart';

class CourseProvider extends ChangeNotifier {
  // Data disesuaikan dengan struktur CourseModel yang BARU
  final List<Course> _courses = [
    Course(
      title: "Web Development with Laravel",
      ratingText: "4.8 (500+ Siswa)",
      price: "Rp 199.000",
      imageUrl: "https://images.unsplash.com/photo-1498050108023-c5249f4df085?w=500",
      badge: "NEW",
    ),
    Course(
      title: "UI/UX Design with Figma",
      ratingText: "4.9 (1k+ Siswa)",
      price: "Rp 149.000",
      imageUrl: "https://images.unsplash.com/photo-1561070791-2526d30994b5?w=500",
      badge: "TERPOPULER",
    ),
    Course(
      title: "Mobile App with Flutter",
      ratingText: "4.7 (300+ Siswa)",
      price: "Rp 249.000",
      imageUrl: "https://images.unsplash.com/photo-1512941937669-90a1b58e7e9c?w=500",
    ),
  ];

  List<Course> get courses => _courses;
}