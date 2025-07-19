import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class SampahDetailModel {
  final int id;
  final String nama;
  final String deskripsi;
  final String satuan;
  final String? gambar;
  final String createdAt;
  final String updatedAt;

  SampahDetailModel({
    required this.id,
    required this.nama,
    required this.deskripsi,
    required this.satuan,
    this.gambar,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SampahDetailModel.fromJson(Map<String, dynamic> json) {
    return SampahDetailModel(
      id: json['id'],
      nama: json['nama'],
      deskripsi: json['deskripsi'],
      satuan: json['satuan'],
      gambar: json['gambar'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

class PriceModel {
  final int id;
  final String bankSampahId;
  final String bankSampahNama;
  final double harga;
  final String tipeLayanan;
  final String createdAt;
  final String updatedAt;

  PriceModel({
    required this.id,
    required this.bankSampahId,
    required this.bankSampahNama,
    required this.harga,
    required this.tipeLayanan,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PriceModel.fromJson(Map<String, dynamic> json) {
    return PriceModel(
      id: json['id'],
      bankSampahId: json['bank_sampah_id'].toString(),
      bankSampahNama: json['bank_sampah_nama'],
      harga: double.tryParse(json['harga'].toString()) ?? 0.0,
      tipeLayanan: json['bank_sampah_tipe_layanan'] ?? 'tempat',
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  // Helper method to get tipe layanan display text
  String get tipeLayananDisplay {
    switch (tipeLayanan) {
      case 'jemput':
        return 'Jemput';
      case 'tempat':
        return 'Tempat';
      case 'keduanya':
        return 'Jemput & Tempat';
      default:
        return 'Tempat';
    }
  }

  // Helper method to get tipe layanan color
  Color get tipeLayananColor {
    switch (tipeLayanan) {
      case 'jemput':
        return AppColors.color_0FB7A6; // Green for pickup
      case 'tempat':
        return AppColors.color_FFAB2A; // Orange for drop-off
      case 'keduanya':
        return AppColors.color_6F6F6F; // Gray for both
      default:
        return AppColors.color_FFAB2A;
    }
  }

  // Helper method to get tipe layanan icon
  IconData get tipeLayananIcon {
    switch (tipeLayanan) {
      case 'jemput':
        return Icons.delivery_dining; // Delivery icon
      case 'tempat':
        return Icons.location_on; // Location icon
      case 'keduanya':
        return Icons.swap_horiz; // Both icon
      default:
        return Icons.location_on;
    }
  }
}
