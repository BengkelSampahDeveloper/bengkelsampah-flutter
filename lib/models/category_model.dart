class CategoryModel {
  final int id;
  final String nama;
  final int sampahCount;

  CategoryModel({
    required this.id,
    required this.nama,
    required this.sampahCount,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      nama: json['nama'],
      sampahCount: json['sampah_count'] ?? 0,
    );
  }
}
