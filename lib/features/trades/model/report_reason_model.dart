class ReportReasonModel {
  final int id;
  final String title;

  ReportReasonModel({
    required this.id,
    required this.title,
  });

  factory ReportReasonModel.fromJson(Map<String, dynamic> json) {
    String parsedTitle = json['title'] ??
        json['reason'] ??
        json['name'] ??
        json['description'] ??
        json['text'] ??
        json['label'] ??
        json['reason_name'] ??
        json['reason_text'] ??
        '';

    if (parsedTitle.isEmpty) {
      // Fallback to show the raw JSON keys so we can debug what the API is returning
      parsedTitle = json.toString();
    }

    return ReportReasonModel(
      id: json['id'] ?? 0,
      title: parsedTitle,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
    };
  }
}
