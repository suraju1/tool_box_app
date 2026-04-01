import 'package:flutter/foundation.dart';

class NotificationResponseModel {
  final bool success;
  final String message;
  final Pagination? pagination;
  final List<NotificationModel> data;

  NotificationResponseModel({
    required this.success,
    required this.message,
    this.pagination,
    required this.data,
  });

  factory NotificationResponseModel.fromJson(Map<String, dynamic> json) =>
      NotificationResponseModel(
        success: json["success"] ?? false,
        message: json["message"] ?? "",
        pagination: json["pagination"] == null
            ? null
            : Pagination.fromJson(json["pagination"]),
        data: json["data"] == null
            ? []
            : List<NotificationModel>.from(
                json["data"].map((x) => NotificationModel.fromJson(x))),
      );
}

class NotificationModel {
  final int id;
  final int userId;
  final String notificationTitle;
  final String notificationMessage;
  final int isRead;
  final DateTime? readAt;
  final DateTime? createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.notificationTitle,
    required this.notificationMessage,
    required this.isRead,
    this.readAt,
    this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    debugPrint("Notification JSON mapping: $json");
    final dynamic rawId =
        json["notification_id"] ?? json["id"] ?? json["user_id"];
    final int parsedId =
        rawId is int ? rawId : int.tryParse(rawId?.toString() ?? "") ?? 0;

    return NotificationModel(
      id: parsedId,
      userId: json["user_id"] ?? 0,
      notificationTitle: json["notification_title"] ?? "",
      notificationMessage: json["notification_message"] ?? "",
      isRead: json["is_read"] ?? 0,
      readAt: json["read_at"] == null ? null : DateTime.parse(json["read_at"]),
      createdAt: json["created_at"] == null
          ? null
          : DateTime.parse(json["created_at"]),
    );
  }
}

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
