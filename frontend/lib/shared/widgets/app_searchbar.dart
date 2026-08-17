import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_typography.dart';

class AppSearchBar extends StatefulWidget {
  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final double width;
  final double height;

  const AppSearchBar({
    super.key,
    this.controller,
    this.hintText = 'Search patients, ap...',
    this.onChanged,
    this.width = 420.0,
    this.height = 40.0, // Match height of topbar elements in Image 2
  });

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  late final TextEditingController _internalController;

  @override
  void initState() {
    super.initState();
    _internalController = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _internalController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      textField: true,
      label: 'Search patients, files, or clinical options',
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: const Color(0xFF0F223D),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14.0),
        alignment: Alignment.center,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.search, size: 18, color: Color(0xFF94A3B8)),
              onPressed: () {
                final query = _internalController.text.trim();
                if (query.isNotEmpty) {
                  _showSearchResultsOverlay(context, query);
                }
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              splashRadius: 18,
              tooltip: 'Submit Search',
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _internalController,
                onChanged: widget.onChanged,
                onSubmitted: (query) {
                  if (query.trim().isNotEmpty) {
                    _showSearchResultsOverlay(context, query.trim());
                  }
                },
                decoration: InputDecoration(
                  isDense: true,
                  hintText: widget.hintText,
                  hintStyle: AppTypography.body.copyWith(
                    color: const Color(0xFF94A3B8),
                    fontWeight: FontWeight.normal,
                    fontSize: 13,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  fillColor: Colors.transparent,
                  filled: false,
                ),
                style: AppTypography.bodySemibold.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Interactive Inline Search Badges
            _SearchBadge(
              icon: Icons.calendar_today_outlined,
              value: '12',
              color: const Color(0xFF3B82F6), // Blue
              onTap: () => _showSearchBadgeOverlay(context, 'calendar'),
            ),
            _SearchBadge(
              icon: Icons.people_outline,
              value: '8',
              color: const Color(0xFFF59E0B), // Orange
              onTap: () => _showSearchBadgeOverlay(context, 'people'),
            ),
            _SearchBadge(
              icon: Icons.videocam_outlined,
              value: '2',
              color: const Color(0xFF6366F1), // Indigo
              onTap: () => _showSearchBadgeOverlay(context, 'video'),
            ),
            _SearchBadge(
              icon: Icons.check_circle_outline,
              value: '6',
              color: const Color(0xFF24C06F), // Green
              onTap: () => _showSearchBadgeOverlay(context, 'check'),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // INTERACTIVE OVERLAYS
  // ───────────────────────────────────────────────────────────────────────────
  void _showSearchBadgeOverlay(BuildContext context, String type) {
    final double width = MediaQuery.sizeOf(context).width;
    final double popupWidth = width > 500 ? 380.0 : width * 0.90;

    Widget content;
    String title;
    IconData titleIcon;
    Color brandColor;

    switch (type) {
      case 'calendar':
        title = 'Appointments (12)';
        titleIcon = Icons.calendar_today_outlined;
        brandColor = const Color(0xFF3B82F6);
        content = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildOverlayItem('09:30 AM', 'Marcus Vance', 'Hypertension Review'),
            _buildOverlayItem('10:15 AM', 'Margaret Chen', 'Cardiac Checkup'),
            _buildOverlayItem('11:00 AM', 'James O\'Sullivan', 'Vitals Follow-up'),
            _buildOverlayItem('11:30 AM', 'David Miller', 'General Consultation'),
            _buildOverlayItem('01:00 PM', 'Sarah Connor', 'Cardiology Review'),
          ],
        );
        break;
      case 'people':
        title = 'Active Patients (8)';
        titleIcon = Icons.people_outline;
        brandColor = const Color(0xFFF59E0B);
        content = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildOverlayPatientItem('Marcus Vance', 'PT-0482', 'HIGH RISK (ACS)', true),
            _buildOverlayPatientItem('James O\'Sullivan', 'PT-0921', 'HIGH RISK (Cardiac)', true),
            _buildOverlayPatientItem('Margaret Chen', 'PT-0831', 'Stable', false),
            _buildOverlayPatientItem('David Miller', 'PT-0294', 'Stable', false),
            _buildOverlayPatientItem('Sarah Connor', 'PT-0518', 'Stable', false),
          ],
        );
        break;
      case 'video':
        title = 'Video Consultations (2 Active)';
        titleIcon = Icons.videocam_outlined;
        brandColor = const Color(0xFF6366F1);
        content = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildOverlayVideoItem('Telehealth Room 1', 'Dr. Amanulla Beig', 'Ongoing', true),
            _buildOverlayVideoItem('Telehealth Room 2', 'Dr. Michael Chen', 'Starts in 10m', false),
          ],
        );
        break;
      case 'check':
        title = 'Completed Tasks (6)';
        titleIcon = Icons.check_circle_outline;
        brandColor = const Color(0xFF24C06F);
        content = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildOverlayTaskItem('Encrypted EMR uploads finalized'),
            _buildOverlayTaskItem('Patient vitals daily logs checked'),
            _buildOverlayTaskItem('June 2026 scheduling shifts approved'),
            _buildOverlayTaskItem('Pathology blood panels cross-examined'),
            _buildOverlayTaskItem('Telemedicine conference session logs saved'),
          ],
        );
        break;
      default:
        return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          alignment: Alignment.topCenter,
          backgroundColor: const Color(0xFF0C0E1F),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.white.withOpacity(0.08)),
          ),
          child: Container(
            width: popupWidth,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(titleIcon, color: brandColor, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          title,
                          style: GoogleFonts.inter(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white54, size: 16),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(color: Colors.white12, height: 1),
                const SizedBox(height: 10),
                content,
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSearchResultsOverlay(BuildContext context, String query) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          alignment: Alignment.topCenter,
          backgroundColor: const Color(0xFF0C0E1F),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.white.withOpacity(0.08)),
          ),
          child: Container(
            width: 380,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Search Results for "$query"',
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white54, size: 16),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(color: Colors.white12, height: 1),
                const SizedBox(height: 10),
                if (query.toLowerCase().contains('mar') || query.toLowerCase().contains('vance')) ...[
                  _buildOverlayPatientItem('Marcus Vance', 'PT-0482', 'Chief: Acute Coronary Syndrome', true),
                  _buildOverlayItem('09:30 AM', 'Marcus Vance', 'Hypertension Review (Dr. Jenkins)'),
                ] else if (query.toLowerCase().contains('marg') || query.toLowerCase().contains('chen')) ...[
                  _buildOverlayPatientItem('Margaret Chen', 'PT-0831', 'Stable Status', false),
                  _buildOverlayItem('10:15 AM', 'Margaret Chen', 'Cardiac Checkup (Dr. Chen)'),
                ] else ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text(
                        'No matching clinical records or patients found.',
                        style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOverlayItem(String time, String name, String details) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.access_time, size: 12, color: Color(0xFF3B82F6)),
              const SizedBox(width: 6),
              Text(time, style: GoogleFonts.inter(color: const Color(0xFF3B82F6), fontSize: 11, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Text(name, style: GoogleFonts.inter(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.bold)),
            ],
          ),
          Text(details, style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildOverlayPatientItem(String name, String id, String condition, bool risk) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: risk ? const Color(0xFFEF4444) : const Color(0xFF24C06F),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(name, style: GoogleFonts.inter(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.bold)),
              const SizedBox(width: 6),
              Text('($id)', style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 10)),
            ],
          ),
          Text(condition, style: GoogleFonts.inter(color: risk ? const Color(0xFFEF4444) : const Color(0xFF24C06F), fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildOverlayVideoItem(String room, String doc, String status, bool active) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.videocam, size: 12, color: Color(0xFF6366F1)),
              const SizedBox(width: 6),
              Text(room, style: GoogleFonts.inter(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.bold)),
              const SizedBox(width: 6),
              Text('• $doc', style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 10)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: active ? const Color(0xFF24C06F).withOpacity(0.12) : const Color(0xFF94A3B8).withOpacity(0.12),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              status,
              style: GoogleFonts.inter(color: active ? const Color(0xFF24C06F) : const Color(0xFF94A3B8), fontSize: 9, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlayTaskItem(String task) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: [
          const Icon(Icons.check, size: 12, color: Color(0xFF24C06F)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              task,
              style: GoogleFonts.inter(color: Colors.white.withOpacity(0.85), fontSize: 11),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBadge extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;
  final VoidCallback onTap;

  const _SearchBadge({
    required this.icon,
    required this.value,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        margin: const EdgeInsets.only(left: 4.0),
        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withOpacity(0.25), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 11, color: color),
            const SizedBox(width: 3),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
