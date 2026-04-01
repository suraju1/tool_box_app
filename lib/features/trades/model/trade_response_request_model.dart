import 'package:dio/dio.dart';
import 'package:tool_bocs/util/string_util.dart';

class TradeResponseRequestModel {
  final int giveawayId;
  final String returnType; // 'existing', 'price', 'item', 'free'
  final String? itemName;
  final int? categoryId;
  final String? condition; // 'New', 'Like New', 'Used'
  final String? description;
  final bool? isHomemade;
  final bool? isStoreBought;
  final bool? notifyPoster;
  final double? priceRangeStart;
  final double? priceRangeEnd;
  final bool? isNegotiable;
  final List<String>? images; // List of file paths

  TradeResponseRequestModel({
    required this.giveawayId,
    required this.returnType,
    this.itemName,
    this.categoryId,
    this.condition,
    this.description,
    this.isHomemade,
    this.isStoreBought,
    this.notifyPoster,
    this.priceRangeStart,
    this.priceRangeEnd,
    this.isNegotiable,
    this.images,
  });

  Future<FormData> toFormData() async {
    final sanitizedName = StringUtil.sanitizeForSql(itemName);
    final sanitizedDescription = StringUtil.sanitizeForSql(description);
    final sanitizedCondition = StringUtil.sanitizeForSql(condition);

    final processedReturnType =
        returnType.toLowerCase() == 'item' ? 'Item' : returnType.toLowerCase();

    final Map<String, dynamic> data = {
      'return_type': processedReturnType,
      if (itemName != null || returnType.toLowerCase() == 'item') ...{
        'Item_name': sanitizedName,
        'item_name': sanitizedName, // Keep lowercase for safety
        'giving_item_name': sanitizedName, // Alias for server-side mapping
        'return_item_name': sanitizedName, // Alias for server-side mapping
      },
      if (categoryId != null) 'category_id': categoryId,
      if (condition != null) 'condition': sanitizedCondition,
      if (description != null) ...{
        'description': sanitizedDescription,
        'giving_item_description': sanitizedDescription, // Alias
        'return_item_description': sanitizedDescription, // Alias
      },
      if (isHomemade != null) 'is_homemade': isHomemade!.toString(),
      if (isStoreBought != null) 'is_store_bought': isStoreBought!.toString(),
      if (notifyPoster != null) 'notify_poster': notifyPoster!.toString(),
      if (priceRangeStart != null) 'price_range_start': priceRangeStart,
      if (priceRangeEnd != null) 'price_range_end': priceRangeEnd,
      if (isNegotiable != null) 'is_negotiable': isNegotiable!.toString(),
    };

    final formData = FormData.fromMap(data);

    if (images != null && images!.isNotEmpty) {
      for (var path in images!) {
        if (path.isNotEmpty) {
          formData.files.add(MapEntry(
            'Images', // Note: Case sensitive for some backend versions
            await MultipartFile.fromFile(path),
          ));
          // Adding lowercase as well for compatibility
          formData.files.add(MapEntry(
            'images',
            await MultipartFile.fromFile(path),
          ));
        }
      }
    }

    return formData;
  }

  Map<String, dynamic> toJson() {
    return {
      'giveaway_id': giveawayId,
      'return_type': returnType,
      'item_name': itemName,
      'category_id': categoryId,
      'condition': condition,
      'description': description,
      'is_homemade': isHomemade,
      'is_store_bought': isStoreBought,
      'notify_poster': notifyPoster,
      'price_range_start': priceRangeStart,
      'price_range_end': priceRangeEnd,
      'is_negotiable': isNegotiable,
    };
  }
}
