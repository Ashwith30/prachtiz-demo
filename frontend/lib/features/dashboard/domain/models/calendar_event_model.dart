import 'package:flutter/material.dart';

enum CalendarEventType { consultation, surgery, conference, personal }

class CalendarEventModel {
  final String id;
  final String title;
  final DateTime dateTime;
  final Duration duration;
  final CalendarEventType type;
  final Color color;

  const CalendarEventModel({
    required this.id,
    required this.title,
    required this.dateTime,
    required this.duration,
    required this.type,
    required this.color,
  });
}
