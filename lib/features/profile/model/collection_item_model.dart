class CollectionItemModel {
  final int id;
  final String itemType;
  final int itemId;
  final String createdAt;
  final String fullName;
  final String? profileImage;
  final String? location;

  CollectionItemModel({
    required this.id,
    required this.itemType,
    required this.itemId,
    required this.createdAt,
    required this.fullName,
    this.profileImage,
    this.location,
  });

  factory CollectionItemModel.fromJson(Map<String, dynamic> json) {
    return CollectionItemModel(
      id: json['id'] ?? 0,
      itemType: json['item_type'] ?? '',
      itemId: json['item_id'] ?? 0,
      createdAt: json['created_at'] ?? '',
      fullName: json['full_name'] ?? '',
      profileImage: json['profile_image'],
      location: json['location'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'item_type': itemType,
      'item_id': itemId,
      'created_at': createdAt,
      'full_name': fullName,
      'profile_image': profileImage,
      'location': location,
    };
  }
}
