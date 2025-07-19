import 'package:flutter/foundation.dart';
import '../models/category_model.dart';
import '../models/sampah_model.dart';
import '../services/api_service.dart';

class KatalogProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<CategoryModel> _categories = [];
  List<SampahModel> _sampah = [];
  CategoryModel? _selectedCategory;
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';

  List<CategoryModel> get categories => _categories;
  List<SampahModel> get sampah => _sampah;
  CategoryModel? get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;

  Future<void> loadKatalog({
    int? categoryId,
    String? search,
    bool refresh = false,
    bool showLoading = true,
  }) async {
    if (refresh) {
      _sampah = [];
      _error = null;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getKatalog(
        category: categoryId,
        search: search,
      );

      if (response['status'] == 'success') {
        final data = response['data'];

        // Update categories if provided
        if (data['categories'] != null) {
          final List<dynamic> categoriesData = data['categories'];
          _categories = categoriesData
              .map((category) => CategoryModel.fromJson(category))
              .toList();
        }

        // Update selected category from response
        if (data['selected_category'] != null) {
          final selectedCategoryData = data['selected_category'];
          _selectedCategory = CategoryModel(
            id: selectedCategoryData['id'],
            nama: selectedCategoryData['nama'],
            sampahCount: 0, // This will be updated from categories list
          );

          // Update sampah count from categories list
          final categoryInList = _categories.firstWhere(
            (category) => category.id == _selectedCategory!.id,
            orElse: () => _selectedCategory!,
          );
          _selectedCategory = categoryInList;
        }

        // Update sampah list
        if (data['sampah'] != null) {
          final List<dynamic> sampahData = data['sampah'];
          _sampah =
              sampahData.map((item) => SampahModel.fromJson(item)).toList();
        }

        _searchQuery = search ?? '';
        _error = null;
      } else {
        _error = response['message'] ?? 'Gagal memuat katalog';
      }
    } catch (e) {
      _error = 'Terjadi kesalahan saat mengambil katalog';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> selectCategory(int categoryId) async {
    await loadKatalog(categoryId: categoryId, search: _searchQuery);
  }

  Future<void> searchSampah(String query) async {
    _searchQuery = query;
    // If we have a selected category, use it. Otherwise, send without category
    final categoryId = _selectedCategory?.id;
    await loadKatalog(categoryId: categoryId, search: query);
  }

  Future<void> refresh() async {
    // On refresh, load without category to get the default (first category)
    await loadKatalog(refresh: true);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
