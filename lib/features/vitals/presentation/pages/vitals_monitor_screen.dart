import "package:prachtiz_flutter/core/theme/app_colors.dart";
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../theme/colors.dart';
import '../../../../theme/styles.dart';

// Patient vitals telemetry model
class PatientVitals {
  final String id;
  final String name;
  final String room;
  final String status; // "Stable", "Warning", "Critical"
  int heartRate;
  String bloodPressure;
  int spo2;
  double temperature;
  final List<double> hrHistory;

  // Editable safety threshold limit configurations
  int hrMinLimit;
  int hrMaxLimit;
  int spo2MinLimit;

  PatientVitals({
    required this.id,
    required this.name,
    required this.room,
    required this.status,
    required this.heartRate,
    required this.bloodPressure,
    required this.spo2,
    required this.temperature,
    required this.hrHistory,
    this.hrMinLimit = 60,
    this.hrMaxLimit = 100,
    this.spo2MinLimit = 95,
  });
}

class VitalsMonitorScreen extends StatefulWidget {
  @override
  State<VitalsMonitorScreen> createState() => _VitalsMonitorScreenState();
}

class _VitalsMonitorScreenState extends State<VitalsMonitorScreen> with SingleTickerProviderStateMixin {
  Timer? _telemetryTimer;
  late AnimationController _animController;
  double _ecgPhase = 0.0;
  final List<double> _liveEcgPoints = [];

  // Seeded active patient telemetry data matching the screenshot
  final List<PatientVitals> _patients = [
    PatientVitals(
      id: "PT-0482",
      name: "Margaret Chen",
      room: "Room 204-A",
      status: "Stable",
      heartRate: 72,
      bloodPressure: "128/82",
      spo2: 98,
      temperature: 98.6,
      hrHistory: [70, 71, 73, 72, 70, 69, 72, 74, 73, 71, 72, 70, 72, 73, 72],
    ),
    PatientVitals(
      id: "PT-0911",
      name: "James O'Sullivan",
      room: "Room ICU-3",
      status: "Critical",
      heartRate: 95,
      bloodPressure: "155/98",
      spo2: 94,
      temperature: 99.8,
      hrHistory: [92, 94, 96, 95, 93, 91, 95, 97, 96, 94, 95, 93, 95, 96, 95],
      hrMinLimit: 55,
      hrMaxLimit: 90,
      spo2MinLimit: 95,
    ),
    PatientVitals(
      id: "PT-0312",
      name: "Aisha Rahman",
      room: "Room 312-B",
      status: "Stable",
      heartRate: 78,
      bloodPressure: "120/78",
      spo2: 99,
      temperature: 98.2,
      hrHistory: [76, 77, 79, 78, 77, 75, 78, 80, 79, 77, 78, 76, 78, 79, 78],
    ),
    PatientVitals(
      id: "PT-0701",
      name: "Robert Nakamura",
      room: "Room ICU-7",
      status: "Critical",
      heartRate: 110,
      bloodPressure: "90/60",
      spo2: 92,
      temperature: 100.4,
      hrHistory: [108, 109, 111, 110, 108, 107, 110, 112, 111, 109, 110, 108, 110, 111, 110],
      hrMinLimit: 60,
      hrMaxLimit: 100,
      spo2MinLimit: 94,
    ),
    PatientVitals(
      id: "PT-0119",
      name: "Elena Vasquez",
      room: "Room 119-A",
      status: "Stable",
      heartRate: 68,
      bloodPressure: "118/75",
      spo2: 97,
      temperature: 98.4,
      hrHistory: [66, 67, 69, 68, 67, 65, 68, 70, 69, 67, 68, 66, 68, 69, 68],
    ),
    PatientVitals(
      id: "PT-0205",
      name: "Thomas Bergstrom",
      room: "Room 205-C",
      status: "Warning",
      heartRate: 82,
      bloodPressure: "142/88",
      spo2: 96,
      temperature: 98.8,
      hrHistory: [80, 81, 83, 82, 80, 79, 82, 84, 83, 81, 82, 80, 82, 83, 82],
      hrMinLimit: 60,
      hrMaxLimit: 85,
      spo2MinLimit: 95,
    ),
  ];

  String _searchQuery = "";
  String _statusFilter = "All"; // "All", "Critical", "Warning", "Stable"

  // Search input state handlers
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final bool isTesting = WidgetsBinding.instance.toString().contains('Test');

    // Telemetry animator for live waveforms
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    if (!isTesting) {
      _animController.repeat();
    } else {
      _animController.value = 0.5;
    }

