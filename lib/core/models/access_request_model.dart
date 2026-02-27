import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AccessRequestModel {
  final String id;
  final String requestByUID;
  final String requestedAccessTitle;
  final String requestedAccessImage;
  final String residentAdminID;
  final String societyID;
  final DateTime requestedForDate;
  final TimeOfDay requestedForTime;
  final DateTime createdAt;
  final DateTime updatedAt;

  AccessRequestModel({
    required this.id,
    required this.requestByUID,
    required this.requestedAccessTitle,
    required this.requestedAccessImage,
    required this.residentAdminID,
    required this.societyID,
    required this.requestedForDate,
    required this.requestedForTime,
    required this.createdAt,
    required this.updatedAt
  });

  String _timeOfDayToString(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'requestByUID': requestByUID,
      'requestedAccessTitle': requestedAccessTitle,
      'requestedAccessImage': requestedAccessImage,
      'residentAdminID': residentAdminID,
      'societyID': societyID,
      'requestedForDate': requestedForDate.toIso8601String(),
      'requestedForTime': _timeOfDayToString(requestedForTime),
      "createdAt": Timestamp.fromDate(createdAt),
      "updatedAt": Timestamp.fromDate(updatedAt),
    };
  }

  factory AccessRequestModel.fromMap(Map<String, dynamic> map) {
    final timeString = map['requestedForTime'] ?? "00:00";
    final parts = timeString.split(":");
    return AccessRequestModel(
      id: map['id'] ?? '',
      requestByUID: map['requestByUID'] ?? '',
      requestedAccessTitle: map['requestedAccessTitle'] ?? '',
      requestedAccessImage: map['requestedAccessImage'] ?? '',
      residentAdminID: map['residentAdminID'] ?? '',
      societyID: map['societyID'] ?? '',
      createdAt: (map["createdAt"] as Timestamp).toDate(),
      updatedAt: (map["updatedAt"] as Timestamp).toDate(),
      requestedForDate: DateTime.parse(map['requestedForDate']),
      requestedForTime: TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      ),
    );
  }

  AccessRequestModel copyWith({
    String? id,
    String? requestByUID,
    String? requestedAccessTitle,
    String? requestedAccessImage,
    String? residentAdminID,
    String? societyID,
    DateTime? requestedForDate,
    TimeOfDay? requestedForTime,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AccessRequestModel(
      id: id ?? this.id,
      requestByUID: requestByUID ?? this.requestByUID,
      requestedAccessTitle:
      requestedAccessTitle ?? this.requestedAccessTitle,
      requestedAccessImage:
      requestedAccessImage ?? this.requestedAccessImage,
      residentAdminID: residentAdminID ?? this.residentAdminID,
      societyID: societyID ?? this.societyID,
      requestedForDate: requestedForDate ?? this.requestedForDate,
      requestedForTime: requestedForTime ?? this.requestedForTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
