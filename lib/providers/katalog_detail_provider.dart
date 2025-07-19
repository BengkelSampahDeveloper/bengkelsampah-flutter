import 'package:flutter/material.dart';
import '../models/sampah_detail_model.dart';
import '../services/api_service.dart';

class KatalogDetailProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  SampahDetailModel? _selectedSampah;
  List<PriceModel> _prices = [];
  bool _isLoading = false;
  String? _error;

  SampahDetailModel? get selectedSampah => _selectedSampah;
  List<PriceModel> get prices => _prices;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadSampahDetail(int sampahId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getKatalogDetail(sampahId);

      if (response['status'] == 'success') {
        _selectedSampah =
            SampahDetailModel.fromJson(response['data']['sampah']);
        _prices = (response['data']['prices'] as List<dynamic>)
            .map((price) => PriceModel.fromJson(price))
            .toList();
        _error = null;
      } else {
        _error = response['message'] ?? 'Terjadi kesalahan';
      }
    } catch (e) {
      _error = 'Terjadi kesalahan: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearData() {
    _selectedSampah = null;
    _prices = [];
    _error = null;
    notifyListeners();
  }
}
