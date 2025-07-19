class NotificationModel {
  final int id;
  final String type;
  final String title;
  final String message;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.data,
    required this.isRead,
    required this.createdAt,
    this.readAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    try {
      return NotificationModel(
        id: _parseId(json['id']),
        type: json['type']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        message: json['body']?.toString() ??
            json['message']?.toString() ??
            '', // Handle both 'body' and 'message'
        data: json['data'] as Map<String, dynamic>?,
        isRead: _parseBool(json['is_read']),
        createdAt: _parseDateTime(json['created_at']),
        readAt:
            json['read_at'] != null ? _parseDateTime(json['read_at']) : null,
      );
    } catch (e) {
      throw FormatException(
          'Failed to parse NotificationModel: $e\nJSON: $json');
    }
  }

  // Helper methods for robust parsing
  static int _parseId(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    if (value is int) return value == 1;
    return false;
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'message': message,
      'data': data,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
    };
  }

  NotificationModel copyWith({
    int? id,
    String? type,
    String? title,
    String? message,
    Map<String, dynamic>? data,
    bool? isRead,
    DateTime? createdAt,
    DateTime? readAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
    );
  }

  @override
  String toString() {
    return 'NotificationModel(id: $id, type: $type, title: $title, isRead: $isRead)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
