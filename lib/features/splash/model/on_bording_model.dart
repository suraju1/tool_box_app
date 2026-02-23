//create a model class for onboarding screen

class OnBoardingModel {
  final int? id;
  final String title;
  final String description;
  final String imageUrl;
  final int? screenOrder;

  OnBoardingModel({
    this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    this.screenOrder,
  });

  factory OnBoardingModel.fromJson(Map<String, dynamic> json) {
    return OnBoardingModel(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '',
      screenOrder: json['screen_order'] is int
          ? json['screen_order']
          : int.tryParse(json['screen_order'].toString()),
    );
  }

  // Getters for backward compatibility with the existing UI
  String get heading => title;
  String get subtext => description;
  String get image => imageUrl;
}
