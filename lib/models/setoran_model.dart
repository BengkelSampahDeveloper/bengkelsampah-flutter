import 'dart:convert';

class SetoranModel {
  final int id;
  final int userId;
  final String userName;
  final String userIdentifier;
  final int bankSampahId;
  final String bankSampahName;
  final String bankSampahCode;
  final String bankSampahAddress;
  final String bankSampahPhone;
  final int addressId;
  final String addressName;
  final String addressPhone;
  final String addressFullAddress;
  final bool addressIsDefault;
  final String tipeSetor;
  final String status;
  final List<Map<String, dynamic>> itemsJson;
  final double estimasiTotal;
  final double? aktualTotal;
  final DateTime? tanggalPenjemputan;
  final String? waktuPenjemputan;
  final String? petugasNama;
  final String? petugasContact;
  final String? fotoSampah;
  final String? notes;
  final String? alasanPembatalan;
  final String? perubahanData;
  final DateTime? tanggalSelesai;
  final String tipeLayanan;
  final DateTime createdAt;
  final DateTime updatedAt;

  SetoranModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userIdentifier,
    required this.bankSampahId,
    required this.bankSampahName,
    required this.bankSampahCode,
    required this.bankSampahAddress,
    required this.bankSampahPhone,
    required this.addressId,
    required this.addressName,
    required this.addressPhone,
    required this.addressFullAddress,
    required this.addressIsDefault,
    required this.tipeSetor,
    required this.status,
    required this.itemsJson,
    required this.estimasiTotal,
    this.aktualTotal,
    this.tanggalPenjemputan,
    this.waktuPenjemputan,
    this.petugasNama,
    this.petugasContact,
    this.fotoSampah,
    this.notes,
    this.alasanPembatalan,
    this.perubahanData,
    this.tanggalSelesai,
    required this.tipeLayanan,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SetoranModel.fromJson(Map<String, dynamic> json) {
    try {
      // Helper function to safely convert to int
      int safeInt(dynamic value) {
        if (value == null) return 0;
        if (value is int) return value;
        if (value is String) {
          final parsed = int.tryParse(value);
          return parsed ?? 0;
        }
        if (value is double) return value.toInt();
        return 0;
      }

      // Helper function to safely convert to double
      double safeDouble(dynamic value) {
        if (value == null) return 0.0;
        if (value is double) return value;
        if (value is int) return value.toDouble();
        if (value is String) {
          final parsed = double.tryParse(value);
          return parsed ?? 0.0;
        }
        return 0.0;
      }

      // Helper function to safely convert to DateTime
      DateTime? safeDateTime(dynamic value) {
        if (value == null) return null;
        if (value is DateTime) return value;
        if (value is String) {
          try {
            return DateTime.parse(value);
          } catch (e) {
            return null;
          }
        }
        return null;
      }

      // Helper function to safely convert to bool
      bool safeBool(dynamic value) {
        if (value == null) return false;
        if (value is bool) return value;
        if (value is int) return value == 1;
        if (value is String) {
          final lower = value.toLowerCase();
          return lower == 'true' || lower == '1';
        }
        return false;
      }

      // Helper function to parse items_json - simplified to prevent crashes
      List<Map<String, dynamic>> parseItemsJson(dynamic value) {
        if (value == null) return [];

        // If it's already a List, convert safely
        if (value is List) {
          final List<Map<String, dynamic>> result = [];
          for (final item in value) {
            if (item is Map<String, dynamic>) {
              result.add(Map<String, dynamic>.from(item));
            }
          }
          return result;
        }

        // If it's a String, try to decode
        if (value is String && value.isNotEmpty) {
          try {
            final decoded = jsonDecode(value);
            if (decoded is List) {
              final List<Map<String, dynamic>> result = [];
              for (final item in decoded) {
                if (item is Map<String, dynamic>) {
                  result.add(Map<String, dynamic>.from(item));
                }
              }
              return result;
            }
          } catch (e) {
            // If parsing fails, return empty list
            return [];
          }
        }

        return [];
      }

      // Helper function to extract time from datetime string
      String? extractTimeFromDateTime(String? dateTimeStr) {
        if (dateTimeStr == null || dateTimeStr.isEmpty) return null;
        try {
          final dateTime = DateTime.parse(dateTimeStr);
          return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
        } catch (e) {
          // If parsing fails, return original string
          return dateTimeStr;
        }
      }

      return SetoranModel(
        id: safeInt(json['id']),
        userId: safeInt(json['user_id']),
        userName: json['user_name']?.toString() ?? '',
        userIdentifier: json['user_identifier']?.toString() ?? '',
        bankSampahId: safeInt(json['bank_sampah_id']),
        bankSampahName: json['bank_sampah_name']?.toString() ?? '',
        bankSampahCode: json['bank_sampah_code']?.toString() ?? '',
        bankSampahAddress: json['bank_sampah_address']?.toString() ?? '',
        bankSampahPhone: json['bank_sampah_phone']?.toString() ?? '',
        addressId: safeInt(json['address_id']),
        addressName: json['address_name']?.toString() ?? '',
        addressPhone: json['address_phone']?.toString() ?? '',
        addressFullAddress: json['address_full_address']?.toString() ?? '',
        addressIsDefault: safeBool(json['address_is_default']),
        tipeSetor: json['tipe_setor']?.toString() ?? '',
        status: json['status']?.toString() ?? '',
        itemsJson: parseItemsJson(json['items_json']),
        estimasiTotal: safeDouble(json['estimasi_total']),
        aktualTotal: json['aktual_total'] != null
            ? safeDouble(json['aktual_total'])
            : null,
        tanggalPenjemputan: safeDateTime(json['tanggal_penjemputan']),
        waktuPenjemputan:
            extractTimeFromDateTime(json['waktu_penjemputan']?.toString()),
        petugasNama: json['petugas_nama']?.toString(),
        petugasContact: json['petugas_contact']?.toString(),
        fotoSampah: json['foto_sampah']?.toString(),
        notes: json['notes']?.toString(),
        alasanPembatalan: json['alasan_pembatalan']?.toString(),
        perubahanData: json['perubahan_data']?.toString(),
        tanggalSelesai: safeDateTime(json['tanggal_selesai']),
        tipeLayanan: json['tipe_layanan']?.toString() ?? '',
        createdAt: safeDateTime(json['created_at']) ?? DateTime.now(),
        updatedAt: safeDateTime(json['updated_at']) ?? DateTime.now(),
      );
    } catch (e) {
      // Return a default SetoranModel if parsing fails completely
      return SetoranModel(
        id: 0,
        userId: 0,
        userName: 'Error',
        userIdentifier: '',
        bankSampahId: 0,
        bankSampahName: 'Error',
        bankSampahCode: '',
        bankSampahAddress: '',
        bankSampahPhone: '',
        addressId: 0,
        addressName: '',
        addressPhone: '',
        addressFullAddress: '',
        addressIsDefault: false,
        tipeSetor: '',
        status: '',
        itemsJson: [],
        estimasiTotal: 0.0,
        tipeLayanan: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'user_identifier': userIdentifier,
      'bank_sampah_id': bankSampahId,
      'bank_sampah_name': bankSampahName,
      'bank_sampah_code': bankSampahCode,
      'bank_sampah_address': bankSampahAddress,
      'bank_sampah_phone': bankSampahPhone,
      'address_id': addressId,
      'address_name': addressName,
      'address_phone': addressPhone,
      'address_full_address': addressFullAddress,
      'address_is_default': addressIsDefault ? 1 : 0,
      'tipe_setor': tipeSetor,
      'status': status,
      'items_json': itemsJson,
      'estimasi_total': estimasiTotal,
      'aktual_total': aktualTotal,
      'tanggal_penjemputan': tanggalPenjemputan?.toIso8601String(),
      'waktu_penjemputan': waktuPenjemputan,
      'petugas_nama': petugasNama,
      'petugas_contact': petugasContact,
      'foto_sampah': fotoSampah,
      'notes': notes,
      'alasan_pembatalan': alasanPembatalan,
      'perubahan_data': perubahanData,
      'tanggal_selesai': tanggalSelesai?.toIso8601String(),
      'tipe_layanan': tipeLayanan,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Status constants
  static const String STATUS_DIKONFIRMASI = 'dikonfirmasi';
  static const String STATUS_DIPROSES = 'diproses';
  static const String STATUS_DIJEMPUT = 'dijemput';
  static const String STATUS_SELESAI = 'selesai';
  static const String STATUS_BATAL = 'batal';

  // Tipe setor constants
  static const String TIPE_JUAL = 'jual';
  static const String TIPE_SEDEKAH = 'sedekah';
  static const String TIPE_TABUNG = 'tabung';

  // Tipe layanan constants
  static const String LAYANAN_JEMPUT = 'jemput';
  static const String LAYANAN_TEMPAT = 'tempat';
  static const String LAYANAN_KEDUANYA = 'keduanya';

  // Helper methods
  bool get isCompleted => status == STATUS_SELESAI;
  bool get isCancelled => status == STATUS_BATAL;
  bool get canEarnPoints => tipeSetor == TIPE_TABUNG;

  String get statusText {
    switch (status) {
      case STATUS_DIKONFIRMASI:
        return 'Dikonfirmasi';
      case STATUS_DIPROSES:
        return 'Diproses';
      case STATUS_DIJEMPUT:
        return 'Dijemput';
      case STATUS_SELESAI:
        return 'Selesai';
      case STATUS_BATAL:
        return 'Batal';
      default:
        return 'Unknown';
    }
  }

  String get tipeSetorText {
    switch (tipeSetor) {
      case TIPE_JUAL:
        return 'Jual';
      case TIPE_SEDEKAH:
        return 'Sedekah';
      case TIPE_TABUNG:
        return 'Tabung';
      default:
        return 'Unknown';
    }
  }
}
