class BannerModel {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final bool isActive;

  BannerModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'imageUrl': imageUrl,
      'isActive': isActive ? 1 : 0,
    };
  }

  factory BannerModel.fromMap(Map<String, dynamic> map) {
    return BannerModel(
      id: map['id'],
      title: map['title'],
      subtitle: map['subtitle'],
      imageUrl: map['imageUrl'],
      isActive: map['isActive'] == 1,
    );
  }
}
