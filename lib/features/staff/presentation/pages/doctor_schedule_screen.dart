import "package:prachtiz_flutter/core/theme/app_colors.dart";
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../theme/colors.dart';
import '../../../../theme/styles.dart';

// High-fidelity active doctor shift model
class DoctorShift {
  final String id;
  final String dayName; // "MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"
  final String type;    // "Morning", "Afternoon", "Evening", "OPD", "CPD"
  final String time;    // "9:00 - 12:00" or "" for no time display
  final bool isAvailable; // true: AVAILABLE, false: BUSY
  final String? room;

  DoctorShift({
    required this.id,
    required this.dayName,
    required this.type,
    required this.time,
    this.isAvailable = true,
    this.room,
  });
}

class DoctorScheduleScreen extends StatefulWidget {
  @override
  State<DoctorScheduleScreen> createState() => _DoctorScheduleScreenState();
}

class _DoctorScheduleScreenState extends State<DoctorScheduleScreen> {
  // Seeded calendar start dates (Aligned to Monday June 16, 2025, to match the real calendar)
  DateTime _startOfWeek = DateTime(2025, 6, 16);
  String _activeView = "Week"; // "Day", "Week", "Month"
  String _weeklySubView = "Week View"; // "Week View", "Day View"
  String _selectedDayName = "FRI";
  bool _isEditingRoster = false;

  // Roster schedule items matching mockup
  final List<DoctorShift> _shifts = [
    // Mon 16
    DoctorShift(id: "1", dayName: "MON", type: "Morning", time: "9:00 - 12:00", isAvailable: true),
    DoctorShift(id: "2", dayName: "MON", type: "Afternoon", time: "14:00 - 18:00", isAvailable: false, room: "Room 201"),
    // Tue 17
    DoctorShift(id: "3", dayName: "TUE", type: "Morning", time: "8:00 - 11:00", isAvailable: true),
    DoctorShift(id: "4", dayName: "TUE", type: "Evening", time: "18:00 - 22:00", isAvailable: true),
    // Wed 18
    DoctorShift(id: "5", dayName: "WED", type: "Afternoon", time: "12:00 - 17:00", isAvailable: false),
    // Thu 19
    DoctorShift(id: "6", dayName: "THU", type: "Morning", time: "9:00 - 12:00", isAvailable: true),
    DoctorShift(id: "7", dayName: "THU", type: "Afternoon", time: "14:00 - 18:00", isAvailable: true),
    // Fri 20
    DoctorShift(id: "8", dayName: "FRI", type: "Morning", time: "9:00 - 12:00", isAvailable: false),
    DoctorShift(id: "9", dayName: "FRI", type: "CPD", time: "", isAvailable: true),
    // Sat 21
    DoctorShift(id: "10", dayName: "SAT", type: "Afternoon", time: "14:00 - 18:00", isAvailable: true),
    // Sun 22 (Day Off)
  ];

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    // Dynamically compute KPI counters based on active shifts roster
    final int morningShiftsCount = _shifts.where((s) => s.type == "Morning").length;
    final int afternoonShiftsCount = _shifts.where((s) => s.type == "Afternoon").length;
    final int shiftsTodayCount = _shifts.where((s) => s.dayName == _selectedDayName).length;
    final String shiftsTodayStr = shiftsTodayCount < 10 ? "0$shiftsTodayCount" : "$shiftsTodayCount";

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Header Title, Subtitle and View Toggles matching mockup
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Doctor Schedule",
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.gray900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Manage your Schedule",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF24C06F),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                // Day / Week / Month Toggle and Edit/Add Button
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeaderToggles(),
                    const SizedBox(width: 12),
                    _buildEditAddButton(),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Roster KPI cards row
            _buildKPICards(morningShiftsCount, afternoonShiftsCount, shiftsTodayStr),
            const SizedBox(height: 24),

