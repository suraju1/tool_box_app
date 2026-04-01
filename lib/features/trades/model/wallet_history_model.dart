import 'dart:convert';

class WalletHistoryResponse {
  final bool success;
  final List<WalletHistory> walletHistory;

  WalletHistoryResponse({
    required this.success,
    required this.walletHistory,
  });

  factory WalletHistoryResponse.fromJson(Map<String, dynamic> json) {
    return WalletHistoryResponse(
      success: json['success'] ?? false,
      walletHistory: (json['walletHistory'] as List?)
              ?.map((e) => WalletHistory.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class WalletHistory {
  final int id;
  final String amount;
  final String deductionDate;
  final WalletPost? post;

  WalletHistory({
    required this.id,
    required this.amount,
    required this.deductionDate,
    this.post,
  });

  factory WalletHistory.fromJson(Map<String, dynamic> json) {
    return WalletHistory(
      id: json['id'] ?? 0,
      amount: json['amount']?.toString() ?? '0.00',
      deductionDate: json['deduction_date'] ?? '',
      post: json['post'] != null ? WalletPost.fromJson(json['post']) : null,
    );
  }
}

class WalletPost {
  final int id;
  final String name;
  final String category;
  final String type;
  final List<String> images;
  final String createdAt;

  WalletPost({
    required this.id,
    required this.name,
    required this.category,
    required this.type,
    required this.images,
    required this.createdAt,
  });

  factory WalletPost.fromJson(Map<String, dynamic> json) {
    List<String> parseImages(dynamic images) {
      if (images == null) return [];
      if (images is List) return images.map((e) => e.toString()).toList();
      if (images is String) {
        if (images.isEmpty || images == "[]") return [];
        try {
          final decoded = jsonDecode(images);
          if (decoded is List) return decoded.map((e) => e.toString()).toList();
        } catch (_) {}
      }
      return [];
    }

    return WalletPost(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      type: json['type'] ?? '',
      images: parseImages(json['image']),
      createdAt: json['created_at'] ?? '',
    );
  }
}
