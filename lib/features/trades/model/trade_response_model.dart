class TradeResponseModel {
  final int id;
  final int postId;
  final int responderId;
  final int posterUserId;
  final String responderName;
  final String? responderImage;
  final String responseType; // 'price' or 'item'
  final double? priceRangeStart;
  final double? priceRangeEnd;
  final bool isNegotiable;
  final String? itemName;
  final String? itemCategory;
  final String? itemCondition;
  final String? itemDescription;
  final bool isHomemade;
  final bool isStoreBought;
  final List<String> itemImages;
  final String status; // 'pending', 'accepted', 'rejected'
  final String createdAt;
  final String paymentStatus; // 'unpaid', 'paid'
  final String? postItemName;
  final String? returnItemName;
  final List<String> postItemImages;
  final String? postType;
  final int? rejectedBy;
  final String? rejectedReason;
  final String? posterName;
  final String? posterImage;
  final int? itemCategoryId;
  final String? posterMobile;
  final String? responderMobile;

  TradeResponseModel({
    required this.id,
    required this.postId,
    required this.responderId,
    required this.posterUserId,
    required this.responderName,
    this.responderImage,
    required this.responseType,
    this.priceRangeStart,
    this.priceRangeEnd,
    this.isNegotiable = false,
    this.itemName,
    this.itemCategory,
    this.itemCondition,
    this.itemDescription,
    this.isHomemade = false,
    this.isStoreBought = false,
    this.itemImages = const [],
    required this.status,
    this.paymentStatus = 'unpaid',
    required this.createdAt,
    this.postItemName,
    this.returnItemName,
    this.postItemImages = const [],
    this.postType,
    this.rejectedBy,
    this.rejectedReason,
    this.posterName,
    this.posterImage,
    this.itemCategoryId,
    this.posterMobile,
    this.responderMobile,
  });

  factory TradeResponseModel.fromJson(Map<String, dynamic> json) {
    return TradeResponseModel(
      id: json['id'] ?? 0,
      postId: json['giveaway_id'] ?? json['post_id'] ?? 0,
      responderId: json['responder_user_id'] ?? json['user_id'] ?? 0,
      posterUserId: json['poster_user_id'] ?? 0,
      responderName: json['responder_name'] ?? json['user_name'] ?? 'User',
      responderImage: json['responder_image'] ?? json['user_image'],
      responseType: json['post_return_type'] ??
          json['return_type'] ??
          json['response_type'] ??
          'item',
      priceRangeStart:
          double.tryParse(json['price_range_start']?.toString() ?? ''),
      priceRangeEnd: double.tryParse(json['price_range_end']?.toString() ?? ''),
      isNegotiable: (json['offer_is_negotiable'] == 1 ||
          json['offer_is_negotiable'] == true ||
          json['is_negotiable'] == 1 ||
          json['is_negotiable'] == true),
      itemName: json['post_type'] == 'give'
          ? (json['return_item_name'] ?? json['giving_item_name'])
          : (json['giving_item_name'] ?? json['return_item_name']),
      itemCategory: json['giving_item_category'] ?? json['category_name'],
      itemCondition: json['giving_item_condition'] ?? json['condition'],
      itemDescription: json['giving_item_note'] ?? json['description'],
      isHomemade: (json['giving_is_homemade'] == 1 ||
          json['giving_is_homemade'] == true ||
          json['is_homemade'] == 1 ||
          json['is_homemade'] == true),
      isStoreBought: (json['giving_is_store_bought'] == 1 ||
          json['giving_is_store_bought'] == true ||
          json['is_store_bought'] == 1 ||
          json['is_store_bought'] == true),
      itemImages: (json['giving_item_images'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          (json['images'] as List?)?.map((e) => e.toString()).toList() ??
          [],
      status: json['status'] ?? 'pending',
      paymentStatus: json['payment_status'] ?? 'unpaid',
      createdAt: json['created_at'] ?? '',
      postItemName: json['post_type'] == 'give'
          ? (json['giving_item_name'] ??
              json['post_item_name'] ??
              json['item_name'])
          : (json['post_item_name'] ?? json['item_name']),
      returnItemName: json['return_item_name'],
      postItemImages: (json['post_item_images'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      postType: json['post_type'],
      rejectedBy: json['rejected_by'],
      rejectedReason: json['rejected_reason'],
      posterName: json['poster_name'],
      posterImage: json['poster_image'],
      itemCategoryId:
          json['giving_item_category_id'] ?? json['item_category_id'],
      posterMobile: json['poster_mobile'] ?? json['poster_phone_number'],
      responderMobile:
          json['responder_mobile'] ?? json['responder_phone_number'],
    );
  }

  TradeResponseModel copyWith({
    String? status,
    String? paymentStatus,
  }) {
    return TradeResponseModel(
      id: id,
      postId: postId,
      responderId: responderId,
      posterUserId: posterUserId,
      responderName: responderName,
      responderImage: responderImage,
      responseType: responseType,
      priceRangeStart: priceRangeStart,
      priceRangeEnd: priceRangeEnd,
      isNegotiable: isNegotiable,
      itemName: itemName,
      itemCategory: itemCategory,
      itemCondition: itemCondition,
      itemDescription: itemDescription,
      isHomemade: isHomemade,
      isStoreBought: isStoreBought,
      itemImages: itemImages,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      createdAt: createdAt,
      postItemName: postItemName,
      returnItemName: returnItemName,
      postItemImages: postItemImages,
      postType: postType,
      rejectedBy: rejectedBy,
      rejectedReason: rejectedReason,
      posterName: posterName,
      posterImage: posterImage,
      itemCategoryId: itemCategoryId,
      posterMobile: posterMobile,
      responderMobile: responderMobile,
    );
  }
}
