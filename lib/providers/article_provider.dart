import 'package:flutter/foundation.dart';
import '../models/article_model.dart';
import '../services/api_service.dart';

class ArticleProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<ArticleModel> _articles = [];
  ArticleModel? _selectedArticle;
  bool _isLoading = false;
  bool _hasMorePages = true;
  int _currentPage = 1;
  String? _error;

  List<ArticleModel> get articles => _articles;
  ArticleModel? get selectedArticle => _selectedArticle;
  bool get isLoading => _isLoading;
  bool get hasMorePages => _hasMorePages;
  String? get error => _error;

  Future<void> loadArticles({bool refresh = false}) async {
    if (refresh) {
      _articles = [];
      _currentPage = 1;
      _hasMorePages = true;
    }

    if (!_hasMorePages || _isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getArticles(page: _currentPage);

      if (response['status'] == 'success') {
        final List<dynamic> data = response['data']['artikels'];

        final List<ArticleModel> newArticles =
            data.map((article) => ArticleModel.fromJson(article)).toList();

        _articles.addAll(newArticles);
        _hasMorePages = response['data']['pagination']['has_more_pages'];
        _currentPage++;
        _error = null;
      } else {
        _error = response['message'] ?? 'Gagal memuat artikel';
      }
    } catch (e) {
      _error = 'Terjadi kesalahan saat mengambil artikel';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadArticleDetail(int id) async {
    _isLoading = true;
    _error = null;
    _selectedArticle = null;
    notifyListeners();

    try {
      final response = await _apiService.getArticleDetail(id);
      if (response['status'] == 'success') {
        _selectedArticle = ArticleModel.fromJson(response['data']['artikel']);
        _error = null;
      } else {
        _error = response['message'] ?? 'Gagal memuat detail artikel';
      }
    } catch (e) {
      _error = 'Terjadi kesalahan saat mengambil detail artikel';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    await loadArticles(refresh: true);
  }
}
