import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/models/day_time_model.dart';

class DateTimeFormatHelpers{
  static String formatDateTime(DateTime dateTime){
    final local = dateTime.toLocal();
    final dateFormat = DateFormat('MMM d, yyyy');
    return dateFormat.format(local);
  }

  static String formatTime(TimeOfDay time){
    return '${time.hour > 12 ? time.hour - 12 : time.hour}:${time.minute} ${time.period.name.toUpperCase()}';
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
    final local = createdAt.toLocal();
    DateFormat dateFormat = DateFormat("MMM dd");
    return '${dateFormat.format(local)}, ${formatTime(eventTime)}';
  }

  static bool isInInclusiveDateRange(DateTime date, DateTime? from, DateTime? to) {
    final local = date.toLocal();
    final d = DateTime(local.year, local.month, local.day);
    if (from != null) {
      final localFrom = from.toLocal();
      if (d.isBefore(DateTime(localFrom.year, localFrom.month, localFrom.day))) return false;
    }
    if (to != null) {
      final localTo = to.toLocal();
      if (d.isAfter(DateTime(localTo.year, localTo.month, localTo.day))) return false;
    }
    return true;
  }
}
