import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/point_history_model.dart';

class PointsProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _pointsData;
  List<PointHistoryModel> _pointHistory = [];
  bool _isLoading = false;
  bool _isLoadingHistory = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMoreHistory = true;

  Map<String, dynamic>? get pointsData => _pointsData;
  List<PointHistoryModel> get pointHistory => List.unmodifiable(_pointHistory);
  bool get isLoading => _isLoading;
  bool get isLoadingHistory => _isLoadingHistory;
  String? get error => _error;
  bool get hasMoreHistory => _hasMoreHistory;

  Future<void> loadPointsData({int page = 1, bool refresh = false}) async {
    // Prevent multiple concurrent calls
    if (_isLoading && !refresh) return;

    if (refresh) {
      _isLoading = true;
      _currentPage = 1;
      _pointHistory.clear();
      _hasMoreHistory = true;
    } else {
      _isLoadingHistory = true;
    }

    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getPointsData(page: page);

      if (response['status'] == 'success' && response['data'] != null) {
        _pointsData = response['data'];

        // Handle point history pagination with safety checks
        if (response['data']['history'] != null) {
          final historyData = response['data']['history'];

          // Safety check for data array
          if (historyData['data'] != null && historyData['data'] is List) {
            final historyList = historyData['data'] as List<dynamic>;

            // Limit processing to prevent memory issues
            const maxItems = 50;
            final itemsToProcess = historyList.take(maxItems).toList();

            final newHistory = <PointHistoryModel>[];
            for (var item in itemsToProcess) {
              try {
                if (item != null && item is Map<String, dynamic>) {
                  final historyItem = PointHistoryModel.fromJson(item);
                  newHistory.add(historyItem);
                }
              } catch (e) {
                debugPrint('Error parsing history item: $e');
                // Continue processing other items instead of crashing
                continue;
              }
            }

            if (refresh) {
              _pointHistory = newHistory;
            } else {
              _pointHistory.addAll(newHistory);
            }

            // Check if there's more data
            _hasMoreHistory = historyData['next_page_url'] != null &&
                historyList.length >= maxItems;
            _currentPage = historyData['current_page'] ?? 1;
          }
        }

        _error = null;
      } else {
        _error =
            response['message'] ?? 'Terjadi kesalahan saat mengambil data poin';
      }
    } catch (e) {
      debugPrint('Error in loadPointsData: $e');
      _error = 'Terjadi kesalahan saat mengambil data poin: ${e.toString()}';
    } finally {
      _isLoading = false;
      _isLoadingHistory = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreHistory() async {
    if (_isLoadingHistory || !_hasMoreHistory) return;

    await loadPointsData(page: _currentPage + 1);
  }

  Future<void> refresh() async {
    await loadPointsData(refresh: true);
  }

  void clearHistory() {
    _pointHistory.clear();
    _currentPage = 1;
    _hasMoreHistory = true;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void resetState() {
    _isLoading = false;
    _isLoadingHistory = false;
    _error = null;
    notifyListeners();
  }
}
