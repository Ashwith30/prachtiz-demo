import 'package:flutter/material.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../domain/models/appointment_model.dart';

const _kPanelBg = Color(0xFF0F172A);
const _kBrandBlue = Color(0xFF315BFF);
const _kBrandGreen = Color(0xFF24C06F);
const _kMutedText = Color(0xFF94A3B8);

class AppointmentSection extends StatefulWidget {
  final List<DashboardAppointment> appointments;

  const AppointmentSection({
    super.key,
    required this.appointments,
  });

  @override
  State<AppointmentSection> createState() => _AppointmentSectionState();
}

class _AppointmentSectionState extends State<AppointmentSection> {
  int _activeTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Categorize appointments based on tab selection
    List<DashboardAppointment> filteredAppts = [];
    if (_activeTabIndex == 0) {
      // Upcoming: scheduled, inProgress, in30Min
      filteredAppts = widget.appointments
          .where((appt) =>
              appt.status == AppointmentStatusType.scheduled ||
              appt.status == AppointmentStatusType.inProgress ||
              appt.status == AppointmentStatusType.in30Min)
          .toList();
    } else if (_activeTabIndex == 1) {
      // Completed: confirmed (or completed)
      filteredAppts = widget.appointments
          .where((appt) => appt.status == AppointmentStatusType.confirmed)
          .toList();
    } else {
      // Cancelled
      filteredAppts = [];
    }

    // Calculate counts for badges
    final upcomingCount = widget.appointments
        .where((appt) =>
            appt.status == AppointmentStatusType.scheduled ||
            appt.status == AppointmentStatusType.inProgress ||
            appt.status == AppointmentStatusType.in30Min)
        .length;
    final completedCount = widget.appointments
        .where((appt) => appt.status == AppointmentStatusType.confirmed)
        .length;
    const cancelledCount = 0;

