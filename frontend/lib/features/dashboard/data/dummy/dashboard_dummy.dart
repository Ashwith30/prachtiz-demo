import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/dashboard_banner_model.dart';
import '../../domain/models/summary_card_model.dart';
import '../../domain/models/appointment_model.dart';
import '../../domain/models/footer_stat_model.dart';
import '../../domain/models/calendar_event_model.dart';

class DashboardDummy {
  static DashboardBannerModel get bannerData => DashboardBannerModel(
    greeting: "Today's Schedule",
    dateRangeText: "Tuesday, 16 June 2026",
    shiftText: "9:00 AM - 12:00 PM",
    locationText: "Hyderabad",
    loginTimeText: "Last Login 10:04 AM",
  );

  static SummaryCardModel get totalAppointments => SummaryCardModel(
    title: "TOTAL APPOINTMENTS TODAY",
    value: "15",
    changePercentage: 2.0,
    isPositive: true,
    icon: Icons.calendar_today_outlined,
    iconColor: AppColors.white,
    iconBgColor: AppColors.primaryDark,
    sparklineData: [10, 12, 11, 14, 13, 15],
  );

  static SummaryCardModel get upcomingThisWeek => SummaryCardModel(
    title: "UPCOMING THIS WEEK",
    value: "48",
    changePercentage: 8.0,
    isPositive: true,
    icon: Icons.event_note_outlined,
    iconColor: AppColors.white,
    iconBgColor: Colors.transparent,
    sparklineData: [38, 40, 42, 45, 43, 48],
  );

  static final List<SummaryCardModel> middleCards = [
    SummaryCardModel(
      title: "Video Consultations",
      value: "03",
      changePercentage: 0.0,
      isPositive: true,
      icon: Icons.videocam_outlined,
      iconColor: AppColors.primary,
      iconBgColor: Colors.transparent,
      sparklineData: [],
    ),
    SummaryCardModel(
      title: "Walk-in Appointments",
      value: "03",
      changePercentage: 0.0,
      isPositive: true,
      icon: Icons.directions_walk,
      iconColor: AppColors.secondary,
      iconBgColor: Colors.transparent,
      sparklineData: [],
    ),
    SummaryCardModel(
      title: "First Time Patients",
      value: "03",
      changePercentage: 0.0,
      isPositive: true,
      icon: Icons.person_add_alt_1_outlined,
      iconColor: AppColors.purple,
      iconBgColor: Colors.transparent,
      sparklineData: [],
    ),
    SummaryCardModel(
      title: "Repeat Patients",
      value: "03",
      changePercentage: 0.0,
      isPositive: true,
      icon: Icons.group_outlined,
      iconColor: AppColors.info,
      iconBgColor: Colors.transparent,
      sparklineData: [],
    ),
    SummaryCardModel(
      title: "Rescheduled",
      value: "03",
      changePercentage: 0.0,
      isPositive: true,
      icon: Icons.restore_outlined,
      iconColor: AppColors.warning,
      iconBgColor: Colors.transparent,
      sparklineData: [],
    ),
    SummaryCardModel(
      title: "Cancelled",
      value: "02",
      changePercentage: 0.0,
      isPositive: false,
      icon: Icons.cancel_outlined,
      iconColor: AppColors.danger,
      iconBgColor: Colors.transparent,
      sparklineData: [],
    ),
  ];

  static final List<DashboardAppointment> appointments = [
    DashboardAppointment(
      id: "AM-1",
      initials: "AM",
      name: "Adrian Marshall",
      symptoms: "Headache, Dizziness",
      dateText: "12 May 2025",
      timeText: "Today 4:30 PM",
      status: AppointmentStatusType.scheduled,
      consultType: "General",
      partnerLogoType: "CH",
      priceText: "₹500",
      paymentStatus: AppointmentPaymentStatus.paid,
      avatarColor: AppColors.warning,
    ),
    DashboardAppointment(
      id: "KS-2",
      initials: "KS",
      name: "Kelly Stevens",
      symptoms: "Chest Pain",
      dateText: "02 Apr 2025",
      timeText: "Today 5:00 PM",
      status: AppointmentStatusType.inProgress,
      consultType: "Follow-up",
      partnerLogoType: "HDFC",
      priceText: "₹500",
      paymentStatus: AppointmentPaymentStatus.due,
      avatarColor: AppColors.secondary,
    ),
    DashboardAppointment(
      id: "SA-3",
      initials: "SA",
      name: "Samuel Anderson",
      symptoms: "Allergies",
      dateText: "20 Mar 2025",
      timeText: "Today 5:30 PM",
      status: AppointmentStatusType.in30Min,
      consultType: "Video-MER",
      partnerLogoType: "CircleBlue",
      priceText: "₹500",
      paymentStatus: AppointmentPaymentStatus.paid,
      avatarColor: AppColors.primary,
    ),
    DashboardAppointment(
      id: "PS-4",
      initials: "PS",
      name: "Priya Sharma",
      symptoms: "Diabetes follow-up",
      dateText: "15 May 2025",
      timeText: "Today 6:00 PM",
      status: AppointmentStatusType.confirmed,
      consultType: "Telehealth",
      partnerLogoType: "SBI",
      priceText: "₹300",
      paymentStatus: AppointmentPaymentStatus.paid,
      avatarColor: AppColors.purple,
    ),
    DashboardAppointment(
      id: "RV-5",
      initials: "RV",
      name: "Rahul Verma",
      symptoms: "Back pain, MRI review",
      dateText: "28 Feb 2025",
      timeText: "Today 6:30 PM",
      status: AppointmentStatusType.scheduled,
      consultType: "In-person",
      partnerLogoType: "HDFC",
      priceText: "₹800",
      paymentStatus: AppointmentPaymentStatus.due,
      avatarColor: AppColors.teal,
    ),
    DashboardAppointment(
      id: "NK-6",
      initials: "NK",
      name: "Nisha Kapoor",
      symptoms: "Migraine, Nausea",
      dateText: "15 Apr 2025",
      timeText: "Tomorrow",
      status: AppointmentStatusType.confirmed,
      consultType: "Tele-MER",
      partnerLogoType: "CH",
      priceText: "₹450",
      paymentStatus: AppointmentPaymentStatus.paid,
      avatarColor: AppColors.danger,
    ),
  ];

  static final List<CalendarEventModel> calendarEvents = [
    CalendarEventModel(
      id: "EVT-001",
      title: "Adrian Marshall - Consultation",
      dateTime: DateTime(2026, 6, 16, 16, 30),
      duration: const Duration(minutes: 30),
      type: CalendarEventType.consultation,
      color: AppColors.primary,
    ),
    CalendarEventModel(
      id: "EVT-002",
      title: "Kelly Stevens - Consultation",
      dateTime: DateTime(2026, 6, 16, 17, 00),
      duration: const Duration(minutes: 30),
      type: CalendarEventType.consultation,
      color: AppColors.secondary,
    ),
  ];

  static final List<FooterStatModel> footerStats = [
    FooterStatModel(
      label: "Avg Consultation Time",
      value: "18 mins",
      icon: Icons.timer_outlined,
      color: AppColors.secondary,
    ),
    FooterStatModel(
      label: "Digital Prescriptions",
      value: "42 Issued",
      icon: Icons.medication_outlined,
      color: AppColors.primary,
    ),
    FooterStatModel(
      label: "Pending Lab Reports",
      value: "7 Approvals",
      icon: Icons.biotech_outlined,
      color: AppColors.warning,
    ),
  ];
}
