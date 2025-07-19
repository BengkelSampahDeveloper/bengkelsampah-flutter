class ArticleModel {
  final int id;
  final String title;
  final String content;
  final String cover;
  final String category;
  final String createdAt;
  final String creator;

  ArticleModel({
    required this.id,
    required this.title,
    required this.content,
    required this.cover,
    required this.category,
    required this.createdAt,
    required this.creator,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      cover: json['cover'],
      category: json['kategori']['nama'],
      createdAt: json['created_at'],
      creator: json['creator'],
    );
  }
}
