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
const Color _kDangerRed = Color(0xFFEF4444); // Warning badge color
const Color _kWarningAmber = Color(0xFFF59E0B); // Alert color

class PrescriptionItem {
  final String drugName;
  final String dosage;
  final String frequency;
  final int durationDays;
  String status;

  PrescriptionItem({
    required this.drugName,
    required this.dosage,
    required this.frequency,
    required this.durationDays,
    required this.status,
  });
}

class PrescriptionsScreen extends StatefulWidget {
  const PrescriptionsScreen({super.key});

  @override
  State<PrescriptionsScreen> createState() => _PrescriptionsScreenState();
}

class _PrescriptionsScreenState extends State<PrescriptionsScreen> {
  // KPI Metrics Counts
  int _activePrescriptionsCount = 342;
  int _refillsCount = 18;
  final int _expiringCount = 7;

  // State Lists
  late List<PrescriptionItem> _prescriptions;
  late List<Map<String, dynamic>> _interactionAlerts;
  late List<Map<String, dynamic>> _refillRequests;

  // Form Controllers
  final _drugController = TextEditingController();
  final _dosageController = TextEditingController();
  String _selectedFrequency = "Once daily (Morning)";
  int _selectedDuration = 30;

  @override
  void initState() {
    super.initState();
    _prescriptions = [
      PrescriptionItem(drugName: "Amlodipine Besylate", dosage: "5mg", frequency: "Once daily (Morning)", durationDays: 30, status: "Active"),
      PrescriptionItem(drugName: "Atorvastatin Calcium", dosage: "20mg", frequency: "Once daily (Bedtime)", durationDays: 90, status: "Active"),
      PrescriptionItem(drugName: "Metformin Hydrochloride", dosage: "500mg", frequency: "Twice daily (With meals)", durationDays: 60, status: "Active"),
    ];

    _interactionAlerts = [
      {
        "patient": "Sarah Johnson",
        "severity": "High",
        "description": "Concurrent use may increase the risk of hyperkalemia. Monitor serum potassium levels closely, especially during initiation or dosage changes.",
        "details": "Interaction detected between Lisinopril (ACE Inhibitor) and Potassium Supplements. Concurrent administration can lead to severe hyperkalemia, potentially causing cardiac arrhythmias. Recommendation: Discontinue potassium supplements or reduce dosage; perform weekly Serum Potassium monitoring."
      },
      {
        "patient": "Emily Davis",
        "severity": "Moderate",
        "description": "Combined use increases the risk of serotonin syndrome. Signs include agitation, confusion, tachycardia, and hyperthermia. Consider alternative pain management.",
        "details": "Interaction detected between Fluoxetine (SSRI) and Tramadol (Opioid Analgesic). TRAMADOL enhances serotonin release and inhibits reuptake, which when combined with SSRIs increases the risk of serotonin toxicity. Recommendation: Use non-serotonergic analgesics (e.g., Acetaminophen) or monitor for symptoms of serotonin syndrome (clonus, hyperreflexia, tremor)."
      }
    ];

    _refillRequests = [
      {"name": "Robert Kim", "drug": "Atorvastatin 40mg", "requested": "Feb 24, 2026", "lastFilled": "Dec 8, 2025", "status": "Pending"},
      {"name": "Lisa Patel", "drug": "Amlodipine 5mg", "requested": "Feb 25, 2026", "lastFilled": "Feb 10, 2026", "status": "Pending"},
      {"name": "Thomas Wright", "drug": "Metoprolol 50mg", "requested": "Feb 23, 2026", "lastFilled": "Jan 20, 2026", "status": "Urgent"},
      {"name": "Anna Nguyen", "drug": "Fluoxetine 20mg", "requested": "Feb 26, 2026", "lastFilled": "Jan 28, 2026", "status": "Pending"}
    ];
  }

