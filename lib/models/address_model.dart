class AddressModel {
  final int id;
  final String nama;
  final String nomorHandphone;
  final String labelAlamat;
  final String provinsi;
  final String kotaKabupaten;
  final String kecamatan;
  final String kodePos;
  final String? detailLain;
  final bool isDefault;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AddressModel({
    required this.id,
    required this.nama,
    required this.nomorHandphone,
    required this.labelAlamat,
    required this.provinsi,
    required this.kotaKabupaten,
    required this.kecamatan,
    required this.kodePos,
    this.detailLain,
    required this.isDefault,
    this.createdAt,
    this.updatedAt,
  });

  // Getter untuk full address
  String get fullAddress {
    final List<String> addressParts = [
      if (detailLain?.isNotEmpty == true) detailLain!,
      if (kecamatan.isNotEmpty) kecamatan,
      if (kotaKabupaten.isNotEmpty) kotaKabupaten,
      if (provinsi.isNotEmpty) provinsi,
      if (kodePos.isNotEmpty) kodePos,
    ];
    return addressParts.join(', ');
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'nomor_handphone': nomorHandphone,
      'label_alamat': labelAlamat,
      'provinsi': provinsi,
      'kota_kabupaten': kotaKabupaten,
      'kecamatan': kecamatan,
      'kode_pos': kodePos,
      'detail_lain': detailLain,
      'is_default': isDefault,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Create from JSON
  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id']?.toInt() ?? 0,
      nama: json['nama']?.toString() ?? '',
      nomorHandphone: json['nomor_handphone']?.toString() ?? '',
      labelAlamat: json['label_alamat']?.toString() ?? '',
      provinsi: json['provinsi']?.toString() ?? '',
      kotaKabupaten: json['kota_kabupaten']?.toString() ?? '',
      kecamatan: json['kecamatan']?.toString() ?? '',
      kodePos: json['kode_pos']?.toString() ?? '',
      detailLain: json['detail_lain']?.toString(),
      isDefault: json['is_default'] == true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  // Create a copy with updated values
  AddressModel copyWith({
    int? id,
    String? nama,
    String? nomorHandphone,
    String? labelAlamat,
    String? provinsi,
    String? kotaKabupaten,
    String? kecamatan,
    String? kodePos,
    String? detailLain,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AddressModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      nomorHandphone: nomorHandphone ?? this.nomorHandphone,
      labelAlamat: labelAlamat ?? this.labelAlamat,
      provinsi: provinsi ?? this.provinsi,
      kotaKabupaten: kotaKabupaten ?? this.kotaKabupaten,
      kecamatan: kecamatan ?? this.kecamatan,
      kodePos: kodePos ?? this.kodePos,
      detailLain: detailLain ?? this.detailLain,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
