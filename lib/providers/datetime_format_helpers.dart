import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/models/day_time_model.dart';

class DateTimeFormatHelpers{
  static String formatDateTime(DateTime dateTime){
    String formattedDateTime = '';
    DateFormat dateFormat = DateFormat('MMM d, yyyy');
    formattedDateTime = dateFormat.format(dateTime);
    return formattedDateTime;
  }

  static String formatTime(TimeOfDay time){
    String formattedTime = '';
    // DateFormat timeFormat = DateFormat('hh:mm aa');
    // formattedTime = timeFormat.format(DateTime.)
    formattedTime = '${time.hour > 12 ? time.hour - 12 : time.hour}:${time.minute} ${time.period.name.toUpperCase()}';
    return formattedTime;
  }

  static String formatGuestTime(DayTimeModel time){
    String startFormattedTime = '${time.time!.hour > 12 ? time.time!.hour - 12 : time.time!.hour}:${time.time!.minute} ${time.time!.period.name.toUpperCase()}';
    String endFormattedTime = '${time.endTime!.hour > 12 ? time.endTime!.hour - 12 : time.endTime!.hour}:${time.endTime!.minute} ${time.endTime!.period.name.toUpperCase()}';
    return '$startFormattedTime - $endFormattedTime';
  }

  static String timeOfDayToString(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  static String formattedTimeFromString(String timeString) {
    final parts = timeString.split(':');
    TimeOfDay time =  TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );

    return formatTime(time);
  }

  static String getCommunityDateTime(DateTime createdAt, TimeOfDay eventTime) {
    DateFormat dateFormat = DateFormat("MMM dd");
    return '${dateFormat.format(createdAt)}, ${formatTime(eventTime)}';
  }
}