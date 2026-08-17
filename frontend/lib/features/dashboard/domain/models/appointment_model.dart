import 'package:flutter/material.dart';

enum AppointmentStatusType {
  scheduled,
  inProgress,
  in30Min,
  confirmed,
}

enum AppointmentPaymentStatus {
  paid,
  due,
}

class DashboardAppointment {
  final String id;
  final String initials;
  final String name;
  final String symptoms;
  final String timeText;
  final AppointmentStatusType status;
  final String consultType;
  final String partnerLogoType; // e.g. 'CM', 'Cross', 'CircleBlue', 'BankCircle'
  final String priceText;
  final AppointmentPaymentStatus paymentStatus;
  final Color avatarColor;
  final String? dateText;

  const DashboardAppointment({
    required this.id,
    required this.initials,
    required this.name,
    required this.symptoms,
    required this.timeText,
    required this.status,
    required this.consultType,
    required this.partnerLogoType,
    required this.priceText,
    required this.paymentStatus,
    required this.avatarColor,
    this.dateText,
  });
}