    _animController.addListener(() {
      if (mounted) {
        setState(() {
          _ecgPhase += 0.12;
          double baseWave = math.sin(_ecgPhase);
          double qrs = 0.0;
          double modPhase = _ecgPhase % (2 * math.pi);
          if (modPhase > 0.8 && modPhase < 1.1) {
            qrs = math.sin((modPhase - 0.8) * 10) * 4.5; // QRS pulse complex
          }
          _liveEcgPoints.add(baseWave * 0.35 + qrs);
          if (_liveEcgPoints.length > 150) {
            _liveEcgPoints.removeAt(0);
          }
        });
      }
    });

    // Fluctuating patient vitals periodically in real-time
    if (!isTesting) {
      _telemetryTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
        if (mounted) {
          setState(() {
            final rng = math.Random();
            for (var p in _patients) {
              if (p.status == "Stable") {
                p.heartRate = (p.heartRate - 1) + rng.nextInt(3); // +/- 1
                p.spo2 = math.min(100, math.max(95, (p.spo2 - 1) + rng.nextInt(3)));
                p.temperature = 97.8 + rng.nextDouble() * 1.0;
                final sys = 115 + rng.nextInt(15);
                final dia = 75 + rng.nextInt(10);
                p.bloodPressure = "$sys/$dia";
              } else if (p.status == "Warning") {
                p.heartRate = (p.heartRate - 2) + rng.nextInt(5);
                p.spo2 = math.min(100, math.max(94, (p.spo2 - 1) + rng.nextInt(3)));
                p.temperature = 98.2 + rng.nextDouble() * 1.2;
                final sys = 135 + rng.nextInt(12);
                final dia = 84 + rng.nextInt(8);
                p.bloodPressure = "$sys/$dia";
              } else if (p.status == "Critical") {
                p.heartRate = (p.heartRate - 3) + rng.nextInt(7);
                p.spo2 = math.min(96, math.max(88, (p.spo2 - 1) + rng.nextInt(3)));
                p.temperature = 99.2 + rng.nextDouble() * 1.8;
                final sys = p.name.contains("Robert") ? (85 + rng.nextInt(10)) : (150 + rng.nextInt(12));
                final dia = p.name.contains("Robert") ? (55 + rng.nextInt(8)) : (92 + rng.nextInt(8));
                p.bloodPressure = "$sys/$dia";
              }

              // Update sparkline history
              p.hrHistory.add(p.heartRate.toDouble());
              if (p.hrHistory.length > 15) {
                p.hrHistory.removeAt(0);
              }
            }
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _telemetryTimer?.cancel();
    _animController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Filter the patient list by query and status choice chip selection
    final filteredPatients = _patients.where((p) {
      final matchesSearch = p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.room.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.id.toLowerCase().contains(_searchQuery.toLowerCase());

      if (!matchesSearch) return false;

      if (_statusFilter == "All") return true;
      return p.status.toLowerCase() == _statusFilter.toLowerCase();
    }).toList();

    final double screenWidth = MediaQuery.of(context).size.width;
    
    final int crossAxisCount;
    final double childAspectRatio;

    if (screenWidth < 650) {
      crossAxisCount = 1;
      childAspectRatio = 2.6;
    } else if (screenWidth < 1200) {
      crossAxisCount = 2;
      childAspectRatio = 3.1;
    } else {
      crossAxisCount = 2;
      childAspectRatio = 3.7;
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Title and Description
            Text(
              "Vitals Monitor",
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.gray900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Real-time patient vital signs monitoring.",
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.gray500,
              ),
            ),
            const SizedBox(height: 20),

            // Search Bar & Filter ChoiceChips Row
            Builder(builder: (context) {
              final isWide = screenWidth > 700;
              final searchField = SizedBox(
                width: isWide ? 300 : double.infinity,
                child: TextField(
                  key: const ValueKey('vitals_search_field'),
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  style: GoogleFonts.inter(fontSize: 13, color: AppColors.gray800),
                  decoration: InputDecoration(
                    hintText: "Search patients, room, ID...",
                    hintStyle: GoogleFonts.inter(color: AppColors.gray400, fontSize: 13),
                    prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.gray400),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 16, color: AppColors.gray400),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = "";
                              });
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.gray200),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primary),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              );

              final filterTabs = SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: ["All", "Critical", "Warning", "Stable"].map((status) {
                    final bool isSelected = _statusFilter == status;
                    Color activeColor = AppColors.primary;
                    if (status == "Critical") activeColor = const Color(0xFFEF4444);
                    if (status == "Warning") activeColor = const Color(0xFFF59E0B);
                    if (status == "Stable") activeColor = const Color(0xFF24C06F);

                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(status),
                        labelStyle: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.white : AppColors.gray800,
                        ),
                        selected: isSelected,
                        selectedColor: activeColor,
                        backgroundColor: Colors.white,
                        onSelected: (val) {
                          if (val) {
                            setState(() {
                              _statusFilter = status;
                            });
                          }
                        },
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: isSelected ? activeColor : AppColors.gray300),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );

              if (isWide) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    filterTabs,
                    searchField,
                  ],
                );
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    searchField,
                    const SizedBox(height: 12),
                    filterTabs,
                  ],
                );
              }
            }),
            const SizedBox(height: 16),

            // Grid Layout of Patient Vitals Cards
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: childAspectRatio,
              ),
              itemCount: filteredPatients.length,
              itemBuilder: (context, index) {
                final patient = filteredPatients[index];
                return _PatientVitalsCard(
                  patient: patient,
                  onTap: () => _showPatientDetailsDialog(patient),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Detailed modal popup displaying live ECG lead and slider configurations
  void _showPatientDetailsDialog(PatientVitals patient) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Color statusColor = const Color(0xFF24C06F);
            if (patient.status == "Critical") statusColor = const Color(0xFFEF4444);
            if (patient.status == "Warning") statusColor = const Color(0xFFF59E0B);

            return AlertDialog(
              backgroundColor: const Color(0xFF11152D),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.white.withOpacity(0.08)),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patient.name,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "${patient.room} • Patient ID: ${patient.id}",
                        style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 11),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor.withOpacity(0.2)),
                    ),
                    child: Text(
                      patient.status.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 520,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Animated ECG Lead trace waveform
                      Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: const Color(0xFF070913),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white10),
                        ),
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "ECG LEAD II (LIVE TELEMETRY)",
                                  style: GoogleFonts.robotoMono(
                                    color: const Color(0xFF22C55E),
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "60Hz FILTER ACTIVE",
                                  style: GoogleFonts.robotoMono(color: const Color(0xFF94A3B8), fontSize: 8),
                                ),
                              ],
                            ),
                            Expanded(
                              child: CustomPaint(
                                painter: _ModalEcgPainter(_liveEcgPoints),
                                child: Container(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Safety alert limit adjusters
                      Text(
                        "Safety Alarm Threshold Adjustments",
                        style: GoogleFonts.inter(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),

                      // Heart rate warning threshold min
                      _buildSliderRow(
                        "Min Heart Rate Limit",
                        "${patient.hrMinLimit} bpm",
                        patient.hrMinLimit.toDouble(),
                        40,
                        80,
                        (val) {
                          setDialogState(() {
                            patient.hrMinLimit = val.toInt();
                          });
                        },
                      ),

                      // Heart rate warning threshold max
                      _buildSliderRow(
                        "Max Heart Rate Limit",
                        "${patient.hrMaxLimit} bpm",
                        patient.hrMaxLimit.toDouble(),
                        80,
                        160,
                        (val) {
                          setDialogState(() {
                            patient.hrMaxLimit = val.toInt();
                          });
                        },
                      ),

                      // SpO2 warning threshold min
                      _buildSliderRow(
                        "Min SpO2 Threshold",
                        "${patient.spo2MinLimit}% SpO2",
                        patient.spo2MinLimit.toDouble(),
                        85,
                        98,
                        (val) {
                          setDialogState(() {
                            patient.spo2MinLimit = val.toInt();
                          });
                        },
                      ),

                      const SizedBox(height: 12),
                      const Divider(color: Colors.white12, height: 1),
                      const SizedBox(height: 12),

                      // Ward Admission Log
                      Text(
                        "Clinical Admission Overview",
                        style: GoogleFonts.inter(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Admitted under Cardiology for acute respiratory evaluation. Live telemetry is being routed directly to Doctor Console.",
                        style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 11, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: const Color(0xFFEF4444),
                        behavior: SnackBarBehavior.floating,
                        content: Text(
                          "Emergency Alert dispatched to ward duty station for ${patient.name}.",
                          style: GoogleFonts.inter(color: Colors.white),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.emergency_outlined, color: Color(0xFFEF4444), size: 16),
                  label: Text(
                    "Emergency Call",
                    style: GoogleFonts.inter(color: const Color(0xFFEF4444), fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    "Dismiss",
                    style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSliderRow(String label, String valueLabel, double val, double minLimit, double maxLimit, Function(double) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 11)),
              Text(valueLabel, style: GoogleFonts.robotoMono(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 2.0,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12.0),
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: Colors.white10,
              thumbColor: AppColors.primary,
            ),
            child: Slider(
              value: val,
              min: minLimit,
              max: maxLimit,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

// Sparkline painter inside the heart rate vital box
class _SparklinePainter extends CustomPainter {
  final List<double> points;
  final Color color;

  _SparklinePainter(this.points, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    double minVal = points.reduce(math.min);
    double maxVal = points.reduce(math.max);
    double valRange = maxVal - minVal;
    if (valRange == 0) valRange = 1.0;

    double stepX = size.width / (points.length - 1);

    for (int i = 0; i < points.length; i++) {
      double x = i * stepX;
      double normY = (points[i] - minVal) / valRange;
      double y = size.height - (normY * (size.height - 6) + 3);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) => true;
}

// ECG lead painter inside the detailed modal popup
class _ModalEcgPainter extends CustomPainter {
  final List<double> points;

  _ModalEcgPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final paint = Paint()
      ..color = const Color(0xFF22C55E)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    double midY = size.height / 2;
    double stepX = size.width / 150;

    path.moveTo(0, midY);

    for (int i = 0; i < points.length; i++) {
      double x = i * stepX;
      double y = midY - (points[i] * 12);
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ModalEcgPainter oldDelegate) => true;
}

// Singular patient vitals monitor card
class _PatientVitalsCard extends StatelessWidget {
  final PatientVitals patient;
  final VoidCallback onTap;

  const _PatientVitalsCard({
    required this.patient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCritical = patient.status == "Critical";
    final bool isWarning = patient.status == "Warning";

    Color statusColor = const Color(0xFF24C06F); // Stable
    Color statusBg = const Color(0xFFDCFCE7);
    if (isCritical) {
      statusColor = const Color(0xFFEF4444);
      statusBg = const Color(0xFFFEE2E2);
    } else if (isWarning) {
      statusColor = const Color(0xFFF59E0B);
      statusBg = const Color(0xFFFEF3C7);
    }

    // High contrast typography colors
    // Critical cards have a light red/pink background body, requiring deep red high-contrast text.
    // Stable/Warning cards have a dark navy background body, requiring white/light gray text.
    final Color cardBg = isCritical ? const Color(0xFFFFECEF) : const Color(0xFF11152D);
    final Color patientNameColor = isCritical ? const Color(0xFFD08A8A) : Colors.white;
    final Color roomColor = isCritical ? const Color(0xFFC08080) : const Color(0xFF94A3B8);
    final Color cardBorderColor = isCritical ? const Color(0xFFFCA5A5) : Colors.white.withOpacity(0.08);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cardBorderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left status color indicator strip
                Container(
                  width: 5,
                  color: statusColor,
                ),
                // Main content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Top Row: Patient Name, Room & Status Badge
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  patient.name,
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13.5,
                                    color: patientNameColor,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  patient.room,
                                  style: GoogleFonts.inter(
                                    fontSize: 9.5,
                                    color: roomColor,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: statusBg,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: statusColor.withOpacity(0.15)),
                              ),
                              child: Text(
                                patient.status,
                                style: GoogleFonts.inter(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        // Vitals Row: 4 parameter boxes
                        Row(
                          children: [
                            // Heart Rate Vital Box (Includes Live Sparkline)
                            Expanded(
                              flex: 3,
                              child: _buildHrVitalBlock(patient, const Color(0xFFEF4444)),
                            ),
                            const SizedBox(width: 6),

                            // Blood Pressure Box
                            Expanded(
                              flex: 2,
                              child: _buildNormalVitalBlock(
                                Icons.speed,
                                patient.bloodPressure,
                                "mmHg",
                                const Color(0xFFF59E0B),
                              ),
                            ),
                            const SizedBox(width: 6),

                            // SpO2 Box
                            Expanded(
                              flex: 2,
                              child: _buildNormalVitalBlock(
                                Icons.bloodtype,
                                "${patient.spo2}%",
                                "SpO2",
                                const Color(0xFF0EA5E9),
                              ),
                            ),
                            const SizedBox(width: 6),

                            // Temperature Box
                            Expanded(
                              flex: 2,
                              child: _buildNormalVitalBlock(
                                Icons.thermostat,
                                "${patient.temperature.toStringAsFixed(1)}°",
                                "F",
                                const Color(0xFF8B5CF6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Heart Rate block incorporating the live custom painter sparkline
  Widget _buildHrVitalBlock(PatientVitals patient, Color sparklineColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF15193B),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          const Icon(Icons.favorite, color: Color(0xFFEF4444), size: 11),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Text(
                      "${patient.heartRate}",
                      style: GoogleFonts.robotoMono(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 1),
                    Text(
                      "bpm",
                      style: GoogleFonts.inter(fontSize: 7, color: const Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 36,
            height: 16,
            child: CustomPaint(
              painter: _SparklinePainter(patient.hrHistory, sparklineColor),
            ),
          ),
        ],
      ),
    );
  }

  // Standard vital block displaying parameter and icon
  Widget _buildNormalVitalBlock(IconData icon, String value, String unit, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF15193B),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 11),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: GoogleFonts.robotoMono(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  unit,
                  style: GoogleFonts.inter(fontSize: 7, color: const Color(0xFF94A3B8)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
