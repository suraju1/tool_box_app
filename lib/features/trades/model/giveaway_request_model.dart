import 'package:dio/dio.dart';

class GiveawayRequestModel {
  final int userId;
  final String pickupArea;
  final double latitude;
  final double longitude;
  final double areaDiameter;
  final String tradeType;
  final String itemName;
  final String itemCategory;
  final int itemCategoryId;
  final String itemCondition;
  final String itemNote;
  final String itemSource; // "Homemade" or "Store bought"
  final String returnType; // "Price" or "Item"
  final double? priceMin;
  final double? priceMax;
  final bool isNegotiable;
  final int walletCredits;
  final bool notifyPartnersOnly;
  final String postType; // "give" or "take"
  final List<String> itemImages; // Paths to images
  final List<String> returnItemImages; // Paths to return item images (if any)

  GiveawayRequestModel({
    required this.userId,
    required this.pickupArea,
    required this.latitude,
    required this.longitude,
    required this.areaDiameter,
    required this.tradeType,
    required this.itemName,
    required this.itemCategory,
    required this.itemCategoryId,
    required this.itemCondition,
    required this.itemNote,
    required this.itemSource,
    required this.returnType,
    this.priceMin,
    this.priceMax,
    required this.isNegotiable,
    required this.walletCredits,
    required this.notifyPartnersOnly,
    required this.postType,
    required this.itemImages,
    this.returnItemImages = const [],
  });

  Future<FormData> toFormData() async {
    final Map<String, dynamic> data = {
      'user_id': userId,
      'pickup_area': pickupArea,
      'latitude': latitude,
      'longitude': longitude,
      'area_diameter': areaDiameter,
      'trade_type': tradeType,
      'item_name': itemName,
      'item_category': itemCategory,
      'item_category_id': itemCategoryId,
      'item_condition': itemCondition,
      'item_note': itemNote,
      'item_source': itemSource,
      'return_type': returnType,
      if (priceMin != null) 'price_min': priceMin,
      if (priceMax != null) 'price_max': priceMax,
      'is_negotiable': isNegotiable,
      'wallet_credits': walletCredits,
      'notify_partners_only': notifyPartnersOnly,
      'post_type': postType,
    };

    final formData = FormData.fromMap(data);

    // Add item images
    for (var imagePath in itemImages) {
      if (imagePath.isNotEmpty) {
        formData.files.add(MapEntry(
          'item_images',
          await MultipartFile.fromFile(imagePath),
        ));
      }
    }

    // Add return item images
    for (var imagePath in returnItemImages) {
      if (imagePath.isNotEmpty) {
        formData.files.add(MapEntry(
          'return_item_images',
          await MultipartFile.fromFile(imagePath),
        ));
      }
    }

    return formData;
  }
}
