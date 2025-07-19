import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class DetailProfileProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _detailProfileData;
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get detailProfileData => _detailProfileData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadDetailProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getDetailProfile();
      if (response['status'] == 'success') {
        _detailProfileData = response['data'];
        _error = null;
      } else {
        _error = response['message'] ??
            'Terjadi kesalahan saat mengambil detail profil';
      }
    } catch (e) {
      _error = 'Terjadi kesalahan saat mengambil detail profil';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    await loadDetailProfile();
  }

  Future<bool> updateProfile({
    String? name,
    String? identifier,
    String? newPassword,
    String? otp,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final Map<String, dynamic> body = {};
      if (name != null) body['name'] = name;
      if (identifier != null) body['identifier'] = identifier;
      if (newPassword != null) body['password'] = newPassword;
      if (otp != null) body['otp'] = otp;

      final response = await _apiService.updateProfile(body: body);

      if (response['status'] == 'success') {
        // Update data in SecureStorage
        const storage = FlutterSecureStorage();
        final userDataStr = await storage.read(key: 'user');
        if (userDataStr != null) {
          final userData = Map<String, dynamic>.from(jsonDecode(userDataStr));
          if (name != null) userData['name'] = name;
          if (identifier != null) userData['identifier'] = identifier;
          await storage.write(key: 'user', value: jsonEncode(userData));
        }
        return true;
      } else {
        _error = response['message'] ?? 'Gagal mengupdate profil';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
