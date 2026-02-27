import 'package:cloud_firestore/cloud_firestore.dart';

enum ComplaintStatus {
  pending,
  inProgress,
  resolved,
  rejected,
}

class ComplaintModel {
  final String id;
  final String complaint;
  final List<String> images;
  final String complaintBy;
  final String residentAdminID;
  final String societyID;
  final ComplaintStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  ComplaintModel({
    required this.id,
    required this.complaint,
    required this.images,
    required this.complaintBy,
    required this.residentAdminID,
    required this.societyID,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  String _statusToString(ComplaintStatus status) {
    return status.name;
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "complaint": complaint,
      "images": images,
      "complaintBy": complaintBy,
      "residentAdminID": residentAdminID,
      "societyID": societyID,
      "status": _statusToString(status),
      "createdAt": Timestamp.fromDate(createdAt),
      "updatedAt": Timestamp.fromDate(updatedAt),
    };
  }

  factory ComplaintModel.fromMap(Map<String, dynamic> map) {
    return ComplaintModel(
      id: map["id"] ?? '',
      complaint: map["complaint"] ?? '',
      images: List<String>.from(map["images"] ?? []),
      complaintBy: map["complaintBy"] ?? '',
      residentAdminID: map["residentAdminID"] ?? '',
      societyID: map["societyID"] ?? '',
      status: ComplaintStatus.values.firstWhere(
            (e) => e.name == map["status"],
        orElse: () => ComplaintStatus.pending,
      ),
      createdAt: (map["createdAt"] as Timestamp).toDate(),
      updatedAt: (map["updatedAt"] as Timestamp).toDate(),
    );
  }

  ComplaintModel copyWith({
    String? id,
    String? complaint,
    List<String>? images,
    String? complaintBy,
    String? residentAdminID,
    String? societyID,
    ComplaintStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ComplaintModel(
      id: id ?? this.id,
      complaint: complaint ?? this.complaint,
      images: images ?? this.images,
      complaintBy: complaintBy ?? this.complaintBy,
      residentAdminID: residentAdminID ?? this.residentAdminID,
      societyID: societyID ?? this.societyID,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}