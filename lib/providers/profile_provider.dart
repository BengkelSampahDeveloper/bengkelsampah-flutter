import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ProfileProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _profileData;

  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get profileData => _profileData;

  Future<void> loadProfileData() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _apiService.getProfileData();

      if (response['status'] == 'success') {
        _profileData = response['data'];
        _error = null;
      } else {
        _error =
            response['message'] ?? 'Terjadi kesalahan saat memuat data profil';
      }
    } catch (e) {
      _error = 'Terjadi kesalahan saat memuat data profil';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await loadProfileData();
  }
}
