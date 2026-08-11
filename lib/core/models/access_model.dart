class AccessModel {
  final String id;
  final String name;
  final String image;
  final bool freeToUse;

  AccessModel({
    required this.id,
    required this.name,
    required this.image,
    required this.freeToUse
  });

  factory AccessModel.fromJson(Map<String, dynamic> json) {
    return AccessModel(
      id: json['_id'] ?? '',
      name: json['name'],
      image: json['image'],
      freeToUse: json['freeToUse'] ?? false
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "name": name,
      "image": image,
      'freeToUse' : freeToUse
    };
  }
  AccessModel copyWith({
    String? id,
    String? name,
    String? image,
    bool? freeToUse,
  }) {
    return AccessModel(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      freeToUse: freeToUse ?? this.freeToUse,
    );
  }
}