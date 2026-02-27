class GuestResponse {
  final String message;
  final bool status;
  final List<Guest> data;

  GuestResponse({
    required this.message,
    required this.status,
    required this.data,
  });

  factory GuestResponse.fromJson(Map<String, dynamic> json) {
    return GuestResponse(
      message: json['message'],
      status: json['status'],
      data: (json['data'] as List)
          .map((guestJson) => Guest.fromJson(guestJson))
          .toList(),
    );
  }
}

class Guest {
  final String id;
  final String name;
  final String type;
  final String contactNumber;
  final String carPlateNumber;
  final String vehicleModel;
  final String color;
  final DateTime fromDate;
  final String fromTime;
  final DateTime toDate;
  final String toTime;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;

  Guest({
    required this.id,
    required this.name,
    required this.type,
    required this.contactNumber,
    required this.carPlateNumber,
    required this.vehicleModel,
    required this.color,
    required this.fromDate,
    required this.fromTime,
    required this.toDate,
    required this.toTime,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory Guest.fromJson(Map<String, dynamic> json) {
    return Guest(
      id: json['_id'],
      name: json['name'],
      type: json['type'],
      contactNumber: json['contactNumber'],
      carPlateNumber: json['carPlateNumber'],
      vehicleModel: json['vehicleModel'],
      color: json['color'],
      fromDate: DateTime.parse(json['fromDate']),
      fromTime: json['fromTime'],
      toDate: DateTime.parse(json['toDate']),
      toTime: json['toTime'],
      createdBy: json['createdBy'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      v: json['__v'],
    );
  }
}