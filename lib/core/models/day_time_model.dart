import 'package:flutter/material.dart';

class DayTimeModel {
  int dayID;
  TimeOfDay? time;
  TimeOfDay? endTime;

  DayTimeModel({required this.dayID, this.time, this.endTime});

  factory DayTimeModel.fromJson(Map<String, dynamic> json) {
    return DayTimeModel(
      dayID: json['dayID'],
      time: json['time'] != null && json['time'].isNotEmpty
          ? _timeOfDayFromString(json['time'])
          : null,
      endTime: json['endTime'] != null && json['endTime'].isNotEmpty
          ? _timeOfDayFromString(json['endTime'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dayID': dayID,
      'time': time != null ? _timeOfDayToString(time!) : null,
      'endTime': endTime != null ? _timeOfDayToString(endTime!) : null,
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