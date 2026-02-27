import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class VehicleInfo {
  final String plateNumber;
  final String model;
  final String color;

  VehicleInfo({
    required this.plateNumber,
    required this.model,
    required this.color,
  });

  factory VehicleInfo.fromMap(Map<String, dynamic> map) {
    return VehicleInfo(
      plateNumber: map['plateNumber'] ?? '',
      model: map['model'] ?? '',
      color: map['color'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'plateNumber': plateNumber,
      'model': model,
      'color': color,
    };
  }

  VehicleInfo copyWith({
    String? plateNumber,
    String? model,
    String? color,
  }) {
    return VehicleInfo(
      plateNumber: plateNumber ?? this.plateNumber,
      model: model ?? this.model,
      color: color ?? this.color,
    );
  }
}

abstract class BaseVisitor {
  final String id;
  // final String code;
  final String name;
  final String contact;
  final String visitorType;
  final String? accessFor;
  final VehicleInfo vehicleInfo;
  final DateTime createdAt;
  final DateTime updatedAt;

  BaseVisitor({
    required this.id,
    // required this.code,
    required this.name,
    required this.contact,
    required this.visitorType,
    this.accessFor,
    required this.vehicleInfo,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BaseVisitor.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final type = data['visitorType'] as String;

    if (type == 'guest') {
      return GuestVisitor.fromFirestore(doc);
    } else if (type == 'regular') {
      return RegularVisitor.fromFirestore(doc);
    } else {
      throw Exception('Unknown visitor type: $type');
    }
  }

  Map<String, dynamic> toFirestore();

  BaseVisitor copyWith();
}

class GuestVisitor extends BaseVisitor {
  final DateTime fromDateTime;
  final DateTime toDateTime;

  GuestVisitor({
    required super.id,
    // required super.code,
    required super.name,
    required super.contact,
    required super.vehicleInfo,
    super.accessFor,
    required super.createdAt,
    required super.updatedAt,
    required this.fromDateTime,
    required this.toDateTime,
  }) : super(visitorType: 'guest');

  Duration get duration => toDateTime.difference(fromDateTime);

  factory GuestVisitor.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GuestVisitor(
      id: doc.id,
      // code: data['code']?.toString() ?? '',
      name: data['name'] ?? '',
      contact: data['contact'] ?? '',
      vehicleInfo: VehicleInfo.fromMap(data['vehicleInfo'] ?? {}),
      accessFor: data['accessFor'],
      fromDateTime: (data['fromDateTime'] as Timestamp).toDate(),
      toDateTime: (data['toDateTime'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  @override
  Map<String, dynamic> toFirestore() {
    return {
      // 'code': code,
      'name': name,
      'contact': contact,
      'visitorType': visitorType,
      'vehicleInfo': vehicleInfo.toMap(),
      'accessFor' : accessFor,
      'fromDateTime': Timestamp.fromDate(fromDateTime),
      'toDateTime': Timestamp.fromDate(toDateTime),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  @override
  GuestVisitor copyWith({
    String? id,
    String? code,
    String? name,
    String? contact,
    String? accessFor,
    VehicleInfo? vehicleInfo,
    DateTime? fromDateTime,
    DateTime? toDateTime,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GuestVisitor(
      id: id ?? this.id,
      // code: code ?? this.code,
      name: name ?? this.name,
      contact: contact ?? this.contact,
      accessFor: accessFor ?? this.accessFor,
      vehicleInfo: vehicleInfo ?? this.vehicleInfo,
      fromDateTime: fromDateTime ?? this.fromDateTime,
      toDateTime: toDateTime ?? this.toDateTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class RegularVisitor extends BaseVisitor {
  final Map<String, VisitorSchedule?> schedule;

  RegularVisitor({
    required super.id,
    // required super.code,
    required super.name,
    required super.contact,
    required super.vehicleInfo,
    super.accessFor,
    required super.createdAt,
    required super.updatedAt,
    required this.schedule,
  }) : super(visitorType: 'regular');

  factory RegularVisitor.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final scheduleData = data['schedule'] as Map<String, dynamic>? ?? {};

    final schedule = <String, VisitorSchedule?>{};
    final days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    
    for (var day in days) {
      if (scheduleData.containsKey(day) && scheduleData[day] != null) {
        schedule[day] = VisitorSchedule.fromMap(scheduleData[day]);
      } else {
        schedule[day] = null;
      }
    }

    return RegularVisitor(
      id: doc.id,
      // code: data['code']?.toString() ?? '',
      name: data['name'] ?? '',
      contact: data['contact'] ?? '',
      accessFor: data['accessFor'],
      vehicleInfo: VehicleInfo.fromMap(data['vehicleInfo'] ?? {}),
      schedule: schedule,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  @override
  Map<String, dynamic> toFirestore() {
    final scheduleMap = <String, dynamic>{};
    schedule.forEach((day, visitorSchedule) {
      scheduleMap[day] = visitorSchedule?.toMap();
    });

    return {
      // 'code': code,
      'name': name,
      'contact': contact,
      'visitorType': visitorType,
      'accessFor' :  accessFor,
      'vehicleInfo': vehicleInfo.toMap(),
      'schedule': scheduleMap,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  @override
  RegularVisitor copyWith({
    String? id,
    String? code,
    String? name,
    String? contact,
    String? accessFor,
    VehicleInfo? vehicleInfo,
    Map<String, VisitorSchedule?>? schedule,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RegularVisitor(
      id: id ?? this.id,
      // code: code ?? this.code,
      name: name ?? this.name,
      contact: contact ?? this.contact,
      accessFor: accessFor ?? this.accessFor,
      vehicleInfo: vehicleInfo ?? this.vehicleInfo,
      schedule: schedule ?? this.schedule,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class VisitorSchedule {
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  VisitorSchedule({
    required this.startTime,
    required this.endTime,
  });

  factory VisitorSchedule.fromMap(Map<String, dynamic> map) {
    return VisitorSchedule(
      startTime: _timeOfDayFromString(map['startTime']),
      endTime: _timeOfDayFromString(map['endTime']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'startTime': _timeOfDayToString(startTime),
      'endTime': _timeOfDayToString(endTime),
    };
  }

  static TimeOfDay _timeOfDayFromString(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  static String _timeOfDayToString(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
