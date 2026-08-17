import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../domain/models/calendar_event_model.dart';

const _kPanelBg = Color(0xFF0F172A);
const _kPanelBorder = Color(0xFF1E293B);
const _kBrandBlue = Color(0xFF315BFF);
const _kBrandGreen = Color(0xFF24C06F);
const _kMutedText = Color(0xFF94A3B8);

class CalendarSection extends StatefulWidget {
  final List<CalendarEventModel> events;

  const CalendarSection({
    super.key,
    required this.events,
  });

  @override
  State<CalendarSection> createState() => _CalendarSectionState();
}

class _CalendarSectionState extends State<CalendarSection> {
  DateTime _selectedDate = DateTime(2026, 6, 16);

  // June 2026: 1st is a Monday, 30 days total
  final int _daysInMonth = 30;
  final int _startWeekdayOffset =
      1; // Monday starts at index 1 in standard US grid (Sunday = 0)

  // Days with active appointments for dot markers
  final Set<int> _daysWithAppointments = {10, 11, 16, 17, 18, 24, 25};

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: _kPanelBg,
      border: Border.all(color: Colors.white.withOpacity(0.08), width: 1.0),
      borderRadius: AppRadius.radius18,
      padding: const EdgeInsets.all(22.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Calendar Header: Month + Year and Navigation
          SizedBox(
            height: 44,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "June 2026",
                  style: AppTypography.sectionTitle.copyWith(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Row(
                  children: [
                    _CalendarNavButton(
                      icon: Icons.chevron_left,
                      onPressed: () {},
                    ),
                    const SizedBox(width: 8),
                    _CalendarNavButton(
                      icon: Icons.chevron_right,
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Weekday Headings (SUN, MON...)
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _WeekdayLabel("SUN"),
              _WeekdayLabel("MON"),
              _WeekdayLabel("TUE"),
              _WeekdayLabel("WED"),
              _WeekdayLabel("THU"),
              _WeekdayLabel("FRI"),
              _WeekdayLabel("SAT"),
            ],
          ),
          const SizedBox(height: 10),

          // Calendar Days Grid
          _buildDaysGrid(),

          const SizedBox(height: 16),

          // Legend Row
          Row(
            children: [
              _buildLegendItem(_kBrandBlue, "Today"),
              const SizedBox(width: 16),
              _buildLegendItem(_kBrandGreen, "Has Appointments"),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(color: _kPanelBorder, height: 1),
          const SizedBox(height: 14),

          // Bottom Count & Channel Progress Bars
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "16 Jun",
                style: AppTypography.bodySemibold.copyWith(
                  color: Colors.white,
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                "13 appointments",
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Channel Breakdown List
          _buildBreakdownRow("SBI", 4, _kBrandBlue,
              logoAsset: AppAssets.logoSbi),
          const SizedBox(height: 12),
          _buildBreakdownRow("HDFC", 3, const Color(0xFF0EA5E9),
              logoAsset: AppAssets.logoHdfc),
          const SizedBox(height: 12),
          _buildBreakdownRow("CallHealth", 3, _kBrandGreen,
              logoAsset: AppAssets.logoCallHealth),
          const SizedBox(height: 12),
          _buildBreakdownRow("Private", 3, const Color(0xFF64748B)),
        ],
      ),
    );
  }

  Widget _buildDaysGrid() {
    List<Widget> dayCells = [];

    // Pre-fill empty spacer cells for weekday start offset (Monday = index 1)
    for (int i = 0; i < _startWeekdayOffset; i++) {
      dayCells.add(const Expanded(child: SizedBox()));
    }

    // Add cells for each day of the month
    for (int day = 1; day <= _daysInMonth; day++) {
      final isSelected = day == _selectedDate.day;
      final isToday = day == 16;
      final hasAppointments = _daysWithAppointments.contains(day);

      dayCells.add(
        Expanded(
          child: _CalendarDayCell(
            day: day,
            isSelected: isSelected,
            isToday: isToday,
            hasAppointments: hasAppointments,
            onTap: () {
              setState(() {
                _selectedDate = DateTime(2026, 6, day);
              });
            },
          ),
        ),
      );
    }

    // Post-fill empty spacer cells to complete the 7-column layout if needed
    int totalCellsCount = dayCells.length;
    int remainingCells = (7 - (totalCellsCount % 7)) % 7;
    for (int i = 0; i < remainingCells; i++) {
      dayCells.add(const Expanded(child: SizedBox()));
    }

    // Chunk cells into rows of 7
    List<Widget> gridRows = [];
    for (int i = 0; i < dayCells.length; i += 7) {
      gridRows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: dayCells.sublist(i, i + 7),
        ),
      );
    }

    return Column(
      children: [
        for (int i = 0; i < gridRows.length; i++) ...[
          gridRows[i],
          if (i < gridRows.length - 1) const SizedBox(height: 2),
        ],
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(-8 * (1.0 - value), 0),
            child: child,
          ),
        );
      },
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              color: const Color(0xFF94A3B8),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(
    String label,
    int count,
    Color color, {
    String? logoAsset,
  }) {
    final leadingWidget = _ChannelLogoChip(
      label: label,
      logoAsset: logoAsset,
      color: color,
    );
    final barFraction = count / 13.0;

    return Row(
      children: [
        _HoverLogo(child: leadingWidget),
        const SizedBox(width: 12),
        SizedBox(
          width: 76,
          child: Text(
            label,
            style: GoogleFonts.inter(
              color: const Color(0xFFCBD5E1),
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 6,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: barFraction),
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeOutCubic,
                builder: (context, val, child) {
                  return LinearProgressIndicator(
                    value: val,
                    backgroundColor: _kPanelBorder,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Text(
          count.toString(),
          style: GoogleFonts.inter(
            color: const Color(0xFFCBD5E1),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _WeekdayLabel extends StatelessWidget {
  final String label;

  const _WeekdayLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(
          color: const Color(0xFF64748B),
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _CalendarNavButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _CalendarNavButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  State<_CalendarNavButton> createState() => _CalendarNavButtonState();
}

class _CalendarNavButtonState extends State<_CalendarNavButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: _hovered
                ? Colors.white.withOpacity(0.08)
                : Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: Colors.white.withOpacity(_hovered ? 0.14 : 0.08)),
          ),
          child: Icon(widget.icon,
              color: _hovered ? Colors.white : _kMutedText, size: 20),
        ),
      ),
    );
  }
}

class _CalendarDayCell extends StatefulWidget {
  final int day;
  final bool isSelected;
  final bool isToday;
  final bool hasAppointments;
  final VoidCallback onTap;

  const _CalendarDayCell({
    required this.day,
    required this.isSelected,
    required this.isToday,
    required this.hasAppointments,
    required this.onTap,
  });

  @override
  State<_CalendarDayCell> createState() => _CalendarDayCellState();
}

class _CalendarDayCellState extends State<_CalendarDayCell> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Feedback.forTap(context);
          widget.onTap();
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 1),
          height: 40,
          color: Colors.transparent, // Transparent outer cell
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Isolated 32x32 container for date number selection / hover
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: widget.isSelected
                    ? const BoxDecoration(
                        color: _kBrandBlue,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x66315BFF),
                            blurRadius: 6,
                            offset: Offset(0, 1.5),
                          ),
                        ],
                      )
                    : BoxDecoration(
                        color: _isHovered
                            ? Colors.white.withOpacity(0.08)
                            : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: GoogleFonts.inter(
                    color: widget.isSelected
                        ? Colors.white
                        : (widget.isToday
                            ? _kBrandBlue
                            : const Color(0xFFCBD5E1)),
                    fontSize: 12,
                    fontWeight: widget.isSelected || widget.isToday
                        ? FontWeight.bold
                        : FontWeight.w500,
                  ),
                  child: Text(widget.day.toString()),
                ),
              ),
              const SizedBox(height: 4),
              // Appointment indicator dot (always below/outside the selection circle)
              SizedBox(
                height: 5,
                child: widget.hasAppointments
                    ? Container(
                        width: widget.isSelected ? 12 : 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          color: _kBrandGreen,
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                        ),
                      )
                    : const SizedBox(width: 5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChannelLogoChip extends StatelessWidget {
  final String label;
  final String? logoAsset;
  final Color color;

  const _ChannelLogoChip({
    required this.label,
    required this.logoAsset,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: logoAsset == null ? color.withOpacity(0.12) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: logoAsset == null
              ? color.withOpacity(0.34)
              : Colors.white.withOpacity(0.92),
        ),
      ),
      alignment: Alignment.center,
      child: logoAsset == null
          ? const Icon(Icons.person_outline, size: 14, color: _kMutedText)
          : Image.asset(
              logoAsset!,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              errorBuilder: (_, __, ___) => Text(
                label,
                style: GoogleFonts.inter(
                  color: color,
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
            ),
    );
  }
}

class _HoverLogo extends StatefulWidget {
  final Widget child;
  const _HoverLogo({required this.child});

  @override
  State<_HoverLogo> createState() => _HoverLogoState();
}

class _HoverLogoState extends State<_HoverLogo> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.08 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}
