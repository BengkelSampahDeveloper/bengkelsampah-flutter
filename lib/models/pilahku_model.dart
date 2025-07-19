class PilahkuItemModel {
  final String id;
  final int sampahId;
  final String sampahNama;
  final String sampahDeskripsi;
  final String sampahSatuan;
  final String? sampahGambar;
  final double estimasiBerat;
  final String bankSampahId;
  final String bankSampahNama;
  final String? bankSampahTipeLayanan;
  final double hargaPerSatuan;
  final DateTime createdAt;

  PilahkuItemModel({
    required this.id,
    required this.sampahId,
    required this.sampahNama,
    required this.sampahDeskripsi,
    required this.sampahSatuan,
    this.sampahGambar,
    required this.estimasiBerat,
    required this.bankSampahId,
    required this.bankSampahNama,
    this.bankSampahTipeLayanan,
    required this.hargaPerSatuan,
    required this.createdAt,
  });

  // Calculate total price for this item
  double get totalHarga => estimasiBerat * hargaPerSatuan;

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sampahId': sampahId,
      'sampahNama': sampahNama,
      'sampahDeskripsi': sampahDeskripsi,
      'sampahSatuan': sampahSatuan,
      'sampahGambar': sampahGambar,
      'estimasiBerat': estimasiBerat,
      'bankSampahId': bankSampahId,
      'bankSampahNama': bankSampahNama,
      'bankSampahTipeLayanan': bankSampahTipeLayanan,
      'hargaPerSatuan': hargaPerSatuan,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create from JSON
  factory PilahkuItemModel.fromJson(Map<String, dynamic> json) {
    try {
      return PilahkuItemModel(
        id: json['id']?.toString() ?? '',
        sampahId: _parseInt(json['sampahId']),
        sampahNama: json['sampahNama']?.toString() ?? '',
        sampahDeskripsi: json['sampahDeskripsi']?.toString() ?? '',
        sampahSatuan: json['sampahSatuan']?.toString() ?? 'kg',
        sampahGambar: json['sampahGambar']?.toString(),
        estimasiBerat: _parseDouble(json['estimasiBerat']),
        bankSampahId: json['bankSampahId']?.toString() ?? '',
        bankSampahNama: json['bankSampahNama']?.toString() ?? '',
        bankSampahTipeLayanan: json['bankSampahTipeLayanan']?.toString(),
        hargaPerSatuan: _parseDouble(json['hargaPerSatuan']),
        createdAt: _parseDateTime(json['createdAt']),
      );
    } catch (e) {
      return _createDefaultItem();
    }
  }

  // Helper methods for parsing
  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  static PilahkuItemModel _createDefaultItem() {
    return PilahkuItemModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sampahId: 0,
      sampahNama: 'Unknown Item',
      sampahDeskripsi: 'Item description not available',
      sampahSatuan: 'kg',
      sampahGambar: null,
      estimasiBerat: 0.0,
      bankSampahId: '',
      bankSampahNama: 'Unknown Branch',
      bankSampahTipeLayanan: null,
      hargaPerSatuan: 0.0,
      createdAt: DateTime.now(),
    );
  }

  // Create a copy with updated values
  PilahkuItemModel copyWith({
    String? id,
    int? sampahId,
    String? sampahNama,
    String? sampahDeskripsi,
    String? sampahSatuan,
    String? sampahGambar,
    double? estimasiBerat,
    String? bankSampahId,
    String? bankSampahNama,
    String? bankSampahTipeLayanan,
    double? hargaPerSatuan,
    DateTime? createdAt,
  }) {
    return PilahkuItemModel(
      id: id ?? this.id,
      sampahId: sampahId ?? this.sampahId,
      sampahNama: sampahNama ?? this.sampahNama,
      sampahDeskripsi: sampahDeskripsi ?? this.sampahDeskripsi,
      sampahSatuan: sampahSatuan ?? this.sampahSatuan,
      sampahGambar: sampahGambar ?? this.sampahGambar,
      estimasiBerat: estimasiBerat ?? this.estimasiBerat,
      bankSampahId: bankSampahId ?? this.bankSampahId,
      bankSampahNama: bankSampahNama ?? this.bankSampahNama,
      bankSampahTipeLayanan:
          bankSampahTipeLayanan ?? this.bankSampahTipeLayanan,
      hargaPerSatuan: hargaPerSatuan ?? this.hargaPerSatuan,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
