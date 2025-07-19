class BankSampahModel {
  final int id;
  final String kodeBankSampah;
  final String namaBankSampah;
  final String alamatBankSampah;
  final String namaPenanggungJawab;
  final String kontakPenanggungJawab;
  final String? foto;
  final String tipeLayanan;

  BankSampahModel({
    required this.id,
    required this.kodeBankSampah,
    required this.namaBankSampah,
    required this.alamatBankSampah,
    required this.namaPenanggungJawab,
    required this.kontakPenanggungJawab,
    this.foto,
    required this.tipeLayanan,
  });

  factory BankSampahModel.fromJson(Map<String, dynamic> json) {
    return BankSampahModel(
      id: json['id'] ?? 0,
      kodeBankSampah: json['kode_bank_sampah'] ?? '',
      namaBankSampah: json['nama_bank_sampah'] ?? '',
      alamatBankSampah: json['alamat_bank_sampah'] ?? '',
      namaPenanggungJawab: json['nama_penanggung_jawab'] ?? '',
      kontakPenanggungJawab: json['kontak_penanggung_jawab'] ?? '',
      foto: json['foto'],
      tipeLayanan: json['tipe_layanan'] ?? 'tempat',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kode_bank_sampah': kodeBankSampah,
      'nama_bank_sampah': namaBankSampah,
      'alamat_bank_sampah': alamatBankSampah,
      'nama_penanggung_jawab': namaPenanggungJawab,
      'kontak_penanggung_jawab': kontakPenanggungJawab,
      'foto': foto,
      'tipe_layanan': tipeLayanan,
    };
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
}
