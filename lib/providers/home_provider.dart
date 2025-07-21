import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/article_model.dart';
import '../models/app_version_model.dart';
import '../models/event_model.dart';

class HomeProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _user;
  List<ArticleModel> _articles = [];
  AppVersionModel? _appVersion;
  List<EventModel> _events = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get user => _user;
  List<ArticleModel> get articles => _articles;
  AppVersionModel? get appVersion => _appVersion;
  List<EventModel> get events => _events;

  Future<void> loadHomeData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await ApiService().getHomeData();
      if (response["status"] == "success") {
        final data = response["data"];
        _user = data["user"] ?? {};
        _articles = data["articles"] != null
            ? (data["articles"] as List)
                .map((e) => ArticleModel.fromJson(e))
                .toList()
            : [];

        // Parse app version
        if (data["app_version"] != null) {
          _appVersion = AppVersionModel.fromJson(data["app_version"]);
        }

        // Parse events
        _events = data["events"] != null
            ? (data["events"] as List)
                .map((e) => EventModel.fromJson(e))
                .toList()
            : [];
      } else {
        _error = response["message"] ?? "Gagal memuat data";
      }
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    await loadHomeData();
  }
}
