class EventModel {
  final int id;
  final String title;
  final String description;
  final String cover;
  final String startDatetime;
  final String endDatetime;
  final String location;
  final int maxParticipants;
  final String status;
  final int participantsCount;
  final bool hasResult;
  final String createdAt;
  final String updatedAt;
  final String adminName;
  final String? resultDescription;
  final double? savedWasteAmount;
  final int? actualParticipants;
  final List<String>? resultPhotos;
  final String? resultSubmittedAt;
  final String? resultSubmittedByName;
  final List<Map<String, dynamic>>? participants;
  final bool isJoined;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.cover,
    required this.startDatetime,
    required this.endDatetime,
    required this.location,
    required this.maxParticipants,
    required this.status,
    required this.participantsCount,
    required this.hasResult,
    required this.createdAt,
    required this.updatedAt,
    required this.adminName,
    this.resultDescription,
    this.savedWasteAmount,
    this.actualParticipants,
    this.resultPhotos,
    this.resultSubmittedAt,
    this.resultSubmittedByName,
    this.participants,
    required this.isJoined,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value, [int defaultValue = 0]) {
      if (value == null) return defaultValue;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? defaultValue;
      return defaultValue;
    }

    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    return EventModel(
      id: parseInt(json['id']),
      title: json['title'] ?? 'Judul tidak tersedia',
      description: json['description'] ?? 'Deskripsi tidak tersedia',
      cover: json['cover'] ?? '',
      startDatetime: json['start_datetime'] ?? '',
      endDatetime: json['end_datetime'] ?? '',
      location: json['location'] ?? 'Lokasi tidak tersedia',
      maxParticipants: parseInt(json['max_participants']),
      status: json['status'] ?? 'active',
      participantsCount: parseInt(json['participants_count']),
      hasResult: json['has_result'] ?? false,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      adminName: json['admin_name'] ?? 'Admin Bengkel Sampah',
      resultDescription: json['result_description'],
      savedWasteAmount: parseDouble(json['saved_waste_amount']),
      actualParticipants: parseInt(json['actual_participants']),
      resultPhotos: json['result_photos'] != null
          ? List<String>.from(json['result_photos'])
          : null,
      resultSubmittedAt: json['result_submitted_at'],
      resultSubmittedByName: json['result_submitted_by_name'],
      participants: json['participants'] != null
          ? List<Map<String, dynamic>>.from(json['participants'])
          : null,
      isJoined: json['user_has_joined'] ?? false,
    );
  }

  String get statusText {
    switch (status) {
      case 'active':
        return 'Aktif';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return 'Tidak Diketahui';
    }
  }

  bool get isActive => status == 'active';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
}
