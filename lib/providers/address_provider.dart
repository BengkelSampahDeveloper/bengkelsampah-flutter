import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/address_model.dart';

class AddressProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String? _error;
  List<AddressModel> _addresses = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<AddressModel> get addresses => _addresses;

  Future<bool> getAddresses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getAddresses();

      if (response['status'] == 'success') {
        final List<dynamic> data = response['data'] ?? [];
        _addresses = data.map((json) => AddressModel.fromJson(json)).toList();
        _error = null;
        return true;
      } else {
        _error =
            response['message'] ?? 'Terjadi kesalahan saat mengambil alamat';
        return false;
      }
    } catch (e) {
      _error = 'Terjadi kesalahan saat mengambil alamat';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addAddress({
    required String nama,
    required String nomorHandphone,
    required String labelAlamat,
    required String provinsi,
    required String kotaKabupaten,
    required String kecamatan,
    required String kodePos,
    required String detailLain,
    required bool isDefault,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.addAddress(
        nama: nama,
        nomorHandphone: nomorHandphone,
        labelAlamat: labelAlamat,
        provinsi: provinsi,
        kotaKabupaten: kotaKabupaten,
        kecamatan: kecamatan,
        kodePos: kodePos,
        detailLain: detailLain,
        isDefault: isDefault,
      );

      if (response['status'] == 'success') {
        _error = null;
        return true;
      } else {
        _error =
            response['message'] ?? 'Terjadi kesalahan saat menambahkan alamat';
        return false;
      }
    } catch (e) {
      _error = 'Terjadi kesalahan saat menambahkan alamat';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateAddress({
    required int id,
    required String nama,
    required String nomorHandphone,
    required String labelAlamat,
    required String provinsi,
    required String kotaKabupaten,
    required String kecamatan,
    required String kodePos,
    required String detailLain,
    required bool isDefault,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.updateAddress(
        id: id,
        nama: nama,
        nomorHandphone: nomorHandphone,
        labelAlamat: labelAlamat,
        provinsi: provinsi,
        kotaKabupaten: kotaKabupaten,
        kecamatan: kecamatan,
        kodePos: kodePos,
        detailLain: detailLain,
        isDefault: isDefault,
      );

      if (response['status'] == 'success') {
        _error = null;
        return true;
      } else {
        _error =
            response['message'] ?? 'Terjadi kesalahan saat mengupdate alamat';
        return false;
      }
    } catch (e) {
      _error = 'Terjadi kesalahan saat mengupdate alamat';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteAddress(int id) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.deleteAddress(id);

      if (response['status'] == 'success') {
        _error = null;
        return true;
      } else {
        _error =
            response['message'] ?? 'Terjadi kesalahan saat menghapus alamat';
        return false;
      }
    } catch (e) {
      _error = 'Terjadi kesalahan saat menghapus alamat';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
