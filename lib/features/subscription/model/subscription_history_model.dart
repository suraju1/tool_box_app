class SubscriptionHistoryResponse {
  final bool success;
  final int total;
  final Pagination? pagination;
  final List<SubscriptionHistoryItem> data;

  SubscriptionHistoryResponse({
    required this.success,
    required this.total,
    this.pagination,
    required this.data,
  });

  factory SubscriptionHistoryResponse.fromJson(Map<String, dynamic> json) {
    return SubscriptionHistoryResponse(
      success: json['success'] ?? false,
      total: json['total'] ?? 0,
      pagination: json['pagination'] != null
          ? Pagination.fromJson(json['pagination'])
          : null,
      data: (json['data'] as List? ?? [])
          .map((i) => SubscriptionHistoryItem.fromJson(i))
          .toList(),
    );
  }
}

class Pagination {
  final int page;
  final int limit;
  final int totalPages;
  final bool hasNext;
  final bool hasPrev;

  Pagination({
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      page: json['page'] ?? 0,
      limit: json['limit'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      hasNext: json['hasNext'] ?? false,
      hasPrev: json['hasPrev'] ?? false,
    );
  }
}

class SubscriptionHistoryItem {
  final int id;
  final int subscriptionId;
  final String name;
  final String totalAmount;
  final String remainingCredit;
  final int usedPosts;
  final String startDate;
  final String endDate;
  final String postPrice;
  final bool isExpired;
  final String status;
  final int remainingDays;

  SubscriptionHistoryItem({
    required this.id,
    required this.subscriptionId,
    required this.name,
    required this.totalAmount,
    required this.remainingCredit,
    required this.usedPosts,
    required this.startDate,
    required this.endDate,
    required this.postPrice,
    required this.isExpired,
    required this.status,
    required this.remainingDays,
  });

  factory SubscriptionHistoryItem.fromJson(Map<String, dynamic> json) {
    return SubscriptionHistoryItem(
      id: json['id'] ?? 0,
      subscriptionId: json['subscription_id'] ?? 0,
      name: json['name'] ?? '',
      totalAmount: json['total_amount']?.toString() ?? '0.00',
      remainingCredit: json['remaining_credit']?.toString() ?? '0.00',
      usedPosts: json['used_posts'] ?? 0,
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      postPrice: json['post_price']?.toString() ?? '0.00',
      isExpired: _parseBool(json['is_expired']),
      status: json['status'] ?? '',
      remainingDays: json['remaining_days'] ?? 0,
    );
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) {
      final v = value.toLowerCase();
      return v == 'true' || v == '1' || v == 'yes' || v == 'active';
    }
    return false;
  }
}
