import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_button.dart';

// Unified Brand Colors (Matches CallHealth & PraCHtiz dark theme guidelines)
const Color _kCardBg = Color(0xFF0C0E1F); // Unified Flat Dark Navy
final Color _kCardBorder = Colors.white.withOpacity(0.08);
Color _kBrandBlue = AppColors.primary; // Primary theme color
const Color _kBrandGreen = Color(0xFF24C06F); // Success theme color
const Color _kTextGray = Color(0xFF94A3B8); // Muted text grey
const Color _kDangerRed = Color(0xFFEF4444); // Warning badge color

class HealthRecordsScreen extends StatefulWidget {
  const HealthRecordsScreen({super.key});

  @override
  State<HealthRecordsScreen> createState() => _HealthRecordsScreenState();
}

class _HealthRecordsScreenState extends State<HealthRecordsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int? _expandedIndex;

  // State Lists
  late List<Map<String, dynamic>> _records;
  late List<Map<String, String>> _attachments;
  late List<Map<String, dynamic>> _diagnoses;
  late List<Map<String, dynamic>> _medications;
  late List<Map<String, dynamic>> _upcomingVisits;

  // Upload Simulation State
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String _uploadingFileName = '';

  @override
  void initState() {
    super.initState();
    _records = [
      {
        "date": "2026-05-10",
        "doctor": "Dr. Sarah Jenkins",
        "reason": "Chronic Headache & Hypertension Review",
        "vitals": "BP: 142/90, HR: 84 bpm, Temp: 37.0°C",
        "notes": "Patient reports mild relief after taking amlodipine daily. Complaining of evening headaches. Recommended lifestyle modifications (low sodium diet, exercise) and scheduled 1-month follow-up.",
        "systolic": 142,
        "diastolic": 90,
      },
      {
        "date": "2026-03-15",
        "doctor": "Dr. Michael Chen (Cardiologist)",
        "reason": "Annual Cardiac Checkup",
        "vitals": "BP: 135/82, HR: 72 bpm, Temp: 36.8°C",
        "notes": "ECG shows normal sinus rhythm. Left ventricular function preserved. Advised to continue current low-sodium diet regime and monitor weekly vitals.",
        "systolic": 135,
        "diastolic": 82,
      },
    ];

    _attachments = [
      {"name": "Cardio_ECG_Report_05_26.pdf", "type": "ECG Report", "size": "2.4 MB"},
      {"name": "Chest_XRay_Digital_View.jpg", "type": "X-Ray Scan", "size": "12.8 MB"},
      {"name": "Biochemical_Blood_Panel.pdf", "type": "Blood Test", "size": "1.1 MB"},
    ];

    _diagnoses = [
      {"name": "Hypertension", "icd": "I10", "since": "2019", "severity": "Moderate"},
      {"name": "Type 2 Diabetes Mellitus", "icd": "E11.9", "since": "2021", "severity": "Managed"},
      {"name": "Mild Persistent Asthma", "icd": "J45.30", "since": "2015", "severity": "Mild"},
      {"name": "Hyperlipidemia", "icd": "E78.5", "since": "2020", "severity": "Managed"},
      {"name": "Generalized Anxiety Disorder", "icd": "F41.1", "since": "2022", "severity": "Mild"},
    ];

    _medications = [
      {"name": "Metformin", "dose": "500mg", "freq": "Twice daily", "status": "Active"},
      {"name": "Lisinopril", "dose": "10mg", "freq": "Once daily", "status": "Active"},
      {"name": "Atorvastatin", "dose": "20mg", "freq": "Once daily", "status": "Active"},
      {"name": "Aspirin", "dose": "81mg", "freq": "Once daily", "status": "Active"},
    ];

    _upcomingVisits = [
      {"type": "Lab Work", "date": "Feb 28, 2026 at 9:30 AM", "doctor": "Dr. Sarah Mitchell"},
      {"type": "Endocrinology Consult", "date": "Mar 4, 2026 at 2:00 PM", "doctor": "Dr. Helen Wu"},
      {"type": "Follow-up Visit", "date": "Mar 12, 2026 at 10:00 AM", "doctor": "Dr. Sarah Mitchell"},
    ];

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _addNewRecord(String doctor, String reason, String bp, String hr, String temp, String notes) {
    // Parse systolic/diastolic from bp input (e.g., "130/80")
    int systolic = 120;
    int diastolic = 80;
    final parts = bp.split('/');
    if (parts.length == 2) {
      systolic = int.tryParse(parts[0]) ?? 120;
      diastolic = int.tryParse(parts[1]) ?? 80;
    }

    final todayStr = DateTime.now().toString().split(' ')[0];

    setState(() {
      _records.insert(0, {
        "date": todayStr,
        "doctor": doctor,
        "reason": reason,
        "vitals": "BP: $bp, HR: $hr bpm, Temp: $temp°C",
        "notes": notes,
        "systolic": systolic,
        "diastolic": diastolic,
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: _kCardBg,
        content: Text("New EMR record added successfully!", style: GoogleFonts.inter(color: Colors.white)),
      ),
    );
  }

  void _simulateUpload(String name, String type, String size) {
    if (_isUploading) return;
    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
      _uploadingFileName = name;
    });

    // Simulate progress timer
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 150));
      if (!mounted) return false;
      setState(() {
        _uploadProgress += 0.15;
      });
      if (_uploadProgress >= 1.0) {
        setState(() {
          _isUploading = false;
          _attachments.insert(0, {
            "name": name,
            "type": type,
            "size": size,
          });
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: _kCardBg,
            content: Text("File '$name' uploaded and encrypted!", style: GoogleFonts.inter(color: Colors.white)),
          ),
        );
        return false;
      }
      return true;
    });
  }

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Screen Title
            Text(
              'EMR Health Records',
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF6B8EFF), // Brand light electric blue
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Complete clinical database, vitals timelines, and diagnostic attachments archive.',
              style: GoogleFonts.inter(color: _kTextGray, fontSize: 13),
            ),
            SizedBox(height: gap),

            // Active Diagnoses Card (Full Width)
            _buildActiveDiagnosesCard()
                .animate()
                .fadeIn(duration: 300.ms)
                .slideY(begin: 0.02, end: 0, curve: Curves.easeOutCubic),
            SizedBox(height: gap),

            // Split Panel Layout
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 5, child: _buildLeftPanel(gap)),
                  SizedBox(width: gap),
                  Expanded(flex: 7, child: _buildRightPanel(gap)),
                ],
              )
            else
              Column(
                children: [
                  _buildLeftPanel(gap),
                  SizedBox(height: gap),
                  _buildRightPanel(gap),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // PANEL BUILDERS
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildLeftPanel(double gap) {
    return Column(
      children: [
        _buildMedicationsCard()
            .animate()
            .fadeIn(duration: 300.ms)
            .slideY(begin: 0.02, end: 0, curve: Curves.easeOutCubic),
        SizedBox(height: gap),
        _buildPatientCard()
            .animate()
            .fadeIn(delay: 100.ms, duration: 300.ms)
            .slideY(begin: 0.02, end: 0, curve: Curves.easeOutCubic),
        SizedBox(height: gap),
        _buildVitalsTrendCard()
            .animate()
            .fadeIn(delay: 200.ms, duration: 300.ms)
            .slideY(begin: 0.02, end: 0, curve: Curves.easeOutCubic),
      ],
    );
  }

  Widget _buildRightPanel(double gap) {
    return Column(
      children: [
        _buildUpcomingVisitsCard()
            .animate()
            .fadeIn(duration: 300.ms)
            .slideY(begin: 0.02, end: 0, curve: Curves.easeOutCubic),
        SizedBox(height: gap),
        _buildTimelineSection(gap)
            .animate()
            .fadeIn(delay: 150.ms, duration: 300.ms)
            .slideY(begin: 0.02, end: 0, curve: Curves.easeOutCubic),
        SizedBox(height: gap),
        _buildAttachmentsSection()
            .animate()
            .fadeIn(delay: 250.ms, duration: 300.ms)
            .slideY(begin: 0.02, end: 0, curve: Curves.easeOutCubic),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // PATIENT PROFILE CARD
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildPatientCard() {
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
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: _kBrandBlue.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _kBrandBlue.withOpacity(0.3), width: 1.5),
                ),
                child: Center(
                  child: Text(
                    'MV',
                    style: GoogleFonts.inter(
                      color: _kBrandBlue,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Marcus Vance',
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Patient ID: PT-0482 • 45 y/o Male',
                      style: GoogleFonts.inter(color: _kTextGray, fontSize: 11.5),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _kDangerRed.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _kDangerRed.withOpacity(0.3)),
                ),
                child: Text(
                  'HIGH RISK',
                  style: GoogleFonts.inter(color: _kDangerRed, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 16),
          _buildDemographicRow('Chief Condition', 'Acute Coronary Syndrome', highlight: true),
          _buildDemographicRow('Allergies', 'Penicillin, Sulfa Drugs', warning: true),
          _buildDemographicRow('Blood Profile', 'O Positive (O+)'),
          _buildDemographicRow('Vitals Summary', '178 cm • 78 kg • BMI 24.6 (Normal)'),
          _buildDemographicRow('Access status', 'EMR Encrypted Database Lock'),
        ],
      ),
    );
  }

  Widget _buildDemographicRow(String label, String value, {bool highlight = false, bool warning = false}) {
    Color valColor = Colors.white.withOpacity(0.85);
    if (highlight) valColor = const Color(0xFF6B8EFF);
    if (warning) valColor = _kDangerRed;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(color: _kTextGray, fontSize: 11.5, fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: GoogleFonts.inter(color: valColor, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // VITALS TREND GRAPH
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildVitalsTrendCard() {
    return AppCard(
      color: _kCardBg,
      borderRadius: AppRadius.radius12,
      border: Border.all(color: _kCardBorder),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Blood Pressure Trends',
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Systolic vs Diastolic readings history',
                    style: GoogleFonts.inter(color: _kTextGray, fontSize: 11.5),
                  ),
                ],
              ),
              Row(
                children: [
                  _buildLegendItem('SYS', _kBrandBlue),
                  const SizedBox(width: 8),
                  _buildLegendItem('DIA', _kBrandGreen),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.white.withOpacity(0.04),
                    strokeWidth: 1.0,
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        if (value % 20 != 0) return const SizedBox.shrink();
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            value.toInt().toString(),
                            style: GoogleFonts.inter(color: _kTextGray, fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 20,
                      getTitlesWidget: (value, meta) {
                        const dates = ['10 JAN', '15 FEB', '15 MAR', '20 APR', '10 MAY'];
                        final idx = value.toInt();
                        if (idx < 0 || idx >= dates.length) return const SizedBox.shrink();
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            dates[idx],
                            style: GoogleFonts.inter(color: _kTextGray, fontSize: 8.5, fontWeight: FontWeight.bold),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minY: 60,
                maxY: 160,
                minX: 0,
                maxX: 4,
                lineBarsData: [
                  // Systolic
                  LineChartBarData(
                    spots: [
                      FlSpot(0, 130),
                      FlSpot(1, 128),
                      FlSpot(2, 135),
                      FlSpot(3, 138),
                      FlSpot(4, 142),
                    ],
                    isCurved: true,
                    color: _kBrandBlue,
                    barWidth: 3.0,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: _kBrandBlue.withOpacity(0.08),
                    ),
                  ),
                  // Diastolic
                  LineChartBarData(
                    spots: [
                      FlSpot(0, 80),
                      FlSpot(1, 82),
                      FlSpot(2, 82),
                      FlSpot(3, 85),
                      FlSpot(4, 90),
                    ],
                    isCurved: true,
                    color: _kBrandGreen,
                    barWidth: 3.0,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: _kBrandGreen.withOpacity(0.04),
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

  Widget _buildLegendItem(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          title,
          style: GoogleFonts.inter(color: _kTextGray, fontSize: 9.5, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // CHECKUP TIMELINE SECTION
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildTimelineSection(double gap) {
    final filtered = _records.where((rec) {
      final doc = rec['doctor'].toString().toLowerCase();
      final reason = rec['reason'].toString().toLowerCase();
      final notes = rec['notes'].toString().toLowerCase();
      return doc.contains(_searchQuery) || reason.contains(_searchQuery) || notes.contains(_searchQuery);
    }).toList();

    return AppCard(
      color: _kCardBg,
      borderRadius: AppRadius.radius12,
      border: Border.all(color: _kCardBorder),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Unified Card Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.history, color: _kBrandBlue, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Clinical Consultation History',
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              AppButton(
                label: 'Add Record',
                height: 32,
                icon: const Icon(Icons.add, color: Colors.white, size: 14),
                onPressed: _showAddRecordDialog,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 16),

          // Search Field inside the Unified Card
          TextField(
            controller: _searchController,
            style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withOpacity(0.02),
              hintText: 'Search timeline logs...',
              hintStyle: GoogleFonts.inter(color: _kTextGray.withOpacity(0.5), fontSize: 13),
              prefixIcon: const Icon(Icons.search, color: _kTextGray, size: 18),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: _kTextGray, size: 16),
                      onPressed: () {
                        _searchController.clear();
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: _kCardBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: _kBrandBlue, width: 1.2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Unified Timeline Log List
          if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Center(
                child: Text(
                  'No health record logs match your search.',
                  style: GoogleFonts.inter(color: _kTextGray, fontSize: 13),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final rec = filtered[index];
                final isExpanded = _expandedIndex == index;
                final bool isLast = index == filtered.length - 1;

                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Timeline node and vertical connector line
                      Column(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: _kBrandBlue.withOpacity(0.12),
                              shape: BoxShape.circle,
                              border: Border.all(color: _kBrandBlue, width: 1.5),
                            ),
                            child: Icon(Icons.calendar_today, size: 10, color: _kBrandBlue),
                          ),
                          Expanded(
                            child: Container(
                              width: 1.5,
                              color: isLast ? Colors.transparent : Colors.white.withOpacity(0.08),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),

                      // Consultation Details Card
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.01),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white.withOpacity(0.03)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Date & Doctor
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    rec['date'],
                                    style: GoogleFonts.inter(color: _kBrandBlue, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    rec['doctor'],
                                    style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Reason label & value
                              Text(
                                'REASON FOR CONSULTATION',
                                style: GoogleFonts.inter(color: _kTextGray, fontSize: 9, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                rec['reason'],
                                style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 10),

                              // Vitalssnapshot
                              Text(
                                'VITAL READINGS SNAPSHOT',
                                style: GoogleFonts.inter(color: _kTextGray, fontSize: 9, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 5),
                              _buildVitalsBadges(rec['vitals']),
                              const SizedBox(height: 12),

                              // Expandable Notes
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _expandedIndex = isExpanded ? null : index;
                                  });
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'CLINICAL LOG RECOMMENDATIONS',
                                      style: GoogleFonts.inter(color: _kTextGray, fontSize: 9, fontWeight: FontWeight.bold),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          isExpanded ? 'Collapse' : 'Expand Notes',
                                          style: GoogleFonts.inter(color: _kBrandBlue, fontSize: 10.5, fontWeight: FontWeight.bold),
                                        ),
                                        Icon(
                                          isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                          color: _kBrandBlue,
                                          size: 14,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 5),
                              AnimatedCrossFade(
                                firstChild: Text(
                                  rec['notes'],
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(color: Colors.white.withOpacity(0.7), fontSize: 11.5, height: 1.4),
                                ),
                                secondChild: Text(
                                  rec['notes'],
                                  style: GoogleFonts.inter(color: Colors.white.withOpacity(0.7), fontSize: 11.5, height: 1.4),
                                ),
                                crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                                duration: const Duration(milliseconds: 200),
                              ),
                            ],
                          ),
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

  Widget _buildVitalsBadges(String vitalsStr) {
    // Expected format: "BP: 142/90, HR: 84 bpm, Temp: 37.0°C"
    final List<Widget> badges = [];
    final items = vitalsStr.split(', ');

    for (var item in items) {
      final parts = item.split(': ');
      if (parts.length == 2) {
        final label = parts[0];
        final val = parts[1];

        IconData icon = Icons.thermostat;
        Color col = _kBrandGreen;
        if (label == 'BP') {
          icon = Icons.favorite_border;
          col = _kBrandBlue;
        } else if (label == 'HR') {
          icon = Icons.bolt;
          col = Colors.purpleAccent;
        }

        badges.add(
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: col.withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: col.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: col, size: 12),
                const SizedBox(width: 4),
                Text(
                  '$label: $val',
                  style: GoogleFonts.inter(color: col, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      }
    }

    return Wrap(children: badges);
  }

  // ───────────────────────────────────────────────────────────────────────────
  // DIAGNOSTIC ATTACHMENTS SECTION
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildAttachmentsSection() {
    return AppCard(
      color: _kCardBg,
      borderRadius: AppRadius.radius12,
      border: Border.all(color: _kCardBorder),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Diagnostic Attachments',
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Patient health records documents archive',
                    style: GoogleFonts.inter(color: _kTextGray, fontSize: 11.5),
                  ),
                ],
              ),
              AppButton(
                label: 'Upload Attachment',
                variant: AppButtonVariant.secondary,
                height: 36,
                icon: Icon(Icons.upload_file, color: _kBrandBlue, size: 16),
                onPressed: _showUploadSelectionDialog,
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Uploading progress indicator if active
          if (_isUploading) ...[
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: _kBrandBlue.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _kBrandBlue.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Uploading: $_uploadingFileName',
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        '${(_uploadProgress * 100).toInt()}%',
                        style: GoogleFonts.inter(color: _kBrandBlue, fontSize: 11.5, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: _uploadProgress,
                    backgroundColor: Colors.white10,
                    color: _kBrandBlue,
                    minHeight: 4,
                  ),
                ],
              ),
            ),
          ],

          // Attachments list
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _attachments.length,
            itemBuilder: (context, index) {
              final file = _attachments[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.02),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withOpacity(0.04)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: _kBrandBlue.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(Icons.insert_drive_file, color: _kBrandBlue, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              file['name']!,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${file['type']} • ${file['size']}',
                              style: GoogleFonts.inter(color: _kTextGray, fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'View attachment report',
                        icon: Icon(Icons.visibility_outlined, color: _kBrandBlue, size: 18),
                        onPressed: () => _showAttachmentPreview(context, file['name']!),
                      ),
                      IconButton(
                        tooltip: 'Download file',
                        icon: const Icon(Icons.file_download_outlined, color: _kBrandGreen, size: 18),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: _kCardBg,
                              content: Text('Downloading "${file['name']}"...', style: GoogleFonts.inter(color: Colors.white)),
                            ),
                          );
                        },
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

  // ───────────────────────────────────────────────────────────────────────────
  // DIALOGS & FORMS
  // ───────────────────────────────────────────────────────────────────────────
  void _showAddRecordDialog() {
    final formKey = GlobalKey<FormState>();
    final docController = TextEditingController(text: 'Dr. Sarah Jenkins');
    final reasonController = TextEditingController();
    final bpController = TextEditingController(text: '120/80');
    final hrController = TextEditingController(text: '75');
    final tempController = TextEditingController(text: '37.0');
    final notesController = TextEditingController();

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
            'Add EMR Health Record',
            style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.5),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDialogTextField('Consulting Doctor', docController, requiredField: true),
                  _buildDialogTextField('Reason for Consultation', reasonController, hint: 'e.g. Hypertension Checkup', requiredField: true),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDialogTextField('Blood Pressure', bpController, hint: '120/80', requiredField: true),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildDialogTextField('Heart Rate (bpm)', hrController, hint: '75', requiredField: true),
                      ),
                    ],
                  ),
                  _buildDialogTextField('Body Temp (°C)', tempController, hint: '37.0', requiredField: true),
                  _buildDialogTextField('Clinical Notes / Recs', notesController, hint: 'Write recommendation log...', maxLines: 3),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: GoogleFonts.inter(color: _kTextGray)),
            ),
            AppButton(
              label: 'Save Record',
              height: 38,
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  _addNewRecord(
                    docController.text.trim(),
                    reasonController.text.trim(),
                    bpController.text.trim(),
                    hrController.text.trim(),
                    tempController.text.trim(),
                    notesController.text.trim(),
                  );
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildDialogTextField(String label, TextEditingController ctrl, {String? hint, bool requiredField = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(color: _kTextGray, fontSize: 11, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 5),
          TextFormField(
            controller: ctrl,
            maxLines: maxLines,
            style: GoogleFonts.inter(color: Colors.white, fontSize: 12.5),
            validator: requiredField
                ? (val) => val == null || val.trim().isEmpty ? 'Required field' : null
                : null,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withOpacity(0.02),
              hintText: hint,
              hintStyle: GoogleFonts.inter(color: _kTextGray.withOpacity(0.4), fontSize: 12.5),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: _kCardBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: _kBrandBlue, width: 1.2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showUploadSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          backgroundColor: _kCardBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: _kCardBorder),
          ),
          title: Text(
            'Select Diagnostic File to Upload',
            style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
          ),
          children: [
            _buildDialogUploadOption('Cardiology ECG Waveform.pdf', 'ECG Report', '3.1 MB'),
            _buildDialogUploadOption('Chest X-Ray Digit Scan.jpg', 'X-Ray Scan', '15.4 MB'),
            _buildDialogUploadOption('Comprehensive Lipids Panel.pdf', 'Blood Test', '1.2 MB'),
            _buildDialogUploadOption('Urine Routine Analysis.pdf', 'Urine Test', '0.8 MB'),
          ],
        );
      },
    );
  }

  Widget _buildDialogUploadOption(String name, String type, String size) {
    return SimpleDialogOption(
      onPressed: () {
        Navigator.of(context).pop();
        _simulateUpload(name, type, size);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Row(
          children: [
            Icon(Icons.attach_file, color: _kBrandBlue, size: 16),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: GoogleFonts.inter(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.bold)),
                  Text('$type • $size', style: GoogleFonts.inter(color: _kTextGray, fontSize: 10)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAttachmentPreview(BuildContext context, String filename) {
    showDialog(
      context: context,
      builder: (context) {
        final width = MediaQuery.sizeOf(context).width;
        final previewWidth = width > 800 ? 650.0 : width * 0.90;

        Widget previewWidget;
        if (filename.toLowerCase().contains('ecg')) {
          previewWidget = Container(
            height: 180,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white12),
            ),
            child: CustomPaint(
              painter: _ECGWaveformPainter(),
              child: Container(),
            ),
          );
        } else if (filename.toLowerCase().contains('xray')) {
          previewWidget = Container(
            height: 180,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white12),
            ),
            child: CustomPaint(
              painter: _XRayPainter(),
              child: Container(),
            ),
          );
        } else {
          previewWidget = Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.02),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PraCHtiz Clinical Laboratories',
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Biochemical Blood Panel Results',
                  style: GoogleFonts.inter(color: _kTextGray, fontSize: 11),
                ),
                const SizedBox(height: 12),
                _buildLabResultRow('Serum Cholesterol', '190 mg/dL', 'Normal (<200)'),
                _buildLabResultRow('Triglycerides', '140 mg/dL', 'Normal (<150)'),
                _buildLabResultRow('Fast Glucose', '104 mg/dL', 'Borderline (70-100)', warning: true),
                _buildLabResultRow('Serum Creatinine', '0.9 mg/dL', 'Normal (0.6-1.2)'),
              ],
            ),
          );
        }

        return AlertDialog(
          backgroundColor: _kCardBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: _kCardBorder),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  filename,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: Colors.white, size: 18),
                splashRadius: 18,
              ),
            ],
          ),
          content: SizedBox(
            width: previewWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SECURE DOCUMENT PREVIEW LOCK',
                  style: GoogleFonts.inter(color: _kBrandGreen, fontSize: 9, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                previewWidget,
                const SizedBox(height: 16),
                Text(
                  'This digital record is encrypted using SHA-256 EMR architecture. Only authorized medical practitioners are permitted to preview or copy clinical records.',
                  style: GoogleFonts.inter(color: _kTextGray, fontSize: 10, height: 1.4),
                ),
              ],
            ),
          ),
          actions: [
            AppButton(
              label: 'Close Preview',
              height: 38,
              variant: AppButtonVariant.ghost,
              onPressed: () => Navigator.of(context).pop(),
            ),
            AppButton(
              label: 'Download File',
              height: 38,
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: _kCardBg,
                    content: Text('Downloading "$filename"...', style: GoogleFonts.inter(color: Colors.white)),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildLabResultRow(String testName, String value, String ref, {bool warning = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(testName, style: GoogleFonts.inter(color: _kTextGray, fontSize: 11)),
          Text(value, style: GoogleFonts.inter(color: warning ? _kDangerRed : Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
          Text(ref, style: GoogleFonts.inter(color: _kTextGray, fontSize: 10, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  Widget _buildActiveDiagnosesCard() {
    return AppCard(
      color: _kCardBg,
      borderRadius: AppRadius.radius12,
      border: Border.all(color: _kCardBorder),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.format_list_bulleted, color: Color(0xFF6B8EFF), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Active Diagnoses',
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: _showAddDiagnosisDialog,
                icon: const Icon(Icons.add, size: 14, color: Color(0xFF6B8EFF)),
                label: Text(
                  'Add Diagnosis',
                  style: GoogleFonts.inter(color: const Color(0xFF6B8EFF), fontSize: 12, fontWeight: FontWeight.bold),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 10),
          ..._diagnoses.asMap().entries.map((entry) {
            final int index = entry.key;
            final Map<String, dynamic> diag = entry.value;

            Color severityColor;
            switch (diag['severity'].toString().toLowerCase()) {
              case 'mild':
                severityColor = AppColors.primary; // Blue
                break;
              case 'moderate':
                severityColor = const Color(0xFFF59E0B); // Yellow/Orange
                break;
              case 'severe':
                severityColor = const Color(0xFFEF4444); // Red
                break;
              case 'managed':
              default:
                severityColor = const Color(0xFF24C06F); // Green
                break;
            }

            return Column(
              children: [
                InkWell(
                  onTap: () => _showDiagnosisDetails(diag),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 6.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                diag['name'],
                                style: GoogleFonts.inter(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'ICD-10: ${diag['icd']} • Since ${diag['since']}',
                                style: GoogleFonts.inter(color: _kTextGray, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: severityColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: severityColor.withOpacity(0.3)),
                          ),
                          child: Text(
                            diag['severity'],
                            style: GoogleFonts.inter(color: severityColor, fontSize: 9.5, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (index < _diagnoses.length - 1)
                  Divider(color: Colors.white.withOpacity(0.04), height: 1),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMedicationsCard() {
    return AppCard(
      color: _kCardBg,
      borderRadius: AppRadius.radius12,
      border: Border.all(color: _kCardBorder),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.medication_outlined, color: Color(0xFF24C06F), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Current Medications',
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: _showAddMedicationDialog,
                icon: const Icon(Icons.add, size: 14, color: Color(0xFF24C06F)),
                label: Text(
                  'Add',
                  style: GoogleFonts.inter(color: const Color(0xFF24C06F), fontSize: 12, fontWeight: FontWeight.bold),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _medications.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final med = _medications[index];
              final bool isActive = med['status'].toString().toLowerCase() == 'active';
              final Color badgeColor = isActive ? const Color(0xFF24C06F) : const Color(0xFFF59E0B);

              return InkWell(
                onTap: () => _toggleMedicationStatus(index),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.01),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withOpacity(0.03)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFF24C06F).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.medical_services_outlined, color: Color(0xFF24C06F), size: 15),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              med['name'],
                              style: GoogleFonts.inter(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${med['dose']} • ${med['freq']}',
                              style: GoogleFonts.inter(color: _kTextGray, fontSize: 10.5),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: badgeColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: badgeColor.withOpacity(0.3)),
                        ),
                        child: Text(
                          med['status'],
                          style: GoogleFonts.inter(color: badgeColor, fontSize: 9, fontWeight: FontWeight.bold),
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

  Widget _buildUpcomingVisitsCard() {
    return AppCard(
      color: _kCardBg,
      borderRadius: AppRadius.radius12,
      border: Border.all(color: _kCardBorder),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined, color: AppColors.primary, size: 17),
                  const SizedBox(width: 8),
                  Text(
                    'Upcoming Visits',
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: _showScheduleVisitDialog,
                icon: Icon(Icons.add, size: 14, color: AppColors.primary),
                label: Text(
                  'Schedule',
                  style: GoogleFonts.inter(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _upcomingVisits.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final visit = _upcomingVisits[index];

              return InkWell(
                onTap: () => _handleVisitAction(index),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              visit['type'],
                              style: GoogleFonts.inter(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              visit['date'],
                              style: GoogleFonts.inter(color: _kTextGray, fontSize: 10.5),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              visit['doctor'],
                              style: GoogleFonts.inter(color: const Color(0xFF6B8EFF), fontSize: 10.5, fontWeight: FontWeight.bold),
                            ),
                          ],
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

  void _showAddDiagnosisDialog() {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final icdController = TextEditingController();
    final sinceController = TextEditingController(text: DateTime.now().year.toString());
    String severity = 'Moderate';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: _kCardBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: _kCardBorder),
              ),
              title: Text(
                'Add Active Diagnosis',
                style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.5),
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDialogTextField('Diagnosis Name', nameController, hint: 'e.g. Hypertension', requiredField: true),
                      _buildDialogTextField('ICD-10 Code', icdController, hint: 'e.g. I10', requiredField: true),
                      _buildDialogTextField('Diagnosed Since (Year)', sinceController, hint: 'e.g. 2026', requiredField: true),
                      Text(
                        'Severity Level',
                        style: GoogleFonts.inter(color: _kTextGray, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.02),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: _kCardBorder),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            dropdownColor: _kCardBg,
                            value: severity,
                            isExpanded: true,
                            style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                            items: ['Mild', 'Moderate', 'Severe', 'Managed'].map((String val) {
                              return DropdownMenuItem<String>(
                                value: val,
                                child: Text(val),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setDialogState(() {
                                  severity = val;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel', style: GoogleFonts.inter(color: _kTextGray)),
                ),
                AppButton(
                  label: 'Add Diagnosis',
                  height: 38,
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      setState(() {
                        _diagnoses.add({
                          "name": nameController.text.trim(),
                          "icd": icdController.text.trim().toUpperCase(),
                          "since": sinceController.text.trim(),
                          "severity": severity,
                        });
                      });
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: _kCardBg,
                          content: Text('Diagnosis "${nameController.text.trim()}" added.', style: GoogleFonts.inter(color: Colors.white)),
                        ),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddMedicationDialog() {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final doseController = TextEditingController();
    final freqController = TextEditingController(text: 'Once daily');

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
            'Add Current Medication',
            style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.5),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDialogTextField('Medication Name', nameController, hint: 'e.g. Metformin', requiredField: true),
                  _buildDialogTextField('Dosage Strength', doseController, hint: 'e.g. 500mg', requiredField: true),
                  _buildDialogTextField('Frequency / Interval', freqController, hint: 'e.g. Twice daily', requiredField: true),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: GoogleFonts.inter(color: _kTextGray)),
            ),
            AppButton(
              label: 'Add Medication',
              height: 38,
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  setState(() {
                    _medications.add({
                      "name": nameController.text.trim(),
                      "dose": doseController.text.trim(),
                      "freq": freqController.text.trim(),
                      "status": "Active",
                    });
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: _kCardBg,
                      content: Text('Medication "${nameController.text.trim()}" added.', style: GoogleFonts.inter(color: Colors.white)),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showScheduleVisitDialog() {
    final formKey = GlobalKey<FormState>();
    final typeController = TextEditingController();
    final dateController = TextEditingController(text: 'Jun 25, 2026 at 10:00 AM');
    final docController = TextEditingController(text: 'Dr. Sarah Jenkins');

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
            'Schedule Upcoming Visit',
            style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.5),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDialogTextField('Visit / Procedure Type', typeController, hint: 'e.g. Cardiology Review', requiredField: true),
                  _buildDialogTextField('Date & Time', dateController, hint: 'e.g. Jun 25, 2026 at 10:00 AM', requiredField: true),
                  _buildDialogTextField('Consulting Doctor', docController, hint: 'e.g. Dr. Sarah Jenkins', requiredField: true),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: GoogleFonts.inter(color: _kTextGray)),
            ),
            AppButton(
              label: 'Schedule',
              height: 38,
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  setState(() {
                    _upcomingVisits.add({
                      "type": typeController.text.trim(),
                      "date": dateController.text.trim(),
                      "doctor": docController.text.trim(),
                    });
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: _kCardBg,
                      content: Text('Visit for "${typeController.text.trim()}" scheduled.', style: GoogleFonts.inter(color: Colors.white)),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showDiagnosisDetails(Map<String, dynamic> diagnosis) {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  diagnosis['name'],
                  style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.5),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: Colors.white54, size: 18),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ICD-10 CLINICAL PROFILE',
                style: GoogleFonts.inter(color: const Color(0xFF6B8EFF), fontSize: 9.5, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'Code: ${diagnosis['icd']}\nDiagnosed: Since ${diagnosis['since']}\nSeverity Classification: ${diagnosis['severity']}',
                style: GoogleFonts.inter(color: Colors.white.withOpacity(0.85), fontSize: 12, height: 1.5),
              ),
              const SizedBox(height: 16),
              Text(
                'TYPICAL EMR CLINICAL RECOMMENDATIONS',
                style: GoogleFonts.inter(color: const Color(0xFF6B8EFF), fontSize: 9.5, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                '• Schedule quarterly blood pressure checks and metabolic panels.\n'
                '• Advise daily logging of systolic/diastolic vitals.\n'
                '• Link diagnosis with related active medication listings.',
                style: GoogleFonts.inter(color: Colors.white.withOpacity(0.7), fontSize: 11.5, height: 1.4),
              ),
            ],
          ),
          actions: [
            AppButton(
              label: 'Close Details',
              height: 36,
              variant: AppButtonVariant.secondary,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _toggleMedicationStatus(int index) {
    setState(() {
      final current = _medications[index]['status'];
      final next = current == 'Active' ? 'Paused' : 'Active';
      _medications[index]['status'] = next;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: _kCardBg,
        duration: const Duration(seconds: 2),
        content: Text(
          'Medication "${_medications[index]['name']}" status updated to ${_medications[index]['status']}.',
          style: GoogleFonts.inter(color: Colors.white),
        ),
      ),
    );
  }

  void _handleVisitAction(int index) {
    final visit = _upcomingVisits[index];

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
            'Visit: ${visit['type']}',
            style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15.5),
          ),
          content: Text(
            'Scheduled on ${visit['date']} with ${visit['doctor']}.\n\nChoose an action for this upcoming visit.',
            style: GoogleFonts.inter(color: _kTextGray, fontSize: 12.5, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _rescheduleVisitDialog(index);
              },
              child: Text('Reschedule', style: GoogleFonts.inter(color: AppColors.primary)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _upcomingVisits.removeAt(index);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: _kCardBg,
                    content: Text('Appointment "${visit['type']}" canceled.', style: GoogleFonts.inter(color: Colors.white)),
                  ),
                );
              },
              child: Text('Cancel Appointment', style: GoogleFonts.inter(color: const Color(0xFFEF4444))),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close', style: GoogleFonts.inter(color: _kTextGray)),
            ),
          ],
        );
      },
    );
  }

  void _rescheduleVisitDialog(int index) {
    final visit = _upcomingVisits[index];
    final dateController = TextEditingController(text: visit['date']);

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
            'Reschedule Visit',
            style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15.5),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rescheduling "${visit['type']}" with ${visit['doctor']}.',
                style: GoogleFonts.inter(color: _kTextGray, fontSize: 11.5),
              ),
              const SizedBox(height: 12),
              _buildDialogTextField('New Date & Time', dateController, requiredField: true),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: GoogleFonts.inter(color: _kTextGray)),
            ),
            AppButton(
              label: 'Reschedule',
              height: 38,
              onPressed: () {
                if (dateController.text.trim().isNotEmpty) {
                  setState(() {
                    _upcomingVisits[index]['date'] = dateController.text.trim();
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: _kCardBg,
                      content: Text('Visit rescheduled to "${dateController.text.trim()}".', style: GoogleFonts.inter(color: Colors.white)),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CUSTOM PAINTERS FOR RICH SCI-FI PREVIEWS
// ─────────────────────────────────────────────────────────────────────────────
class _ECGWaveformPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Fill background
    final bgPaint = Paint()..color = const Color(0xFF0F172A);
    canvas.drawRect(Offset.zero & size, bgPaint);

    final gridPaint = Paint()
      ..color = Colors.green.withOpacity(0.05)
      ..strokeWidth = 0.5;
    for (double i = 0; i < size.width; i += 15) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
    }
    for (double i = 0; i < size.height; i += 15) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), gridPaint);
    }

    final paint = Paint()
      ..color = const Color(0xFF24C06F) // emerald green
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    double x = 0;
    final points = <double>[];
    
    // Sinus wave pulse pattern generator
    while (x < size.width) {
      points.addAll([0, 0, 0, 0, -4, 4, -25, 45, -8, 0, 8, 0]);
      x += 60;
    }

    x = 0;
    final stepX = size.width / (points.length - 1);
    for (int i = 0; i < points.length; i++) {
      final y = size.height * 0.5 - points[i] * (size.height * 0.007);
      if (i == 0) {
        path.moveTo(0, y);
      } else {
        path.lineTo(i * stepX, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _XRayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // High-tech blueprint dark outline chest X-ray
    final bgPaint = Paint()..color = const Color(0xFF0F172A);
    canvas.drawRect(Offset.zero & size, bgPaint);

    final gridPaint = Paint()
      ..color = Colors.cyan.withOpacity(0.04)
      ..strokeWidth = 1.0;
    for (double i = 0; i < size.width; i += 25) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
    }
    for (double i = 0; i < size.height; i += 25) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), gridPaint);
    }

    final chestPaint = Paint()
      ..color = Colors.cyan.withOpacity(0.2)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    final w = size.width;
    final h = size.height;

    // Outer skeletal lung frames
    path.moveTo(w * 0.25, h * 0.15);
    path.quadraticBezierTo(w * 0.15, h * 0.5, w * 0.28, h * 0.85);
    path.lineTo(w * 0.46, h * 0.85);
    path.quadraticBezierTo(w * 0.43, h * 0.5, w * 0.47, h * 0.15);
    path.close();

    path.moveTo(w * 0.75, h * 0.15);
    path.quadraticBezierTo(w * 0.85, h * 0.5, w * 0.72, h * 0.85);
    path.lineTo(w * 0.54, h * 0.85);
    path.quadraticBezierTo(w * 0.57, h * 0.5, w * 0.53, h * 0.15);
    path.close();

    // Heart outline
    final heartPaint = Paint()
      ..color = Colors.red.withOpacity(0.08)
      ..style = PaintingStyle.fill;
    canvas.drawOval(Rect.fromLTWH(w * 0.40, h * 0.48, w * 0.18, h * 0.22), heartPaint);

    canvas.drawPath(path, chestPaint);

    // Spinal spine columns
    final spinePaint = Paint()
      ..color = Colors.cyan.withOpacity(0.25)
      ..strokeWidth = 5.0;
    canvas.drawLine(Offset(w * 0.5, h * 0.08), Offset(w * 0.5, h * 0.92), spinePaint);

    // Curved ribs
    final ribPaint = Paint()
      ..color = Colors.cyan.withOpacity(0.15)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;
    
    for (int i = 0; i < 5; i++) {
      final y = h * (0.25 + i * 0.10);
      final rLeft = Path();
      rLeft.moveTo(w * 0.5, y);
      rLeft.quadraticBezierTo(w * 0.32, y - 4, w * 0.22, y + 12);
      canvas.drawPath(rLeft, ribPaint);

      final rRight = Path();
      rRight.moveTo(w * 0.5, y);
      rRight.quadraticBezierTo(w * 0.68, y - 4, w * 0.78, y + 12);
      canvas.drawPath(rRight, ribPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