    return AppCard(
      color: _kPanelBg,
      border: Border.all(color: Colors.white.withOpacity(0.08), width: 1.0),
      borderRadius: AppRadius.radius18,
      padding: const EdgeInsets.all(22.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 44,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Stack(
              children: [
                AnimatedAlign(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOutCubic,
                  alignment: Alignment(
                    _activeTabIndex == 0
                        ? -1.0
                        : (_activeTabIndex == 1 ? 0.0 : 1.0),
                    1.0, // bottom alignment
                  ),
                  child: FractionallySizedBox(
                    widthFactor: 1 / 3,
                    child: Container(
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: _kBrandGreen.withOpacity(0.16),
                        borderRadius: BorderRadius.circular(9),
                        border:
                            Border.all(color: _kBrandGreen.withOpacity(0.22)),
                        boxShadow: [
                          BoxShadow(
                            color: _kBrandGreen.withOpacity(0.12),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                        child: _buildTabItem(0, "Upcoming", upcomingCount)),
                    Expanded(
                        child: _buildTabItem(1, "Completed", completedCount)),
                    Expanded(
                        child: _buildTabItem(2, "Cancelled", cancelledCount)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Queue List
          if (filteredAppts.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 48.0),
                child: Column(
                  children: [
                    const Icon(Icons.event_busy_outlined,
                        color: Color(0xFF64748B), size: 36),
                    const SizedBox(height: 12),
                    Text(
                      "No patients in this queue",
                      style: AppTypography.body.copyWith(
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              children: [
                for (int i = 0; i < filteredAppts.length; i++) ...[
                  _buildAppointmentRow(filteredAppts[i]),
                  if (i < filteredAppts.length - 1) const SizedBox(height: 10),
                ],
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String label, int count) {
    final bool isActive = _activeTabIndex == index;

    return Semantics(
      button: true,
      selected: isActive,
      label: "View $label queue tab",
      child: InkWell(
        onTap: () {
          setState(() {
            _activeTabIndex = index;
          });
        },
        child: Container(
          height: 36,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                  color: isActive ? Colors.white : _kMutedText,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                decoration: BoxDecoration(
                  color: isActive
                      ? _kBrandGreen.withOpacity(0.18)
                      : Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isActive ? _kBrandGreen : _kMutedText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentRow(DashboardAppointment appt) {
    return _InteractiveAppointmentRow(appt: appt);
  }
}

class _InteractiveAppointmentRow extends StatefulWidget {
  final DashboardAppointment appt;

  const _InteractiveAppointmentRow({required this.appt});

  @override
  State<_InteractiveAppointmentRow> createState() =>
      _InteractiveAppointmentRowState();
}

class _InteractiveAppointmentRowState
    extends State<_InteractiveAppointmentRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final appt = widget.appt;
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final bool isMobile = screenWidth < 768;
    final bool isSmallMobile = screenWidth < 480;

    // Map status to a left stripe color
    final Color statusStripeColor;
    switch (appt.status) {
      case AppointmentStatusType.scheduled:
        statusStripeColor = const Color(0xFF315BFF); // Blue
        break;
      case AppointmentStatusType.inProgress:
        statusStripeColor = const Color(0xFFFFB020); // Orange
        break;
      case AppointmentStatusType.in30Min:
        statusStripeColor = const Color(0xFF0EA5E9); // Cyan
        break;
      case AppointmentStatusType.confirmed:
        statusStripeColor = const Color(0xFF24C06F); // Green
        break;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: _isHovered
              ? Colors.white.withOpacity(0.055)
              : Colors.white.withOpacity(0.032),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _isHovered
                ? statusStripeColor.withOpacity(0.32)
                : Colors.white.withOpacity(0.07),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_isHovered ? 0.18 : 0.08),
              blurRadius: _isHovered ? 14 : 8,
              offset: Offset(0, _isHovered ? 8 : 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Status-bound left vertical stripe
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: _isHovered ? 4.0 : 3.0,
                decoration: BoxDecoration(
                  color: statusStripeColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    bottomLeft: Radius.circular(14),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14.0, vertical: 12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Avatar
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 40,
                        height: 40,
                        transform: Matrix4.identity()
                          ..scale(_isHovered ? 1.05 : 1.0),
                        decoration: BoxDecoration(
                          color: appt.avatarColor.withOpacity(0.18),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          appt.initials,
                          style: TextStyle(
                            color: appt.avatarColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Patient Details: Name + Complaint + Date
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appt.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              appt.symptoms,
                              style: const TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 11.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (appt.dateText != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                appt.dateText!,
                                style: const TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 10.5,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Timing Info: Today/Tomorrow + Clock & Time
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appt.timeText.contains("Tomorrow")
                                  ? "Tomorrow"
                                  : "Today",
                              style: const TextStyle(
                                color: _kMutedText,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.access_time_outlined,
                                    size: 12, color: _kMutedText),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    appt.timeText
                                        .replaceAll("Today ", "")
                                        .replaceAll("Tomorrow", "10:00 AM"),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Status Badge (hidden on extra small screens)
                      if (!isSmallMobile)
                        Expanded(
                          flex: 2,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: _buildStatusBadge(appt.status),
                          ),
                        ),

                      // Consultation Type Tag (hidden on mobile)
                      if (!isMobile)
                        Expanded(
                          flex: 2,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _kBrandBlue.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: _kBrandBlue.withOpacity(0.24),
                                    width: 1.0),
                              ),
                              child: Text(
                                appt.consultType,
                                style: const TextStyle(
                                  color: Color(0xFFDDE7F5),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),

                      // Partner Logo (hidden on mobile)
                      if (!isMobile)
                        Expanded(
                          flex: 1,
                          child: Center(
                            child:
                                _buildPartnerLogoWidget(appt.partnerLogoType),
                          ),
                        ),

                      // Pricing & Payment status
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              appt.priceText,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            _buildPaymentBadgeWidget(appt.paymentStatus),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Details Action Eye Icon
                      IconButton(
                        icon: const Icon(Icons.visibility_outlined,
                            size: 18, color: _kMutedText),
                        onPressed: () {},
                        tooltip: "View Session Details",
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(6),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Global/Private Badges Builders for clean reuse across components
Widget _buildStatusBadge(AppointmentStatusType status) {
  switch (status) {
    case AppointmentStatusType.scheduled:
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: _kBrandBlue.withOpacity(0.12),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: _kBrandBlue.withOpacity(0.35), width: 1.0),
        ),
        child: const Text(
          "Scheduled",
          style: TextStyle(
              color: Color(0xFF5375FF),
              fontSize: 10,
              fontWeight: FontWeight.bold),
        ),
      );
    case AppointmentStatusType.inProgress:
      return _PulsingStatusBadge();
    case AppointmentStatusType.in30Min:
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFF0EA5E9).withOpacity(0.12),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
              color: const Color(0xFF0EA5E9).withOpacity(0.35), width: 1.0),
        ),
        child: const Text(
          "In 30 min",
          style: TextStyle(
              color: Color(0xFF0EA5E9),
              fontSize: 10,
              fontWeight: FontWeight.bold),
        ),
      );
    case AppointmentStatusType.confirmed:
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: _kBrandGreen.withOpacity(0.12),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: _kBrandGreen.withOpacity(0.35), width: 1.0),
        ),
        child: const Text(
          "Confirmed",
          style: TextStyle(
              color: Color(0xFF24C06F),
              fontSize: 10,
              fontWeight: FontWeight.bold),
        ),
      );
  }
}

class _PulsingStatusBadge extends StatefulWidget {
  @override
  State<_PulsingStatusBadge> createState() => _PulsingStatusBadgeState();
}

class _PulsingStatusBadgeState extends State<_PulsingStatusBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFFFB020).withOpacity(0.12),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
            color: const Color(0xFFFFB020).withOpacity(0.35), width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: 0.3 + (_controller.value * 0.7),
                child: child,
              );
            },
            child: const Icon(Icons.circle, color: Color(0xFFFFB020), size: 6),
          ),
          const SizedBox(width: 4),
          const Text(
            "In Progress",
            style: TextStyle(
                color: Color(0xFFFFB020),
                fontSize: 10,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

Widget _buildPaymentBadgeWidget(AppointmentPaymentStatus status) {
  final bool isPaid = status == AppointmentPaymentStatus.paid;
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: isPaid
          ? _kBrandGreen.withOpacity(0.12)
          : const Color(0xFFF04438).withOpacity(0.12),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: isPaid
            ? _kBrandGreen.withOpacity(0.24)
            : const Color(0xFFF04438).withOpacity(0.22),
      ),
    ),
    child: Text(
      isPaid ? "Paid" : "Due",
      style: TextStyle(
        color: isPaid ? _kBrandGreen : const Color(0xFFF04438),
        fontSize: 9,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

Widget _buildPartnerLogoWidget(String type) {
  Widget logoWidget;

  if (type.toUpperCase() == "CH" || type == "CircleBlue") {
    logoWidget =
        _PartnerLogoChip(asset: AppAssets.logoCallHealth, fallback: "CH");
  } else if (type.toUpperCase() == "SBI") {
    logoWidget = _PartnerLogoChip(asset: AppAssets.logoSbi, fallback: "SBI");
  } else if (type.toUpperCase() == "HDFC") {
    logoWidget = _PartnerLogoChip(asset: AppAssets.logoHdfc, fallback: "HDFC");
  } else {
    return const SizedBox(width: 38);
  }

  return _HoverLogo(child: logoWidget);
}

class _PartnerLogoChip extends StatelessWidget {
  final String asset;
  final String fallback;

  const _PartnerLogoChip({
    required this.asset,
    required this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.9)),
      ),
      alignment: Alignment.center,
      child: Image.asset(
        asset,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        errorBuilder: (_, __, ___) => Text(
          fallback,
          style: const TextStyle(
            color: _kBrandBlue,
            fontSize: 9,
            fontWeight: FontWeight.w800,
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
        scale: _isHovered ? 1.15 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}
