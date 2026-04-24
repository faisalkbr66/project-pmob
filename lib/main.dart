// ============================================
// FILE: lib/main.dart
// ============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'services/api_service.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/competition_viewmodel.dart';
import 'viewmodels/dashboard_viewmodel.dart';
import 'viewmodels/course_provider.dart';

void main() {
  // Pastikan interceptor token di Dio sudah ter-register sebelum
  // request pertama ke API.
  ApiService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => DashboardViewModel()),
        ChangeNotifierProvider(create: (_) => CourseProvider()),
        ChangeNotifierProvider(create: (_) => CompetitionViewModel()),
      ],
      child: const MarkUpApp(),
    ),
  );
}
