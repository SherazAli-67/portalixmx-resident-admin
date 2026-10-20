class AccessModel {
  final String id;
  final String name;
  final String image;
  final bool freeToUse;
  final String? societyID;

  AccessModel({
    required this.id,
    required this.name,
    required this.image,
    required this.freeToUse,
    this.societyID,
  });

  factory AccessModel.fromJson(Map<String, dynamic> json) {
    return AccessModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      freeToUse: json['freeToUse'] ?? false,
      societyID: json['societyID'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "name": name,
      "image": image,
      'freeToUse': freeToUse,
      if (societyID != null) 'societyID': societyID,
    };
  }

  AccessModel copyWith({
    String? id,
    String? name,
    String? image,
    bool? freeToUse,
    String? societyID,
  }) {
    return AccessModel(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      freeToUse: freeToUse ?? this.freeToUse,
      societyID: societyID ?? this.societyID,
    );
  }
}
