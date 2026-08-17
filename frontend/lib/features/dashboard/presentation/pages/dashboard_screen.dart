import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/responsive/responsive_builder.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/services/api_service.dart';
import '../../../../shared/services/auth_service.dart';

import '../../domain/models/appointment_model.dart';
import '../../domain/models/calendar_event_model.dart';
import '../../domain/models/dashboard_banner_model.dart';
import '../sections/hero_section.dart';
import '../sections/summary_section.dart';
import '../sections/appointment_section.dart';
import '../sections/calendar_section.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<DashboardAppointment> _appointments = [];
  List<CalendarEventModel> _calendarEvents = [];
  Map<String, dynamic> _summary = {};
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final apptsData = await ApiService.instance.get('/doctor/appointments');
      final summaryData = await ApiService.instance.get('/doctor/analytics/summary');

      final apiAppts = apptsData as List;
      final List<DashboardAppointment> mappedAppts = apiAppts.map((appt) {
        final name = appt['patient_name'] ?? 'Unknown';
        final time = appt['time'] ?? '12:00';
        final date = appt['date'] ?? '';
        final initials = _getInitials(name);
        final status = _parseStatus(appt['status']);
        final consultType = appt['consult_type'] ?? appt['type'] ?? 'General';
        final partnerLogoType = appt['partner_logo'] ?? '';
        final priceText = '₹${appt['price'] ?? '500'}';
        final paymentStatus = _parsePaymentStatus(appt['payment_status']);
        final avatarColor = _getAvatarColor(name);

        return DashboardAppointment(
          id: appt['id']?.toString() ?? '',
          initials: initials,
          name: name,
          symptoms: appt['symptoms'] ?? '',
          timeText: 'Today $time',
          status: status,
          consultType: consultType,
          partnerLogoType: partnerLogoType,
          priceText: priceText,
          paymentStatus: paymentStatus,
          avatarColor: avatarColor,
          dateText: date,
        );
      }).toList();

      final mappedEvents = _mapCalendarEvents(apiAppts);

      if (mounted) {
        setState(() {
          _appointments = mappedAppts;
          _calendarEvents = mappedEvents;
          _summary = summaryData as Map<String, dynamic>;
          _loading = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Connection error. Is the server running?';
          _loading = false;
        });
      }
    }
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return 'P';
    if (parts.length == 1) return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : 'P';
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }

  AppointmentStatusType _parseStatus(String? status) {
    switch (status) {
      case 'inProgress':
        return AppointmentStatusType.inProgress;
      case 'confirmed':
      case 'completed':
        return AppointmentStatusType.confirmed;
      case 'pending':
      case 'scheduled':
      default:
        return AppointmentStatusType.scheduled;
    }
  }

  AppointmentPaymentStatus _parsePaymentStatus(String? status) {
    if (status?.toLowerCase() == 'paid') {
      return AppointmentPaymentStatus.paid;
    }
    return AppointmentPaymentStatus.due;
  }

  Color _getAvatarColor(String name) {
    final colors = [
      const Color(0xFF3F8CFF),
      const Color(0xFF8B5CF6),
      const Color(0xFF24C06F),
      const Color(0xFFF59E0B),
    ];
    final hash = name.codeUnits.fold(0, (prev, element) => prev + element);
    return colors[hash % colors.length];
  }

  List<CalendarEventModel> _mapCalendarEvents(List<dynamic> appts) {
    return appts.map((appt) {
      final name = appt['patient_name'] ?? 'Unknown';
      final dateStr = appt['date'] ?? ''; // YYYY-MM-DD
      final timeStr = appt['time'] ?? '12:00'; // HH:MM
      
      DateTime? dt;
      try {
        final dateParts = dateStr.split('-');
        final timeParts = timeStr.split(':');
        dt = DateTime(
          int.parse(dateParts[0]),
          int.parse(dateParts[1]),
          int.parse(dateParts[2]),
          int.parse(timeParts[0]),
          int.parse(timeParts[1]),
        );
      } catch (_) {
        dt = DateTime.now();
      }

      return CalendarEventModel(
        id: appt['id']?.toString() ?? '',
        title: '$name - ${appt['type'] ?? 'Consultation'}',
        dateTime: dt!,
        duration: const Duration(minutes: 30),
        type: CalendarEventType.consultation,
        color: appt['type']?.toString().toLowerCase().contains('tele') == true
            ? AppColors.primary
            : AppColors.secondary,
      );
    }).toList();
  }

  // Format date helper for today's banner
  String _formatTodayText() {
    final now = DateTime.now();
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final weekdays = ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'];
    return '${weekdays[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthService.instance;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    margin: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error!, style: GoogleFonts.inter(fontSize: 14, color: Colors.red.shade300)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.pagePaddingHorizontal,
                      vertical: AppDimensions.pagePaddingVertical,
                    ),
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: ResponsiveBuilder(
                      builder: (context, deviceType) {
                        final isDesktop = deviceType.isDesktop;
                        final screenWidth = MediaQuery.sizeOf(context).width;
                        final dashboardGap = screenWidth < 700 ? 16.0 : 20.0;
                        final queueHeight = screenWidth >= 1400 ? 640.0 : 612.0;

                        // Build banner model dynamically
                        final bannerModel = DashboardBannerModel(
                          greeting: "Today's Schedule",
                          dateRangeText: _formatTodayText(),
                          shiftText: "9:00 AM - 12:00 PM",
                          locationText: auth.session?.profile['specialty'] ?? "General Physician",
                          loginTimeText: "Dr. ${auth.session?.fullName ?? ''}",
                        );

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Hero / Schedule Banner Section
                            HeroSection(bannerData: bannerModel)
                                .animate()
                                .fadeIn(duration: 400.ms)
                                .slideY(begin: -0.05, end: 0, curve: Curves.easeOutQuad),
                            SizedBox(height: dashboardGap),

                            // 2. Summary / Metrics Section
                            SummarySection(
                              appointmentsToday: _summary['appointmentsToday'] ?? 0,
                              upcomingThisWeek: _summary['appointmentsThisWeek'] ?? 0,
                              videoConsultations: _summary['videoConsultations'] ?? 0,
                              walkInAppointments: _summary['walkInAppointments'] ?? 0,
                              firstTimePatients: _summary['firstTimePatients'] ?? 0,
                              repeatPatients: _summary['repeatPatients'] ?? 0,
                              rescheduled: _summary['rescheduled'] ?? 0,
                              cancelled: _summary['cancelled'] ?? 0,
                            )
                                .animate()
                                .fadeIn(delay: 150.ms, duration: 400.ms)
                                .slideY(begin: 0.05, end: 0, curve: Curves.easeOutQuad),
                            SizedBox(height: dashboardGap),

                            // 3. Columns: Calendar Section and Appointment Queue
                            if (isDesktop)
                              SizedBox(
                                height: queueHeight,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      flex: 5,
                                      child: CalendarSection(events: _calendarEvents),
                                    ),
                                    SizedBox(width: dashboardGap),
                                    Expanded(
                                      flex: 7,
                                      child: AppointmentSection(appointments: _appointments),
                                    ),
                                  ],
                                ),
                              )
                                  .animate()
                                  .fadeIn(delay: 250.ms, duration: 450.ms)
                                  .slideY(begin: 0.05, end: 0, curve: Curves.easeOutQuad)
                            else
                              Column(
                                children: [
                                  CalendarSection(events: _calendarEvents),
                                  SizedBox(height: dashboardGap),
                                  AppointmentSection(appointments: _appointments),
                                ],
                              )
                                  .animate()
                                  .fadeIn(delay: 250.ms, duration: 450.ms)
                                  .slideY(begin: 0.05, end: 0, curve: Curves.easeOutQuad),
                          ],
                        );
                      },
                    ),
                  ),
                ),
    );
  }
}
