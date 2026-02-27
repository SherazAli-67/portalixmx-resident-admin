class AccessModel {
  final String id;
  final String name;
  final String image;

  AccessModel({
    required this.id,
    required this.name,
    required this.image,
  });

  factory AccessModel.fromJson(Map<String, dynamic> json) {
    return AccessModel(
      id: json['_id'] ?? '',
      name: json['name'],
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "name": name,
      "image": image,
    };
  }
}