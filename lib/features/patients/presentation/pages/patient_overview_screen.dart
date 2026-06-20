import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/models/patient.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_radius.dart';

class PatientOverviewScreen extends StatefulWidget {
  const PatientOverviewScreen({super.key});

  @override
  State<PatientOverviewScreen> createState() => _PatientOverviewScreenState();
}

class _PatientOverviewScreenState extends State<PatientOverviewScreen> {
  // Mock patients database matching the provided screenshot exactly
  final List<Patient> _patients = [
    Patient(
      id: "P-1001",
      name: "Margaret Chen",
      age: 64,
      gender: "Female",
      contact: "+1 (555) 012-3456",
      condition: "Type 2 Diabetes",
      vitalStatus: VitalStatus.normal,
      statusLabel: "Stable",
      doctorName: "Dr. Sarah Mitchell",
      roomNumber: "204-A",
      dob: "1962-05-18",
      allergies: ["Sulfa Drugs"],
      vitalsHistory: [
        VitalReading(heartRate: 74, bloodPressure: "122/80", temperature: 36.8, spo2: 98, timestamp: "Just now"),
      ],
    ),
    Patient(
      id: "P-1002",
      name: "James O'Sullivan",
      age: 72,
      gender: "Male",
      contact: "+1 (555) 018-7654",
      condition: "Hypertension",
      vitalStatus: VitalStatus.critical,
      statusLabel: "Critical",
      doctorName: "Dr. Robert Kim",
      roomNumber: "ICU-3",
      dob: "1954-11-04",
      allergies: ["Penicillin"],
      vitalsHistory: [
        VitalReading(heartRate: 110, bloodPressure: "155/98", temperature: 37.9, spo2: 90, timestamp: "Just now"),
      ],
    ),
    Patient(
      id: "P-1003",
      name: "Aisha Rahman",
      age: 45,
      gender: "Female",
      contact: "+1 (555) 019-2834",
      condition: "Post-op Recovery (Knee)",
      vitalStatus: VitalStatus.warning,
      statusLabel: "Recovering",
      doctorName: "Dr. Michael Torres",
      roomNumber: "312-B",
      dob: "1981-08-14",
      allergies: ["Penicillin", "Sulfa Drugs"],
      vitalsHistory: [
        VitalReading(heartRate: 85, bloodPressure: "130/85", temperature: 37.1, spo2: 96, timestamp: "Just now"),
      ],
    ),
    Patient(
      id: "P-1004",
      name: "Robert Nakamura",
      age: 58,
      gender: "Male",
      contact: "+1 (555) 014-9821",
      condition: "Chronic Heart Failure",
      vitalStatus: VitalStatus.critical,
      statusLabel: "Critical",
      doctorName: "Dr. Sarah Mitchell",
      roomNumber: "ICU-7",
      dob: "1968-03-22",
      allergies: ["Aspirin"],
      vitalsHistory: [
        VitalReading(heartRate: 104, bloodPressure: "148/96", temperature: 37.8, spo2: 91, timestamp: "Just now"),
      ],
    ),
    Patient(
      id: "P-1005",
      name: "Elena Vasquez",
      age: 34,
      gender: "Female",
      contact: "+1 (555) 018-4720",
      condition: "Pneumonia",
      vitalStatus: VitalStatus.normal,
      statusLabel: "Stable",
      doctorName: "Dr. Angela Park",
      roomNumber: "118-A",
      dob: "1992-06-10",
      allergies: ["Lactose"],
      vitalsHistory: [
        VitalReading(heartRate: 72, bloodPressure: "116/78", temperature: 36.8, spo2: 99, timestamp: "Just now"),
      ],
    ),
    Patient(
      id: "P-1006",
      name: "Thomas Bergstrom",
      age: 81,
      gender: "Male",
      contact: "+1 (555) 011-8291",
      condition: "Atrial Fibrillation",
      vitalStatus: VitalStatus.normal,
      statusLabel: "Stable",
      doctorName: "Dr. Robert Kim",
      roomNumber: "205-C",
      dob: "1945-09-02",
      allergies: ["Dust Mites", "Pollen"],
      vitalsHistory: [
        VitalReading(heartRate: 78, bloodPressure: "105/70", temperature: 36.4, spo2: 98, timestamp: "Just now"),
      ],
    ),
    Patient(
      id: "P-1007",
      name: "Priya Patel",
      age: 29,
      gender: "Female",
      contact: "+1 (555) 017-3810",
      condition: "Appendectomy Recovery",
      vitalStatus: VitalStatus.inactive,
      statusLabel: "Discharged",
      doctorName: "Dr. Michael Torres",
      roomNumber: "—",
      dob: "1997-01-25",
      allergies: [],
      vitalsHistory: [
        VitalReading(heartRate: 68, bloodPressure: "110/72", temperature: 36.6, spo2: 99, timestamp: "Just now"),
      ],
    ),
    Patient(
      id: "P-1008",
      name: "William Frost",
      age: 67,
      gender: "Male",
      contact: "+1 (555) 012-9876",
      condition: "COPD Exacerbation",
      vitalStatus: VitalStatus.warning,
      statusLabel: "Recovering",
      doctorName: "Dr. Angela Park",
      roomNumber: "310-A",
      dob: "1959-12-07",
      allergies: ["NSAIDs"],
      vitalsHistory: [
        VitalReading(heartRate: 92, bloodPressure: "135/88", temperature: 37.3, spo2: 94, timestamp: "Just now"),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.pagePaddingHorizontal,
          vertical: AppDimensions.pagePaddingVertical,
        ),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Title & Subtitle Zone
            Text(
              "Patient Overview",
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF6B8EFF), // Light electric brand blue
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Monitor and manage patient records, vitals, and care plans.",
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF94A3B8), // Muted slate color
              ),
            ),
            const SizedBox(height: 20),

            // Stat Cards Row
            LayoutBuilder(
              builder: (context, constraints) {
                final double width = constraints.maxWidth;
                if (width > 1100) {
                  return Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          title: "Total Patients",
                          value: "1,247",
                          trend: "+3.2% from last month",
                          isPositiveTrend: true,
                          icon: Icons.people_outline,
                          iconColor: const Color(0xFF6366F1), // Indigo
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          title: "New This Month",
                          value: "86",
                          trend: "+12.4% from last month",
                          isPositiveTrend: true,
                          icon: Icons.person_add_alt_1_outlined,
                          iconColor: const Color(0xFF3B82F6), // Blue
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          title: "Critical Cases",
                          value: "12",
                          trend: "-2 from last month",
                          isPositiveTrend: false, // Wait: negative trend for critical is good, but shown in red/coral
                          icon: Icons.local_hospital_outlined,
                          iconColor: AppColors.danger, // Red
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          title: "Avg Stay",
                          value: "4.2 days",
                          trend: "-0.3d from last month",
                          isPositiveTrend: false,
                          icon: Icons.hotel_outlined,
                          iconColor: const Color(0xFF8B5CF6), // Purple
                        ),
                      ),
                    ],
                  );
                } else if (width > 600) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              title: "Total Patients",
                              value: "1,247",
                              trend: "+3.2% from last month",
                              isPositiveTrend: true,
                              icon: Icons.people_outline,
                              iconColor: const Color(0xFF6366F1),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStatCard(
                              title: "New This Month",
                              value: "86",
                              trend: "+12.4% from last month",
                              isPositiveTrend: true,
                              icon: Icons.person_add_alt_1_outlined,
                              iconColor: const Color(0xFF3B82F6),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              title: "Critical Cases",
                              value: "12",
                              trend: "-2 from last month",
                              isPositiveTrend: false,
                              icon: Icons.local_hospital_outlined,
                              iconColor: AppColors.danger,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStatCard(
                              title: "Avg Stay",
                              value: "4.2 days",
                              trend: "-0.3d from last month",
                              isPositiveTrend: false,
                              icon: Icons.hotel_outlined,
                              iconColor: const Color(0xFF8B5CF6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildStatCard(
                        title: "Total Patients",
                        value: "1,247",
                        trend: "+3.2% from last month",
                        isPositiveTrend: true,
                        icon: Icons.people_outline,
                        iconColor: const Color(0xFF6366F1),
                      ),
                      const SizedBox(height: 12),
                      _buildStatCard(
                        title: "New This Month",
                        value: "86",
                        trend: "+12.4% from last month",
                        isPositiveTrend: true,
                        icon: Icons.person_add_alt_1_outlined,
                        iconColor: const Color(0xFF3B82F6),
                      ),
                      const SizedBox(height: 12),
                      _buildStatCard(
                        title: "Critical Cases",
                        value: "12",
                        trend: "-2 from last month",
                        isPositiveTrend: false,
                        icon: Icons.local_hospital_outlined,
                        iconColor: AppColors.danger,
                      ),
                      const SizedBox(height: 12),
                      _buildStatCard(
                        title: "Avg Stay",
                        value: "4.2 days",
                        trend: "-0.3d from last month",
                        isPositiveTrend: false,
                        icon: Icons.hotel_outlined,
                        iconColor: const Color(0xFF8B5CF6),
                      ),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 24),

            // Grid of Patient Cards
            LayoutBuilder(
              builder: (context, constraints) {
                final double width = constraints.maxWidth;
                final int columns = width > 1100 ? 2 : 1;
                
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _patients.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    mainAxisExtent: 220,
                  ),
                  itemBuilder: (context, index) {
                    final patient = _patients[index];
                    return _PatientCard(
                      patient: patient,
                      onTap: () => _showPatientDetails(patient),
                    ).animate().fadeIn(
                          delay: (index * 50).ms,
                          duration: 400.ms,
                        ).slideY(
                          begin: 0.05,
                          end: 0,
                          curve: Curves.easeOutQuad,
                        );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String trend,
    required bool isPositiveTrend,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0C0E1F), // Unified Flat Dark Navy
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  color: const Color(0xFF94A3B8), // Muted grey-blue title
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            trend,
            style: GoogleFonts.inter(
              color: isPositiveTrend ? const Color(0xFF24C06F) : const Color(0xFFF04438),
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showPatientDetails(Patient patient) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (context) => _PatientDetailsDialog(patient: patient),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Patient Card Widget with hover interactions
// ─────────────────────────────────────────────────────────────────────────────
class _PatientCard extends StatefulWidget {
  final Patient patient;
  final VoidCallback onTap;

  const _PatientCard({
    required this.patient,
    required this.onTap,
  });

  @override
  State<_PatientCard> createState() => _PatientCardState();
}

class _PatientCardState extends State<_PatientCard> {
  bool _isHovered = false;

  Color _getStatusColor(String? label) {
    switch (label?.toLowerCase()) {
      case "critical":
        return AppColors.danger;
      case "recovering":
        return AppColors.primary;
      case "stable":
        return AppColors.secondary;
      case "discharged":
        return const Color(0xFF64748B);
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.patient;
    final Color statusColor = _getStatusColor(p.statusLabel);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          transform: Matrix4.identity()
            ..translate(0.0, _isHovered ? -4.0 : 0.0, 0.0)
            ..scale(_isHovered ? 1.01 : 1.0),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF0C0E1F), // Deep navy matching dashboard cards
            borderRadius: AppRadius.radius16,
            border: Border.all(
              color: _isHovered ? statusColor.withOpacity(0.4) : Colors.white.withOpacity(0.08),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_isHovered ? 0.3 : 0.15),
                blurRadius: _isHovered ? 16 : 8,
                offset: Offset(0, _isHovered ? 8 : 4),
              ),
              if (_isHovered)
                BoxShadow(
                  color: statusColor.withOpacity(0.08),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Avatar, Name & Diagnosis, Status Badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: statusColor,
                    child: Text(
                      p.name.isNotEmpty ? p.name[0].toUpperCase() : '',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.name,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          p.condition,
                          style: GoogleFonts.inter(
                            color: const Color(0xFF94A3B8),
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      p.statusLabel ?? "Unknown",
                      style: GoogleFonts.inter(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Divider(
                color: Colors.white.withOpacity(0.08),
                height: 1,
              ),
              const SizedBox(height: 16),

              // Detail Grid: Age/Gender, Doctor, Room, ID
              Expanded(
                child: Row(
                  children: [
                    // Left Column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildDetailBlock("Age", "${p.age} · ${p.gender}"),
                          _buildDetailBlock("Room", p.roomNumber ?? "—"),
                        ],
                      ),
                    ),
                    // Right Column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildDetailBlock("Doctor", p.doctorName ?? "—"),
                          _buildDetailBlock("ID", p.id),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailBlock(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: const Color(0xFF64748B),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.inter(
            color: const Color(0xFFE2E8F0),
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Interactive Patient Details Dialog
// ─────────────────────────────────────────────────────────────────────────────
class _PatientDetailsDialog extends StatelessWidget {
  final Patient patient;

  const _PatientDetailsDialog({required this.patient});

  Color _getStatusColor(String? label) {
    switch (label?.toLowerCase()) {
      case "critical":
        return AppColors.danger;
      case "recovering":
        return AppColors.primary;
      case "stable":
        return AppColors.secondary;
      case "discharged":
        return const Color(0xFF64748B);
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color statusColor = _getStatusColor(patient.statusLabel);
    final latestVitals = patient.vitalsHistory.isNotEmpty
        ? patient.vitalsHistory[0]
        : VitalReading(heartRate: 75, bloodPressure: "120/80", temperature: 36.7, spo2: 98, timestamp: "N/A");

    return Dialog(
      backgroundColor: const Color(0xFF0C0E1F),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withOpacity(0.08)),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 550),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Dialog Header: Initials Avatar, Name & Condition, Close Button
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: statusColor,
                    child: Text(
                      patient.name.isNotEmpty ? patient.name[0].toUpperCase() : '',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          patient.name,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "DOB: ${patient.dob} (Age: ${patient.age} • ${patient.gender})",
                          style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(color: Colors.white.withOpacity(0.08)),
              const SizedBox(height: 16),

              // Care Information Section
              Text(
                "CHIEF DIAGNOSIS",
                style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                patient.condition,
                style: GoogleFonts.inter(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildInfoField("CONTACT INFO", patient.contact),
                  ),
                  Expanded(
                    child: _buildInfoField("VITALS STATUS", patient.statusLabel?.toUpperCase() ?? "UNKNOWN"),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Telemetry Vitals Grid
              Text(
                "LATEST TELEMETRY",
                style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              LayoutBuilder(
                builder: (context, constraints) {
                  return GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.8,
                    children: [
                      _buildVitalCard("HEART RATE", "${latestVitals.heartRate} bpm", Icons.favorite, AppColors.danger),
                      _buildVitalCard("BLOOD PRESSURE", latestVitals.bloodPressure, Icons.speed, AppColors.primary),
                      _buildVitalCard("TEMPERATURE", "${latestVitals.temperature}°C", Icons.thermostat, AppColors.warning),
                      _buildVitalCard("SPO2 LEVEL", "${latestVitals.spo2}%", Icons.bloodtype, const Color(0xFF0D9488)),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),

              // Allergies Section
              Text(
                "KNOWN ALLERGIES",
                style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              patient.allergies.isEmpty
                  ? Text("No known drug or food allergies.", style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 12))
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: patient.allergies.map((allergy) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.danger.withOpacity(0.12),
                            border: Border.all(color: AppColors.danger.withOpacity(0.3)),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            allergy,
                            style: GoogleFonts.inter(color: AppColors.danger, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        );
                      }).toList(),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildVitalCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF10183C), // Slight lighter dark navy for card body
        borderRadius: AppRadius.radius8,
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 9, fontWeight: FontWeight.bold),
              ),
              Icon(icon, color: color, size: 16),
            ],
          ),
          Text(
            value,
            style: GoogleFonts.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
