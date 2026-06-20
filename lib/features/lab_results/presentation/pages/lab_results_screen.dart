import "package:prachtiz_flutter/core/theme/app_colors.dart";
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_button.dart';

// Unified Brand Colors (Matches CallHealth & PraCHtiz dark theme guidelines)
const Color _kCardBg = Color(0xFF0C0E1F); // Unified Flat Dark Navy
final Color _kCardBorder = Colors.white.withOpacity(0.08);
Color _kBrandBlue = AppColors.primary; // Primary theme color
const Color _kBrandGreen = Color(0xFF24C06F); // Success theme color
const Color _kTextGray = Color(0xFF94A3B8); // Muted text grey
const Color _kDangerRed = Color(0xFFEF4444); // Warning badge color
const Color _kWarningAmber = Color(0xFFF59E0B); // Alert color
const Color _kBorderlinePurple = Color(0xFF8B5CF6); // Borderline status color

class LabResultsScreen extends StatefulWidget {
  const LabResultsScreen({super.key});

  @override
  State<LabResultsScreen> createState() => _LabResultsScreenState();
}

class _LabResultsScreenState extends State<LabResultsScreen> {
  // KPI Metrics counts
  final int _pendingResultsCount = 23;
  final int _completedTodayCount = 48;
  int _abnormalFlagsCount = 8;
  final double _avgTurnaroundHours = 4.2;

  // Search and Filtering state
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _selectedStatusFilter = "All";

  // Data lists
  late List<Map<String, dynamic>> _recentResults;
  late int _selectedResultIndex;