  @override
  void dispose() {
    _drugController.dispose();
    _dosageController.dispose();
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
            // Header Title Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Prescriptions",
                        style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF6B8EFF),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Manage medications, refills, and drug interactions.",
                        style: GoogleFonts.inter(color: _kTextGray, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                AppButton(
                  label: "Create Rx",
                  icon: const Icon(Icons.add, color: Colors.white, size: 16),
                  onPressed: () => _showAddPrescriptionDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // KPI Cards Section
            _buildKPICardsGrid(isDesktop, gap)
                .animate()
                .fadeIn(duration: 300.ms)
                .slideY(begin: 0.02, end: 0, curve: Curves.easeOutCubic),
            SizedBox(height: gap),

            // Split Layout Panel
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
        _buildInteractionAlertsCard()
            .animate()
            .fadeIn(delay: 100.ms, duration: 300.ms)
            .slideY(begin: 0.02, end: 0, curve: Curves.easeOutCubic),
        SizedBox(height: gap),
        _buildActiveMedicationsCard()
            .animate()
            .fadeIn(delay: 200.ms, duration: 300.ms)
            .slideY(begin: 0.02, end: 0, curve: Curves.easeOutCubic),
      ],
    );
  }

  Widget _buildRightPanel(double gap) {
    return Column(
      children: [
        _buildRefillRequestsCard()
            .animate()
            .fadeIn(delay: 150.ms, duration: 300.ms)
            .slideY(begin: 0.02, end: 0, curve: Curves.easeOutCubic),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // KPI CARD SUB-WIDGETS
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildKPICardsGrid(bool isDesktop, double gap) {
    final List<Widget> cards = [
      _buildKPICard(
        title: "Active Prescriptions",
        value: "$_activePrescriptionsCount",
        icon: Icons.assignment_outlined,
        color: _kBrandBlue,
      ),
      _buildKPICard(
        title: "Refill Requests",
        value: "$_refillsCount",
        icon: Icons.autorenew_outlined,
        color: _kWarningAmber,
      ),
      _buildKPICard(
        title: "Expiring Soon",
        value: "$_expiringCount",
        icon: Icons.access_time,
        color: _kDangerRed,
      ),
    ];

    if (isDesktop) {
      return Row(
        children: cards.map((c) => Expanded(child: Padding(padding: EdgeInsets.only(right: c == cards.last ? 0 : gap), child: c))).toList(),
      );
    } else {
      return Column(
        children: cards.map((c) => Padding(padding: EdgeInsets.only(bottom: c == cards.last ? 0 : gap), child: c)).toList(),
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
  // DRUG INTERACTION ALERTS WIDGET
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildInteractionAlertsCard() {
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
              const Icon(Icons.warning_amber_rounded, color: _kWarningAmber, size: 18),
              const SizedBox(width: 8),
              Text(
                'Drug Interaction Alerts',
                style: GoogleFonts.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 12),
          if (_interactionAlerts.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'No drug-drug interaction warnings on file.',
                  style: GoogleFonts.inter(color: _kTextGray, fontSize: 12.5),
                ),
              ),
            )
          else
            Column(
              children: _interactionAlerts.asMap().entries.map((entry) {
                final idx = entry.key;
                final alert = entry.value;
                final bool isHigh = alert['severity'].toString().toLowerCase() == 'high';
                final Color accentColor = isHigh ? _kDangerRed : _kWarningAmber;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: InkWell(
                    onTap: () => _showInteractionDetailsDialog(idx),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.01),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white.withOpacity(0.03)),
                      ),
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Left Accent Indicator Bar
                            Container(
                              width: 4,
                              decoration: BoxDecoration(
                                color: accentColor,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  bottomLeft: Radius.circular(8),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Patient: ${alert['patient']}',
                                          style: GoogleFonts.inter(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: accentColor.withOpacity(0.12),
                                            borderRadius: BorderRadius.circular(5),
                                            border: Border.all(color: accentColor.withOpacity(0.3)),
                                          ),
                                          child: Text(
                                            alert['severity'],
                                            style: GoogleFonts.inter(
                                              color: accentColor,
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      alert['description'],
                                      style: GoogleFonts.inter(
                                        color: Colors.white.withOpacity(0.75),
                                        fontSize: 11.5,
                                        height: 1.35,
                                      ),
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
              }).toList(),
            ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // ACTIVE SCRIPTS DATA TABLE WIDGET
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildActiveMedicationsCard() {
    return AppCard(
      color: _kCardBg,
      borderRadius: AppRadius.radius12,
      border: Border.all(color: _kCardBorder),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Active Medication Scripts",
            style: GoogleFonts.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          if (_prescriptions.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No active medication scripts issued.',
                  style: GoogleFonts.inter(color: _kTextGray, fontSize: 12.5),
                ),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: DataTable(
                columnSpacing: 24,
                horizontalMargin: 8,
                headingRowColor: MaterialStateProperty.all(Colors.white.withOpacity(0.02)),
                columns: [
                  DataColumn(label: Text("DRUG NAME", style: GoogleFonts.inter(color: _kTextGray, fontSize: 9.5, fontWeight: FontWeight.bold))),
                  DataColumn(label: Text("DOSAGE", style: GoogleFonts.inter(color: _kTextGray, fontSize: 9.5, fontWeight: FontWeight.bold))),
                  DataColumn(label: Text("FREQUENCY", style: GoogleFonts.inter(color: _kTextGray, fontSize: 9.5, fontWeight: FontWeight.bold))),
                  DataColumn(label: Text("DURATION", style: GoogleFonts.inter(color: _kTextGray, fontSize: 9.5, fontWeight: FontWeight.bold))),
                  DataColumn(label: Text("STATUS", style: GoogleFonts.inter(color: _kTextGray, fontSize: 9.5, fontWeight: FontWeight.bold))),
                  DataColumn(label: Text("ACTIONS", style: GoogleFonts.inter(color: _kTextGray, fontSize: 9.5, fontWeight: FontWeight.bold))),
                ],
                rows: _prescriptions.asMap().entries.map((entry) {
                  final int index = entry.key;
                  final rx = entry.value;

                  return DataRow(
                    cells: [
                      DataCell(Text(rx.drugName, style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
                      DataCell(Text(rx.dosage, style: GoogleFonts.inter(color: Colors.white.withOpacity(0.85), fontSize: 11.5))),
                      DataCell(Text(rx.frequency, style: GoogleFonts.inter(color: _kTextGray, fontSize: 11.5))),
                      DataCell(Text("${rx.durationDays} Days", style: GoogleFonts.inter(color: _kTextGray, fontSize: 11.5))),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                          decoration: BoxDecoration(
                            color: _kBrandGreen.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: _kBrandGreen.withOpacity(0.3)),
                          ),
                          child: Text(
                            rx.status,
                            style: GoogleFonts.inter(color: _kBrandGreen, fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      DataCell(
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: _kDangerRed, size: 16),
                          onPressed: () => _confirmCancelScript(index),
                          tooltip: 'Cancel Prescription',
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // REFILL REQUESTS LIST CARD
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildRefillRequestsCard() {
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
              Icon(Icons.cached, color: _kBrandBlue, size: 18),
              const SizedBox(width: 8),
              Text(
                'Refill Requests',
                style: GoogleFonts.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 12),
          if (_refillRequests.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No pending refills.',
                  style: GoogleFonts.inter(color: _kTextGray, fontSize: 12.5),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _refillRequests.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final req = _refillRequests[index];
                final bool isUrgent = req['status'].toString().toLowerCase() == 'urgent';
                final Color badgeColor = isUrgent ? _kDangerRed : _kWarningAmber;
                final initials = req['name'].toString().split(' ').map((s) => s[0]).take(2).join();

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.01),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withOpacity(0.03)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: _kBrandBlue.withOpacity(0.12),
                        child: Text(
                          initials,
                          style: GoogleFonts.inter(color: _kBrandBlue, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              req['name'],
                              style: GoogleFonts.inter(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              req['drug'],
                              style: GoogleFonts.inter(color: Colors.white.withOpacity(0.85), fontSize: 11.5, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Req: ${req['requested']} • Filled: ${req['lastFilled']}',
                              style: GoogleFonts.inter(color: _kTextGray, fontSize: 9.5),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: badgeColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: badgeColor.withOpacity(0.3)),
                            ),
                            child: Text(
                              req['status'],
                              style: GoogleFonts.inter(color: badgeColor, fontSize: 8.5, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.check_circle_outline, color: _kBrandGreen, size: 18),
                                onPressed: () => _approveRefill(index),
                                tooltip: 'Approve Refill',
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.cancel_outlined, color: _kDangerRed, size: 18),
                                onPressed: () => _denyRefill(index),
                                tooltip: 'Deny Refill',
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                              ),
                            ],
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
  // STATE MANAGEMENT HELPERS
  // ───────────────────────────────────────────────────────────────────────────
  void _approveRefill(int index) {
    final req = _refillRequests[index];
    setState(() {
      _refillRequests.removeAt(index);
      _refillsCount--;
      _activePrescriptionsCount++;

      // Parse drug name & dose
      final parts = req['drug'].toString().split(' ');
      final name = parts[0];
      final dose = parts.length > 1 ? parts[1] : "Daily";

      _prescriptions.insert(0, PrescriptionItem(
        drugName: name,
        dosage: dose,
        frequency: "Once daily (Morning)",
        durationDays: 30,
        status: "Active",
      ));
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: _kCardBg,
        content: Text('Refill request for "${req['name']}" approved successfully.', style: GoogleFonts.inter(color: Colors.white)),
      ),
    );
  }

  void _denyRefill(int index) {
    final req = _refillRequests[index];

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
            'Deny Refill Request',
            style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          content: Text(
            'Are you sure you want to deny the refill request for ${req['name']} (${req['drug']})?',
            style: GoogleFonts.inter(color: _kTextGray, fontSize: 12.5, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: GoogleFonts.inter(color: _kTextGray)),
            ),
            AppButton(
              label: 'Deny Request',
              height: 38,
              onPressed: () {
                setState(() {
                  _refillRequests.removeAt(index);
                  _refillsCount--;
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: _kCardBg,
                    content: Text('Refill request for "${req['name']}" denied.', style: GoogleFonts.inter(color: Colors.white)),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _confirmCancelScript(int index) {
    final rx = _prescriptions[index];

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
            'Cancel Medication Script',
            style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          content: Text(
            'Are you sure you want to cancel the active script for ${rx.drugName}?',
            style: GoogleFonts.inter(color: _kTextGray, fontSize: 12.5, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Keep Active', style: GoogleFonts.inter(color: _kTextGray)),
            ),
            AppButton(
              label: 'Cancel Script',
              height: 38,
              onPressed: () {
                setState(() {
                  _prescriptions.removeAt(index);
                  _activePrescriptionsCount--;
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: _kCardBg,
                    content: Text('Medication script for "${rx.drugName}" canceled.', style: GoogleFonts.inter(color: Colors.white)),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showInteractionDetailsDialog(int index) {
    final alert = _interactionAlerts[index];

    showDialog(
      context: context,
      builder: (context) {
        final bool isHigh = alert['severity'].toString().toLowerCase() == 'high';
        final Color accentColor = isHigh ? _kDangerRed : _kWarningAmber;

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
                  'Alert: ${alert['patient']}',
                  style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.5),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: accentColor.withOpacity(0.3)),
                ),
                child: Text(
                  alert['severity'],
                  style: GoogleFonts.inter(color: accentColor, fontSize: 9.5, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'INTERACTION SUMMARY',
                style: GoogleFonts.inter(color: const Color(0xFF6B8EFF), fontSize: 9.5, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                alert['description'],
                style: GoogleFonts.inter(color: Colors.white.withOpacity(0.85), fontSize: 12, height: 1.4),
              ),
              const SizedBox(height: 16),
              Text(
                'CLINICAL ADVISORY & RECS',
                style: GoogleFonts.inter(color: const Color(0xFF6B8EFF), fontSize: 9.5, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                alert['details'],
                style: GoogleFonts.inter(color: Colors.white.withOpacity(0.7), fontSize: 11.5, height: 1.45),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _interactionAlerts.removeAt(index);
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: _kCardBg,
                    content: Text('Interaction alert for "${alert['patient']}" marked as reviewed.', style: GoogleFonts.inter(color: Colors.white)),
                  ),
                );
              },
              child: Text('Mark Reviewed', style: GoogleFonts.inter(color: _kBrandGreen)),
            ),
            AppButton(
              label: 'Close',
              height: 36,
              variant: AppButtonVariant.secondary,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _showAddPrescriptionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: _kCardBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: _kCardBorder),
              ),
              title: Text(
                "Issue Digital Prescription",
                style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDialogTextField("Medication Name", _drugController, hint: "e.g. Amoxicillin", requiredField: true),
                    _buildDialogTextField("Dosage Strength", _dosageController, hint: "e.g. 500mg", requiredField: true),
                    Text(
                      'Frequency',
                      style: GoogleFonts.inter(color: _kTextGray, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.02),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: _kCardBorder),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          dropdownColor: _kCardBg,
                          value: _selectedFrequency,
                          isExpanded: true,
                          style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                          items: [
                            DropdownMenuItem(value: "Once daily (Morning)", child: Text("Once daily (Morning)")),
                            DropdownMenuItem(value: "Once daily (Bedtime)", child: Text("Once daily (Bedtime)")),
                            DropdownMenuItem(value: "Twice daily (With meals)", child: Text("Twice daily (With meals)")),
                            DropdownMenuItem(value: "Three times daily", child: Text("Three times daily")),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setDialogState(() {
                                _selectedFrequency = val;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    Text(
                      'Duration',
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
                        child: DropdownButton<int>(
                          dropdownColor: _kCardBg,
                          value: _selectedDuration,
                          isExpanded: true,
                          style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                          items: [
                            DropdownMenuItem(value: 7, child: Text("7 Days")),
                            DropdownMenuItem(value: 14, child: Text("14 Days")),
                            DropdownMenuItem(value: 30, child: Text("30 Days")),
                            DropdownMenuItem(value: 60, child: Text("60 Days")),
                            DropdownMenuItem(value: 90, child: Text("90 Days")),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setDialogState(() {
                                _selectedDuration = val;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("Cancel", style: GoogleFonts.inter(color: _kTextGray)),
                ),
                AppButton(
                  label: "Issue Rx",
                  height: 38,
                  onPressed: () {
                    if (_drugController.text.isNotEmpty && _dosageController.text.isNotEmpty) {
                      setState(() {
                        _prescriptions.add(PrescriptionItem(
                          drugName: _drugController.text.trim(),
                          dosage: _dosageController.text.trim(),
                          frequency: _selectedFrequency,
                          durationDays: _selectedDuration,
                          status: "Active",
                        ));
                        _activePrescriptionsCount++;
                      });
                      _drugController.clear();
                      _dosageController.clear();
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: _kCardBg,
                          content: Text('Prescription issued successfully.', style: GoogleFonts.inter(color: Colors.white)),
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