            // Main Weekly Planner card container
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF11152D),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Weekly/Monthly/Daily Schedule Header Toolbar
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _activeView == "Month"
                              ? "Monthly Schedule"
                              : (_activeView == "Day" ? "Daily Schedule" : "Weekly Schedule"),
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // Calendar date range picker
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chevron_left, color: Colors.white70, size: 18),
                              onPressed: _navigatePrevious,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatToolbarDate(),
                              style: GoogleFonts.inter(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.chevron_right, color: Colors.white70, size: 18),
                              onPressed: _navigateNext,
                            ),
                          ],
                        ),
                        // Week/Day view toggle controls & + Add Shift
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_activeView != "Month") ...[
                              _buildSubViewToggles(),
                              const SizedBox(width: 12),
                            ],
                            ElevatedButton.icon(
                              onPressed: _showAddShiftDialog,
                              icon: const Icon(Icons.add, size: 14, color: Colors.white),
                              label: Text(
                                "+ Add Shift",
                                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF24C06F),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const Divider(color: Colors.white12, height: 1),

                  // Calendar View Body (Month, Week Grid or Day list)
                  if (_activeView == "Month")
                    _buildMonthViewGrid()
                  else if (_weeklySubView == "Week View")
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: SizedBox(
                            width: math.max(900.0, constraints.maxWidth),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
                              child: IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: List.generate(7, (i) => Expanded(child: _buildDayColumn(i))),
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _buildSingleDayView(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderToggles() {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3E),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ["Day", "Week", "Month"].map((view) {
          final bool isSelected = _activeView == view;
          return GestureDetector(
            onTap: () => setState(() {
              _activeView = view;
              if (view == "Day") {
                _weeklySubView = "Day View";
              } else if (view == "Week") {
                _weeklySubView = "Week View";
              }
            }),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                view,
                style: GoogleFonts.inter(
                  color: isSelected ? Colors.white : Colors.white60,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEditAddButton() {
    return InkWell(
      onTap: () => setState(() => _isEditingRoster = !_isEditingRoster),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: _isEditingRoster ? const Color(0xFFEF4444) : const Color(0xFF1A1F3E),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isEditingRoster ? Icons.done : Icons.edit_outlined,
              size: 13,
              color: Colors.white,
            ),
            const SizedBox(width: 6),
            Text(
              _isEditingRoster ? "Done" : "Edit/Add",
              style: GoogleFonts.inter(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubViewToggles() {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3E),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ["Week View", "Day View"].map((subView) {
          final bool isSelected = _weeklySubView == subView;
          return GestureDetector(
            onTap: () => setState(() {
              _weeklySubView = subView;
              if (subView == "Day View") {
                _activeView = "Day";
              } else {
                _activeView = "Week";
              }
            }),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                subView,
                style: GoogleFonts.inter(
                  color: isSelected ? Colors.white : Colors.white60,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildKPICards(int morningCount, int afternoonCount, String shiftsTodayStr) {
    final double screenWidth = MediaQuery.of(context).size.width;

    final List<Widget> cards = [
      _InteractiveKPICard(label: "Total Shifts Today", value: shiftsTodayStr, icon: Icons.access_time, color: AppColors.primary),
      _InteractiveKPICard(label: "Morning Shifts", value: "9 AM - 12 PM", subtitle: "$morningCount shifts scheduled", icon: Icons.wb_sunny_outlined, color: const Color(0xFFF59E0B)),
      _InteractiveKPICard(label: "Afternoon Shifts", value: "2 PM - 6 PM", subtitle: "$afternoonCount shifts scheduled", icon: Icons.nights_stay_outlined, color: const Color(0xFF8B5CF6)),
      _InteractiveKPICard(label: "Next Week Shifts", value: "${_shifts.length}", icon: Icons.calendar_today_outlined, color: const Color(0xFF0EA5E9)),
      const _InteractiveKPICard(label: "Weekly Offs Scheduled", value: "01", icon: Icons.event_busy_outlined, color: Color(0xFFEF4444)),
      const _InteractiveKPICard(label: "Overlapping Appointments", value: "0", icon: Icons.block, color: Color(0xFF24C06F)),
    ];

    if (screenWidth < 650) {
      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.3,
        children: cards,
      );
    } else if (screenWidth < 1200) {
      return GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.5,
        children: cards,
      );
    } else {
      return Row(
        children: cards.map((c) => Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: c,
          ),
        )).toList(),
      );
    }
  }

  Widget _buildDayColumn(int index) {
    final DateTime dayDate = _startOfWeek.add(Duration(days: index));
    final String dayName = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"][index];
    final int dateNum = dayDate.day;

    // Filter shifts for this day key
    final dayShifts = _shifts.where((s) => s.dayName == dayName).toList();
    final bool isSelectedDay = dayName == _selectedDayName;

    return GestureDetector(
      onTap: () => setState(() => _selectedDayName = dayName),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        decoration: BoxDecoration(
          color: isSelectedDay ? Colors.white.withOpacity(0.015) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelectedDay ? const Color(0xFFF59E0B) : Colors.transparent,
            width: 1.5,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: Column(
          children: [
            // Day Header
            Text(
              dayName,
              style: GoogleFonts.inter(
                color: isSelectedDay ? Colors.white70 : Colors.white54,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelectedDay ? const Color(0xFF1E2548) : Colors.transparent,
                shape: BoxShape.circle,
                border: isSelectedDay ? Border.all(color: const Color(0xFFF59E0B), width: 1.2) : null,
              ),
              alignment: Alignment.center,
              child: Text(
                "$dateNum",
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Divider(color: Colors.white12, height: 1),
            const SizedBox(height: 8),

            // Day Off Placeholder or Shifts list
            if (dayShifts.isEmpty)
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.weekend_outlined, color: Colors.white24, size: 22),
                        const SizedBox(height: 6),
                        Text("Day Off", style: GoogleFonts.inter(color: Colors.white24, fontSize: 10)),
                      ],
                    ),
                  ),
                ),
              )
            else
              ...dayShifts.map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: _buildShiftCard(s),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildShiftCard(DoctorShift shift) {
    // Generate card gradient based on availability status and shift type
    final Color topGlowColor;
    if (!shift.isAvailable) {
      topGlowColor = const Color(0xFFEF4444); // Busy
    } else {
      switch (shift.type) {
        case "Morning":
        case "OPD":
        case "CPD":
          topGlowColor = const Color(0xFF24C06F);
          break;
        case "Afternoon":
          topGlowColor = const Color(0xFF0EA5E9);
          break;
        case "Evening":
          topGlowColor = const Color(0xFF8B5CF6);
          break;
        default:
          topGlowColor = const Color(0xFF24C06F);
      }
    }

    final Color statusColor = shift.isAvailable ? const Color(0xFF24C06F) : const Color(0xFFEF4444);
    final Color statusBgColor = shift.isAvailable ? const Color(0xFFDCFCE7).withOpacity(0.12) : const Color(0xFFFEE2E2).withOpacity(0.12);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [topGlowColor.withOpacity(0.15), const Color(0xFF15193B)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(shift.type, style: GoogleFonts.inter(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              if (shift.time.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(shift.time, style: GoogleFonts.inter(color: Colors.white54, fontSize: 9)),
              ],
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: statusColor.withOpacity(0.2)),
                    ),
                    child: Text(
                      shift.isAvailable ? "AVAILABLE" : "BUSY",
                      style: GoogleFonts.inter(color: statusColor, fontSize: 7, fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (shift.room != null)
                    Text(shift.room!, style: GoogleFonts.inter(color: Colors.white30, fontSize: 7.5)),
                ],
              ),
            ],
          ),
          if (_isEditingRoster)
            Positioned(
              right: 0,
              top: 0,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _shifts.removeWhere((s) => s.id == shift.id);
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 10, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSingleDayView() {
    final String currentDayName = _selectedDayName;
    final dayShifts = _shifts.where((s) => s.dayName == currentDayName).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Timeline of shifts for $currentDayName:",
          style: GoogleFonts.inter(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (dayShifts.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.weekend_outlined, color: Colors.white24, size: 36),
                  const SizedBox(height: 8),
                  Text("No active shifts scheduled. Enjoy the day off!", style: GoogleFonts.inter(color: Colors.white30, fontSize: 12)),
                ],
              ),
            ),
          )
        else
          ...dayShifts.map((s) {
            final Color statusColor = s.isAvailable ? const Color(0xFF24C06F) : const Color(0xFFEF4444);
            return Card(
              color: const Color(0xFF1A1F3E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.white.withOpacity(0.08)),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: statusColor.withOpacity(0.12),
                  child: Icon(Icons.watch_later_outlined, color: statusColor, size: 18),
                ),
                title: Text(s.type, style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                subtitle: Text("Time: ${s.time.isNotEmpty ? s.time : 'No specific time'} ${s.room != null ? '• ${s.room}' : ''}", style: GoogleFonts.inter(color: Colors.white54, fontSize: 11)),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    s.isAvailable ? "AVAILABLE" : "BUSY",
                    style: GoogleFonts.inter(color: statusColor, fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildMonthViewGrid() {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 800;

    final monthDate = DateTime(_startOfWeek.year, _startOfWeek.month, 1);
    final int daysInMonth = DateTime(_startOfWeek.year, _startOfWeek.month + 1, 0).day;
    final int startEmptySlots = monthDate.weekday == 7 ? 0 : monthDate.weekday;
    final List<String> weekdays = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: weekdays.map((w) => Expanded(
              child: Center(
                child: Text(
                  w,
                  style: GoogleFonts.inter(
                    color: Colors.white54,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )).toList(),
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: isMobile ? 1.0 : 1.3,
            ),
            itemCount: startEmptySlots + daysInMonth,
            itemBuilder: (context, index) {
              if (index < startEmptySlots) {
                return const SizedBox.shrink();
              }

              final int dayNum = index - startEmptySlots + 1;
              final DateTime tileDate = DateTime(_startOfWeek.year, _startOfWeek.month, dayNum);
              final String dayName = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"][tileDate.weekday - 1];
              final dayShifts = _shifts.where((s) => s.dayName == dayName).toList();

              final selectedDayIndex = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"].indexOf(_selectedDayName);
              final selectedDate = _startOfWeek.add(Duration(days: selectedDayIndex));
              final bool isSelected = tileDate.year == selectedDate.year &&
                                      tileDate.month == selectedDate.month &&
                                      tileDate.day == selectedDate.day;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _startOfWeek = _alignToMonday(tileDate);
                    _selectedDayName = dayName;
                    _activeView = "Day";
                    _weeklySubView = "Day View";
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary.withOpacity(0.15) : Color(0xFF15193B),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.04),
                      width: isSelected ? 1.5 : 1.0,
                    ),
                  ),
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "$dayNum",
                        style: GoogleFonts.inter(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Shifts layout
                      if (dayShifts.isNotEmpty)
                        Expanded(
                          child: isMobile
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: dayShifts.take(3).map((s) {
                                    final Color dotColor = s.isAvailable
                                        ? ((s.type == "Morning" || s.type == "CPD" || s.type == "OPD") ? const Color(0xFF24C06F) : const Color(0xFF0EA5E9))
                                        : const Color(0xFFEF4444);
                                    return Container(
                                      width: 5,
                                      height: 5,
                                      margin: const EdgeInsets.only(right: 3, bottom: 2),
                                      decoration: BoxDecoration(
                                        color: dotColor,
                                        shape: BoxShape.circle,
                                      ),
                                    );
                                  }).toList(),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: dayShifts.take(2).map((s) {
                                    final Color statusColor = s.isAvailable
                                        ? ((s.type == "Morning" || s.type == "CPD" || s.type == "OPD") ? const Color(0xFF24C06F) : const Color(0xFF0EA5E9))
                                        : const Color(0xFFEF4444);
                                    return Container(
                                      margin: const EdgeInsets.only(top: 2),
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: statusColor.withOpacity(0.2)),
                                      ),
                                      child: Text(
                                        s.type,
                                        style: GoogleFonts.inter(
                                          color: statusColor,
                                          fontSize: 8.5,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList(),
                                ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showAddShiftDialog() {
    String dayName = "MON";
    String shiftType = "Morning";
    String time = "09:00 - 12:00";
    bool isAvailable = true;
    String room = "";

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF0C0E1F),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.white.withOpacity(0.08)),
              ),
              title: Text(
                "+ Plan New Shift",
                style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<String>(
                    dropdownColor: const Color(0xFF0C0E1F),
                    value: dayName,
                    onChanged: (val) => setDialogState(() => dayName = val!),
                    decoration: _buildInputDecoration("Roster Day"),
                    items: ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]
                        .map((d) => DropdownMenuItem(value: d, child: Text(d, style: GoogleFonts.inter(color: Colors.white))))
                        .toList(),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    dropdownColor: const Color(0xFF0C0E1F),
                    value: shiftType,
                    onChanged: (val) => setDialogState(() => shiftType = val!),
                    decoration: _buildInputDecoration("Shift Roster Type"),
                    items: ["Morning", "Afternoon", "Evening", "OPD", "CPD"]
                        .map((t) => DropdownMenuItem(value: t, child: Text(t, style: GoogleFonts.inter(color: Colors.white))))
                        .toList(),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    initialValue: time,
                    onChanged: (val) => time = val,
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                    decoration: _buildInputDecoration("Shift Time Range"),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    initialValue: room,
                    onChanged: (val) => room = val,
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                    decoration: _buildInputDecoration("Room Number (Optional)"),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Shift Availability Status:", style: GoogleFonts.inter(color: Colors.white70, fontSize: 11)),
                      Switch(
                        value: isAvailable,
                        activeColor: const Color(0xFF24C06F),
                        onChanged: (val) => setDialogState(() => isAvailable = val),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel", style: GoogleFonts.inter(color: Colors.white54, fontSize: 12)),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _shifts.add(DoctorShift(
                        id: math.Random().nextInt(1000).toString(),
                        dayName: dayName,
                        type: shiftType,
                        time: time,
                        isAvailable: isAvailable,
                        room: room.isNotEmpty ? room : null,
                      ));
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: const Color(0xFF24C06F),
                        content: Text("Shift successfully added to EMR roster.", style: GoogleFonts.inter(color: Colors.white)),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  child: Text("Save", style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.inter(color: AppColors.gray400, fontSize: 11),
      filled: true,
      fillColor: const Color(0xFF1E2548),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
        borderRadius: BorderRadius.circular(6),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.primary),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }

  String _formatToolbarDate() {
    final months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
    final monthName = months[_startOfWeek.month - 1];

    if (_activeView == "Month") {
      return "$monthName ${_startOfWeek.year}";
    } else if (_activeView == "Day") {
      final days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];
      final selectedDayIndex = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"].indexOf(_selectedDayName);
      final selectedDate = _startOfWeek.add(Duration(days: selectedDayIndex));
      final dayOfWeekName = days[selectedDate.weekday - 1];
      return "$dayOfWeekName, ${months[selectedDate.month - 1]} ${selectedDate.day}, ${selectedDate.year}";
    } else {
      final end = _startOfWeek.add(const Duration(days: 6));
      final startMonthShort = monthName.substring(0, math.min(4, monthName.length));
      final endMonthName = months[end.month - 1];
      final endMonthShort = endMonthName.substring(0, math.min(4, endMonthName.length));

      if (_startOfWeek.month == end.month) {
        return "$monthName ${_startOfWeek.day} - ${end.day}, ${_startOfWeek.year}";
      } else {
        return "$startMonthShort ${_startOfWeek.day} - $endMonthShort ${end.day}, ${_startOfWeek.year}";
      }
    }
  }

  void _navigatePrevious() {
    setState(() {
      if (_activeView == "Month") {
        _startOfWeek = DateTime(_startOfWeek.year, _startOfWeek.month - 1, 1);
        _startOfWeek = _alignToMonday(_startOfWeek);
      } else if (_activeView == "Day") {
        final selectedDayIndex = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"].indexOf(_selectedDayName);
        final newDate = _startOfWeek.add(Duration(days: selectedDayIndex - 1));
        _startOfWeek = _alignToMonday(newDate);
        _selectedDayName = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"][newDate.weekday - 1];
      } else {
        _startOfWeek = _startOfWeek.subtract(const Duration(days: 7));
      }
    });
  }

  void _navigateNext() {
    setState(() {
      if (_activeView == "Month") {
        _startOfWeek = DateTime(_startOfWeek.year, _startOfWeek.month + 1, 1);
        _startOfWeek = _alignToMonday(_startOfWeek);
      } else if (_activeView == "Day") {
        final selectedDayIndex = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"].indexOf(_selectedDayName);
        final newDate = _startOfWeek.add(Duration(days: selectedDayIndex + 1));
        _startOfWeek = _alignToMonday(newDate);
        _selectedDayName = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"][newDate.weekday - 1];
      } else {
        _startOfWeek = _startOfWeek.add(const Duration(days: 7));
      }
    });
  }

  DateTime _alignToMonday(DateTime date) {
    int daysToSubtract = date.weekday - 1;
    return date.subtract(Duration(days: daysToSubtract));
  }
}

class _InteractiveKPICard extends StatefulWidget {
  final String label;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color color;

  const _InteractiveKPICard({
    Key? key,
    required this.label,
    required this.value,
    this.subtitle,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  State<_InteractiveKPICard> createState() => _InteractiveKPICardState();
}

class _InteractiveKPICardState extends State<_InteractiveKPICard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()..translate(0.0, _isHovered ? -4.0 : 0.0),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF11152D),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isHovered ? widget.color.withOpacity(0.3) : Colors.white.withOpacity(0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? widget.color.withOpacity(0.08)
                  : Colors.black.withOpacity(0.04),
              blurRadius: _isHovered ? 16 : 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.label,
                    style: GoogleFonts.inter(
                      fontSize: 9.5,
                      color: const Color(0xFF94A3B8),
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    widget.value,
                    style: GoogleFonts.inter(
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (widget.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      widget.subtitle!,
                      style: GoogleFonts.inter(
                        fontSize: 8.5,
                        color: Colors.white38,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 4),
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: widget.color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                widget.icon,
                color: widget.color,
                size: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
