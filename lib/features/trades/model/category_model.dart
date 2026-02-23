class CategoryModel {
  final int id;
  final String name;
  final int subId;
  final String imageUrl;
  final int status;

  CategoryModel({
    required this.id,
    required this.name,
    required this.subId,
    required this.imageUrl,
    required this.status,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      subId: json['sub_id'] ?? 0,
      imageUrl: json['image_url'] ?? '',
      status: json['status'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sub_id': subId,
      'image_url': imageUrl,
      'status': status,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CategoryModel &&
        other.id == id &&
        other.name == name &&
        other.subId == subId &&
        other.imageUrl == imageUrl &&
        other.status == status;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        subId.hashCode ^
        imageUrl.hashCode ^
        status.hashCode;
  }
}
