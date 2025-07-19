class SampahModel {
  final int id;
  final String nama;
  final String deskripsi;
  final String satuan;
  final String? gambar;

  SampahModel({
    required this.id,
    required this.nama,
    required this.deskripsi,
    required this.satuan,
    this.gambar,
  });

  factory SampahModel.fromJson(Map<String, dynamic> json) {
    return SampahModel(
      id: json['id'],
      nama: json['nama'],
      deskripsi: json['deskripsi'] ?? '',
      satuan: json['satuan'] ?? '',
      gambar: json['gambar'],
    );
  }
}
