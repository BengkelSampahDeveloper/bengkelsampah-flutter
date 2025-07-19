class AppVersionModel {
  final String version;
  final int versionCode;
  final bool isRequired;
  final String? updateMessage;
  final String? storeUrl;

  AppVersionModel({
    required this.version,
    required this.versionCode,
    required this.isRequired,
    this.updateMessage,
    this.storeUrl,
  });

  factory AppVersionModel.fromJson(Map<String, dynamic> json) {
    return AppVersionModel(
      version: json['version'] ?? '',
      versionCode: json['version_code'] ?? 0,
      isRequired: json['is_required'] ?? false,
      updateMessage: json['update_message'],
      storeUrl: json['store_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'version_code': versionCode,
      'is_required': isRequired,
      'update_message': updateMessage,
      'store_url': storeUrl,
    };
  }
}
