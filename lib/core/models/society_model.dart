class SocietyModel {
  final String id;
  final String name;
  final String? location;
  final String? residentAdmin;
  final String status;
  final String imageUrl;

  SocietyModel({
    required this.id,
    required this.name,
    this.location,
    this.residentAdmin,
    required this.status,
    required this.imageUrl,
  });

  factory SocietyModel.fromMap(Map<String, dynamic> map) {
    return SocietyModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      location: map['location'],
      residentAdmin: map['residentAdmin'],
      status: map['status'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'residentAdmin': residentAdmin,
      'status': status,
      'imageUrl' : imageUrl
    };
  }

  SocietyModel copyWith({
    String? id,
    String? name,
    String? location,
    String? residentAdmin,
    String? status,
    String? imageUrl
  }) {
    return SocietyModel(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      residentAdmin: residentAdmin ?? this.residentAdmin,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl
    );
  }
}