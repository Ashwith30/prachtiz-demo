import "package:prachtiz_flutter/core/theme/app_colors.dart";
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/services/web_media_service.dart';
import '../../../../shared/widgets/web_video_view.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Brand Color System (Matches PraCHtiz dark theme)
// ─────────────────────────────────────────────────────────────────────────────
const Color _kCardBg = Color(0xFF0C0E1F);
final Color _kCardBorder = Colors.white.withValues(alpha: 0.08);
Color _kBrandBlue = AppColors.primary;
const Color _kBrandGreen = Color(0xFF24C06F);
const Color _kTextGray = Color(0xFF94A3B8);
const Color _kDangerRed = Color(0xFFEF4444);
const Color _kWarningAmber = Color(0xFFF59E0B);
const Color _kBorderlinePurple = Color(0xFF8B5CF6);

// ─────────────────────────────────────────────────────────────────────────────
// Chat Message model
// ─────────────────────────────────────────────────────────────────────────────
class ChatMessage {
  final String sender;
  final String text;
  final String time;

  ChatMessage({required this.sender, required this.text, required this.time});
}

// ─────────────────────────────────────────────────────────────────────────────
// TelemedicineScreen root widget
// ─────────────────────────────────────────────────────────────────────────────
class TelemedicineScreen extends StatefulWidget {
  const TelemedicineScreen({super.key});

  @override
  State<TelemedicineScreen> createState() => _TelemedicineScreenState();
}

