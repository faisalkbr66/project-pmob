import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class DashboardViewModel extends ChangeNotifier {
  String _userName = 'User';
  String get userName => _userName;

  Future<void> loadUserName() async {
    final name = await StorageService.getUserName();
    if (name != null && name.isNotEmpty) {
      _userName = name.split(' ')[0]; // Ambil nama panggilan
      notifyListeners();
    }
  }
}
