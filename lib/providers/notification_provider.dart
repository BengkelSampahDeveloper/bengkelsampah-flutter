import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/notification_model.dart';

class NotificationProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  String? _error;

  // Getters
  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMoreData => _hasMoreData;
  String? get error => _error;

  // Get notifications from API
  Future<void> getNotifications(
      {int limit = 20, int offset = 0, bool refresh = false}) async {
    try {
      if (refresh) {
        _isLoading = true;
        _notifications = [];
        _hasMoreData = true;
      } else {
        _isLoadingMore = true;
      }
      _error = null;
      notifyListeners();

      final response =
          await _apiService.getNotifications(limit: limit, offset: offset);

      if (response['success'] == true) {
        // Fix: Handle different response structures
        final dynamic responseData = response['data'];
        List<dynamic> data = [];

        if (responseData is List) {
          // Case 1: data is directly an array
          data = responseData;
        } else if (responseData is Map<String, dynamic>) {
          // Case 2: data is an object containing notifications array
          data = responseData['notifications'] ?? [];
        }

        final newNotifications = data
            .map((json) =>
                NotificationModel.fromJson(json as Map<String, dynamic>))
            .toList();

        if (refresh) {
          // Replace all notifications for refresh
          _notifications = newNotifications;
        } else {
          // Add new notifications to existing list for pagination
          _notifications.addAll(newNotifications);
        }

        // Check if we have more data
        _hasMoreData = newNotifications.length >= limit;
      } else {
        _error = response['message'] ?? 'Failed to load notifications';
      }
    } catch (e) {
      _error = 'Error loading notifications: $e';
      debugPrint('Error in getNotifications: $e');
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // Load more notifications (for pagination)
  Future<void> loadMoreNotifications({int limit = 20}) async {
    if (_isLoadingMore || !_hasMoreData) return;

    await getNotifications(
        limit: limit, offset: _notifications.length, refresh: false);
  }

  // Refresh notifications (reset and load from beginning)
  Future<void> refresh() async {
    await getNotifications(refresh: true);
  }

  // Mark notification as read
  Future<bool> markAsRead(int notificationId) async {
    try {
      final response = await _apiService.markNotificationAsRead(notificationId);

      if (response['success'] == true) {
        // Update local notification
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          _notifications[index] = _notifications[index].copyWith(isRead: true);
          _unreadCount = (_unreadCount - 1).clamp(0, double.infinity).toInt();
          notifyListeners();
        }
        return true;
      } else {
        _error = response['message'] ?? 'Failed to mark notification as read';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error marking notification as read: $e';
      debugPrint('Error in markAsRead: $e');
      notifyListeners();
      return false;
    }
  }

  // Mark all notifications as read
  Future<bool> markAllAsRead() async {
    try {
      final response = await _apiService.markAllNotificationsAsRead();

      if (response['success'] == true) {
        // Update all local notifications
        _notifications =
            _notifications.map((n) => n.copyWith(isRead: true)).toList();
        _unreadCount = 0;
        notifyListeners();
        return true;
      } else {
        _error =
            response['message'] ?? 'Failed to mark all notifications as read';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error marking all notifications as read: $e';
      debugPrint('Error in markAllAsRead: $e');
      notifyListeners();
      return false;
    }
  }

  // Delete notification
  Future<bool> deleteNotification(int notificationId) async {
    try {
      final response = await _apiService.deleteNotification(notificationId);

      if (response['success'] == true) {
        // Remove from local list
        final removedNotification = _notifications.firstWhere(
          (n) => n.id == notificationId,
          orElse: () => throw StateError('Notification not found'),
        );

        _notifications.removeWhere((n) => n.id == notificationId);

        // Update unread count if deleted notification was unread
        if (!removedNotification.isRead) {
          _unreadCount = (_unreadCount - 1).clamp(0, double.infinity).toInt();
        }

        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Failed to delete notification';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error deleting notification: $e';
      debugPrint('Error in deleteNotification: $e');
      notifyListeners();
      return false;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Add notification to list (for real-time updates)
  void addNotification(NotificationModel notification) {
    _notifications.insert(0, notification);
    if (!notification.isRead) {
      _unreadCount++;
    }
    notifyListeners();
  }

  // Update unread count (for real-time updates)
  void updateUnreadCount(int count) {
    _unreadCount = count;
    notifyListeners();
  }
}
