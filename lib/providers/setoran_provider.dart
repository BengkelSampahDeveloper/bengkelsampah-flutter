import 'package:flutter/material.dart';
import 'dart:io';
import '../models/setoran_model.dart';
import '../services/api_service.dart';

class SetoranProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<SetoranModel> _setorans = [];
  SetoranModel? _selectedSetoran;
  bool _isLoading = false;
  String? _error;
  bool _hasMoreData = true;
  int _currentPage = 1;
  DateTime? _lastRefreshTime;
  static const Duration _refreshCooldown = Duration(seconds: 2);

  List<SetoranModel> get setorans => _setorans;
  SetoranModel? get selectedSetoran => _selectedSetoran;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMoreData => _hasMoreData;

  // Load setorans with optional filters
  Future<void> loadSetorans({
    String? status,
    String? tipeSetor,
    bool refresh = false,
    bool forceRefresh = false,
  }) async {
    // Prevent multiple concurrent calls
    if (_isLoading && !forceRefresh) {
      return;
    }

    // Add cooldown to prevent rapid successive calls
    if (!forceRefresh && _lastRefreshTime != null) {
      final timeSinceLastRefresh = DateTime.now().difference(_lastRefreshTime!);
      if (timeSinceLastRefresh < _refreshCooldown) {
        return;
      }
    }

    if (refresh) {
      _setorans.clear();
      _currentPage = 1;
      _hasMoreData = true;
    }

    if (!_hasMoreData || _isLoading) return;

    _setLoading(true);
    _setError(null);
    _lastRefreshTime = DateTime.now();

    try {
      final response = await _apiService.getSetorans(
        status: status,
        tipeSetor: tipeSetor,
        page: _currentPage,
      );

      if (response['status'] == 'success' && response['data'] != null) {
        final data = response['data'];

        // Safely parse the data array
        List<SetoranModel> newSetorans = [];
        if (data['data'] is List) {
          for (final json in data['data']) {
            try {
              if (json is Map<String, dynamic>) {
                final setoran = SetoranModel.fromJson(json);
                newSetorans.add(setoran);
              }
            } catch (e) {
              // Skip invalid items instead of crashing
              debugPrint('Error parsing setoran: $e');
              continue;
            }
          }
        }

        if (refresh) {
          _setorans = newSetorans;
        } else {
          _setorans.addAll(newSetorans);
        }

        // Check if there's more data
        _hasMoreData = data['next_page_url'] != null;
        _currentPage++;
      } else {
        _setError(response['message'] ??
            'Terjadi kesalahan saat mengambil data setoran');
      }
    } catch (e) {
      _setError('Terjadi kesalahan: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Load specific setoran detail
  Future<void> loadSetoranDetail(int id) async {
    // Prevent multiple concurrent calls for the same detail
    if (_isLoading) return;

    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.getSetoranDetail(id);

      if (response['status'] == 'success' && response['data'] != null) {
        _selectedSetoran = SetoranModel.fromJson(response['data']);
      } else {
        _setError(response['message'] ??
            'Terjadi kesalahan saat mengambil detail setoran');
      }
    } catch (e) {
      _setError('Terjadi kesalahan: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Refresh setorans data
  Future<void> refresh() async {
    await loadSetorans(refresh: true, forceRefresh: true);
  }

  // Create new setoran
  Future<Map<String, dynamic>> createSetoran({
    required int bankSampahId,
    required int addressId,
    required String tipeSetor,
    required List<Map<String, dynamic>> items,
    required double estimasiTotal,
    DateTime? tanggalPenjemputan,
    String? waktuPenjemputan,
    Object? fotoSampah,
    required String tipeLayanan,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.createSetoran(
        bankSampahId: bankSampahId,
        addressId: addressId,
        tipeSetor: tipeSetor,
        items: items,
        estimasiTotal: estimasiTotal,
        tanggalPenjemputan: tanggalPenjemputan,
        waktuPenjemputan: waktuPenjemputan,
        fotoSampah: fotoSampah,
        tipeLayanan: tipeLayanan,
      );

      if (response['status'] == 'success') {
        // Force refresh setorans list immediately after successful creation
        try {
          // Clear current data and reload
          _setorans.clear();
          _currentPage = 1;
          _hasMoreData = true;
          await loadSetorans(refresh: true, forceRefresh: true);
        } catch (refreshError) {
          debugPrint('Error refreshing setorans after create: $refreshError');
          // Don't fail the create operation if refresh fails
        }
        return {
          'success': true,
          'data': response['data'],
        };
      } else {
        _setError(
            response['message'] ?? 'Terjadi kesalahan saat membuat setoran');
        return {
          'success': false,
          'message': response['message'],
        };
      }
    } catch (e) {
      _setError('Terjadi kesalahan: ${e.toString()}');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    } finally {
      _setLoading(false);
    }
  }

  // Force refresh data (useful for external calls)
  Future<void> forceRefresh() async {
    _setorans.clear();
    _currentPage = 1;
    _hasMoreData = true;
    _setError(null);
    await loadSetorans(refresh: true, forceRefresh: true);
  }

  // Cancel setoran
  Future<Map<String, dynamic>> cancelSetoran(
      int id, String alasanPembatalan) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.cancelSetoran(id, alasanPembatalan);

      if (response['status'] == 'success') {
        // Refresh setorans list after successful cancellation
        try {
          await loadSetorans(refresh: true, forceRefresh: true);
        } catch (refreshError) {
          debugPrint('Error refreshing setorans after cancel: $refreshError');
        }
        return {
          'success': true,
          'data': response['data'],
        };
      } else {
        _setError(response['message'] ??
            'Terjadi kesalahan saat membatalkan setoran');
        return {
          'success': false,
          'message': response['message'],
        };
      }
    } catch (e) {
      _setError('Terjadi kesalahan: ${e.toString()}');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    } finally {
      _setLoading(false);
    }
  }

  // Get setorans by status
  List<SetoranModel> getSetoransByStatus(String status) {
    return _setorans.where((setoran) => setoran.status == status).toList();
  }

  // Get setorans by tipe setor
  List<SetoranModel> getSetoransByTipeSetor(String tipeSetor) {
    return _setorans
        .where((setoran) => setoran.tipeSetor == tipeSetor)
        .toList();
  }

  // Get completed setorans
  List<SetoranModel> get completedSetorans {
    return _setorans.where((setoran) => setoran.isCompleted).toList();
  }

  // Get cancelled setorans
  List<SetoranModel> get cancelledSetorans {
    return _setorans.where((setoran) => setoran.isCancelled).toList();
  }

  // Get active setorans (not completed and not cancelled)
  List<SetoranModel> get activeSetorans {
    return _setorans
        .where((setoran) => !setoran.isCompleted && !setoran.isCancelled)
        .toList();
  }

  // Check if refresh is needed (data is stale)
  bool get needsRefresh {
    if (_lastRefreshTime == null) return true;
    final timeSinceLastRefresh = DateTime.now().difference(_lastRefreshTime!);
    return timeSinceLastRefresh.inMinutes >= 5; // Refresh every 5 minutes
  }

  // Smart refresh - only refresh if needed
  Future<void> smartRefresh() async {
    if (needsRefresh || _setorans.isEmpty) {
      await loadSetorans(refresh: true, forceRefresh: true);
    }
  }

  // Pull to refresh - always refresh data
  Future<void> pullToRefresh() async {
    await loadSetorans(refresh: true, forceRefresh: true);
  }

  // Clear selected setoran
  void clearSelectedSetoran() {
    _selectedSetoran = null;
    notifyListeners();
  }

  // Clear all data
  void clearAllData() {
    _setorans.clear();
    _selectedSetoran = null;
    _currentPage = 1;
    _hasMoreData = true;
    _setError(null);
    _lastRefreshTime = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }
}