  @override
  void initState() {
    super.initState();
    _selectedResultIndex = 1; // Default to David Thompson (Critical) for trend charts
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });

    _recentResults = [
      {
        "patient": "Robert Kim",
        "avatarColor": const Color(0xFF3B82F6),
        "test": "LDL Cholesterol",
        "value": "162",
        "unit": "mg/dL",
        "reference": "< 100",
        "status": "High",
        "date": "Feb 27, 2026",
        "details": [
          {"parameter": "Total Cholesterol", "result": "248 mg/dL", "referenceRange": "< 200 mg/dL", "status": "High"},
          {"parameter": "Triglycerides", "result": "165 mg/dL", "referenceRange": "< 150 mg/dL", "status": "High"},
          {"parameter": "HDL Cholesterol", "result": "42 mg/dL", "referenceRange": "> 40 mg/dL", "status": "Normal"},
          {"parameter": "LDL Cholesterol", "result": "162 mg/dL", "referenceRange": "< 100 mg/dL", "status": "High"},
        ],
        "orderedBy": "Dr. Sarah Jenkins",
        "chartData": [135.0, 142.0, 148.0, 155.0, 162.0],
      },
      {
        "patient": "David Thompson",
        "avatarColor": const Color(0xFFEF4444),
        "test": "Potassium",
        "value": "5.8",
        "unit": "mEq/L",
        "reference": "3.5-5.0",
        "status": "Critical",
        "date": "Feb 27, 2026",
        "details": [
          {"parameter": "Potassium", "result": "5.8 mEq/L", "referenceRange": "3.5 - 5.0 mEq/L", "status": "Critical"},
          {"parameter": "Sodium", "result": "141 mEq/L", "referenceRange": "135 - 145 mEq/L", "status": "Normal"},
          {"parameter": "Chloride", "result": "102 mEq/L", "referenceRange": "96 - 106 mEq/L", "status": "Normal"},
        ],
        "orderedBy": "Dr. Michael Chen",
        "chartData": [4.1, 4.4, 4.8, 5.3, 5.8],
      },
      {
        "patient": "Patricia Moore",
        "avatarColor": const Color(0xFF8B5CF6),
        "test": "Troponin I",
        "value": "0.04",
        "unit": "ng/mL",
        "reference": "< 0.04",
        "status": "Borderline",
        "date": "Feb 27, 2026",
        "details": [
          {"parameter": "Troponin I", "result": "0.04 ng/mL", "referenceRange": "< 0.04 ng/mL", "status": "Borderline"},
          {"parameter": "CK-MB", "result": "3.2 ng/mL", "referenceRange": "< 5.0 ng/mL", "status": "Normal"},
          {"parameter": "Myoglobin", "result": "45 ng/mL", "referenceRange": "< 85 ng/mL", "status": "Normal"},
        ],
        "orderedBy": "Dr. Michael Chen",
        "chartData": [0.01, 0.02, 0.02, 0.03, 0.04],
      },
      {
        "patient": "Sarah Johnson",
        "avatarColor": const Color(0xFFF59E0B),
        "test": "HbA1c",
        "value": "7.2",
        "unit": "%",
        "reference": "< 5.7",
        "status": "High",
        "date": "Feb 26, 2026",
        "details": [
          {"parameter": "HbA1c", "result": "7.2 %", "referenceRange": "< 5.7 %", "status": "High"},
          {"parameter": "Estimated Avg Glucose", "result": "160 mg/dL", "referenceRange": "< 117 mg/dL", "status": "High"},
        ],
        "orderedBy": "Dr. Sarah Jenkins",
        "chartData": [6.1, 6.4, 6.7, 6.9, 7.2],
      },
      {
        "patient": "James Chen",
        "avatarColor": const Color(0xFF10B981),
        "test": "TSH",
        "value": "2.1",
        "unit": "mIU/L",
        "reference": "0.4-4.0",
        "status": "Normal",
        "date": "Feb 26, 2026",
        "details": [
          {"parameter": "TSH", "result": "2.1 mIU/L", "referenceRange": "0.4 - 4.0 mIU/L", "status": "Normal"},
          {"parameter": "Free T4", "result": "1.2 ng/dL", "referenceRange": "0.8 - 1.8 ng/dL", "status": "Normal"},
          {"parameter": "Free T3", "result": "3.1 pg/mL", "referenceRange": "2.3 - 4.2 pg/mL", "status": "Normal"},
        ],
        "orderedBy": "Dr. Helen Wu",
        "chartData": [2.7, 2.5, 2.3, 2.2, 2.1],
      },
      {
        "patient": "Maria Garcia",
        "avatarColor": const Color(0xFFEC4899),
        "test": "CBC - WBC",
        "value": "11.2",
        "unit": "K/uL",
        "reference": "4.5-11.0",
        "status": "High",
        "date": "Feb 25, 2026",
        "details": [
          {"parameter": "White Blood Cells (WBC)", "result": "11.2 K/uL", "referenceRange": "4.5 - 11.0 K/uL", "status": "High"},
          {"parameter": "Red Blood Cells (RBC)", "result": "4.6 million/uL", "referenceRange": "4.3 - 5.9 million/uL", "status": "Normal"},
          {"parameter": "Hemoglobin", "result": "14.2 g/dL", "referenceRange": "13.5 - 17.5 g/dL", "status": "Normal"},
          {"parameter": "Platelets", "result": "280 x10^3/uL", "referenceRange": "150 - 450 x10^3/uL", "status": "Normal"},
        ],
        "orderedBy": "Dr. Sarah Jenkins",
        "chartData": [8.4, 9.1, 9.7, 10.4, 11.2],
      },
    ];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
            // Title Header
            Text(
              "Lab Results",
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF6B8EFF),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Review laboratory test results, trends, and critical flags.",
              style: GoogleFonts.inter(color: _kTextGray, fontSize: 13),
            ),
            const SizedBox(height: 20),

            // KPI Cards Row
            _buildKPICardsGrid(isDesktop, gap)
                .animate()
                .fadeIn(duration: 300.ms)
                .slideY(begin: 0.02, end: 0, curve: Curves.easeOutCubic),
            SizedBox(height: gap),

            // Responsive Layout Grid
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 7, child: _buildLeftPanel(gap)),
                  SizedBox(width: gap),
                  Expanded(flex: 5, child: _buildRightPanel(gap)),
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
        _buildRecentResultsCard(gap)
            .animate()
            .fadeIn(delay: 100.ms, duration: 300.ms)
            .slideY(begin: 0.02, end: 0, curve: Curves.easeOutCubic),
      ],
    );
  }

  Widget _buildRightPanel(double gap) {
    return Column(
      children: [
        _buildLabTrendsCard()
            .animate()
            .fadeIn(delay: 180.ms, duration: 300.ms)
            .slideY(begin: 0.02, end: 0, curve: Curves.easeOutCubic),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // KPI METRICS SECTION
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildKPICardsGrid(bool isDesktop, double gap) {
    final List<Widget> cards = [
      _buildKPICard(
        title: "Pending Results",
        value: "$_pendingResultsCount",
        icon: Icons.hourglass_empty_rounded,
        color: _kWarningAmber,
      ),
      _buildKPICard(
        title: "Completed Today",
        value: "$_completedTodayCount",
        icon: Icons.check_circle_outline,
        color: _kBrandGreen,
      ),
      _buildKPICard(
        title: "Abnormal Flags",
        value: "$_abnormalFlagsCount",
        icon: Icons.outlined_flag_rounded,
        color: _kDangerRed,
      ),
      _buildKPICard(
        title: "Avg Turnaround",
        value: "${_avgTurnaroundHours.toStringAsFixed(1)} hrs",
        icon: Icons.timer_outlined,
        color: _kBrandBlue,
      ),
    ];

    if (isDesktop) {
      return Row(
        children: cards
            .map((c) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: c == cards.last ? 0 : gap),
                    child: c,
                  ),
                ))
            .toList(),
      );
    } else {
      return Column(
        children: cards
            .map((c) => Padding(
                  padding: EdgeInsets.only(bottom: c == cards.last ? 0 : gap),
                  child: c,
                ))
            .toList(),
      );
    }
  }

  Widget _buildKPICard({required String title, required String value, required IconData icon, required Color color}) {
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
                color: color.withOpacity(0.08),
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
                    style: GoogleFonts.inter(color: _kTextGray, fontSize: 11.5, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // RECENT RESULTS TABLE CARD
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildRecentResultsCard(double gap) {
    // Filter logic
    final filtered = _recentResults.where((res) {
      final matchesSearch = res['patient'].toString().toLowerCase().contains(_searchQuery) ||
          res['test'].toString().toLowerCase().contains(_searchQuery);
      if (!matchesSearch) return false;

      if (_selectedStatusFilter == "All") return true;
      return res['status'].toString().toLowerCase() == _selectedStatusFilter.toLowerCase();
    }).toList();

    return AppCard(
      color: _kCardBg,
      borderRadius: AppRadius.radius12,
      border: Border.all(color: _kCardBorder),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Recent Results",
            style: GoogleFonts.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Search and Filters Bar
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 12.5),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.02),
                    hintText: 'Search patients, parameters...',
                    hintStyle: GoogleFonts.inter(color: _kTextGray.withOpacity(0.4), fontSize: 12.5),
                    prefixIcon: const Icon(Icons.search, color: _kTextGray, size: 16),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: _kTextGray, size: 16),
                            onPressed: () => _searchController.clear(),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Status Filters Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: ["All", "Critical", "High", "Borderline", "Normal"].map((filter) {
                final isSelected = _selectedStatusFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: InkWell(
                    onTap: () => setState(() => _selectedStatusFilter = filter),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? _kBrandBlue.withOpacity(0.12) : Colors.white.withOpacity(0.01),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? _kBrandBlue : Colors.white.withOpacity(0.04),
                        ),
                      ),
                      child: Text(
                        filter,
                        style: GoogleFonts.inter(
                          color: isSelected ? _kBrandBlue : _kTextGray,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 12),

          // Main Table Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.01),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Expanded(flex: 5, child: Text("PATIENT", style: GoogleFonts.inter(color: _kTextGray, fontSize: 9.5, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis, maxLines: 1)),
                Expanded(flex: 4, child: Text("TEST", style: GoogleFonts.inter(color: _kTextGray, fontSize: 9.5, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis, maxLines: 1)),
                Expanded(flex: 3, child: Text("VALUE", style: GoogleFonts.inter(color: _kTextGray, fontSize: 9.5, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis, maxLines: 1)),
                Expanded(flex: 3, child: Text("REFERENCE", style: GoogleFonts.inter(color: _kTextGray, fontSize: 9.5, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis, maxLines: 1)),
                Expanded(flex: 3, child: Text("STATUS", style: GoogleFonts.inter(color: _kTextGray, fontSize: 9.5, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis, maxLines: 1)),
                Expanded(flex: 3, child: Text("DATE", style: GoogleFonts.inter(color: _kTextGray, fontSize: 9.5, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis, maxLines: 1)),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Main Table Body
          if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text(
                  "No laboratory results match your criteria.",
                  style: GoogleFonts.inter(color: _kTextGray, fontSize: 13),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              separatorBuilder: (context, index) => const Divider(color: Colors.white12, height: 1),
              itemBuilder: (context, index) {
                final res = filtered[index];
                final int realIndex = _recentResults.indexOf(res);
                final isSelected = _selectedResultIndex == realIndex;
                final statusStr = res['status'].toString();
                final Color statusColor = _getStatusColor(statusStr);
                final initials = res['patient'].toString().split(' ').map((s) => s[0]).take(2).join();

                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedResultIndex = realIndex;
                    });
                    _showReportDetailsDialog(res);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? _kBrandBlue.withOpacity(0.08) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? _kBrandBlue.withOpacity(0.3) : Colors.transparent,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Patient
                        Expanded(
                          flex: 5,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 12,
                                backgroundColor: res['avatarColor'].withOpacity(0.12),
                                child: Text(
                                  initials,
                                  style: GoogleFonts.inter(color: res['avatarColor'], fontSize: 9, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  res['patient'],
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Test
                        Expanded(
                          flex: 4,
                          child: Text(
                            res['test'],
                            style: GoogleFonts.inter(color: Colors.white.withOpacity(0.85), fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),

                        // Value
                        Expanded(
                          flex: 3,
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: res['value'],
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const TextSpan(text: ' '),
                                TextSpan(
                                  text: res['unit'],
                                  style: GoogleFonts.inter(color: _kTextGray, fontSize: 10),
                                ),
                              ],
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),

                        // Reference
                        Expanded(
                          flex: 3,
                          child: Text(
                            res['reference'],
                            style: GoogleFonts.inter(color: _kTextGray, fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),

                        // Status
                        Expanded(
                          flex: 3,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(color: statusColor.withOpacity(0.3)),
                              ),
                              child: Text(
                                statusStr,
                                style: GoogleFonts.inter(color: statusColor, fontSize: 9, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ),
                        ),

                        // Date
                        Expanded(
                          flex: 3,
                          child: Text(
                            res['date'],
                            style: GoogleFonts.inter(color: _kTextGray, fontSize: 11.5),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                ),
              );
            },
          )
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // LAB PARAMETERS TREND CARD
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildLabTrendsCard() {
    final report = _recentResults[_selectedResultIndex];
    final List<double> historyData = List<double>.from(report['chartData']);
    final double maxVal = historyData.reduce((curr, next) => curr > next ? curr : next);
    final double minVal = historyData.reduce((curr, next) => curr < next ? curr : next);
    final double range = maxVal - minVal;
    final double buffer = range > 0 ? range * 0.15 : 1.0;

    final bool isCritical = report['status'].toString() == 'Critical';
    final Color trendColor = isCritical ? _kDangerRed : _kBrandBlue;

    return Column(
      children: [
        if (isCritical) ...[
          _buildCriticalAlertBox(report),
          const SizedBox(height: 16),
        ],
        AppCard(
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
                        "${report['test']} Trend Analysis",
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Patient: ${report['patient']}",
                        style: GoogleFonts.inter(color: _kTextGray, fontSize: 11),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: trendColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: trendColor.withOpacity(0.2)),
                    ),
                    child: Text(
                      "Latest: ${report['value']} ${report['unit']}",
                      style: GoogleFonts.inter(color: trendColor, fontSize: 10.5, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Trend Chart
              SizedBox(
                height: 160,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0, left: 4.0),
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: Colors.white.withOpacity(0.04),
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 22,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              const dates = ["Oct", "Nov", "Dec", "Jan", "Feb"];
                              final int idx = value.toInt();
                              if (idx >= 0 && idx < dates.length) {
                                return SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  child: Text(dates[idx], style: GoogleFonts.inter(color: _kTextGray, fontSize: 9)),
                                );
                              }
                              return const SizedBox();
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 34,
                            getTitlesWidget: (value, meta) {
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                child: Text(
                                  value.toStringAsFixed(1),
                                  style: GoogleFonts.inter(color: _kTextGray, fontSize: 9),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      minX: 0,
                      maxX: 4,
                      minY: minVal - buffer,
                      maxY: maxVal + buffer,
                      lineBarsData: [
                        LineChartBarData(
                          spots: historyData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                          isCurved: true,
                          color: trendColor,
                          barWidth: 2.8,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                              radius: 4,
                              color: trendColor,
                              strokeWidth: 1.5,
                              strokeColor: _kCardBg,
                            ),
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            color: trendColor.withOpacity(0.04),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  "Lab readings timeline snapshot (Oct 2025 - Feb 2026)",
                  style: GoogleFonts.inter(color: _kTextGray, fontSize: 9.5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCriticalAlertBox(Map<String, dynamic> report) {
    return Container(
      decoration: BoxDecoration(
        color: _kDangerRed.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kDangerRed.withOpacity(0.25)),
      ),
      padding: const EdgeInsets.all(16),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: _kDangerRed,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: _kDangerRed, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        "CRITICAL ALARM FLAG",
                        style: GoogleFonts.inter(color: _kDangerRed, fontSize: 10.5, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Patient ${report['patient']} registered a Potassium level of ${report['value']} mEq/L (Critical High). Immediate callback is recommended to prevent severe arrhythmia events.",
                    style: GoogleFonts.inter(color: const Color(0xFF450A0A), fontSize: 12, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      AppButton(
                        label: "Acknowledge Flag",
                        height: 30,
                        onPressed: () {
                          setState(() {
                            report['status'] = "Normal"; // Acknowledge changes status
                            _abnormalFlagsCount--;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: _kCardBg,
                              content: Text("Critical flag acknowledged.", style: GoogleFonts.inter(color: Colors.white)),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: _kCardBg,
                              content: Text("Physician callback log dispatched.", style: GoogleFonts.inter(color: Colors.white)),
                            ),
                          );
                        },
                        child: Text("Emergency Callback", style: GoogleFonts.inter(color: _kDangerRed, fontSize: 11.5, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // DETAILED CLINICAL REPORT DRILL-DOWN MODAL
  // ───────────────────────────────────────────────────────────────────────────
  void _showReportDetailsDialog(Map<String, dynamic> res) {
    showDialog(
      context: context,
      builder: (context) {
        final List<Map<String, dynamic>> details = List<Map<String, dynamic>>.from(res['details']);
        final statusStr = res['status'].toString();
        final Color statusColor = _getStatusColor(statusStr);

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      res['patient'],
                      style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.5),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Attending: ${res['orderedBy']} • ${res['date']}",
                      style: GoogleFonts.inter(color: _kTextGray, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Text(
                  statusStr,
                  style: GoogleFonts.inter(color: statusColor, fontSize: 9.5, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 460,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LABORATORY DIAGNOSTIC RESULTS',
                    style: GoogleFonts.inter(color: const Color(0xFF6B8EFF), fontSize: 9.5, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Colors.white12, height: 1),
                  const SizedBox(height: 8),

                  // Header Row
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Row(
                      children: [
                        Expanded(flex: 3, child: Text("PARAMETER", style: GoogleFonts.inter(color: _kTextGray, fontSize: 9, fontWeight: FontWeight.bold))),
                        Expanded(flex: 2, child: Text("RESULT", style: GoogleFonts.inter(color: _kTextGray, fontSize: 9, fontWeight: FontWeight.bold))),
                        Expanded(flex: 2, child: Text("REFERENCE", style: GoogleFonts.inter(color: _kTextGray, fontSize: 9, fontWeight: FontWeight.bold))),
                        Expanded(flex: 2, child: Text("STATUS", style: GoogleFonts.inter(color: _kTextGray, fontSize: 9, fontWeight: FontWeight.bold))),
                      ],
                    ),
                  ),
                  const Divider(color: Colors.white12, height: 1),

                  // Report Items
                  ...details.map((item) {
                    final itemStatusColor = _getStatusColor(item['status'].toString());
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              item['parameter'],
                              style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              item['result'],
                              style: GoogleFonts.inter(
                                color: Colors.white.withOpacity(0.95),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              item['referenceRange'],
                              style: GoogleFonts.inter(color: _kTextGray, fontSize: 11.5),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Container(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: itemStatusColor.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: itemStatusColor.withOpacity(0.2)),
                                ),
                                child: Text(
                                  item['status'].toString(),
                                  style: GoogleFonts.inter(color: itemStatusColor, fontSize: 8.5, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                  const Divider(color: Colors.white12, height: 1),
                  const SizedBox(height: 14),

                  // Diagnostic Notes Summary
                  Text(
                    'CLINICAL ADVISORY NOTES',
                    style: GoogleFonts.inter(color: const Color(0xFF6B8EFF), fontSize: 9.5, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    statusStr == "Critical"
                        ? "Potassium level is critically elevated. A callback was dispatched. Monitor closely for signs of severe hyperkalemia."
                        : statusStr == "High"
                            ? "Parameter is elevated above standard reference ranges. Lifestyle revisions or medical follow-up recommended."
                            : "All laboratory parameters are registered within the clinical standard references. Routine checkups recommended.",
                    style: GoogleFonts.inter(color: Colors.white.withOpacity(0.7), fontSize: 11.5, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: _kCardBg,
                    content: Text("PDF report downloaded successfully.", style: GoogleFonts.inter(color: Colors.white)),
                  ),
                );
              },
              child: Text("Download PDF", style: GoogleFonts.inter(color: _kBrandBlue)),
            ),
            AppButton(
              label: "Close",
              height: 36,
              variant: AppButtonVariant.secondary,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // STATE COLOR HELPERS
  // ───────────────────────────────────────────────────────────────────────────
  Color _getStatusColor(String status) {
    switch (status.trim().toLowerCase()) {
      case 'critical':
        return _kDangerRed;
      case 'high':
        return _kWarningAmber;
      case 'borderline':
        return _kBorderlinePurple;
      case 'normal':
        return _kBrandGreen;
      default:
        return _kTextGray;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HOVER CONTAINER FOR SAAS EFFECT
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
        transform: _isHovered ? (Matrix4.identity()..translate(0, -4, 0)) : Matrix4.identity(),
        decoration: BoxDecoration(
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: _kBrandBlue.withOpacity(0.12),
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
