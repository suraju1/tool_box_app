class PostModel {
  final int id;
  final int userId;
  final String pickupArea;
  final double latitude;
  final double longitude;
  final double areaDiameter;
  final String tradeType;
  final String itemName;
  final String itemCategory;
  final int? itemCategoryId;
  final String itemCondition;
  final String itemNote;
  final String itemSource;
  final List<String> itemImages;
  final String returnType;
  final double? priceMin;
  final double? priceMax;
  final bool isNegotiable;
  final String? returnItemName;
  final String? returnItemCategory;
  final String? returnItemCondition;
  final String? returnItemDescription;
  final String? returnItemSource;
  final List<String> returnItemImages;
  final int walletCredits;
  final bool notifyPartnersOnly;
  final String postType;
  final String status;
  final String createdAt;
  final String updatedAt;
  final String userName;
  final String? userImage;
  final double? userRating;
<<<<<<< HEAD
  final double? distanceKm;
  final int? responseCount;

  PostModel({
    required this.id,
    required this.userId,
    required this.pickupArea,
    required this.latitude,
    required this.longitude,
    required this.areaDiameter,
    required this.tradeType,
    required this.itemName,
    required this.itemCategory,
    this.itemCategoryId,
    required this.itemCondition,
    required this.itemNote,
    required this.itemSource,
    required this.itemImages,
    required this.returnType,
    this.priceMin,
    this.priceMax,
    required this.isNegotiable,
    this.returnItemName,
    this.returnItemCategory,
    this.returnItemCondition,
    this.returnItemDescription,
    this.returnItemSource,
    required this.returnItemImages,
    required this.walletCredits,
    required this.notifyPartnersOnly,
    required this.postType,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.userName,
    this.userImage,
    this.userRating,
    this.distanceKm,
    this.responseCount,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      pickupArea: json['pickup_area'] ?? '',
      latitude: double.tryParse(json['latitude']?.toString() ?? '0') ?? 0.0,
      longitude: double.tryParse(json['longitude']?.toString() ?? '0') ?? 0.0,
      areaDiameter:
          double.tryParse(json['area_diameter']?.toString() ?? '0') ?? 0.0,
      tradeType: json['trade_type'] ?? '',
      itemName: json['item_name'] ?? '',
      itemCategory: json['item_category'] ?? '',
      itemCategoryId: json['item_category_id'],
      itemCondition: json['item_condition'] ?? '',
      itemNote: json['item_note'] ?? '',
      itemSource: json['item_source'] ?? '',
      itemImages: (json['item_images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      returnType: json['return_type'] ?? '',
      priceMin: double.tryParse(json['price_min']?.toString() ?? ''),
      priceMax: double.tryParse(json['price_max']?.toString() ?? ''),
      isNegotiable:
          (json['is_negotiable'] == 1 || json['is_negotiable'] == true),
      returnItemName: json['return_item_name'],
      returnItemCategory: json['return_item_category'],
      returnItemCondition: json['return_item_condition'],
      returnItemDescription: json['return_item_description'],
      returnItemSource: json['return_item_source'],
      returnItemImages: (json['return_item_images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      walletCredits: json['wallet_credits'] ?? 0,
      notifyPartnersOnly: (json['notify_partners_only'] == 1 ||
          json['notify_partners_only'] == true),
      postType: json['post_type'] ?? '',
      status: json['status'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      userName: json['user_name'] ?? '',
      userImage: json['user_image'],
      userRating: double.tryParse(json['user_rating']?.toString() ?? ''),
      distanceKm: double.tryParse(json['distance_km']?.toString() ?? ''),
      responseCount: json['response_count'],
    );
  }
}
