class VisitorResponse {
  final String message;
  final bool status;
  final List<Visitor> data;

  VisitorResponse({
    required this.message,
    required this.status,
    required this.data,
  });

  factory VisitorResponse.fromJson(Map<String, dynamic> json) {
    return VisitorResponse(
      message: json['message'],
      status: json['status'],
      data: (json['data'] as List)
          .map((visitorJson) => Visitor.fromJson(visitorJson))
          .toList(),
    );
  }
}

class Visitor {
  final String id;
  final String name;
  final String type;
  final String contactNumber;
  final String? moTime;
  final String? tueTime;
  final String? wedTime;
  final String? thuTime;
  final String? friTime;
  final String? satTime;
  final String? sunTime;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  Visitor({
    required this.id,
    required this.name,
    required this.type,
    required this.contactNumber,
    this.moTime,
    this.tueTime,
    this.wedTime,
    this.thuTime,
    this.friTime,
    this.satTime,
    this.sunTime,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Visitor.fromJson(Map<String, dynamic> json) {
    return Visitor(
      id: json['_id'],
      name: json['name'],
      type: json['type'],
      contactNumber: json['contactNumber'],
      moTime: json['moTime'],
      tueTime: json['tueTime'],
      wedTime: json['wedTime'],
      thuTime: json['thuTime'],
      friTime: json['friTime'],
      satTime: json['satTime'],
      sunTime: json['sunTime'],
      createdBy: json['createdBy'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}