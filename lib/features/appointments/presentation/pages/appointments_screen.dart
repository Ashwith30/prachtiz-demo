import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_radius.dart';

// Local Appointment model for high-fidelity schedule simulation
class LocalAppointment {
  final String id;
  final String patientName;
  final String doctorName;
  final String time; // e.g. "10:30"
  final String endTime; // e.g. "11:00"
  final String date; // "YYYY-MM-DD"
  final String type; // "Telehealth", "Check-up", "Consultation", "Follow-up", "Emergency"
  final String status; // "Confirmed", "Cancelled", "Completed", "Pending"

  LocalAppointment({
    required this.id,
    required this.patientName,
    required this.doctorName,
    required this.time,
    required this.endTime,
    required this.date,
    required this.type,
    required this.status,
  });

  LocalAppointment copyWith({
    String? id,
    String? patientName,
    String? doctorName,
    String? time,
    String? endTime,
    String? date,
    String? type,
    String? status,
  }) {
    return LocalAppointment(
      id: id ?? this.id,
      patientName: patientName ?? this.patientName,
      doctorName: doctorName ?? this.doctorName,
      time: time ?? this.time,
      endTime: endTime ?? this.endTime,
      date: date ?? this.date,
      type: type ?? this.type,
      status: status ?? this.status,
    );
  }
}

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  // Active calendar view modes: "Month", "Week", "Day"
  String _currentViewMode = "Month";
  
  // Selected day for the timeline view (defaulting to 2026-06-16 matching June 16, 2026)
  DateTime _selectedDate = DateTime(2026, 6, 16);
  DateTime _currentMonth = DateTime(2026, 6, 1);

  // Initial list of appointments across June 2026
  final List<LocalAppointment> _appointmentsList = [
    // June 14
    LocalAppointment(id: "AP-101", patientName: "Clara Jones", doctorName: "Dr. Robert Kim", time: "09:30", endTime: "10:00", date: "2026-06-14", type: "Consultation", status: "Completed"),
    
    // June 15
    LocalAppointment(id: "AP-102", patientName: "Marcus Vance", doctorName: "Dr. Sarah Mitchell", time: "10:00", endTime: "10:30", date: "2026-06-15", type: "Follow-up", status: "Completed"),
    
    // June 16
    LocalAppointment(id: "AP-103", patientName: "David Thompson", doctorName: "Dr. Michael Torres", time: "10:30", endTime: "11:00", date: "2026-06-16", type: "Telehealth", status: "Confirmed"),
    LocalAppointment(id: "AP-104", patientName: "Sophia Andersson", doctorName: "Dr. Sarah Mitchell", time: "11:00", endTime: "11:30", date: "2026-06-16", type: "Check-up", status: "Cancelled"),
    LocalAppointment(id: "AP-105", patientName: "James Okafor", doctorName: "Dr. Robert Kim", time: "11:30", endTime: "12:00", date: "2026-06-16", type: "Emergency", status: "Completed"),
    LocalAppointment(id: "AP-106", patientName: "Aisha Mahmoud", doctorName: "Dr. Michael Torres", time: "13:00", endTime: "13:30", date: "2026-06-16", type: "Consultation", status: "Confirmed"),
    
    // June 17
    LocalAppointment(id: "AP-107", patientName: "Aisha Mahmoud", doctorName: "Dr. Michael Torres", time: "13:00", endTime: "13:30", date: "2026-06-17", type: "Consultation", status: "Confirmed"),
    LocalAppointment(id: "AP-108", patientName: "Emily Watson", doctorName: "Dr. Sarah Mitchell", time: "13:30", endTime: "14:00", date: "2026-06-17", type: "Follow-up", status: "Pending"),
    
    // June 18
    LocalAppointment(id: "AP-109", patientName: "Robert Nakamura", doctorName: "Dr. Sarah Mitchell", time: "14:00", endTime: "14:30", date: "2026-06-18", type: "Telehealth", status: "Confirmed"),
    
    // June 19
    LocalAppointment(id: "AP-110", patientName: "Thomas Bergstrom", doctorName: "Dr. Robert Kim", time: "14:30", endTime: "15:00", date: "2026-06-19", type: "Check-up", status: "Confirmed"),
    
    // June 20
    LocalAppointment(id: "AP-111", patientName: "Elena Vasquez", doctorName: "Dr. Angela Park", time: "09:00", endTime: "09:30", date: "2026-06-20", type: "Check-up", status: "Confirmed"),
    LocalAppointment(id: "AP-112", patientName: "William Frost", doctorName: "Dr. Angela Park", time: "15:00", endTime: "15:30", date: "2026-06-20", type: "Consultation", status: "Confirmed"),
    
    // June 21
    LocalAppointment(id: "AP-113", patientName: "Priya Patel", doctorName: "Dr. Michael Torres", time: "15:30", endTime: "16:00", date: "2026-06-21", type: "Emergency", status: "Confirmed"),
  ];

  // Helper date utility to format DateTime to "YYYY-MM-DD"
  String _formatDateString(DateTime date) {
    String month = date.month.toString().padLeft(2, '0');
    String day = date.day.toString().padLeft(2, '0');
    return "${date.year}-$month-$day";
  }

  // Get appointments for a specific date
  List<LocalAppointment> _getAppointmentsForDate(DateTime date) {
    final String dateString = _formatDateString(date);
    return _appointmentsList.where((app) => app.date == dateString).toList();
  }

  // Get active color mapping based on type
  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case "telehealth":
        return const Color(0xFF8B5CF6); // Purple
      case "check-up":
        return const Color(0xFFF59E0B); // Orange
      case "consultation":
        return const Color(0xFF3B82F6); // Blue
      case "follow-up":
        return const Color(0xFF24C06F); // Green
      case "emergency":
        return AppColors.danger; // Red
      default:
        return AppColors.primary;
    }
  }

  // Get status color mapping
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "confirmed":
        return const Color(0xFF3B82F6);
      case "cancelled":
        return AppColors.danger;
      case "completed":
        return const Color(0xFF24C06F);
      case "pending":
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF94A3B8);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String dateStr = _formatDateString(_selectedDate);
    final List<LocalAppointment> selectedDateAppointments = _getAppointmentsForDate(_selectedDate);
    
    // Sort selected date appointments by time
    selectedDateAppointments.sort((a, b) => a.time.compareTo(b.time));

    // Summary numbers for Today
    final todayAppointments = _appointmentsList.where((app) => app.date == "2026-06-16").toList();
    final totalCount = todayAppointments.length;
    final inPersonCount = todayAppointments.where((app) => app.type != "Telehealth").length;
    final telehealthCount = todayAppointments.where((app) => app.type == "Telehealth").length;
    final cancelledCount = todayAppointments.where((app) => app.status == "Cancelled").length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.pagePaddingHorizontal,
          vertical: AppDimensions.pagePaddingVertical,
        ),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Zone: Title + Buttons Panel
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 800;
                return isWide
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildPageTitleBlock(),
                          _buildHeaderControls(),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPageTitleBlock(),
                          const SizedBox(height: 16),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            child: _buildHeaderControls(),
                          ),
                        ],
                      );
              },
            ),
            const SizedBox(height: 20),

            // Stat Cards Row
            LayoutBuilder(
              builder: (context, constraints) {
                final double width = constraints.maxWidth;
                if (width > 1100) {
                  return Row(
                    children: [
                      Expanded(child: _buildStatCard("Today's Total", totalCount.toString(), Icons.calendar_today_outlined, const Color(0xFF3B82F6))),
                      const SizedBox(width: 16),
                      Expanded(child: _buildStatCard("In-Person", inPersonCount.toString(), Icons.person_outline, const Color(0xFF3B82F6))),
                      const SizedBox(width: 16),
                      Expanded(child: _buildStatCard("Telehealth", telehealthCount.toString(), Icons.videocam_outlined, const Color(0xFF24C06F))),
                      const SizedBox(width: 16),
                      Expanded(child: _buildStatCard("Cancelled", cancelledCount.toString(), Icons.cancel_outlined, AppColors.danger)),
                    ],
                  );
                } else if (width > 600) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: _buildStatCard("Today's Total", totalCount.toString(), Icons.calendar_today_outlined, const Color(0xFF3B82F6))),
                          const SizedBox(width: 16),
                          Expanded(child: _buildStatCard("In-Person", inPersonCount.toString(), Icons.person_outline, const Color(0xFF3B82F6))),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildStatCard("Telehealth", telehealthCount.toString(), Icons.videocam_outlined, const Color(0xFF24C06F))),
                          const SizedBox(width: 16),
                          Expanded(child: _buildStatCard("Cancelled", cancelledCount.toString(), Icons.cancel_outlined, AppColors.danger)),
                        ],
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildStatCard("Today's Total", totalCount.toString(), Icons.calendar_today_outlined, const Color(0xFF3B82F6)),
                      const SizedBox(height: 12),
                      _buildStatCard("In-Person", inPersonCount.toString(), Icons.person_outline, const Color(0xFF3B82F6)),
                      const SizedBox(height: 12),
                      _buildStatCard("Telehealth", telehealthCount.toString(), Icons.videocam_outlined, const Color(0xFF24C06F)),
                      const SizedBox(height: 12),
                      _buildStatCard("Cancelled", cancelledCount.toString(), Icons.cancel_outlined, AppColors.danger),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 24),

            // Main Columns Layout
            LayoutBuilder(
              builder: (context, constraints) {
                final double width = constraints.maxWidth;
                final bool isDesktop = width > 1100;
                
                if (isDesktop) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left: Calendar Grid View
                      Expanded(
                        flex: 8,
                        child: _buildCalendarCard(),
                      ),
                      const SizedBox(width: 20),
                      // Right: Today's Schedule panel
                      Expanded(
                        flex: 3,
                        child: _buildSchedulePanel(selectedDateAppointments),
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildCalendarCard(),
                      const SizedBox(height: 20),
                      _buildSchedulePanel(selectedDateAppointments),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageTitleBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Appointments",
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF6B8EFF),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Manage your daily appointment schedule",
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderControls() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // "Today" Button
        _HeaderButton(
          label: "Today",
          icon: Icons.calendar_today_outlined,
          onTap: () {
            setState(() {
              _selectedDate = DateTime(2026, 6, 16);
              _currentMonth = DateTime(2026, 6, 1);
            });
          },
        ),
        const SizedBox(width: 12),

        // Segmented Switch Mode (Month, Week, Day)
        Container(
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFF0C0E1F),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          padding: const EdgeInsets.all(2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: ["Month", "Week", "Day"].map((mode) {
              final bool isActive = _currentViewMode == mode;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _currentViewMode = mode;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: isActive ? const Color(0xFF10183C) : Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    mode,
                    style: GoogleFonts.inter(
                      color: isActive ? Colors.white : const Color(0xFF94A3B8),
                      fontSize: 12,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(width: 12),

        // "+ New Appointment" Button
        ElevatedButton.icon(
          onPressed: () => _showNewAppointmentDialog(),
          icon: const Icon(Icons.add, size: 16, color: Colors.white),
          label: Text(
            "New Appointment",
            style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF315BFF),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 0,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF0C0E1F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: GoogleFonts.inter(
                  color: const Color(0xFF94A3B8),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0C0E1F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          // Navigation controls Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Month Heading
              Text(
                "${_getMonthName(_currentMonth.month)} ${_currentMonth.year}",
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Arrow Navigation Buttons
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
                      });
                    },
                    icon: const Icon(Icons.chevron_left, color: Color(0xFF94A3B8)),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
                      });
                    },
                    icon: const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Render view mode specific calendar structure
          _currentViewMode == "Month"
              ? _buildMonthCalendarGrid()
              : _currentViewMode == "Week"
                  ? _buildWeekCalendarGrid()
                  : _buildDayTimelineGrid(),
        ],
      ),
    );
  }

  Widget _buildMonthCalendarGrid() {
    // Standard weekday headers
    final weekdays = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"];
    final int year = _currentMonth.year;
    final int month = _currentMonth.month;

    // Grid days construction
    final firstDayOfMonth = DateTime(year, month, 1);
    final totalDays = DateTime(year, month + 1, 0).day;
    final leadingEmptyDays = firstDayOfMonth.weekday == 7 ? 0 : firstDayOfMonth.weekday; // SUN is index 7 in standard dart DateTime, but we want 0 for SUN-based layout

    // Determine grid rows count
    final totalCells = leadingEmptyDays + totalDays;
    final rowsCount = (totalCells / 7).ceil();

    return Column(
      children: [
        // Grid Weekday Headers
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: weekdays.map((day) {
            return Expanded(
              child: Center(
                child: Text(
                  day,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF64748B),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),

        // Grid Rows
        Column(
          children: List.generate(rowsCount, (rowIndex) {
            return Row(
              children: List.generate(7, (colIndex) {
                final int cellIndex = rowIndex * 7 + colIndex;
                if (cellIndex < leadingEmptyDays || cellIndex >= totalCells) {
                  // Muted day from previous or next month (simulated as empty day box)
                  return Expanded(
                    child: Container(
                      height: 90,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white.withOpacity(0.02)),
                      ),
                    ),
                  );
                } else {
                  final int day = cellIndex - leadingEmptyDays + 1;
                  final DateTime date = DateTime(year, month, day);
                  final bool isSelected = date.day == _selectedDate.day &&
                      date.month == _selectedDate.month &&
                      date.year == _selectedDate.year;

                  final List<LocalAppointment> dayApps = _getAppointmentsForDate(date);

                  return Expanded(
                    child: _CalendarDayCell(
                      dayNumber: day.toString(),
                      isSelected: isSelected,
                      appointments: dayApps,
                      onTap: () {
                        setState(() {
                          _selectedDate = date;
                        });
                      },
                    ),
                  );
                }
              }),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildWeekCalendarGrid() {
    // Shows the current selected week days (June 14 - June 20)
    final DateTime startOfWeek = _selectedDate.subtract(Duration(days: _selectedDate.weekday == 7 ? 0 : _selectedDate.weekday)); // Sunday
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(7, (index) {
            final DateTime date = startOfWeek.add(Duration(days: index));
            final bool isSelected = date.day == _selectedDate.day;
            final List<LocalAppointment> dayApps = _getAppointmentsForDate(date);
            final weekdays = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"];

            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedDate = date),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF10183C) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF315BFF).withOpacity(0.3) : Colors.white.withOpacity(0.04),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        weekdays[index],
                        style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: isSelected ? const Color(0xFF315BFF) : Colors.transparent,
                        child: Text(
                          date.day.toString(),
                          style: GoogleFonts.inter(
                            color: isSelected ? Colors.white : const Color(0xFFCBD5E1),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Dot indicators for active events
                      if (dayApps.isNotEmpty)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: dayApps.take(3).map((app) {
                            return Container(
                              width: 5,
                              height: 5,
                              margin: const EdgeInsets.symmetric(horizontal: 1),
                              decoration: BoxDecoration(
                                color: _getTypeColor(app.type),
                                shape: BoxShape.circle,
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 24),
        Text(
          "Week Schedule details for selected date",
          style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildDayTimelineGrid(),
      ],
    );
  }

  Widget _buildDayTimelineGrid() {
    final List<LocalAppointment> dayApps = _getAppointmentsForDate(_selectedDate);
    dayApps.sort((a, b) => a.time.compareTo(b.time));

    final hours = ["09:00", "10:00", "11:00", "12:00", "13:00", "14:00", "15:00", "16:00", "17:00"];

    return Column(
      children: hours.map((hour) {
        // Find if any appointment matches the hour
        final List<LocalAppointment> hourApps = dayApps.where((app) => app.time.startsWith(hour)).toList();

        return Container(
          height: 60,
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.04))),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 50,
                child: Text(
                  hour,
                  style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: hourApps.isEmpty
                    ? const SizedBox()
                    : Row(
                        children: hourApps.map((app) {
                          final Color color = _getTypeColor(app.type);
                          return Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: color.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      "${app.time} - ${app.patientName} (${app.type})",
                                      style: GoogleFonts.inter(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSchedulePanel(List<LocalAppointment> selectedDateAppointments) {
    // Show upcoming lists
    final upcomingList = _appointmentsList.where((app) {
      // Show next day or same day afternoon appointments as simulated upcoming list
      return app.date == "2026-06-16" || app.date == "2026-06-17";
    }).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0C0E1F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Today's Schedule title row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Today's Schedule",
                style: GoogleFonts.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF315BFF).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF315BFF).withOpacity(0.3)),
                ),
                child: Text(
                  "${selectedDateAppointments.length} appointments",
                  style: GoogleFonts.inter(color: const Color(0xFF6B8EFF), fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Appointment Items list
          selectedDateAppointments.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      "No appointments scheduled",
                      style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 12),
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: selectedDateAppointments.length,
                  separatorBuilder: (context, index) => Divider(color: Colors.white.withOpacity(0.04), height: 16),
                  itemBuilder: (context, index) {
                    final app = selectedDateAppointments[index];
                    final Color statusColor = _getStatusColor(app.status);
                    final Color typeColor = _getTypeColor(app.type);

                    return _InteractiveAppointmentTile(
                      appointment: app,
                      statusColor: statusColor,
                      typeColor: typeColor,
                    );
                  },
                ),
          const SizedBox(height: 24),

          // UPCOMING header
          Text(
            "UPCOMING",
            style: GoogleFonts.inter(
              color: const Color(0xFF64748B),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),

          // Upcoming Items list
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: upcomingList.take(4).length,
            itemBuilder: (context, index) {
              final app = upcomingList[index];
              Color avatarColor;
              switch (index % 4) {
                case 0:
                  avatarColor = const Color(0xFF8B5CF6);
                  break;
                case 1:
                  avatarColor = const Color(0xFFF59E0B);
                  break;
                case 2:
                  avatarColor = AppColors.danger;
                  break;
                default:
                  avatarColor = const Color(0xFF3B82F6);
              }

              // Get initials
              final names = app.patientName.split(" ");
              final String initials = names.length >= 2 ? "${names[0][0]}${names[1][0]}" : app.patientName[0];

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 15,
                      backgroundColor: avatarColor,
                      child: Text(
                        initials,
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            app.patientName,
                            style: GoogleFonts.inter(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Jun ${app.date.split('-')[2]} - ${app.time}",
                            style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
    return months[month - 1];
  }

  void _showNewAppointmentDialog() {
    final nameController = TextEditingController();
    final doctorController = TextEditingController(text: "Dr. Michael Torres");
    String selectedType = "Consultation";
    String selectedTime = "10:30";

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: const Color(0xFF0C0E1F),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.white.withOpacity(0.08)),
              ),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Book Clinic Appointment",
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: nameController,
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        labelText: "Patient Full Name",
                        labelStyle: GoogleFonts.inter(color: const Color(0xFF64748B)),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.08))),
                        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF315BFF))),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      dropdownColor: const Color(0xFF0C0E1F),
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        labelText: "Consultation Type",
                        labelStyle: GoogleFonts.inter(color: const Color(0xFF64748B)),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.08))),
                        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: const Color(0xFF315BFF))),
                      ),
                      items: ["Consultation", "Telehealth", "Check-up", "Follow-up", "Emergency"].map((t) {
                        return DropdownMenuItem(value: t, child: Text(t));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedType = val);
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedTime,
                      dropdownColor: const Color(0xFF0C0E1F),
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        labelText: "Preferred Time",
                        labelStyle: GoogleFonts.inter(color: const Color(0xFF64748B)),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.08))),
                        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: const Color(0xFF315BFF))),
                      ),
                      items: ["09:00", "09:30", "10:00", "10:30", "11:00", "11:30", "13:00", "13:30", "14:00", "14:30", "15:00", "15:30", "16:00"].map((t) {
                        return DropdownMenuItem(value: t, child: Text(t));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedTime = val);
                      },
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            "Cancel",
                            style: GoogleFonts.inter(color: const Color(0xFF64748B), fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () {
                            if (nameController.text.isNotEmpty) {
                              setState(() {
                                final String newId = "AP-${100 + _appointmentsList.length + 1}";
                                final String targetDateString = _formatDateString(_selectedDate);
                                _appointmentsList.add(LocalAppointment(
                                  id: newId,
                                  patientName: nameController.text,
                                  doctorName: doctorController.text,
                                  time: selectedTime,
                                  endTime: "${int.parse(selectedTime.split(':')[0])}:${(int.parse(selectedTime.split(':')[1]) + 30).toString().padLeft(2, '0')}",
                                  date: targetDateString,
                                  type: selectedType,
                                  status: "Pending",
                                ));
                              });
                              Navigator.pop(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF315BFF)),
                          child: Text(
                            "Book Token",
                            style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header Button Widget with hover animations
// ─────────────────────────────────────────────────────────────────────────────
class _HeaderButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  State<_HeaderButton> createState() => _HeaderButtonState();
}

class _HeaderButtonState extends State<_HeaderButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _isHovered ? Colors.white.withOpacity(0.06) : const Color(0xFF0C0E1F),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isHovered ? const Color(0xFF315BFF).withOpacity(0.3) : Colors.white.withOpacity(0.08),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, color: const Color(0xFF94A3B8), size: 14),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Calendar Day Cell Widget
// ─────────────────────────────────────────────────────────────────────────────
class _CalendarDayCell extends StatefulWidget {
  final String dayNumber;
  final bool isSelected;
  final List<LocalAppointment> appointments;
  final VoidCallback onTap;

  const _CalendarDayCell({
    required this.dayNumber,
    required this.isSelected,
    required this.appointments,
    required this.onTap,
  });

  @override
  State<_CalendarDayCell> createState() => _CalendarDayCellState();
}

class _CalendarDayCellState extends State<_CalendarDayCell> {
  bool _isHovered = false;

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case "telehealth":
        return const Color(0xFF8B5CF6);
      case "check-up":
        return const Color(0xFFF59E0B);
      case "consultation":
        return const Color(0xFF3B82F6);
      case "follow-up":
        return const Color(0xFF24C06F);
      case "emergency":
        return AppColors.danger;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 100,
          decoration: BoxDecoration(
            color: widget.isSelected
                ? const Color(0xFF10183C)
                : (_isHovered ? Colors.white.withOpacity(0.02) : Colors.transparent),
            border: Border.all(
              color: widget.isSelected
                  ? const Color(0xFF315BFF)
                  : (_isHovered ? Colors.white.withOpacity(0.12) : Colors.white.withOpacity(0.03)),
              width: widget.isSelected ? 1.2 : 0.6,
            ),
          ),
          padding: const EdgeInsets.all(6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Day number circle
              CircleAvatar(
                radius: 10,
                backgroundColor: widget.isSelected ? const Color(0xFF315BFF) : Colors.transparent,
                child: Text(
                  widget.dayNumber,
                  style: GoogleFonts.inter(
                    color: widget.isSelected ? Colors.white : const Color(0xFF94A3B8),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 6),

              // Calendar Events list inside cell
              Expanded(
                child: Column(
                  children: [
                    ...widget.appointments.take(2).map((app) {
                      final Color color = _getTypeColor(app.type);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 3),
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: color.withOpacity(0.25)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 3.5,
                              height: 3.5,
                              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                "${app.time} ${app.type}",
                                style: GoogleFonts.inter(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 8.2,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    if (widget.appointments.length > 2)
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "+${widget.appointments.length - 2} more",
                            style: GoogleFonts.inter(
                              color: const Color(0xFF64748B),
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Interactive Appointment List Tile
// ─────────────────────────────────────────────────────────────────────────────
class _InteractiveAppointmentTile extends StatefulWidget {
  final LocalAppointment appointment;
  final Color statusColor;
  final Color typeColor;

  const _InteractiveAppointmentTile({
    required this.appointment,
    required this.statusColor,
    required this.typeColor,
  });

  @override
  State<_InteractiveAppointmentTile> createState() => _InteractiveAppointmentTileState();
}

class _InteractiveAppointmentTileState extends State<_InteractiveAppointmentTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final app = widget.appointment;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()
          ..translate(0.0, _isHovered ? -2.0 : 0.0, 0.0),
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: _isHovered ? Colors.white.withOpacity(0.02) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time section (Left)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  app.time,
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                ),
                Text(
                  app.endTime,
                  style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 11),
                ),
              ],
            ),
            const SizedBox(width: 14),

            // Middle info section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    app.patientName,
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: widget.statusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: widget.statusColor.withOpacity(0.3)),
                        ),
                        child: Text(
                          app.status,
                          style: GoogleFonts.inter(color: widget.statusColor, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Type Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: widget.typeColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: widget.typeColor.withOpacity(0.3)),
                        ),
                        child: Text(
                          app.type,
                          style: GoogleFonts.inter(color: widget.typeColor, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Right doctor section
            Text(
              app.doctorName.split(" ").last, // Display last name only for space
              style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
