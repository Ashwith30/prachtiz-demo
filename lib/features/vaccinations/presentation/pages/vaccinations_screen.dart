import "package:prachtiz_flutter/core/theme/app_colors.dart";
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
const Color _kWarningAmber = Color(0xFFF59E0B); // Alert color
const Color _kBorderlinePurple = Color(0xFF8B5CF6); // Borderline status color

class VaccinationsScreen extends StatefulWidget {
  const VaccinationsScreen({super.key});

  @override
  State<VaccinationsScreen> createState() => _VaccinationsScreenState();
}

class _VaccinationsScreenState extends State<VaccinationsScreen> {
  // KPI Metrics counts
  int _totalAdministered = 3;
  int _upcomingSchedules = 2;
  String _lastAdministeredDate = "2026-02-15";
  double _complianceRate = 85.0;

  // Search and Filtering state
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _selectedCategoryFilter = "All";

  // Data lists
  late List<Map<String, dynamic>> _administeredDoses;
  late List<Map<String, dynamic>> _upcomingSchedulesList;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });

    _administeredDoses = [
      {
        "patient": "Robert Kim",
        "avatarColor": const Color(0xFF3B82F6),
        "vaccine": "COVID-19 mRNA (Pfizer)",
        "batch": "PZ-8201",
        "date": "2026-02-15",
        "administrator": "Nurse Emily Parker",
        "site": "Left Deltoid",
        "category": "Routine",
        "doseSequence": "1st Booster",
        "nextDue": "Feb 2027",
      },
      {
        "patient": "David Thompson",
        "avatarColor": const Color(0xFFEF4444),
        "vaccine": "Influenza Quadrivalent",
        "batch": "FL-9932",
        "date": "2025-11-10",
        "administrator": "Nurse Emily Parker",
        "site": "Right Deltoid",
        "category": "Seasonal",
        "doseSequence": "Annual Dose",
        "nextDue": "Oct 2026",
      },
      {
        "patient": "Patricia Moore",
        "avatarColor": const Color(0xFF8B5CF6),
        "vaccine": "Tdap (Tetanus, Diphtheria, Pertussis)",
        "batch": "TD-0481",
        "date": "2022-04-18",
        "administrator": "Dr. Sarah Jenkins",
        "site": "Left Deltoid",
        "category": "Mandatory",
        "doseSequence": "Dose 1 of 1",
        "nextDue": "Apr 2032 (10-Yr Booster)",
      },
    ];

    _upcomingSchedulesList = [
      {
        "patient": "Sarah Johnson",
        "avatarColor": const Color(0xFFF59E0B),
        "vaccine": "Pneumococcal Conjugate (PCV13)",
        "dueText": "Due: July 2026 (Age 65+)",
        "category": "Routine",
        "color": _kWarningAmber,
      },
      {
        "patient": "James Chen",
        "avatarColor": const Color(0xFF10B981),
        "vaccine": "Shingles (Shingrix) Dose 1",
        "dueText": "Due: October 2026 (Age 50+)",
        "category": "Routine",
        "color": _kBrandBlue,
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
            // Title Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Immunization & Vaccination Records",
                        style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF6B8EFF),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Register and track patient vaccine administrations and schedules.",
                        style: GoogleFonts.inter(color: _kTextGray, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                AppButton(
                  label: "Record Dose",
                  icon: const Icon(Icons.add, size: 16),
                  height: 38,
                  onPressed: () => _showRecordDoseDialog(),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // KPI Metrics Cards Row
            _buildKPICardsGrid(isDesktop, gap)
                .animate()
                .fadeIn(duration: 300.ms)
                .slideY(begin: 0.02, end: 0, curve: Curves.easeOutCubic),
            SizedBox(height: gap),

            // Responsive Split Grid
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
        _buildHistoryTableCard()
            .animate()
            .fadeIn(delay: 100.ms, duration: 300.ms)
            .slideY(begin: 0.02, end: 0, curve: Curves.easeOutCubic),
      ],
    );
  }

  Widget _buildRightPanel(double gap) {
    return Column(
      children: [
        _buildUpcomingSchedulesCard()
            .animate()
            .fadeIn(delay: 180.ms, duration: 300.ms)
            .slideY(begin: 0.02, end: 0, curve: Curves.easeOutCubic),
        SizedBox(height: gap),
        _buildComplianceGaugeCard()
            .animate()
            .fadeIn(delay: 240.ms, duration: 300.ms)
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
        title: "Total Administered",
        value: "$_totalAdministered Doses",
        icon: Icons.vaccines_outlined,
        color: _kBrandBlue,
      ),
      _buildKPICard(
        title: "Upcoming Schedules",
        value: "$_upcomingSchedules Due",
        icon: Icons.calendar_today_outlined,
        color: _kWarningAmber,
      ),
      _buildKPICard(
        title: "Last Administered",
        value: _lastAdministeredDate,
        icon: Icons.check_circle_outline,
        color: _kBrandGreen,
      ),
      _buildKPICard(
        title: "Compliance Status",
        value: "${_complianceRate.toStringAsFixed(0)}% - High",
        icon: Icons.shield_outlined,
        color: _kBorderlinePurple,
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
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
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
  // IMMUNIZATION HISTORY TABLE CARD
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildHistoryTableCard() {
    final filtered = _administeredDoses.where((vac) {
      final matchesSearch = vac['patient'].toString().toLowerCase().contains(_searchQuery) ||
          vac['vaccine'].toString().toLowerCase().contains(_searchQuery);
      if (!matchesSearch) return false;

      if (_selectedCategoryFilter == "All") return true;
      return vac['category'].toString().toLowerCase() == _selectedCategoryFilter.toLowerCase();
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
            "Administered Vaccine Doses",
            style: GoogleFonts.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Search input
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 12.5),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.02),
                    hintText: 'Search patients, vaccines...',
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

          // Category Chips Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: ["All", "Routine", "Mandatory", "Seasonal", "Travel"].map((filter) {
                final isSelected = _selectedCategoryFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: InkWell(
                    onTap: () => setState(() => _selectedCategoryFilter = filter),
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

          // Custom Flex Table Headers
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.01),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Expanded(flex: 5, child: Text("PATIENT", style: GoogleFonts.inter(color: _kTextGray, fontSize: 9.5, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis, maxLines: 1)),
                Expanded(flex: 4, child: Text("VACCINE", style: GoogleFonts.inter(color: _kTextGray, fontSize: 9.5, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis, maxLines: 1)),
                Expanded(flex: 3, child: Text("DATE", style: GoogleFonts.inter(color: _kTextGray, fontSize: 9.5, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis, maxLines: 1)),
                Expanded(flex: 3, child: Text("BATCH", style: GoogleFonts.inter(color: _kTextGray, fontSize: 9.5, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis, maxLines: 1)),
                Expanded(flex: 3, child: Text("ADMINISTRATOR", style: GoogleFonts.inter(color: _kTextGray, fontSize: 9.5, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis, maxLines: 1)),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Custom Flex Table Body
          if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text(
                  "No immunization records match your criteria.",
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
                final vac = filtered[index];
                final initials = vac['patient'].toString().split(' ').map((s) => s[0]).take(2).join();
                final categoryStr = vac['category'].toString();
                final Color categoryColor = _getCategoryColor(categoryStr);

                return InkWell(
                  onTap: () => _showCertificateDialog(vac),
                  borderRadius: BorderRadius.circular(8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        // Patient Name & Avatar
                        Expanded(
                          flex: 5,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 12,
                                backgroundColor: vac['avatarColor'].withOpacity(0.12),
                                child: Text(
                                  initials,
                                  style: GoogleFonts.inter(color: vac['avatarColor'], fontSize: 9, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      vac['patient'],
                                      style: GoogleFonts.inter(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                    const SizedBox(height: 2),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                      decoration: BoxDecoration(
                                        color: categoryColor.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(3),
                                        border: Border.all(color: categoryColor.withOpacity(0.2)),
                                      ),
                                      child: Text(
                                        categoryStr,
                                        style: GoogleFonts.inter(color: categoryColor, fontSize: 7.5, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Vaccine Name
                        Expanded(
                          flex: 4,
                          child: Text(
                            vac['vaccine'],
                            style: GoogleFonts.inter(color: Colors.white.withOpacity(0.85), fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),

                        // Date Administered
                        Expanded(
                          flex: 3,
                          child: Text(
                            vac['date'],
                            style: GoogleFonts.inter(color: _kTextGray, fontSize: 11.5),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),

                        // Batch Number
                        Expanded(
                          flex: 3,
                          child: Text(
                            vac['batch'],
                            style: GoogleFonts.robotoMono(color: _kTextGray, fontSize: 11.5),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),

                        // Administrator
                        Expanded(
                          flex: 3,
                          child: Text(
                            vac['administrator'],
                            style: GoogleFonts.inter(color: Colors.white.withOpacity(0.75), fontSize: 11.5),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
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

  // ───────────────────────────────────────────────────────────────────────────
  // UPCOMING SCHEDULES PANEL
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildUpcomingSchedulesCard() {
    return AppCard(
      color: _kCardBg,
      borderRadius: AppRadius.radius12,
      border: Border.all(color: _kCardBorder),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Upcoming Due Dates (Schedules)",
            style: GoogleFonts.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          if (_upcomingSchedulesList.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  "All schedules are up to date.",
                  style: GoogleFonts.inter(color: _kTextGray, fontSize: 12.5),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _upcomingSchedulesList.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final schedule = _upcomingSchedulesList[index];
                final initials = schedule['patient'].toString().split(' ').map((s) => s[0]).take(2).join();
                final Color themeColor = schedule['color'];

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.01),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withOpacity(0.04)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: schedule['avatarColor'].withOpacity(0.12),
                            child: Text(
                              initials,
                              style: GoogleFonts.inter(color: schedule['avatarColor'], fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  schedule['patient'],
                                  style: GoogleFonts.inter(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  schedule['dueText'],
                                  style: GoogleFonts.inter(color: themeColor, fontSize: 10, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: themeColor.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: themeColor.withOpacity(0.25)),
                            ),
                            child: Text(
                              "SCHEDULED",
                              style: GoogleFonts.inter(color: themeColor, fontSize: 8, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        schedule['vaccine'],
                        style: GoogleFonts.inter(color: Colors.white.withOpacity(0.9), fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              label: "Administer Now",
                              height: 30,
                              onPressed: () => _administerDoseFromSchedule(schedule),
                            ),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: _kCardBg,
                                  content: Text("Dose rescheduled. Notification sent to ${schedule['patient']}.", style: GoogleFonts.inter(color: Colors.white)),
                                ),
                              );
                            },
                            child: Text(
                              "Reschedule",
                              style: GoogleFonts.inter(color: _kTextGray, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
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

  // ───────────────────────────────────────────────────────────────────────────
  // IMMUNIZATION COMPLIANCE CARD
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildComplianceGaugeCard() {
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
              Text(
                "Compliance Progress",
                style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: _kBorderlinePurple.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _kBorderlinePurple.withOpacity(0.2)),
                ),
                child: Text(
                  "Goal: > 90%",
                  style: GoogleFonts.inter(color: _kBorderlinePurple, fontSize: 9.5, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Immunization coverage rate", style: GoogleFonts.inter(color: _kTextGray, fontSize: 11.5)),
                        Text("${_complianceRate.toStringAsFixed(0)}%", style: GoogleFonts.inter(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _complianceRate / 100.0,
                        minHeight: 8,
                        backgroundColor: Colors.white.withOpacity(0.04),
                        valueColor: const AlwaysStoppedAnimation<Color>(_kBorderlinePurple),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.01),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: _kTextGray, size: 14),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "3 of 5 scheduled routinely due vaccine doses have been successfully administered and verified by clinic staff.",
                    style: GoogleFonts.inter(color: _kTextGray, fontSize: 10, height: 1.3),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // CDC-STYLE DIGITAL CERTIFICATE DRILL-DOWN MODAL
  // ───────────────────────────────────────────────────────────────────────────
  void _showCertificateDialog(Map<String, dynamic> vac) {
    showDialog(
      context: context,
      builder: (context) {
        final initials = vac['patient'].toString().split(' ').map((s) => s[0]).take(2).join();

        return AlertDialog(
          backgroundColor: const Color(0xFFFCFBF7), // Warm CDC Paper White background
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFE5DECF), width: 1.5),
          ),
          titlePadding: EdgeInsets.zero,
          title: Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF1E3A8A), // Deep CDC Navy Blue
              borderRadius: BorderRadius.only(topLeft: Radius.circular(14), topRight: Radius.circular(14)),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_user, color: Colors.white, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "IMMUNIZATION RECORD CARD",
                        style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.1),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "CDC Guidelines compliant record • Clinic Certified",
                        style: GoogleFonts.inter(color: Colors.white.withOpacity(0.8), fontSize: 9.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          content: SizedBox(
            width: 440,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Patient Summary Section
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: vac['avatarColor'].withOpacity(0.12),
                      child: Text(
                        initials,
                        style: GoogleFonts.inter(color: vac['avatarColor'], fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vac['patient'].toString().toUpperCase(),
                            style: GoogleFonts.inter(color: const Color(0xFF1E293B), fontWeight: FontWeight.w800, fontSize: 15),
                          ),
                          Text(
                            "Patient Record Verified • Sequenced Record",
                            style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: Color(0xFFE2E8F0), height: 1),
                const SizedBox(height: 16),

                // CDC Style Dose Table
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      _buildCertificateRow("Vaccine Type", vac['vaccine'], isHeader: true),
                      _buildCertificateRow("Sequence", vac['doseSequence']),
                      _buildCertificateRow("Date Administered", vac['date']),
                      _buildCertificateRow("Lot / Batch #", vac['batch']),
                      _buildCertificateRow("Injection Site", vac['site']),
                      _buildCertificateRow("Clinical Staff", vac['administrator']),
                      _buildCertificateRow("Next Recommended", vac['nextDue'], highlight: true),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Advisory Stamp
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.shield_outlined, color: Color(0xFFD97706), size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "OFFICIAL CLINICAL RECORD",
                              style: GoogleFonts.inter(color: const Color(0xFF92400E), fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "This record represents a verified dose administration log. Certified under local clinical surveillance protocols.",
                              style: GoogleFonts.inter(color: const Color(0xFFB45309), fontSize: 9.5, height: 1.3),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: _kCardBg,
                    content: Text("CDC Immunization Certificate PDF downloaded.", style: GoogleFonts.inter(color: Colors.white)),
                  ),
                );
              },
              child: Text("Download PDF", style: GoogleFonts.inter(color: const Color(0xFF1E3A8A), fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Close", style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCertificateRow(String label, String value, {bool isHeader = false, bool highlight = false}) {
    final bgColor = isHeader ? const Color(0xFFEDF2F7) : Colors.transparent;
    final textColor = highlight ? const Color(0xFF1E3A8A) : const Color(0xFF1E293B);
    final textWeight = (isHeader || highlight) ? FontWeight.bold : FontWeight.normal;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        border: const Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.inter(color: textColor, fontSize: 11.5, fontWeight: textWeight),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // THEMED DOSE RECORDING FORM DIALOG
  // ───────────────────────────────────────────────────────────────────────────
  void _showRecordDoseDialog({String? preFilledPatient, String? preFilledVaccine}) {
    final formKey = GlobalKey<FormState>();
    final patientCtrl = TextEditingController(text: preFilledPatient);
    final vaccineCtrl = TextEditingController(text: preFilledVaccine);
    final batchCtrl = TextEditingController();
    final adminCtrl = TextEditingController(text: "Nurse Emily Parker");
    String selectedSite = "Left Deltoid";
    String selectedCategory = "Routine";

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
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Record Vaccine Dose",
                    style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Log certified immunization details into patient EMR database",
                    style: GoogleFonts.inter(color: _kTextGray, fontSize: 10.5),
                  ),
                ],
              ),
              content: SizedBox(
                width: 440,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildDialogTextField("Patient Name", patientCtrl, hint: "e.g. Adrian Marshall", requiredField: true),
                        _buildDialogTextField("Vaccine Type / Brand", vaccineCtrl, hint: "e.g. Hepatitis B (Engerix-B)", requiredField: true),
                        _buildDialogTextField("Batch / Lot #", batchCtrl, hint: "e.g. HB-7719", requiredField: true),
                        _buildDialogTextField("Administrator", adminCtrl, hint: "e.g. Nurse Emily Parker", requiredField: true),
                        
                        // Site selection
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Injection Site",
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
                                    value: selectedSite,
                                    isExpanded: true,
                                    style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                                    items: ["Left Deltoid", "Right Deltoid", "Left Anterolateral Thigh", "Right Anterolateral Thigh"]
                                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                                        .toList(),
                                    onChanged: (val) {
                                      if (val != null) {
                                        setDialogState(() {
                                          selectedSite = val;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Category selection
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Category",
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
                                    value: selectedCategory,
                                    isExpanded: true,
                                    style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                                    items: ["Routine", "Mandatory", "Seasonal", "Travel"]
                                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                                        .toList(),
                                    onChanged: (val) {
                                      if (val != null) {
                                        setDialogState(() {
                                          selectedCategory = val;
                                        });
                                      }
                                    },
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
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("Cancel", style: GoogleFonts.inter(color: _kTextGray)),
                ),
                AppButton(
                  label: "Record Dose",
                  height: 38,
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final pName = patientCtrl.text.trim();
                      final vName = vaccineCtrl.text.trim();
                      final bNo = batchCtrl.text.trim();
                      final adm = adminCtrl.text.trim();

                      setState(() {
                        _administeredDoses.add({
                          "patient": pName,
                          "avatarColor": _getAvatarColorForName(pName),
                          "vaccine": vName,
                          "batch": bNo,
                          "date": "2026-06-20",
                          "administrator": adm,
                          "site": selectedSite,
                          "category": selectedCategory,
                          "doseSequence": "1st Dose",
                          "nextDue": "TBD",
                        });

                        _totalAdministered++;
                        _lastAdministeredDate = "2026-06-20";

                        // Remove from upcoming list if matched
                        _upcomingSchedulesList.removeWhere((item) =>
                            item['patient'].toString().toLowerCase() == pName.toLowerCase() &&
                            item['vaccine'].toString().toLowerCase() == vName.toLowerCase());
                        _upcomingSchedules = _upcomingSchedulesList.length;

                        // Increment compliance rate slightly if not 100%
                        if (_complianceRate < 95.0) {
                          _complianceRate += 5.0;
                        }
                      });

                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: _kCardBg,
                          content: Text("Dose recorded successfully.", style: GoogleFonts.inter(color: Colors.white)),
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

  Widget _buildDialogTextField(String label, TextEditingController ctrl, {String? hint, bool requiredField = false}) {
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

  // Helper helpers
  Color _getCategoryColor(String cat) {
    switch (cat.trim().toLowerCase()) {
      case 'routine':
        return _kBrandBlue;
      case 'mandatory':
        return _kBorderlinePurple;
      case 'seasonal':
        return _kBrandGreen;
      case 'travel':
        return _kWarningAmber;
      default:
        return _kTextGray;
    }
  }

  Color _getAvatarColorForName(String name) {
    final colors = [
      const Color(0xFF3B82F6),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFFEF4444),
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
    ];
    return colors[name.hashCode % colors.length];
  }

  void _administerDoseFromSchedule(Map<String, dynamic> schedule) {
    _showRecordDoseDialog(
      preFilledPatient: schedule['patient'],
      preFilledVaccine: schedule['vaccine'],
    );
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
