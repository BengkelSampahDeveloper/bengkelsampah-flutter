class UserModel {
  final int id;
  final String name;
  final String identifier;
  final String? createdAt;
  final String? updatedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.identifier,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      identifier: json['identifier'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'identifier': identifier,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
