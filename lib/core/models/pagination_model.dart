class Pagination {
  final int total;
  final int page;
  final int limit;
  final int totalPages;
  final bool hasNext;
  final bool hasPrev;

  Pagination({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    total: json["total"] ?? 0,
    page: json["page"] ?? 1,
    limit: json["limit"] ?? 10,
    totalPages: json["totalPages"] ?? 0,
    hasNext: json["hasNext"] ?? false,
    hasPrev: json["hasPrev"] ?? false,
  );
}
