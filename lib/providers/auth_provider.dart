import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../helpers/validation_helper.dart';
import '../providers/pilahku_provider.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final storage = const FlutterSecureStorage();
  bool _isLoading = false;
  String? _error;
  String? _currentType;
  String? _currentIdentifier;
  String? _currentPassword;
  String? _currentConfirmPassword;
  String? _currentFullname;
  UserModel? _user;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get currentType => _currentType;
  String? get currentIdentifier => _currentIdentifier;
  String? get currentPassword => _currentPassword;
  String? get currentConfirmPassword => _currentConfirmPassword;
  String? get currentFullname => _currentFullname;

  Future<void> _saveAuthState(
      String token, Map<String, dynamic> responseData) async {
    try {
      await storage.write(key: 'token', value: token);

      // Extract user data from response
      final userData = {
        'id': responseData['user']['id'],
        'name': responseData['user']['name'],
        'identifier': responseData['user']['identifier'],
        'created_at': responseData['user']['created_at'],
        'updated_at': responseData['user']['updated_at'],
      };

      await storage.write(key: 'user', value: jsonEncode(userData));
      _user = UserModel.fromJson(userData);
      notifyListeners();
    } catch (e) {
      _setError('Terjadi kesalahan saat menyimpan data user');
      rethrow;
    }
  }

  Future<void> _clearAuthState() async {
    try {
      await storage.delete(key: 'token');
      await storage.delete(key: 'user');
      _user = null;
      notifyListeners();
    } catch (e) {
      _setError('Terjadi kesalahan saat menghapus data user');
    }
  }

  set currentFullname(String? value) {
    _currentFullname = value;
    notifyListeners();
  }

  set currentIdentifier(String? value) {
    _currentIdentifier = value;
    notifyListeners();
  }

  set currentType(String? value) {
    _currentType = value;
    notifyListeners();
  }

  set currentPassword(String? value) {
    _currentPassword = value;
    notifyListeners();
  }

  set currentConfirmPassword(String? value) {
    _currentConfirmPassword = value;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    _setLoading(true);

    try {
      final userJson = await storage.read(key: 'user');
      if (userJson != null) {
        _user = UserModel.fromJson(jsonDecode(userJson));
      }
    } catch (e) {
      _setError(e.toString());
    }

    _setLoading(false);
  }

  Future<bool> sendOtp(String identifier, String type) async {
    _setLoading(true);
    _setError(null);

    try {
      // Validate identifier
      final identifierError = identifier.contains('@')
          ? ValidationHelper.validateEmail(identifier)
          : ValidationHelper.validatePhone(identifier);
      if (identifierError != null) {
        _setError(identifierError);
        return false;
      }

      final response = await _apiService.sendOtp(identifier, type);
      if (response['success'] == true) {
        _currentType = type;
        _currentIdentifier = identifier;
        return true;
      } else {
        _setError(response['message']);
        return false;
      }
    } catch (e) {
      _setError('Terjadi kesalahan saat mengirim OTP');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> handleOtp(String otp) async {
    _setLoading(true);
    _setError(null);

    try {
      // Validate OTP
      final otpError = ValidationHelper.validateOtp(otp);
      if (otpError != null) {
        _setError(otpError);
        return false;
      }

      switch (_currentType) {
        case 'register':
          if (_currentFullname == null ||
              _currentPassword == null ||
              _currentConfirmPassword == null) {
            _setError('Data registrasi tidak lengkap');
            return false;
          }
          return await register(
            fullname: _currentFullname!,
            identifier: _currentIdentifier!,
            password: _currentPassword!,
            confirmPassword: _currentConfirmPassword!,
            otp: otp,
          );

        case 'login':
          if (_currentPassword == null) {
            _setError('Password tidak lengkap');
            return false;
          }
          return await login(
            _currentIdentifier!,
            _currentPassword!,
            otp,
          );

        case 'forgot':
          if (_currentPassword == null) {
            _setError('Password baru tidak lengkap');
            return false;
          }
          return await forgotPassword(
            _currentIdentifier!,
            otp,
            _currentPassword!,
          );

        default:
          _setError('Tipe operasi tidak valid');
          return false;
      }
    } catch (e) {
      _setError('Terjadi kesalahan saat memproses OTP');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register({
    required String fullname,
    required String identifier,
    required String password,
    required String confirmPassword,
    required String otp,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      // Validate all fields
      final nameError = ValidationHelper.validateName(fullname);
      if (nameError != null) {
        _setError(nameError);
        return false;
      }

      final identifierError = identifier.contains('@')
          ? ValidationHelper.validateEmail(identifier)
          : ValidationHelper.validatePhone(identifier);
      if (identifierError != null) {
        _setError(identifierError);
        return false;
      }

      final passwordError = ValidationHelper.validatePassword(password);
      if (passwordError != null) {
        _setError(passwordError);
        return false;
      }

      if (password != confirmPassword) {
        _setError('Password dan konfirmasi password tidak sama');
        return false;
      }

      final otpError = ValidationHelper.validateOtp(otp);
      if (otpError != null) {
        _setError(otpError);
        return false;
      }

      final response = await _apiService.register(
        fullname: fullname,
        identifier: identifier,
        password: password,
        confirmPassword: confirmPassword,
        otp: otp,
      );

      if (response['success'] == true) {
        if (response['data']?['token'] != null) {
          await _saveAuthState(response['data']['token'], response['data']);
        }
        return true;
      } else {
        _setError(response['message']);
        return false;
      }
    } catch (e) {
      _setError('Terjadi kesalahan saat registrasi');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> login(String identifier, String password, String otp) async {
    _setLoading(true);
    _setError(null);

    try {
      // Validate identifier and password
      final identifierError = identifier.contains('@')
          ? ValidationHelper.validateEmail(identifier)
          : ValidationHelper.validatePhone(identifier);
      if (identifierError != null) {
        _setError(identifierError);
        return false;
      }

      final passwordError = ValidationHelper.validatePassword(password);
      if (passwordError != null) {
        _setError(passwordError);
        return false;
      }

      final otpError = ValidationHelper.validateOtp(otp);
      if (otpError != null) {
        _setError(otpError);
        return false;
      }

      final response = await _apiService.login(identifier, password, otp);
      if (response['success'] == true) {
        if (response['data']?['token'] != null) {
          await _saveAuthState(response['data']['token'], response['data']);
        }
        return true;
      } else {
        _setError(response['message']);
        return false;
      }
    } catch (e) {
      _setError('Terjadi kesalahan saat login');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> forgotPassword(
      String identifier, String otp, String newPassword) async {
    _setLoading(true);
    _setError(null);

    try {
      // Validate all fields
      final identifierError = identifier.contains('@')
          ? ValidationHelper.validateEmail(identifier)
          : ValidationHelper.validatePhone(identifier);
      if (identifierError != null) {
        _setError(identifierError);
        return false;
      }

      final passwordError = ValidationHelper.validatePassword(newPassword);
      if (passwordError != null) {
        _setError(passwordError);
        return false;
      }

      final otpError = ValidationHelper.validateOtp(otp);
      if (otpError != null) {
        _setError(otpError);
        return false;
      }

      final response = await _apiService.forgotPassword(
        identifier: identifier,
        otp: otp,
        newPassword: newPassword,
        newPasswordConfirmation: _currentConfirmPassword!,
      );

      if (response['success'] == true) {
        return true;
      } else {
        _setError(response['message']);
        return false;
      }
    } catch (e) {
      _setError('Terjadi kesalahan saat mengubah password');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void clearCurrentData() {
    _currentType = null;
    _currentIdentifier = null;
    _currentPassword = null;
    _currentConfirmPassword = null;
    _currentFullname = null;
  }

  Future<void> logout() async {
    _setLoading(true);
    _setError(null);

    try {
      await _apiService.logout();
      await _clearAuthState();
      clearCurrentData();

      // Clear pilahku data
      final pilahkuProvider = PilahkuProvider();
      await pilahkuProvider.clearAllData();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteAccount() async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.deleteAccount();
      if (response['success'] == true) {
        await _clearAuthState();

        // Clear pilahku data
        final pilahkuProvider = PilahkuProvider();
        await pilahkuProvider.clearAllData();

        return true;
      } else {
        _setError(response['message'] ?? 'Gagal menghapus akun');
        return false;
      }
    } catch (e) {
      _setError('Terjadi kesalahan saat menghapus akun');
      return false;
    } finally {
      _setLoading(false);
    }
  }
}
