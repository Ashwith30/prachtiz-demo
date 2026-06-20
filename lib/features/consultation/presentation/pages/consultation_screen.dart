import "package:prachtiz_flutter/core/theme/app_colors.dart";
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/services/web_media_service.dart';
import '../../../../shared/widgets/web_video_view.dart';


// Unified Brand Colors (Matches CallHealth & PraCHtiz dark theme guidelines)
const Color _kCanvasBg = Color(0xFF0A0C16);    // Dark canvas background
const Color _kCardBg = Color(0xFF11152D);      // Flat Dark Navy card background
final Color _kCardBorder = Colors.white.withOpacity(0.08);
Color _kBrandBlue = AppColors.primary;   // Primary theme color
const Color _kBrandGreen = Color(0xFF24C06F);  // Success theme color
const Color _kTextGray = Color(0xFF94A3B8);    // Muted text grey
const Color _kDangerRed = Color(0xFFEF4444);   // Warning badge color
const Color _kWarningAmber = Color(0xFFF59E0B); // Alert color
const Color _kPurple = Color(0xFF8B5CF6);       // Purple accent color
const Color _kIndigo = Color(0xFF6366F1);       // Indigo accent color
const Color _kPink = Color(0xFFEC4899);         // Pink accent color

class ConsultationScreen extends StatefulWidget {
  const ConsultationScreen({super.key});

