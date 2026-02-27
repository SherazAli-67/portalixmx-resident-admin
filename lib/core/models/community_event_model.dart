import 'package:flutter/material.dart';

class CommunityEventModel {
  final String id;
  final String eventTitle;
  final String eventDescription;
  final DateTime eventDate;
  final TimeOfDay eventTime;
  final DateTime createdAt;

  CommunityEventModel({
    required this.id,
    required this.eventTitle,
    required this.eventDescription,
    required this.eventDate,
    required this.eventTime,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'eventTitle': eventTitle,
      'eventDescription': eventDescription,
      'eventDate': eventDate.millisecondsSinceEpoch,
      'eventTime': {
        'hour': eventTime.hour,
        'minute': eventTime.minute,
      },
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory CommunityEventModel.fromMap(Map<String, dynamic> map) {
    return CommunityEventModel(
      id: map['id'] ?? '',
      eventTitle: map['eventTitle'] ?? '',
      eventDescription: map['eventDescription'] ?? '',
      eventDate: DateTime.fromMillisecondsSinceEpoch(
        map['eventDate'],
      ),
      eventTime: TimeOfDay(
        hour: map['eventTime']['hour'],
        minute: map['eventTime']['minute'],
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        map['createdAt'],
      ),
    );
  }

  CommunityEventModel copyWith({
    String? id,
    String? eventTitle,
    String? eventDescription,
    DateTime? eventDate,
    TimeOfDay? eventTime,
    DateTime? createdAt,
  }) {
    return CommunityEventModel(
      id: id ?? this.id,
      eventTitle: eventTitle ?? this.eventTitle,
      eventDescription: eventDescription ?? this.eventDescription,
      eventDate: eventDate ?? this.eventDate,
      eventTime: eventTime ?? this.eventTime,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}