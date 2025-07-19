import 'package:flutter/rendering.dart';

class PointHistoryModel {
  final int id;
  final String type;
  final DateTime tanggal;
  final int jumlahPoint;
  final int xp;
  final String? keterangan;
  final int? setoranId;

  const PointHistoryModel({
    required this.id,
    required this.type,
    required this.tanggal,
    required this.jumlahPoint,
    required this.xp,
    this.keterangan,
    this.setoranId,
  });

  factory PointHistoryModel.fromJson(Map<String, dynamic> json) {
    // Helper function to safely parse numeric values
    int parseNumeric(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.round();
      if (value is String) {
        final parsed = double.tryParse(value);
        return parsed?.round() ?? 0;
      }
      return 0;
    }

    // Helper function to safely parse date
    DateTime parseDate(dynamic value) {
      try {
        if (value == null) return DateTime.now();
        if (value is DateTime) return value;
        if (value is String) {
          return DateTime.parse(value);
        }
        return DateTime.now();
      } catch (e) {
        debugPrint('Error parsing date: $e');
        return DateTime.now();
      }
    }

    try {
      return PointHistoryModel(
        id: parseNumeric(json['id']),
        type: json['type']?.toString() ?? '',
        tanggal: parseDate(json['tanggal']),
        jumlahPoint: parseNumeric(json['jumlah_point']),
        xp: parseNumeric(json['xp']),
        keterangan: json['keterangan']?.toString(),
        setoranId: json['setoran_id'] != null
            ? parseNumeric(json['setoran_id'])
            : null,
      );
    } catch (e) {
      debugPrint('Error creating PointHistoryModel: $e');
      // Return a default model to prevent crash
      return PointHistoryModel(
        id: 0,
        type: 'unknown',
        tanggal: DateTime.now(),
        jumlahPoint: 0,
        xp: 0,
        keterangan: 'Error parsing data',
        setoranId: null,
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'tanggal': tanggal.toIso8601String(),
      'jumlah_point': jumlahPoint,
      'xp': xp,
      'keterangan': keterangan,
      'setoran_id': setoranId,
    };
  }

  // Type constants
  static const String TYPE_SETOR = 'setor';
  static const String TYPE_REDEEM = 'redeem';

  // Helper methods
  bool get isFromDeposit => type == TYPE_SETOR;
  bool get isFromRedemption => type == TYPE_REDEEM;

  String get typeDisplay {
    switch (type) {
      case TYPE_SETOR:
        return 'Setoran';
      case TYPE_REDEEM:
        return 'Penukaran';
      default:
        return 'Lainnya';
    }
  }

  String get keteranganDisplay {
    return keterangan ?? 'Tidak ada keterangan';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PointHistoryModel &&
        other.id == id &&
        other.type == type &&
        other.tanggal == tanggal &&
        other.jumlahPoint == jumlahPoint &&
        other.xp == xp &&
        other.keterangan == keterangan &&
        other.setoranId == setoranId;
  }

  @override
  int get hashCode {
    return Object.hash(
        id, type, tanggal, jumlahPoint, xp, keterangan, setoranId);
  }

  @override
  String toString() {
    return 'PointHistoryModel(id: $id, type: $type, tanggal: $tanggal, jumlahPoint: $jumlahPoint, xp: $xp, keterangan: $keterangan, setoranId: $setoranId)';
  }
}