  @override
  State<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen> with SingleTickerProviderStateMixin {
  // Navigation & View Mode State
  int _selectedLeftViewMode = 2; // 0 = EMR Timeline, 1 = ECG Telemetry, 2 = Video Consult (Default)
  int _activeTabIdx = 0; // Active Right tab: Vitals, Complaint, Diagnosis, Medications, Advice, Investigation, Follow Up, Invoice

  // ── Web Media Service (real camera/mic/screen via dart:html) ─────────────────
  final WebMediaService _media = WebMediaService();

  // Draggable PiP Position state
  double _pipTop = 70.0;
  double _pipRight = 16.0;

  // Resizable Left viewport width
  double? _leftPaneWidth;

  // Animation controller for real-time ECG simulation
  late AnimationController _ecgAnimController;

  // ────────────────────────────────────────────────────────────────────────────
  // MEDIA — request real browser camera + mic + screen sharing
  // ────────────────────────────────────────────────────────────────────────────
  Future<void> _requestMediaPermissions() async {
    final ok = await _media.requestAndStartMedia();
    if (mounted) setState(() {});
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: _kDangerRed,
        behavior: SnackBarBehavior.floating,
        content: Text(
          _media.lastError ?? 'Camera permission denied.',
          style: GoogleFonts.inter(color: Colors.white),
        ),
      ));
    }
  }

  Future<void> _switchCamera() async {
    final msg = await _media.switchCamera();
    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor:
            _media.hasMultipleCameras ? _kBrandBlue : _kWarningAmber,
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            Icon(
              _media.hasMultipleCameras
                  ? Icons.switch_camera_outlined
                  : Icons.laptop_mac_outlined,
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
      ));
    }
  }

  void _onMediaChanged() {
    if (mounted) setState(() {});
  }


  // Active Patient local state data
  final String _patientName = "James Carter";
  final String _patientId = "P-20240125-001";
  final String _chiefComplaintInitial = "Pain near left chest, Pelvic salinity";
  final String _patientMeta = "28 Yrs - Male • O +ve • Cardiology • 25 Jan 2025, 07:00 AM • Online Consultation";

  // Tab 1: Vitals State
  late Map<String, Map<String, dynamic>> _vitalsData;

  // Tab 2: Complaint State
  late TextEditingController _complaintController;
  final List<String> _symptomChecklist = ["Chest Tightness", "Shortness of Breath", "Radiation to Left Arm", "Dizziness", "Fatigue", "Nausea", "Palpitations"];
  final Set<String> _selectedSymptoms = {"Chest Tightness"};

  // Tab 3: Diagnosis State
  final List<Map<String, String>> _diagnosesList = [
    {"code": "I20.9", "name": "Angina pectoris, unspecified", "severity": "Moderate"},
    {"code": "I10", "name": "Essential (primary) hypertension", "severity": "Mild"},
  ];
  final TextEditingController _diagSearchController = TextEditingController();
  String _selectedSeverity = "Mild";

  // Tab 4: Medications State
  final List<Map<String, String>> _prescriptionsList = [
    {"drug": "Nitroglycerin 0.4mg sublingual", "dose": "1 tab as needed", "freq": "PRN", "duration": "10 days"},
    {"drug": "Metoprolol succinate 50mg", "dose": "1 tablet", "freq": "Once daily", "duration": "30 days"},
    {"drug": "Aspirin 81mg EC", "dose": "1 tablet", "freq": "Once daily", "duration": "90 days"},
  ];
  final TextEditingController _drugNameController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  String _selectedFreq = "Once daily";
  String _selectedDuration = "30 days";

  // Tab 5: Advice State
  late TextEditingController _adviceController;

  // Tab 6: Investigation State
  final List<Map<String, dynamic>> _investigationsList = [
    {"test": "ECG 12-Lead (Standard)", "price": 50.0, "checked": true},
    {"test": "Lipid Profile Panel", "price": 45.0, "checked": false},
    {"test": "Complete Blood Count (CBC)", "price": 30.0, "checked": false},
    {"test": "Chest X-Ray (PA View)", "price": 35.0, "checked": true},
    {"test": "Cardiac Troponin T Test", "price": 60.0, "checked": false},
  ];

  // Tab 7: Follow Up State
  String _followUpInterval = "1 Week";
  DateTime _followUpDate = DateTime.now().add(const Duration(days: 7));
  final TextEditingController _followUpNotesController = TextEditingController(text: "Repeat ECG if chest pain persists. Review diagnostic panels in clinic.");

  // Tab 8: Invoice State
  double _discountPercent = 10.0; // 10% default discount

  @override
  void initState() {
    super.initState();
    _media.addListener(_onMediaChanged);
    _ecgAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _vitalsData = {
      "Blood Pressure": {"val": "120/80", "unit": "mmHg", "color": _kBrandBlue},
      "Heart Rate": {"val": "72", "unit": "bpm", "color": _kWarningAmber},
      "Temperature": {"val": "98.6", "unit": "°F", "color": _kPurple},
      "SpO2": {"val": "98", "unit": "%", "color": _kBrandGreen},
      "Resp. Rate": {"val": "18", "unit": "br/min", "color": _kIndigo},
      "Weight": {"val": "74", "unit": "kg", "color": _kPink},
    };

    _complaintController = TextEditingController(text: _chiefComplaintInitial);
    _adviceController = TextEditingController(text: "1. Strict bed rest for the next 48 hours.\n2. Avoid strenuous physical activities or lifting heavy loads.\n3. Administer sublingual Nitroglycerin immediately in case of acute angina recurrence.\n4. Take metoprolol succinate in the morning after breakfast.");
  }

  @override
  void dispose() {
    _media.removeListener(_onMediaChanged);
    _media.stopAll();
    _ecgAnimController.dispose();
    _complaintController.dispose();
    _diagSearchController.dispose();
    _drugNameController.dispose();
    _dosageController.dispose();
    _adviceController.dispose();
    _followUpNotesController.dispose();
    super.dispose();
  }

  // Quick symptom toggler
  void _toggleSymptom(String symptom) {
    setState(() {
      if (_selectedSymptoms.contains(symptom)) {
        _selectedSymptoms.remove(symptom);
      } else {
        _selectedSymptoms.add(symptom);
      }
      // Rebuild complaints field text
      List<String> activeList = [_chiefComplaintInitial, ..._selectedSymptoms];
      _complaintController.text = activeList.join(", ");
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 1024;

    return Container(
      color: _kCanvasBg,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Initialize split pane width on desktop if null
          if (isDesktop && _leftPaneWidth == null) {
            _leftPaneWidth = constraints.maxWidth * 0.45; // Start at 45%
          }

          if (isDesktop) {
            return SizedBox(
              height: constraints.maxHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left panel with resizable width
                  SizedBox(
                    width: _leftPaneWidth,
                    child: _buildLeftClinicalViewport(isDesktop),
                  ),

                  // Draggable Divider Resize Handle
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onHorizontalDragUpdate: (details) {
                      setState(() {
                        // Clamp the resizable width between 25% and 75% of screen width
                        _leftPaneWidth = (_leftPaneWidth! + details.delta.dx).clamp(
                          constraints.maxWidth * 0.25,
                          constraints.maxWidth * 0.75,
                        );
                      });
                    },
                    child: MouseRegion(
                      cursor: SystemMouseCursors.resizeLeftRight,
                      child: Container(
                        width: 16,
                        color: Colors.transparent,
                        child: Center(
                          child: Container(
                            width: 2,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Right panel takes up all remaining space
                  Expanded(
                    child: _buildRightControlsPanel(),
                  ),
                ],
              ),
            );
          } else {
            // Mobile viewport stack
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildLeftClinicalViewport(isDesktop),
                  const SizedBox(height: 16),
                  _buildRightControlsPanel(),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // LEFT CLINICAL VIEWPORT PANEL
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildLeftClinicalViewport(bool isDesktop) {
    return Container(
      height: isDesktop ? double.infinity : 420.0,
      decoration: BoxDecoration(
        color: const Color(0xFF070913),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08), width: 1.2),
      ),
      child: Stack(
        children: [
          // Viewport Content depending on state
          Positioned.fill(
            child: _buildLeftViewportBody(),
          ),

          // Top Left Floating Bar View Toggles
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Row(
                children: [
                  _buildViewportToggleBtn(Icons.assignment_outlined, 0),
                  _buildViewportToggleBtn(Icons.show_chart, 1),
                  _buildViewportToggleBtn(Icons.videocam_outlined, 2),
                ],
              ),
            ),
          ),

          // E2EE Indicator badge in Call View
          if (_selectedLeftViewMode == 2)
            Positioned(
              top: 20,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _kBrandGreen.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _kBrandGreen.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: _kBrandGreen,
                        shape: BoxShape.circle,
                      ),
                    ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1.seconds),
                    const SizedBox(width: 6),
                    Text(
                      "E2EE SECURE",
                      style: GoogleFonts.inter(
                        color: _kBrandGreen,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildViewportToggleBtn(IconData icon, int modeIdx) {
    final bool isSelected = _selectedLeftViewMode == modeIdx;
    return GestureDetector(
      onTap: () => setState(() => _selectedLeftViewMode = modeIdx),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: isSelected ? _kBrandBlue : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 18,
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.4),
        ),
      ),
    );
  }

  Widget _buildLeftViewportBody() {
    switch (_selectedLeftViewMode) {
      case 0:
        return _buildEmrTimelineViewport();
      case 1:
        return _buildEcgTelemetryViewport();
      case 2:
      default:
        return _buildVideoConsultViewport();
    }
  }

  // 1. EMR Timeline Sub-Viewport
  Widget _buildEmrTimelineViewport() {
    final List<Map<String, String>> timelineLogs = [
      {"date": "12 Dec 2025", "title": "Hypertension Follow-Up", "details": "Clinician: Dr. Sarah Mitchell\nBP: 138/92 mmHg, HR: 80 bpm. Advised salt restriction and mild walking. Continued Amlodipine 5mg QD."},
      {"date": "15 Oct 2025", "title": "Cardiology Screening & ECG", "details": "Clinician: Dr. Williams\nNormal Sinus Rhythm. Mild ST-segment deviation noted during exertion. Ordered echocardiogram diagnostics."},
      {"date": "04 Jun 2025", "title": "General Health Examination", "details": "Clinician: Dr. Patel\nComplains of occasional chest tightness. Cholesterol levels borderline. Scheduled lifestyle intervention program."},
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 70.0, left: 16, right: 16, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Patient Clinical EMR History",
            style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: timelineLogs.length,
              itemBuilder: (context, idx) {
                final log = timelineLogs[idx];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.02),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white.withOpacity(0.04)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(log["title"]!, style: GoogleFonts.inter(color: _kBrandBlue, fontSize: 12, fontWeight: FontWeight.bold)),
                            Text(log["date"]!, style: GoogleFonts.inter(color: _kTextGray, fontSize: 10)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          log["details"]!,
                          style: GoogleFonts.inter(color: Colors.white.withOpacity(0.8), fontSize: 11, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 2. ECG Waveform Telemetry Viewport
  Widget _buildEcgTelemetryViewport() {
    return Padding(
      padding: const EdgeInsets.only(top: 70.0, left: 16, right: 16, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "ECG Vitals Telemetry Live",
                style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _kBrandGreen.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text("Live Feed", style: GoogleFonts.inter(color: _kBrandGreen, fontSize: 9, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withOpacity(0.15)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AnimatedBuilder(
                  animation: _ecgAnimController,
                  builder: (context, _) {
                    return CustomPaint(
                      painter: _EcgWavePainter(phase: _ecgAnimController.value),
                      child: Container(),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTelemetryIndicator("PR INTERVAL", "148 ms", _kBrandGreen),
              _buildTelemetryIndicator("QRS DURATION", "92 ms", _kBrandBlue),
              _buildTelemetryIndicator("QT/QTc", "380/420 ms", _kPurple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTelemetryIndicator(String title, String val, Color col) {
    return Column(
      children: [
        Text(title, style: GoogleFonts.inter(color: _kTextGray, fontSize: 9, fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(val, style: GoogleFonts.robotoMono(color: col, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  // 3. E2EE Video Consult Viewport — REAL camera / mic / screen share
  Widget _buildVideoConsultViewport() {
    return Stack(
      children: [
        // ── MAIN: Patient cam (remote) OR Doctor cam (local, when expanded) ──────
        Positioned.fill(
          child: _buildMainVideoArea(),
        ),

        // ── Gradient overlay ─────────────────────────────────────────────────────
        if (_media.localStream != null && !_media.isVideoOff)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.6),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.5),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

        // ── Patient label (top-left) ──────────────────────────────────────────────
        Positioned(
          left: 16,
          top: 70,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'James Carter (Patient)',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Container(
                    width: 6, height: 6,
                    decoration: const BoxDecoration(
                      color: _kBrandGreen, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Connected • 24ms latency',
                    style: GoogleFonts.inter(
                      color: _kTextGray,
                      fontSize: 10,
                      shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // ── Screen-share indicator banner ─────────────────────────────────────────
        if (_media.isScreenSharing)
          Positioned(
            top: 70,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: _kBrandBlue.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.screen_share, color: Colors.white, size: 13),
                    const SizedBox(width: 6),
                    Text(
                      'You are sharing your screen',
                      style: GoogleFonts.inter(
                          color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // ── Live Audio level bars ─────────────────────────────────────────────────
        if (!_media.isMicMuted && _media.isInitialized)
          Positioned(
            left: 20,
            bottom: 80,
            child: Row(
              children: List.generate(8, (idx) {
                final int rh = math.Random().nextInt(20) + 4;
                return Container(
                  margin: const EdgeInsets.only(right: 3),
                  width: 3,
                  height: rh.toDouble(),
                  decoration: BoxDecoration(
                    color: _kBrandGreen,
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }),
            ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1.seconds),
          ),

        // ── Draggable Doctor PiP ──────────────────────────────────────────────────
        Positioned(
          top: _pipTop,
          right: _pipRight,
          child: GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                _pipTop = (_pipTop + details.delta.dy).clamp(10.0, 260.0);
                _pipRight = (_pipRight - details.delta.dx).clamp(10.0, 360.0);
              });
            },
            child: Container(
              width: 100,
              height: 130,
              decoration: BoxDecoration(
                color: const Color(0xFF131935),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _buildDoctorPip(),
                    ),
                  ),
                  // Drag handle
                  Positioned(
                    top: 4, left: 0, right: 0,
                    child: Center(
                      child: Container(
                        width: 20, height: 3,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                  // Cam status icon
                  Positioned(
                    bottom: 6, right: 6,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _media.isVideoOff ? Icons.videocam_off : Icons.videocam,
                        color: _media.isVideoOff ? _kDangerRed : _kBrandGreen,
                        size: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ── Bottom Media Control Bar ──────────────────────────────────────────────
        Positioned(
          bottom: 16, left: 0, right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. Mic toggle — real hardware mute
                  _buildCallMediaBtn(
                    _media.isMicMuted ? Icons.mic_off : Icons.mic,
                    !_media.isMicMuted,
                    () {
                      _media.toggleMicrophone();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        backgroundColor:
                            _media.isMicMuted ? _kDangerRed : _kBrandGreen,
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
                    tooltip: _media.isMicMuted ? 'Unmute' : 'Mute',
                  ),
                  const SizedBox(width: 12),
                  // 2. Camera toggle — real track.enabled
                  _buildCallMediaBtn(
                    _media.isVideoOff ? Icons.videocam_off : Icons.videocam,
                    !_media.isVideoOff,
                    () {
                      if (!_media.isInitialized) {
                        _requestMediaPermissions();
                        return;
                      }
                      _media.toggleVideo();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        backgroundColor:
                            _media.isVideoOff ? _kDangerRed : _kBrandGreen,
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 1),
                        content: Text(
                          _media.isVideoOff
                              ? '📷 Camera off'
                              : '📷 Camera on',
                          style: GoogleFonts.inter(color: Colors.white),
                        ),
                      ));
                    },
                    tooltip: _media.isVideoOff ? 'Turn On Camera' : 'Turn Off Camera',
                  ),
                  const SizedBox(width: 12),
                  // 3. Screen share — real getDisplayMedia
                  _buildCallMediaBtn(
                    _media.isScreenSharing
                        ? Icons.screen_share
                        : Icons.stop_screen_share,
                    _media.isScreenSharing,
                    () async {
                      if (_media.isScreenSharing) {
                        _media.stopScreenShare();
                      } else {
                        final ok = await _media.startScreenShare();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            backgroundColor: ok ? _kBrandBlue : _kDangerRed,
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
                    tooltip: _media.isScreenSharing
                        ? 'Stop Sharing'
                        : 'Share Screen',
                  ),
                  const SizedBox(width: 12),
                  // 4. Camera switch — with laptop message
                  _buildCallMediaBtn(
                    Icons.switch_camera_outlined,
                    true,
                    _switchCamera,
                    tooltip: _media.hasMultipleCameras
                        ? 'Switch Camera'
                        : 'No back camera on this device',
                  ),
                  const SizedBox(width: 12),
                  // 5. Swap to ECG view
                  GestureDetector(
                    onTap: () {
                      setState(() => _selectedLeftViewMode = 1);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        backgroundColor: _kBrandBlue,
                        content: Text(
                          'Switched viewport to Live ECG Vitals Feed.',
                          style: GoogleFonts.inter(color: Colors.white),
                        ),
                      ));
                    },
                    child: Tooltip(
                      message: 'Switch to ECG View',
                      child: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: const Icon(Icons.swap_horiz,
                            color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Main video area: patient cam (remote) — simulated with remote video loop
  Widget _buildMainVideoArea() {
    return WebVideoView(
      videoUrl:
          'https://assets.mixkit.co/videos/preview/mixkit-patient-lying-in-bed-talking-to-doctor-41604-large.mp4',
      mirror: false,
      muted: true,
      overlay: Positioned(
        bottom: 12,
        left: 12,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'James Carter (Patient)',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Doctor PiP: real local camera stream
  Widget _buildDoctorPip() {
    if (_media.localStream != null && !_media.isVideoOff) {
      final mirror = _media.currentCamera?.isFront ?? true;
      return WebVideoView(
        stream: _media.localStream,
        mirror: mirror,
        muted: true,
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: _kBrandBlue.withValues(alpha: 0.2),
            child: Text(
              'DB',
              style: GoogleFonts.inter(
                  color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Dr. Baig\n(Doctor)',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 9,
                height: 1.2),
          ),
        ],
      ),
    );
  }

  Widget _buildCallMediaBtn(IconData icon, bool isOn, VoidCallback onTap,
      {String? tooltip}) {
    final btn = GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: isOn ? _kBrandBlue : _kDangerRed.withValues(alpha: 0.18),
          shape: BoxShape.circle,
          border: Border.all(
              color: isOn ? _kBrandBlue : _kDangerRed.withValues(alpha: 0.4)),
        ),
        child: Icon(icon, size: 16, color: isOn ? Colors.white : _kDangerRed),
      ),
    );
    if (tooltip != null) return Tooltip(message: tooltip, child: btn);
    return btn;
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // RIGHT PANELS (Profile, Tabs, Tab views, Action Buttons)
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildRightControlsPanel() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive horizontal padding: shrinks as pane narrows
        final double w = constraints.maxWidth;
        final double hPad = w < 380 ? 8.0 : (w < 560 ? 12.0 : 16.0);

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: hPad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Patient Profile Header Card
              _buildPatientProfileHeaderCard(),
              const SizedBox(height: 12),

              // 2. Horizontal Scrollable Navigation Tabs
              _buildNavigationTabsSystem(),
              const SizedBox(height: 12),

              // 3. Tab Area container
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(w < 420 ? 10.0 : 16.0),
                  decoration: BoxDecoration(
                    color: _kCardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _kCardBorder),
                  ),
                  child: _buildActiveTabContentWidget(),
                ),
              ),
              const SizedBox(height: 12),

              // 4. Bottom Control Action Buttons
              _buildBottomActionButtonsRow(w),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  // Profile Header Card builder
  Widget _buildPatientProfileHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1E2652),
            _kCardBg,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kCardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // JC avatar bubble
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _kBrandBlue.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(color: _kBrandBlue.withOpacity(0.4), width: 1.5),
            ),
            child: Center(
              child: Text(
                "JC",
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Name and ID details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      _patientName,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _patientId,
                        style: GoogleFonts.robotoMono(
                          color: _kTextGray,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  _complaintController.text,
                  style: GoogleFonts.inter(
                    color: _kWarningAmber,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 6),

                // Meta Tag lists
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: _patientMeta.split("•").map((tag) {
                      return Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _kBrandBlue.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: _kBrandBlue.withOpacity(0.12)),
                        ),
                        child: Text(
                          tag.trim(),
                          style: GoogleFonts.inter(
                            color: _kBrandBlue,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Horizontal Tab Navigation — responsive & scroll-indicator-aware
  Widget _buildNavigationTabsSystem() {
    final List<String> tabLabels = [
      "Vitals",
      "Complaint",
      "Diagnosis",
      "Medications",
      "Advice",
      "Investigation",
      "Follow Up",
      "Invoice",
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final double w = constraints.maxWidth;

        // Breakpoints: shrink padding + font as the right pane narrows
        final bool isTiny    = w < 420;
        final bool isCompact = w < 620;

        final double hPad    = isTiny ? 7.0  : (isCompact ? 10.0 : 14.0);
        final double vPad    = isTiny ? 7.0  : 9.0;
        final double fontSize= isTiny ? 10.0 : (isCompact ? 11.0 : 12.0);
        final double gap     = isTiny ? 4.0  : 6.0;

        // Estimate natural total width to decide whether fade arrow is needed
        final double estimatedTotal = tabLabels.fold(
          0.0,
          (sum, label) => sum + (hPad * 2) + gap + (label.length * fontSize * 0.70),
        );
        final bool needsScrollHint = estimatedTotal > w;

        return Stack(
          children: [
            // Scrollable tab row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: List.generate(tabLabels.length, (idx) {
                  final bool isActive = _activeTabIdx == idx;
                  return GestureDetector(
                    onTap: () => setState(() => _activeTabIdx = idx),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      margin: EdgeInsets.only(right: gap),
                      padding: EdgeInsets.symmetric(
                          horizontal: hPad, vertical: vPad),
                      decoration: BoxDecoration(
                        color: isActive ? _kBrandBlue : _kCardBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isActive ? _kBrandBlue : _kCardBorder,
                        ),
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: _kBrandBlue.withValues(alpha: 0.28),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : [],
                      ),
                      child: Text(
                        tabLabels[idx],
                        style: GoogleFonts.inter(
                          color: isActive
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.65),
                          fontSize: fontSize,
                          fontWeight: isActive
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Right-edge fade + chevron only when content overflows
            if (needsScrollHint)
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: IgnorePointer(
                  child: Container(
                    width: 36,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          _kCardBg.withValues(alpha: 0.96),
                        ],
                      ),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 4),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white.withValues(alpha: 0.45),
                      size: 16,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  // Active Tab content router
  Widget _buildActiveTabContentWidget() {
    switch (_activeTabIdx) {
      case 0:
        return _buildVitalsTabContent();
      case 1:
        return _buildComplaintTabContent();
      case 2:
        return _buildDiagnosisTabContent();
      case 3:
        return _buildMedicationsTabContent();
      case 4:
        return _buildAdviceTabContent();
      case 5:
        return _buildInvestigationTabContent();
      case 6:
        return _buildFollowUpTabContent();
      case 7:
        return _buildInvoiceTabContent();
      default:
        return Container();
    }
  }

  // 1. Vitals Tab Panel
  Widget _buildVitalsTabContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.favorite_outline, color: _kBrandBlue, size: 18),
                const SizedBox(width: 8),
                Text(
                  "Clinical Vitals",
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Text(
              "Tap card to edit metric value",
              style: GoogleFonts.inter(color: _kTextGray, fontSize: 11),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: LayoutBuilder(
            builder: (context, box) {
              final int crossAxisCount = box.maxWidth >= 500 ? 3 : 2;
              return GridView.count(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.4,
                children: _vitalsData.keys.map((title) {
                  final metric = _vitalsData[title]!;
                  return _buildVitalGridCard(title, metric["val"], metric["unit"], metric["color"]);
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVitalGridCard(String title, String val, String unit, Color accentColor) {
    return GestureDetector(
      onTap: () => _showEditVitalDialog(title),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _kCardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Styled Accent indicator top line
            Container(
              height: 3,
              width: 40,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title.toUpperCase(),
              style: GoogleFonts.inter(
                color: _kTextGray,
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            const Spacer(),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: val,
                    style: GoogleFonts.robotoMono(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const TextSpan(text: " "),
                  TextSpan(
                    text: unit,
                    style: GoogleFonts.inter(
                      color: _kTextGray,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }

  void _showEditVitalDialog(String vitalKey) {
    final Map<String, dynamic> item = _vitalsData[vitalKey]!;
    final controller = TextEditingController(text: item["val"].toString());
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: _kCardBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: _kCardBorder),
          ),
          title: Text(
            "Update $vitalKey",
            style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                style: GoogleFonts.inter(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Value (${item["unit"]})",
                  labelStyle: GoogleFonts.inter(color: _kTextGray),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: _kCardBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: _kBrandBlue),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: GoogleFonts.inter(color: _kTextGray)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: _kBrandBlue),
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  setState(() {
                    _vitalsData[vitalKey]!["val"] = controller.text.trim();
                  });
                }
                Navigator.pop(context);
              },
              child: Text("Save", style: GoogleFonts.inter(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // 2. Complaint Tab Panel
  Widget _buildComplaintTabContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.chat_bubble_outline, color: _kBrandBlue, size: 18),
            const SizedBox(width: 8),
            Text(
              "Chief Complaints & Symptoms",
              style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _complaintController,
          maxLines: 3,
          style: GoogleFonts.inter(color: Colors.white, fontSize: 12.5),
          decoration: InputDecoration(
            hintText: "Enter chief complaints...",
            hintStyle: GoogleFonts.inter(color: _kTextGray.withOpacity(0.5)),
            filled: true,
            fillColor: Colors.white.withOpacity(0.01),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: _kCardBorder),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: _kBrandBlue, width: 1.2),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text("QUICK TOGGLE SYMPTOMS:", style: GoogleFonts.inter(color: _kTextGray, fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _symptomChecklist.map((symptom) {
                final bool isSelected = _selectedSymptoms.contains(symptom);
                return FilterChip(
                  label: Text(symptom),
                  selected: isSelected,
                  labelStyle: GoogleFonts.inter(
                    color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  selectedColor: _kBrandBlue,
                  checkmarkColor: Colors.white,
                  backgroundColor: Colors.white.withOpacity(0.02),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected ? _kBrandBlue : _kCardBorder,
                    ),
                  ),
                  onSelected: (_) => _toggleSymptom(symptom),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  // 3. Diagnosis Tab Panel
  Widget _buildDiagnosisTabContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.assignment_outlined, color: _kBrandBlue, size: 18),
            const SizedBox(width: 8),
            Text(
              "EMR Diagnosis & ICD-10 Coding",
              style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Quick add row
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _diagSearchController,
                style: GoogleFonts.inter(color: Colors.white, fontSize: 12),
                decoration: InputDecoration(
                  hintText: "Search ICD-10 (e.g. Angina, Hypertension)...",
                  hintStyle: GoogleFonts.inter(color: _kTextGray.withOpacity(0.5), fontSize: 12),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.01),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: _kCardBorder),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: _kBrandBlue, width: 1.2),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: _kCardBorder),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedSeverity,
                  dropdownColor: _kCardBg,
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 12),
                  items: ["Mild", "Moderate", "Severe"].map((String val) {
                    return DropdownMenuItem<String>(value: val, child: Text(val));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedSeverity = val);
                  },
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.add_circle, color: _kBrandBlue, size: 28),
              onPressed: () {
                if (_diagSearchController.text.isNotEmpty) {
                  setState(() {
                    _diagnosesList.add({
                      "code": "ICD-${math.Random().nextInt(900) + 100}",
                      "name": _diagSearchController.text.trim(),
                      "severity": _selectedSeverity,
                    });
                    _diagSearchController.clear();
                  });
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Added diagnoses list
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: _diagnosesList.length,
            itemBuilder: (context, idx) {
              final item = _diagnosesList[idx];
              Color sevColor = _kBrandGreen;
              if (item["severity"] == "Moderate") sevColor = _kWarningAmber;
              if (item["severity"] == "Severe") sevColor = _kDangerRed;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.01),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _kCardBorder),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _kBrandBlue.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item["code"]!,
                          style: GoogleFonts.robotoMono(color: _kBrandBlue, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item["name"]!,
                          style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: sevColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item["severity"]!,
                          style: GoogleFonts.inter(color: sevColor, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => setState(() => _diagnosesList.removeAt(idx)),
                        child: const Icon(Icons.delete_outline, color: _kDangerRed, size: 18),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 4. Medications Tab Panel
  Widget _buildMedicationsTabContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.medication_outlined, color: _kBrandBlue, size: 18),
            const SizedBox(width: 8),
            Text(
              "Digital Rx Medications Builder",
              style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Quick add inputs
        Row(
          children: [
            Expanded(
              flex: 3,
              child: TextField(
                controller: _drugNameController,
                style: GoogleFonts.inter(color: Colors.white, fontSize: 11),
                decoration: InputDecoration(
                  hintText: "Drug Name (e.g. Metformin)",
                  hintStyle: GoogleFonts.inter(color: _kTextGray.withOpacity(0.5), fontSize: 11),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.01),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: _kCardBorder),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: _kBrandBlue, width: 1.2),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              flex: 2,
              child: TextField(
                controller: _dosageController,
                style: GoogleFonts.inter(color: Colors.white, fontSize: 11),
                decoration: InputDecoration(
                  hintText: "Dose (e.g. 500mg)",
                  hintStyle: GoogleFonts.inter(color: _kTextGray.withOpacity(0.5), fontSize: 11),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.01),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: _kCardBorder),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: _kBrandBlue, width: 1.2),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: _kCardBorder),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedFreq,
                  dropdownColor: _kCardBg,
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 11),
                  items: ["Once daily", "Twice daily", "PRN (as needed)"].map((val) {
                    return DropdownMenuItem(value: val, child: Text(val));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedFreq = val);
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Text("Duration: ", style: GoogleFonts.inter(color: _kTextGray, fontSize: 11)),
                  const SizedBox(width: 6),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedDuration,
                      dropdownColor: _kCardBg,
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 11),
                      items: ["7 days", "10 days", "14 days", "30 days", "90 days"].map((val) {
                        return DropdownMenuItem(value: val, child: Text(val));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedDuration = val);
                      },
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.add, size: 14, color: Colors.white),
              label: Text("Add Rx", style: GoogleFonts.inter(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _kBrandBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onPressed: () {
                if (_drugNameController.text.isNotEmpty && _dosageController.text.isNotEmpty) {
                  setState(() {
                    _prescriptionsList.add({
                      "drug": "${_drugNameController.text.trim()} ${_dosageController.text.trim()}",
                      "dose": "1 tab",
                      "freq": _selectedFreq,
                      "duration": _selectedDuration,
                    });
                    _drugNameController.clear();
                    _dosageController.clear();
                  });
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Added prescriptions table list
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: _prescriptionsList.length,
            itemBuilder: (context, idx) {
              final item = _prescriptionsList[idx];
              return Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.01),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: _kCardBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.medication, color: _kBrandGreen, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item["drug"]!, style: GoogleFonts.inter(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.bold)),
                            Text("${item["dose"]} • ${item["freq"]} • ${item["duration"]}", style: GoogleFonts.inter(color: _kTextGray, fontSize: 10)),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _prescriptionsList.removeAt(idx)),
                        child: const Icon(Icons.delete_outline, color: _kDangerRed, size: 16),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 5. Advice Tab Panel
  Widget _buildAdviceTabContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.info_outline, color: _kBrandBlue, size: 18),
            const SizedBox(width: 8),
            Text(
              "Clinical Advice & SOAP Notes",
              style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text("DOCTOR ADVICE & INSTRUCTIONS TO PATIENT", style: GoogleFonts.inter(color: _kTextGray, fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Expanded(
          child: TextField(
            controller: _adviceController,
            maxLines: 8,
            style: GoogleFonts.inter(color: Colors.white, fontSize: 12, height: 1.4),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withOpacity(0.01),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: _kCardBorder),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: _kBrandBlue, width: 1.2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 6. Investigation Tab Panel
  Widget _buildInvestigationTabContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.science_outlined, color: _kBrandBlue, size: 18),
            const SizedBox(width: 8),
            Text(
              "Laboratory & Diagnostic Investigations",
              style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: _investigationsList.length,
            itemBuilder: (context, idx) {
              final item = _investigationsList[idx];
              final bool isChecked = item["checked"];
              return CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: isChecked,
                activeColor: _kBrandBlue,
                checkColor: Colors.white,
                title: Text(item["test"], style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                subtitle: Text("Price: ₹${item["price"].toStringAsFixed(2)}", style: GoogleFonts.robotoMono(color: _kTextGray, fontSize: 10)),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _investigationsList[idx]["checked"] = val;
                    });
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // 7. Follow Up Tab Panel
  Widget _buildFollowUpTabContent() {
    final List<String> intervals = ["3 Days", "1 Week", "2 Weeks", "1 Month", "3 Months"];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.calendar_today_outlined, color: _kBrandBlue, size: 18),
            const SizedBox(width: 8),
            Text(
              "Follow-Up Planning",
              style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text("SELECT FOLLOW UP TIMELINE:", style: GoogleFonts.inter(color: _kTextGray, fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          children: intervals.map((interval) {
            final bool isSelected = _followUpInterval == interval;
            return ChoiceChip(
              label: Text(interval),
              selected: isSelected,
              labelStyle: GoogleFonts.inter(
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              selectedColor: _kBrandBlue,
              backgroundColor: Colors.white.withOpacity(0.02),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? _kBrandBlue : _kCardBorder,
                ),
              ),
              onSelected: (bool selected) {
                if (selected) {
                  setState(() {
                    _followUpInterval = interval;
                    // Compute follow-up date dynamically
                    int days = 7;
                    if (interval == "3 Days") days = 3;
                    if (interval == "1 Week") days = 7;
                    if (interval == "2 Weeks") days = 14;
                    if (interval == "1 Month") days = 30;
                    if (interval == "3 Months") days = 90;
                    _followUpDate = DateTime.now().add(Duration(days: days));
                  });
                }
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Follow Up Appointment Date:", style: GoogleFonts.inter(color: _kTextGray, fontSize: 11)),
            Text(
              "${_followUpDate.day} ${_getMonthName(_followUpDate.month)} ${_followUpDate.year}",
              style: GoogleFonts.inter(color: _kBrandBlue, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text("SCHEDULER CLINICAL INSTRUCTIONS:", style: GoogleFonts.inter(color: _kTextGray, fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Expanded(
          child: TextField(
            controller: _followUpNotesController,
            maxLines: 4,
            style: GoogleFonts.inter(color: Colors.white, fontSize: 12),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withOpacity(0.01),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: _kCardBorder),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: _kBrandBlue, width: 1.2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return months[month - 1];
  }

  // 8. Invoice Tab Panel
  Widget _buildInvoiceTabContent() {
    // Compute total charges
    double consultationFee = 150.0;
    double labFee = _investigationsList.where((item) => item["checked"] == true).fold(0.0, (sum, item) => sum + item["price"]);
    double subtotal = consultationFee + labFee;
    double discountAmount = subtotal * (_discountPercent / 100.0);
    double total = subtotal - discountAmount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.receipt_long_outlined, color: _kBrandBlue, size: 18),
            const SizedBox(width: 8),
            Text(
              "Billing Summary & Invoicing",
              style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                _buildInvoiceItemRow("General Cardiology Consult Fee", consultationFee),
                ..._investigationsList.where((item) => item["checked"] == true).map((item) {
                  return _buildInvoiceItemRow(item["test"], item["price"]);
                }),
                const Divider(color: Colors.white10),
                const SizedBox(height: 8),
                _buildInvoiceSummaryLine("Subtotal", "₹${subtotal.toStringAsFixed(2)}", false),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Apply Discount: ${_discountPercent.toInt()}%", style: GoogleFonts.inter(color: _kWarningAmber, fontSize: 11)),
                    SizedBox(
                      width: 140,
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 2,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
                        ),
                        child: Slider(
                          value: _discountPercent,
                          min: 0.0,
                          max: 50.0,
                          activeColor: _kWarningAmber,
                          inactiveColor: Colors.white.withOpacity(0.08),
                          onChanged: (val) => setState(() => _discountPercent = val),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildInvoiceSummaryLine("Discount Deducted", "-₹${discountAmount.toStringAsFixed(2)}", false, color: _kWarningAmber),
                const SizedBox(height: 8),
                const Divider(color: Colors.white24),
                const SizedBox(height: 4),
                _buildInvoiceSummaryLine("CONSULTATION TOTAL", "₹${total.toStringAsFixed(2)}", true, color: _kBrandGreen),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInvoiceItemRow(String name, double price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              name,
              style: GoogleFonts.inter(color: Colors.white.withOpacity(0.8), fontSize: 11.5),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            "₹${price.toStringAsFixed(2)}",
            style: GoogleFonts.robotoMono(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceSummaryLine(String title, String val, bool isTotal, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            color: isTotal ? Colors.white : _kTextGray,
            fontSize: isTotal ? 12 : 11,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          val,
          style: GoogleFonts.robotoMono(
            color: color ?? Colors.white,
            fontSize: isTotal ? 15 : 11.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // BOTTOM CONTROL ACTION BUTTONS ROW
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildBottomActionButtonsRow(double availableWidth) {
    // On very narrow panes, wrap to 2×2 grid to prevent button text clipping
    final bool wrap = availableWidth < 480;

    final List<Widget> buttons = [
      AppButton(
        label: "Cancel",
        variant: AppButtonVariant.outline,
        onPressed: _showCancelWarningDialog,
      ),
      AppButton(
        label: "Preview",
        variant: AppButtonVariant.primary,
        onPressed: _showPreviewReportDialog,
      ),
      AppButton(
        label: "Draft",
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: _kWarningAmber,
              behavior: SnackBarBehavior.floating,
              content: Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Text("Saving consultation draft...",
                      style: GoogleFonts.inter(color: Colors.white)),
                ],
              ),
            ),
          );
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: _kBrandGreen,
                  behavior: SnackBarBehavior.floating,
                  content: Text(
                    "Draft saved successfully into practice EMR.",
                    style: GoogleFonts.inter(color: Colors.white),
                  ),
                ),
              );
            }
          });
        },
      ),
      Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: _kBrandGreen.withValues(alpha: 0.24),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: AppButton(
          label: "Complete",
          icon: const Icon(Icons.check_circle_outline,
              color: Colors.white, size: 14),
          onPressed: _showCompleteSuccessDialog,
        ),
      ),
    ];

    if (wrap) {
      // 2×2 grid layout for narrow panes
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: buttons[0]),
              const SizedBox(width: 8),
              Expanded(child: buttons[1]),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: buttons[2]),
              const SizedBox(width: 8),
              Expanded(child: buttons[3]),
            ],
          ),
        ],
      );
    }

    // Default: single row with Expanded children
    return Row(
      children: [
        Expanded(child: buttons[0]),
        const SizedBox(width: 10),
        Expanded(child: buttons[1]),
        const SizedBox(width: 10),
        Expanded(child: buttons[2]),
        const SizedBox(width: 10),
        Expanded(child: buttons[3]),
      ],
    );
  }

  void _showCancelWarningDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: _kCardBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: _kCardBorder),
          ),
          title: Row(
            children: [
              const Icon(Icons.warning_amber, color: _kDangerRed),
              const SizedBox(width: 8),
              Text("Discard Changes?", style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(
            "Are you sure you want to discard this consultation? All unsaved diagnostics, vitals updates, and prescriptions will be permanently lost.",
            style: GoogleFonts.inter(color: Colors.white.withOpacity(0.8), fontSize: 13, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("No, Continue", style: GoogleFonts.inter(color: _kTextGray)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: _kDangerRed),
              onPressed: () {
                // Reset state
                setState(() {
                  _diagnosesList.clear();
                  _prescriptionsList.clear();
                  _selectedSymptoms.clear();
                  _complaintController.text = _chiefComplaintInitial;
                  _activeTabIdx = 0;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: _kDangerRed,
                    content: Text("Consultation session cleared.", style: GoogleFonts.inter(color: Colors.white)),
                  ),
                );
              },
              child: Text("Yes, Discard", style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showCompleteSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: _kCardBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: _kCardBorder),
          ),
          title: Row(
            children: [
              const Icon(Icons.check_circle, color: _kBrandGreen),
              const SizedBox(width: 8),
              Text("Consultation Completed", style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "The clinical consultation record for James Carter has been securely filed, signed, and locked in the EMR successfully.",
                style: GoogleFonts.inter(color: Colors.white.withOpacity(0.8), fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.02),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Prescriptions Generated: ${_prescriptionsList.length}", style: GoogleFonts.inter(color: _kTextGray, fontSize: 11)),
                    const SizedBox(height: 3),
                    Text("Diagnoses Filer: ${_diagnosesList.length} ICD Codes", style: GoogleFonts.inter(color: _kTextGray, fontSize: 11)),
                    const SizedBox(height: 3),
                    Text("Follow-Up Date: ${_followUpDate.day} ${_getMonthName(_followUpDate.month)} ${_followUpDate.year}", style: GoogleFonts.inter(color: _kTextGray, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: _kBrandGreen),
              onPressed: () {
                Navigator.pop(context);
                // Return to previous route or dashboard
              },
              child: Text("Close Portal", style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showPreviewReportDialog() {
    // Calculate final billing total
    double consultationFee = 150.0;
    double labFee = _investigationsList.where((item) => item["checked"] == true).fold(0.0, (sum, item) => sum + item["price"]);
    double subtotal = consultationFee + labFee;
    double discountAmount = subtotal * (_discountPercent / 100.0);
    double total = subtotal - discountAmount;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFF0F132E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: _kCardBorder),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Consultation Summary Preview",
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.close, color: _kTextGray, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Box
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.02),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white.withOpacity(0.05)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Patient Name: $_patientName", style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 2),
                              Text("Patient ID: $_patientId", style: GoogleFonts.robotoMono(color: _kBrandBlue, fontSize: 11)),
                              const SizedBox(height: 2),
                              Text("Provider: Dr. Amanulla Baig (General Physician)", style: GoogleFonts.inter(color: _kTextGray, fontSize: 11)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Section Vitals
                        _buildPreviewHeader("EMR Vitals Captured"),
                        Wrap(
                          spacing: 12,
                          runSpacing: 6,
                          children: _vitalsData.keys.map((title) {
                            final metric = _vitalsData[title]!;
                            return Text(
                              "$title: ${metric["val"]} ${metric["unit"]}",
                              style: GoogleFonts.inter(color: Colors.white.withOpacity(0.8), fontSize: 11.5),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),

                        // Section Chief Complaints
                        _buildPreviewHeader("Chief Complaints"),
                        Text(
                          _complaintController.text,
                          style: GoogleFonts.inter(color: Colors.white.withOpacity(0.8), fontSize: 11.5, height: 1.4),
                        ),
                        const SizedBox(height: 16),

                        // Section Diagnosis
                        _buildPreviewHeader("Diagnoses File"),
                        if (_diagnosesList.isEmpty)
                          Text("No diagnosis recorded.", style: GoogleFonts.inter(color: _kTextGray, fontSize: 11.5))
                        else
                          Column(
                            children: _diagnosesList.map((item) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 4.0),
                                child: Row(
                                  children: [
                                    Icon(Icons.circle, size: 6, color: _kBrandBlue),
                                    const SizedBox(width: 8),
                                    Text("[${item["code"]}] ${item["name"]} (${item["severity"]})", style: GoogleFonts.inter(color: Colors.white.withOpacity(0.8), fontSize: 11.5)),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        const SizedBox(height: 16),

                        // Section Medications
                        _buildPreviewHeader("Prescriptions (Digital Rx)"),
                        if (_prescriptionsList.isEmpty)
                          Text("No prescriptions added.", style: GoogleFonts.inter(color: _kTextGray, fontSize: 11.5))
                        else
                          Column(
                            children: _prescriptionsList.map((item) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 4.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.circle, size: 6, color: _kBrandGreen),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        "${item["drug"]} - ${item["dose"]} • ${item["freq"]} • ${item["duration"]}",
                                        style: GoogleFonts.inter(color: Colors.white.withOpacity(0.8), fontSize: 11.5),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        const SizedBox(height: 16),

                        // Section Advice
                        _buildPreviewHeader("Advice / Patient Notes"),
                        Text(
                          _adviceController.text,
                          style: GoogleFonts.inter(color: Colors.white.withOpacity(0.8), fontSize: 11.5, height: 1.4),
                        ),
                        const SizedBox(height: 16),

                        // Section Invoice Total
                        _buildPreviewHeader("Billing Invoice Total"),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Total Invoice charges due:", style: GoogleFonts.inter(color: _kTextGray, fontSize: 11.5)),
                            Text("₹${total.toStringAsFixed(2)}", style: GoogleFonts.robotoMono(color: _kBrandGreen, fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.download, size: 16, color: Colors.white),
                        label: Text("Download PDF", style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(backgroundColor: _kBrandBlue),
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: _kBrandGreen,
                              content: Text("Downloading signed consultation report PDF...", style: GoogleFonts.inter(color: Colors.white)),
                            ),
                          );
                        },
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
  }

  Widget _buildPreviewHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text.toUpperCase(), style: GoogleFonts.inter(color: _kBrandBlue, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          const SizedBox(height: 2),
          const Divider(color: Colors.white10),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ECG WAVEFORM TELEMETRY LIVE SIMULATOR PAINTER
// ─────────────────────────────────────────────────────────────────────────────
class _EcgWavePainter extends CustomPainter {
  final double phase;
  _EcgWavePainter({required this.phase});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint gridPaint = Paint()
      ..color = Colors.green.withOpacity(0.06)
      ..strokeWidth = 0.5;

    // Draw background graph grid lines
    const double gridSize = 15.0;
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Bold grid lines (every 5 squares)
    final Paint boldGridPaint = Paint()
      ..color = Colors.green.withOpacity(0.12)
      ..strokeWidth = 1.0;
    for (double x = 0; x < size.width; x += gridSize * 5) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), boldGridPaint);
    }
    for (double y = 0; y < size.height; y += gridSize * 5) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), boldGridPaint);
    }

    final Paint wavePaint = Paint()
      ..color = const Color(0xFF22C55E) // Bright Neon Green
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Path path = Path();
    final double midY = size.height / 2;

    // Draw continuous scrolling ECG wave pattern
    bool first = true;
    for (double x = 0; x < size.width; x += 1.0) {
      // Localized wave calculation relative to width scrolling phase
      final double waveX = (x / size.width) - phase;
      final double normalizedX = waveX - waveX.floor(); // wrap 0.0 -> 1.0

      // Math equation representing periodic heartbeat pulses
      double yOffset = 0.0;
      if (normalizedX > 0.1 && normalizedX < 0.15) {
        // P-Wave
        yOffset = -8 * math.sin((normalizedX - 0.1) * (2 * math.pi) / 0.05);
      } else if (normalizedX >= 0.15 && normalizedX < 0.17) {
        // Q-wave
        yOffset = 4 * math.sin((normalizedX - 0.15) * (2 * math.pi) / 0.02);
      } else if (normalizedX >= 0.17 && normalizedX < 0.21) {
        // R-wave (Sharp vertical spike)
        yOffset = -50 * math.sin((normalizedX - 0.17) * (2 * math.pi) / 0.04);
      } else if (normalizedX >= 0.21 && normalizedX < 0.23) {
        // S-wave (Deep vertical drop)
        yOffset = 18 * math.sin((normalizedX - 0.21) * (2 * math.pi) / 0.02);
      } else if (normalizedX >= 0.23 && normalizedX < 0.28) {
        // Flat ST segment
        yOffset = 0;
      } else if (normalizedX >= 0.28 && normalizedX < 0.35) {
        // T-wave
        yOffset = -15 * math.sin((normalizedX - 0.28) * (2 * math.pi) / 0.07);
      }

      final double y = midY + yOffset;

      if (first) {
        path.moveTo(x, y);
        first = false;
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, wavePaint);

    // Neon glowing dot at the end of scroll
    final double scanX = phase * size.width;
    double scanNormalizedX = phase - phase.floor();
    double scanYOffset = 0.0;
    if (scanNormalizedX > 0.1 && scanNormalizedX < 0.15) {
      scanYOffset = -8 * math.sin((scanNormalizedX - 0.1) * (2 * math.pi) / 0.05);
    } else if (scanNormalizedX >= 0.15 && scanNormalizedX < 0.17) {
      scanYOffset = 4 * math.sin((scanNormalizedX - 0.15) * (2 * math.pi) / 0.02);
    } else if (scanNormalizedX >= 0.17 && scanNormalizedX < 0.21) {
      scanYOffset = -50 * math.sin((scanNormalizedX - 0.17) * (2 * math.pi) / 0.04);
    } else if (scanNormalizedX >= 0.21 && scanNormalizedX < 0.23) {
      scanYOffset = 18 * math.sin((scanNormalizedX - 0.21) * (2 * math.pi) / 0.02);
    } else if (scanNormalizedX >= 0.23 && scanNormalizedX < 0.28) {
      scanYOffset = 0;
    } else if (scanNormalizedX >= 0.28 && scanNormalizedX < 0.35) {
      scanYOffset = -15 * math.sin((scanNormalizedX - 0.28) * (2 * math.pi) / 0.07);
    }

    final Offset dotPos = Offset(scanX % size.width, midY + scanYOffset);
    final Paint dotPaint = Paint()..color = const Color(0xFF4ADE80);
    final Paint glowPaint = Paint()..color = const Color(0xFF4ADE80).withOpacity(0.35);

    canvas.drawCircle(dotPos, 6.0, glowPaint);
    canvas.drawCircle(dotPos, 3.5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _EcgWavePainter oldDelegate) => oldDelegate.phase != phase;
}
