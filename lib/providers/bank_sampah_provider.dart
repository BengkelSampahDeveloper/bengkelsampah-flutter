import 'package:flutter/foundation.dart';
import '../models/bank_sampah_model.dart';
import '../services/api_service.dart';

class BankSampahProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<BankSampahModel> _bankSampahList = [];
  bool _isLoading = false;
  String? _error;

  List<BankSampahModel> get bankSampahList => _bankSampahList;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadBankSampah({bool refresh = false}) async {
    if (refresh) {
      _bankSampahList = [];
    }

    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getBankSampah();

      if (response['status'] == 'success') {
        final List<dynamic> data = response['data'];

        final List<BankSampahModel> newBankSampahList = data
            .map((bankSampah) => BankSampahModel.fromJson(bankSampah))
            .toList();

        _bankSampahList = newBankSampahList;
        _error = null;
      } else {
        _error = response['message'] ?? 'Gagal memuat data bank sampah';
      }
    } catch (e) {
      _error = 'Terjadi kesalahan saat mengambil data bank sampah';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    await loadBankSampah(refresh: true);
  }
}