class _TelemedicineScreenState extends State<TelemedicineScreen>
    with TickerProviderStateMixin {
  // ── Screen Mode ─────────────────────────────────────────────────────────────
  bool _isInActiveCall = false;
  Map<String, dynamic>? _activeCallPatient;

  // ── Web Media Service (real camera/mic/screen via dart:html) ─────────────────
  final WebMediaService _media = WebMediaService();

  // ── View state (mirrors media service for setState rebuilds) ─────────────────
  bool _isPatientCamExpanded = false; // true = patient cam is main view

  // ── Draggable Doctor PiP Position ────────────────────────────────────────────
  double _pipRight = 16.0;
  double _pipTop = 16.0;

  // ── Audio Level Animation ────────────────────────────────────────────────────
  late AnimationController _audioLevelController;
  late Timer _callTimer;
  int _callSeconds = 0;

  // ── KPI Metrics ──────────────────────────────────────────────────────────────
  int _activeSessionsCount = 3;
  final int _scheduledTodayCount = 12;
  int _completedCount = 8;
  final String _avgDuration = '18 min';

  // ── Data Lists ───────────────────────────────────────────────────────────────
  late List<Map<String, dynamic>> _activeSessionsList;
  late List<Map<String, dynamic>> _doctorAvailabilityList;

  // ── Live Chat ────────────────────────────────────────────────────────────────
  final List<ChatMessage> _chatHistory = [];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();

  // ────────────────────────────────────────────────────────────────────────────
  // MEDIA INIT — request real browser camera + mic permissions
  // ────────────────────────────────────────────────────────────────────────────
  Future<void> _requestMediaPermissions() async {
    final ok = await _media.requestAndStartMedia();
    if (mounted) setState(() {});
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          content: Text(
            _media.lastError ?? 'Camera permission denied.',
            style: GoogleFonts.inter(color: Colors.white),
          ),
        ),
      );
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // CAMERA SWITCH — with laptop single-camera message
  // ────────────────────────────────────────────────────────────────────────────
  Future<void> _switchCamera() async {
    final msg = await _media.switchCamera();
    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: _media.hasMultipleCameras ? _kBrandBlue : _kWarningAmber,
          behavior: SnackBarBehavior.floating,
          content: Row(
            children: [
              Icon(
                _media.hasMultipleCameras
                    ? Icons.switch_camera_outlined
                    : Icons.info_outline,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  msg,
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }


  // ────────────────────────────────────────────────────────────────────────────
  // LIFECYCLE
  // ────────────────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();

    // Listen to media service state changes → rebuild
    _media.addListener(_onMediaChanged);

    _audioLevelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _callTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_isInActiveCall) {
        setState(() => _callSeconds++);
      }
    });

    _activeSessionsList = [
      {
        'patient': 'Sarah Johnson',
        'avatarColor': const Color(0xFF3B82F6),
        'doctor': 'Dr. Williams',
        'type': 'Follow-up',
        'time': '12:34',
        'isActive': true,
      },
      {
        'patient': 'James Chen',
        'avatarColor': const Color(0xFF10B981),
        'doctor': 'Dr. Patel',
        'type': 'Consultation',
        'time': '08:15',
        'isActive': true,
      },
      {
        'patient': 'Maria Garcia',
        'avatarColor': const Color(0xFFEC4899),
        'doctor': 'Dr. Brooks',
        'type': 'Urgent',
        'time': '03:47',
        'isActive': true,
      },
      {
        'patient': 'David Thompson',
        'avatarColor': const Color(0xFFEF4444),
        'doctor': 'Dr. Michael Torres',
        'type': 'Telehealth',
        'time': '00:00',
        'isActive': false,
      },
      {
        'patient': 'Laura Bennett',
        'avatarColor': const Color(0xFFF59E0B),
        'doctor': 'Dr. Sarah Mitchell',
        'type': 'Telehealth',
        'time': '00:00',
        'isActive': false,
      },
    ];

    _doctorAvailabilityList = [
      {
        'doctor': 'Dr. Williams',
        'specialty': 'Internal Medicine',
        'status': 'In Session',
        'count': '4 today',
        'avatarColor': const Color(0xFF3B82F6),
      },
      {
        'doctor': 'Dr. Brooks',
        'specialty': 'Pediatrics',
        'status': 'In Session',
        'count': '3 today',
        'avatarColor': const Color(0xFF8B5CF6),
      },
      {
        'doctor': 'Dr. Patel',
        'specialty': 'Cardiology',
        'status': 'In Session',
        'count': '5 today',
        'avatarColor': const Color(0xFFEC4899),
      },
      {
        'doctor': 'Dr. Kim',
        'specialty': 'Dermatology',
        'status': 'Available',
        'count': '2 today',
        'avatarColor': const Color(0xFFEF4444),
      },
      {
        'doctor': 'Dr. Chen',
        'specialty': 'Neurology',
        'status': 'Available',
        'count': '1 today',
        'avatarColor': const Color(0xFF10B981),
      },
      {
        'doctor': 'Dr. Martinez',
        'specialty': 'Orthopedics',
        'status': 'Offline',
        'count': '0 today',
        'avatarColor': const Color(0xFFF59E0B),
      },
    ];
  }

  @override
  void dispose() {
    _media.removeListener(_onMediaChanged);
    _media.stopAll();
    _audioLevelController.dispose();
    _callTimer.cancel();
    _messageController.dispose();
    _chatScrollController.dispose();
    super.dispose();
  }

  void _onMediaChanged() {
    if (mounted) setState(() {});
  }

  // ────────────────────────────────────────────────────────────────────────────
  // CALL LIFECYCLE
  // ────────────────────────────────────────────────────────────────────────────
  void _enterCall(Map<String, dynamic> session) {
    setState(() {
      _isInActiveCall = true;
      _activeCallPatient = session;
      _callSeconds = 0;
      _pipRight = 16.0;
      _pipTop = 16.0;
      _isPatientCamExpanded = false;
      _chatHistory
        ..clear()
        ..addAll([
          ChatMessage(
            sender: 'Patient (${session['patient']})',
            text: 'Hello doctor, can you hear me clearly?',
            time: '10:14 AM',
          ),
          ChatMessage(
            sender: 'System',
            text: 'Secure WebRTC connection established. E2EE active.',
            time: '10:15 AM',
          ),
        ]);
    });
    // Request real camera+mic when entering a call
    if (!_media.isInitialized) {
      _requestMediaPermissions();
    } else {
      _media.resetForNewCall();
    }
  }

  void _endCall() {
    final patient = _activeCallPatient;
    _media.stopAll();
    setState(() {
      _isInActiveCall = false;
      _activeCallPatient = null;
      _callSeconds = 0;
      _completedCount++;
      if (patient != null) {
        _activeSessionsList
            .removeWhere((item) => item['patient'] == patient['patient']);
        _activeSessionsCount =
            _activeSessionsList.where((item) => item['isActive']).length;
      }
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: _kCardBg,
          behavior: SnackBarBehavior.floating,
          content: Text(
            'Secure consultation call ended.',
            style: GoogleFonts.inter(color: Colors.white),
          ),
        ),
      );
    }
  }

  String get _callDurationStr {
    final m = (_callSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_callSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // ────────────────────────────────────────────────────────────────────────────
  // BUILD
  // ────────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 1100;
    final gap = width < 700 ? 12.0 : 16.0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: width < 700 ? 12.0 : AppDimensions.pagePaddingHorizontal,
          vertical: AppDimensions.pagePaddingVertical,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, anim) =>
              FadeTransition(opacity: anim, child: child),
          child: _isInActiveCall
              ? _buildVideoCallPortal(isDesktop, gap)
              : _buildLobbyDashboard(isDesktop, gap),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // VIEW 1: LOBBY DASHBOARD
  // ────────────────────────────────────────────────────────────────────────────
  Widget _buildLobbyDashboard(bool isDesktop, double gap) {
    return Column(
      key: const ValueKey('lobby_view'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Telemedicine',
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF6B8EFF),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Manage virtual consultations, video sessions, and scheduling.',
          style: GoogleFonts.inter(color: _kTextGray, fontSize: 13),
        ),
        const SizedBox(height: 20),
        _buildKPICardsGrid(isDesktop, gap)
            .animate()
            .fadeIn(duration: 300.ms)
            .slideY(begin: 0.02, end: 0, curve: Curves.easeOutCubic),
        SizedBox(height: gap),
        if (isDesktop)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 7, child: _buildActiveSessionsCard()),
              SizedBox(width: gap),
              Expanded(flex: 5, child: _buildDoctorAvailabilityCard()),
            ],
          )
        else
          Column(
            children: [
              _buildActiveSessionsCard(),
              SizedBox(height: gap),
              _buildDoctorAvailabilityCard(),
            ],
          ),
      ],
    );
  }

  Widget _buildKPICardsGrid(bool isDesktop, double gap) {
    final List<Widget> cards = [
      _buildKPICard(
        title: 'Active Sessions',
        value: '$_activeSessionsCount',
        icon: Icons.videocam_outlined,
        color: _kBrandGreen,
      ),
      _buildKPICard(
        title: 'Scheduled Today',
        value: '$_scheduledTodayCount',
        icon: Icons.calendar_today_outlined,
        color: _kBrandBlue,
      ),
      _buildKPICard(
        title: 'Completed',
        value: '$_completedCount',
        icon: Icons.assignment_turned_in_outlined,
        color: _kBorderlinePurple,
      ),
      _buildKPICard(
        title: 'Avg Duration',
        value: _avgDuration,
        icon: Icons.timer_outlined,
        color: _kWarningAmber,
      ),
    ];

    if (isDesktop) {
      return Row(
        children: cards
            .asMap()
            .entries
            .map((e) => Expanded(
                  child: Padding(
                    padding:
                        EdgeInsets.only(right: e.key < cards.length - 1 ? gap : 0),
                    child: e.value,
                  ),
                ))
            .toList(),
      );
    } else {
      return Column(
        children: cards
            .asMap()
            .entries
            .map((e) => Padding(
                  padding: EdgeInsets.only(
                      bottom: e.key < cards.length - 1 ? gap : 0),
                  child: e.value,
                ))
            .toList(),
      );
    }
  }

  Widget _buildKPICard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return _HoverCard(
      child: AppCard(
        color: _kCardBg,
        borderRadius: AppRadius.radius12,
        border: Border.all(color: _kCardBorder),
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                        color: _kTextGray,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveSessionsCard() {
    return AppCard(
      color: _kCardBg,
      borderRadius: AppRadius.radius12,
      border: Border.all(color: _kCardBorder),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.videocam_outlined, color: _kBrandBlue, size: 18),
              const SizedBox(width: 8),
              Text(
                'Active Sessions',
                style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_activeSessionsList.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text(
                  'No active virtual consultations in progress.',
                  style: GoogleFonts.inter(color: _kTextGray, fontSize: 13),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _activeSessionsList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final session = _activeSessionsList[index];
                final initials = session['patient']
                    .toString()
                    .split(' ')
                    .map((s) => s[0])
                    .take(2)
                    .join();
                final bool isActive = session['isActive'] == true;

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.01),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: Colors.white.withValues(alpha: 0.04)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor:
                                  session['avatarColor'].withValues(alpha: 0.12),
                              child: Text(
                                initials,
                                style: GoogleFonts.inter(
                                    color: session['avatarColor'],
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          session['patient'],
                                          style: GoogleFonts.inter(
                                              color: Colors.white,
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                      if (isActive) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: const BoxDecoration(
                                              color: _kBrandGreen,
                                              shape: BoxShape.circle),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "${session['doctor']} • ${session['type']}",
                                    style: GoogleFonts.inter(
                                        color: _kTextGray, fontSize: 11),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14.0),
                        child: Text(
                          session['time'],
                          style: GoogleFonts.robotoMono(
                            color: isActive ? _kBrandBlue : _kTextGray,
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: _kCardBg,
                              behavior: SnackBarBehavior.floating,
                              content: Text(
                                'Telemedicine meeting link copied to clipboard.',
                                style:
                                    GoogleFonts.inter(color: Colors.white),
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.06)),
                          ),
                          child: const Icon(Icons.reply_rounded,
                              color: Colors.white, size: 14),
                        ),
                      ),
                      const SizedBox(width: 8),
                      AppButton(
                        label: 'Join',
                        icon: const Icon(Icons.arrow_forward_rounded, size: 12),
                        height: 32,
                        variant: isActive
                            ? AppButtonVariant.success
                            : AppButtonVariant.secondary,
                        onPressed: () => _enterCall(session),
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

  Widget _buildDoctorAvailabilityCard() {
    return AppCard(
      color: _kCardBg,
      borderRadius: AppRadius.radius12,
      border: Border.all(color: _kCardBorder),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.people_outline_rounded,
                  color: _kBrandBlue, size: 18),
              const SizedBox(width: 8),
              Text(
                'Doctor Availability',
                style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _doctorAvailabilityList.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final doc = _doctorAvailabilityList[index];
              final initials = doc['doctor']
                  .toString()
                  .replaceAll('Dr. ', '')
                  .split(' ')
                  .map((s) => s[0])
                  .take(2)
                  .join();
              final statusStr = doc['status'].toString();
              final Color statusColor = _getDoctorStatusColor(statusStr);

              return Row(
                children: [
                  CircleAvatar(
                    radius: 13,
                    backgroundColor:
                        doc['avatarColor'].withValues(alpha: 0.12),
                    child: Text(
                      initials,
                      style: GoogleFonts.inter(
                          color: doc['avatarColor'],
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doc['doctor'],
                          style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          doc['specialty'],
                          style: GoogleFonts.inter(
                              color: _kTextGray, fontSize: 10.5),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    doc['count'],
                    style:
                        GoogleFonts.inter(color: _kTextGray, fontSize: 10.5),
                  ),
                  const SizedBox(width: 14),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                          color: statusColor.withValues(alpha: 0.2)),
                    ),
                    child: Text(
                      statusStr,
                      style: GoogleFonts.inter(
                          color: statusColor,
                          fontSize: 8.5,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // VIEW 2: ACTIVE VIDEO CALL PORTAL
  // ────────────────────────────────────────────────────────────────────────────
  Widget _buildVideoCallPortal(bool isDesktop, double gap) {
    final patient = _activeCallPatient ?? {};

    return Column(
      key: const ValueKey('call_view'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ────────────────────────────────────────────────────────────
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 16),
              onPressed: () => setState(() => _isInActiveCall = false),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Virtual Consultation Portal',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF6B8EFF),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Secure E2EE WebRTC link • ${patient['patient']}",
                    style: GoogleFonts.inter(color: _kTextGray, fontSize: 13),
                  ),
                ],
              ),
            ),
            // Live call duration clock
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _kBrandGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: _kBrandGreen.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                        color: _kBrandGreen, shape: BoxShape.circle),
                  ).animate(onPlay: (c) => c.repeat()).shimmer(
                      duration: 1.2.seconds),
                  const SizedBox(width: 6),
                  Text(
                    _callDurationStr,
                    style: GoogleFonts.robotoMono(
                        color: _kBrandGreen,
                        fontSize: 13,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // ── Responsive Layout ─────────────────────────────────────────────────
        if (isDesktop)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 7, child: _buildMainVideoSection(patient)),
              SizedBox(width: gap),
              Expanded(flex: 5, child: _buildChatPanel()),
            ],
          )
        else
          Column(
            children: [
              _buildMainVideoSection(patient),
              SizedBox(height: gap),
              _buildChatPanel(),
            ],
          ),
      ],
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // MAIN VIDEO SECTION (patient + doctor PiP + controls)
  // ────────────────────────────────────────────────────────────────────────────
  Widget _buildMainVideoSection(Map<String, dynamic> patient) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxHeight = constraints.maxWidth < 500 ? 300.0 : 440.0;

        return Container(
          height: boxHeight,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: const Color(0xFF050812),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Stack(
            children: [
              // ── MAIN: Patient Cam or Doctor Cam (swappable) ─────────────────
              Positioned.fill(
                child: _isPatientCamExpanded
                    ? _buildDoctorMainView()
                    : _buildPatientMainView(patient),
              ),

              // ── Gradient overlay for text readability ────────────────────────
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: 0.55),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.6),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),

              // ── E2EE Badge (top-left) ────────────────────────────────────────
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: _kBrandGreen.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lock_outline_rounded,
                          color: _kBrandGreen, size: 11),
                      const SizedBox(width: 5),
                      Text(
                        'E2EE SECURE',
                        style: GoogleFonts.inter(
                            color: _kBrandGreen,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Screen-Share indicator (top-center) ─────────────────────────
              if (_media.isScreenSharing)
                Positioned(
                  top: 16,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: _kBrandBlue.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.screen_share,
                              color: Colors.white, size: 13),
                          const SizedBox(width: 6),
                          Text(
                            'You are sharing your screen',
                            style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // ── Audio level bars (bottom-left) ───────────────────────────────
              if (!_media.isMicMuted)
                Positioned(
                  left: 16,
                  bottom: 72,
                  child: _buildAudioLevelBars(),
                ),

              // ── Current cam label (bottom-left) ──────────────────────────────
              Positioned(
                left: 16,
                bottom: 100,
                child: Text(
                  _isPatientCamExpanded
                      ? 'Dr. Baig (Your Camera)'
                      : "${patient['patient']} (Patient)",
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    shadows: [
                      const Shadow(blurRadius: 4, color: Colors.black)
                    ],
                  ),
                ),
              ),

              // ── DRAGGABLE Doctor PiP (or Patient PiP) ───────────────────────
              Positioned(
                top: _pipTop,
                right: _pipRight,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      // Clamp to container bounds
                      _pipTop = (_pipTop + details.delta.dy).clamp(16.0, boxHeight - 150.0);
                      _pipRight = (_pipRight - details.delta.dx)
                          .clamp(16.0, constraints.maxWidth - 116.0);
                    });
                  },
                  onTap: () {
                    // Clicking the PiP swaps main/pip views
                    setState(() {
                      _isPatientCamExpanded = !_isPatientCamExpanded;
                    });
                  },
                  child: Container(
                    width: 100,
                    height: 130,
                    decoration: BoxDecoration(
                      color: const Color(0xFF131935),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.15),
                          width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: _isPatientCamExpanded
                                ? _buildPatientPipContent(patient)
                                : _buildDoctorPipContent(),
                          ),
                        ),
                        // Drag handle indicator
                        Positioned(
                          top: 4,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              width: 24,
                              height: 3,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                        // Swap icon overlay
                        Positioned(
                          bottom: 5,
                          right: 5,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.swap_horiz,
                                color: Colors.white, size: 10),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Bottom Media Controls ────────────────────────────────────────
              Positioned(
                left: 0,
                right: 0,
                bottom: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildControlBtn(
                      icon: _media.isMicMuted ? Icons.mic_off : Icons.mic,
                      color: _media.isMicMuted
                          ? _kDangerRed
                          : Colors.white.withValues(alpha: 0.12),
                      iconColor: Colors.white,
                      tooltip: _media.isMicMuted
                          ? 'Unmute Microphone'
                          : 'Mute Microphone',
                      onTap: () {
                        _media.toggleMicrophone();
                        // Show feedback snackbar
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          backgroundColor: _media.isMicMuted
                              ? _kDangerRed
                              : _kBrandGreen,
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 1),
                          content: Text(
                            _media.isMicMuted
                                ? '🎤 Microphone muted'
                                : '🎤 Microphone on',
                            style: GoogleFonts.inter(color: Colors.white),
                          ),
                        ));
                      },
                    ),
                    _buildControlBtn(
                      icon: _media.isVideoOff
                          ? Icons.videocam_off
                          : Icons.videocam,
                      color: _media.isVideoOff
                          ? _kDangerRed
                          : Colors.white.withValues(alpha: 0.12),
                      iconColor: Colors.white,
                      tooltip: _media.isVideoOff
                          ? 'Turn On Camera'
                          : 'Turn Off Camera',
                      onTap: () {
                        _media.toggleVideo();
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          backgroundColor: _media.isVideoOff
                              ? _kDangerRed
                              : _kBrandGreen,
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 1),
                          content: Text(
                            _media.isVideoOff
                                ? '📷 Camera turned off'
                                : '📷 Camera turned on',
                            style: GoogleFonts.inter(color: Colors.white),
                          ),
                        ));
                      },
                    ),
                    _buildControlBtn(
                      icon: _media.isScreenSharing
                          ? Icons.screen_share
                          : Icons.stop_screen_share,
                      color: _media.isScreenSharing
                          ? _kBrandBlue
                          : Colors.white.withValues(alpha: 0.12),
                      iconColor: Colors.white,
                      tooltip: _media.isScreenSharing
                          ? 'Stop Screen Share'
                          : 'Share Screen',
                      onTap: () async {
                        if (_media.isScreenSharing) {
                          _media.stopScreenShare();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            backgroundColor: _kCardBg,
                            behavior: SnackBarBehavior.floating,
                            content: Text(
                              'Screen sharing stopped',
                              style: GoogleFonts.inter(color: Colors.white),
                            ),
                          ));
                        } else {
                          final ok = await _media.startScreenShare();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              backgroundColor:
                                  ok ? _kBrandBlue : _kDangerRed,
                              behavior: SnackBarBehavior.floating,
                              content: Text(
                                ok
                                    ? '🖥️ Screen sharing started'
                                    : _media.lastError ?? 'Screen share failed',
                                style: GoogleFonts.inter(color: Colors.white),
                              ),
                            ));
                          }
                        }
                      },
                    ),
                    // Camera switch button — always shown; message if only 1 cam
                    _buildControlBtn(
                      icon: Icons.switch_camera_outlined,
                      color: Colors.white.withValues(alpha: 0.12),
                      iconColor: Colors.white,
                      tooltip: _media.hasMultipleCameras
                          ? 'Switch Camera'
                          : 'No back camera on this device',
                      onTap: _switchCamera,
                    ),
                    const SizedBox(width: 16),
                    // End call button
                    _buildControlBtn(
                      icon: Icons.call_end,
                      color: _kDangerRed,
                      iconColor: Colors.white,
                      tooltip: 'End Call',
                      onTap: _endCall,
                      size: 52,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Patient main view: simulate patient stream with avatar fallback
  Widget _buildPatientMainView(Map<String, dynamic> patient) {
    return WebVideoView(
      videoUrl:
          'https://assets.mixkit.co/videos/preview/mixkit-patient-lying-in-bed-talking-to-doctor-41604-large.mp4',
      mirror: false,
      muted: true,
    );
  }

  // Doctor main view: shows REAL camera via WebMediaService
  Widget _buildDoctorMainView() {
    if (_media.isVideoOff) {
      return Container(
        color: const Color(0xFF0D1529),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 44,
              backgroundColor: _kBrandBlue.withValues(alpha: 0.12),
              child: Text(
                'DB',
                style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Dr. Baig — Camera Off',
              style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }

    if (_media.camPermission == MediaPermissionState.idle ||
        _media.camPermission == MediaPermissionState.denied) {
      return MediaPermissionGate(
        state: _media.camPermission,
        errorMessage: _media.lastError,
        onRequestPermission: _requestMediaPermissions,
      );
    }

    if (_media.camPermission == MediaPermissionState.requesting) {
      return MediaPermissionGate(
        state: MediaPermissionState.requesting,
        onRequestPermission: _requestMediaPermissions,
      );
    }

    if (_media.localStream != null) {
      // Mirror if front camera
      final mirror = _media.currentCamera?.isFront ?? true;
      return WebVideoView(
        stream: _media.localStream,
        mirror: mirror,
        muted: true, // mute local preview to prevent echo
      );
    }

    // Fallback if stream not yet ready
    return Container(
      color: const Color(0xFF0D1529),
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: _kBrandBlue,
        ),
      ),
    );
  }

  // Patient PiP content (fallback avatar)
  Widget _buildPatientPipContent(Map<String, dynamic> patient) {
    return WebVideoView(
      videoUrl:
          'https://assets.mixkit.co/videos/preview/mixkit-patient-lying-in-bed-talking-to-doctor-41604-large.mp4',
      mirror: false,
      muted: true,
    );
  }

  // Doctor PiP content: REAL camera via WebMediaService
  Widget _buildDoctorPipContent() {
    if (_media.isVideoOff) {
      return Container(
        color: const Color(0xFF131935),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: _kBrandBlue.withValues(alpha: 0.2),
                child: Text(
                  'DB',
                  style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Cam Off',
                style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 8),
              ),
            ],
          ),
        ),
      );
    }

    if (_media.localStream != null) {
      final mirror = _media.currentCamera?.isFront ?? true;
      return WebVideoView(
        stream: _media.localStream,
        mirror: mirror,
        muted: true,
      );
    }

    return Container(
      color: const Color(0xFF131935),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: _kBrandBlue.withValues(alpha: 0.2),
              child: Text(
                'DB',
                style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Dr. Baig',
              style: GoogleFonts.inter(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 8),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioLevelBars() {
    return AnimatedBuilder(
      animation: _audioLevelController,
      builder: (context, _) {
        return Row(
          children: List.generate(8, (i) {
            final double height =
                4 + math.sin(_audioLevelController.value * math.pi * 2 + i) * 10 + 6;
            return Container(
              margin: const EdgeInsets.only(right: 3),
              width: 3,
              height: height.clamp(4.0, 20.0),
              decoration: BoxDecoration(
                color: _kBrandGreen,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildControlBtn({
    required IconData icon,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
    String? tooltip,
    double size = 44,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: Tooltip(
        message: tooltip ?? '',
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(size / 2),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Icon(icon, color: iconColor, size: size * 0.42),
          ),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // CHAT PANEL
  // ────────────────────────────────────────────────────────────────────────────
  Widget _buildChatPanel() {
    return AppCard(
      color: _kCardBg,
      borderRadius: AppRadius.radius12,
      border: Border.all(color: _kCardBorder),
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        height: 440,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.chat_bubble_outline_rounded,
                    color: _kBrandBlue, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Secure Session Chat',
                  style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _kBrandGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'E2EE',
                    style: GoogleFonts.inter(
                        color: _kBrandGreen,
                        fontSize: 8,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                controller: _chatScrollController,
                physics: const BouncingScrollPhysics(),
                itemCount: _chatHistory.length,
                itemBuilder: (context, index) {
                  final msg = _chatHistory[index];
                  final isMe = msg.sender.startsWith('Dr.');
                  final isSystem = msg.sender == 'System';

                  if (isSystem) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Center(
                        child: Text(
                          msg.text,
                          style: GoogleFonts.inter(
                              color: _kTextGray.withValues(alpha: 0.6),
                              fontSize: 9.5,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.all(9.0),
                        constraints: const BoxConstraints(maxWidth: 230.0),
                        decoration: BoxDecoration(
                          color: isMe
                              ? _kBrandBlue.withValues(alpha: 0.12)
                              : Colors.white.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(10),
                            topRight: const Radius.circular(10),
                            bottomLeft: isMe
                                ? const Radius.circular(10)
                                : Radius.zero,
                            bottomRight: isMe
                                ? Radius.zero
                                : const Radius.circular(10),
                          ),
                          border: Border.all(
                            color: isMe
                                ? _kBrandBlue.withValues(alpha: 0.2)
                                : Colors.white.withValues(alpha: 0.04),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              msg.sender,
                              style: GoogleFonts.inter(
                                  fontSize: 9,
                                  color: isMe ? _kBrandBlue : _kTextGray,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              msg.text,
                              style: GoogleFonts.inter(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 11.5),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              msg.time,
                              style: GoogleFonts.inter(
                                  color: _kTextGray.withValues(alpha: 0.5),
                                  fontSize: 8.5),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 12),
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: GoogleFonts.inter(
                          color: _kTextGray.withValues(alpha: 0.4),
                          fontSize: 12),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.02),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: _kCardBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            BorderSide(color: _kBrandBlue, width: 1.2),
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: _kBrandBlue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send_rounded,
                        color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    setState(() {
      _chatHistory.add(ChatMessage(
        sender: 'Dr. Sarah Jenkins',
        text: _messageController.text.trim(),
        time: 'Just now',
      ));
    });
    _messageController.clear();
    // Auto-scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ────────────────────────────────────────────────────────────────────────────
  // HELPERS
  // ────────────────────────────────────────────────────────────────────────────
  Color _getDoctorStatusColor(String status) {
    switch (status.trim().toLowerCase()) {
      case 'in session':
        return _kDangerRed;
      case 'available':
        return _kBrandGreen;
      case 'offline':
        return _kTextGray;
      default:
        return _kTextGray;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HOVER CARD WIDGET (SaaS hover elevation effect)
// ─────────────────────────────────────────────────────────────────────────────
class _HoverCard extends StatefulWidget {
  final Widget child;
  const _HoverCard({required this.child});

  @override
  State<_HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<_HoverCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: _isHovered
            ? (Matrix4.identity()..translate(0, -4, 0))
            : Matrix4.identity(),
        decoration: BoxDecoration(
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: _kBrandBlue.withValues(alpha: 0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  )
                ]
              : [],
        ),
        child: widget.child,
      ),
    );
  }
}
