class SocietyModel {
  String id;
  String name;

  SocietyModel({
    required this.id,
    required this.name,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory SocietyModel.fromMap(Map<String, dynamic> map) {
    return SocietyModel(
      id: map['id'] ?? 0,
      name: map['name'] ?? '',
    );
  }
}