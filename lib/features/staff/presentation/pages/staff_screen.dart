import "package:prachtiz_flutter/core/theme/app_colors.dart";
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../theme/colors.dart';
import '../../../../theme/styles.dart';

// Unified Brand Colors (Matches CallHealth & PraCHtiz dark theme guidelines)
const Color _kCardBg = Color(0xFF11152D);      // Flat Dark Navy card background
final Color _kCardBorder = Colors.white.withOpacity(0.08);
Color _kBrandBlue = AppColors.primary;   // Primary theme color
const Color _kBrandGreen = Color(0xFF24C06F);  // Success theme color
const Color _kTextGray = Color(0xFF94A3B8);    // Muted text grey
const Color _kDangerRed = Color(0xFFEF4444);   // Warning badge color
const Color _kWarningAmber = Color(0xFFF59E0B); // Alert color

class StaffMember {
  final String name;
  final String role;
  final String department;
  final String shift; // "Morning", "Afternoon", "Evening", "-"
  final int patientsCount; // 0 if not applicable
  final String status; // "On Duty", "Off Duty", "On Leave"

  StaffMember({
    required this.name,
    required this.role,
    required this.department,
    required this.shift,
    required this.patientsCount,
    required this.status,
  });
}

class StaffScreen extends StatefulWidget {
  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen> {
  // Initial seeded staff roster matching the screenshot data
  final List<StaffMember> _staff = [
    StaffMember(
      name: "Dr. Sarah Mitchell",
      role: "Cardiologist",
      department: "Cardiology",
      shift: "Morning",
      patientsCount: 12,
      status: "On Duty",
    ),
    StaffMember(
      name: "Dr. Robert Kim",
      role: "Neurologist",
      department: "Neurology",
      shift: "Morning",
      patientsCount: 8,
      status: "On Duty",
    ),
    StaffMember(
      name: "Dr. Angela Park",
      role: "Pulmonologist",
      department: "Pulmonology",
      shift: "Evening",
      patientsCount: 0,
      status: "Off Duty",
    ),
    StaffMember(
      name: "Dr. Michael Torres",
      role: "Orthopedic Surgeon",
      department: "Orthopedics",
      shift: "Morning",
      patientsCount: 6,
      status: "On Duty",
    ),
    StaffMember(
      name: "Nurse Lisa Wong",
      role: "Head Nurse",
      department: "ICU",
      shift: "Morning",
      patientsCount: 15,
      status: "On Duty",
    ),
    StaffMember(
      name: "Nurse James Hall",
      role: "Registered Nurse",
      department: "ER",
      shift: "Afternoon",
      patientsCount: 10,
      status: "On Duty",
    ),
    StaffMember(
      name: "Dr. Helen Wu",
      role: "Endocrinologist",
      department: "Endocrinology",
      shift: "-",
      patientsCount: 0,
      status: "On Leave",
    ),
    StaffMember(
      name: "Tech. David Lam",
      role: "Lab Technician",
      department: "Laboratory",
      shift: "Morning",
      patientsCount: 0,
      status: "On Duty",
    ),
  ];

  String _searchQuery = "";
  String _activeFilter = "All"; // "All", "Doctors", "Nurses", "Tech/Admin"

  // Search text field controller & focus node
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Filter the staff list based on search query and department/role filter
    final filteredStaff = _staff.where((member) {
      final matchesSearch = member.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          member.role.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          member.department.toLowerCase().contains(_searchQuery.toLowerCase());

      if (!matchesSearch) return false;

      if (_activeFilter == "All") return true;
      if (_activeFilter == "Doctors") return member.role.contains("Dr.") || member.role.contains("Surgeon") || member.role.contains("gist");
      if (_activeFilter == "Nurses") return member.role.contains("Nurse");
      if (_activeFilter == "Tech/Admin") return member.role.contains("Tech") || member.role.contains("Administrator") || member.role.contains("Technician");

      return true;
    }).toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Title, Subtitle, and Add Staff Button
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Staff",
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.gray900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Manage hospital staff, schedules, and assignments.",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.gray500,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _showAddStaffDialog,
                  icon: const Icon(Icons.group_add_outlined, size: 18, color: Colors.white),
                  label: Text(
                    "Add Staff",
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kBrandBlue,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Search Bar and Filter Tabs Row
            Builder(builder: (context) {
              final double screenWidth = MediaQuery.of(context).size.width;
              final bool isWide = screenWidth > 700;
              final searchBar = SizedBox(
                width: isWide ? 300 : double.infinity,
                child: TextField(
                  key: const ValueKey('staff_search_field'),
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  style: GoogleFonts.inter(fontSize: 13, color: AppColors.gray800),
                  decoration: InputDecoration(
                    hintText: "Search staff, role, specialty...",
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
                      borderSide: BorderSide(color: _kBrandBlue),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              );

              final filterTabs = SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: ["All", "Doctors", "Nurses", "Tech/Admin"].map((filter) {
                    final bool isSelected = _activeFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(filter),
                        labelStyle: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.white : AppColors.gray800,
                        ),
                        selected: isSelected,
                        selectedColor: _kBrandBlue,
                        backgroundColor: Colors.white,
                        onSelected: (val) {
                          if (val) {
                            setState(() {
                              _activeFilter = filter;
                            });
                          }
                        },
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: isSelected ? _kBrandBlue : AppColors.gray300),
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
                    searchBar,
                  ],
                );
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    searchBar,
                    const SizedBox(height: 12),
                    filterTabs,
                  ],
                );
              }
            }),
            const SizedBox(height: 16),

            // Staff Cards Grid
            LayoutBuilder(builder: (context, constraints) {
              // Grid columns selection: 4 on desktop, 2 on tablet, 1 on mobile
              int crossAxisCount = 1;
              if (constraints.maxWidth >= 1100) {
                crossAxisCount = 4;
              } else if (constraints.maxWidth >= 650) {
                crossAxisCount = 2;
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.45,
                ),
                itemCount: filteredStaff.length,
                itemBuilder: (context, index) {
                  final member = filteredStaff[index];
                  return _HoverStaffCard(member: member);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showAddStaffDialog() {
    final formKey = GlobalKey<FormState>();
    String name = "";
    String role = "";
    String department = "Cardiology";
    String shift = "Morning";
    String status = "On Duty";
    int patientsCount = 0;

    final List<String> departments = [
      "Cardiology", "Neurology", "Pulmonology", "Orthopedics",
      "ICU", "ER", "Endocrinology", "Laboratory", "General Medicine"
    ];

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
                "Add New Staff Member",
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              content: Container(
                width: 460,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Name
                        TextFormField(
                          style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                          decoration: _buildInputDecoration("Full Name (e.g. Dr. Sarah Mitchell)"),
                          validator: (val) => val == null || val.trim().isEmpty ? "Please enter staff name" : null,
                          onSaved: (val) => name = val!.trim(),
                        ),
                        const SizedBox(height: 12),

                        // Role
                        TextFormField(
                          style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                          decoration: _buildInputDecoration("Role/Title (e.g. Cardiologist)"),
                          validator: (val) => val == null || val.trim().isEmpty ? "Please enter role" : null,
                          onSaved: (val) => role = val!.trim(),
                        ),
                        const SizedBox(height: 12),

                        // Department Dropdown
                        DropdownButtonFormField<String>(
                          dropdownColor: _kCardBg,
                          value: department,
                          style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                          decoration: _buildInputDecoration("Department"),
                          items: departments.map((dept) {
                            return DropdownMenuItem(
                              value: dept,
                              child: Text(dept, style: GoogleFonts.inter(color: Colors.white, fontSize: 13)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setDialogState(() => department = val);
                            }
                          },
                        ),
                        const SizedBox(height: 12),

                        // Shift Dropdown
                        DropdownButtonFormField<String>(
                          dropdownColor: _kCardBg,
                          value: shift,
                          style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                          decoration: _buildInputDecoration("Shift Time"),
                          items: ["Morning", "Afternoon", "Evening", "-"].map((s) {
                            return DropdownMenuItem(
                              value: s,
                              child: Text(s, style: GoogleFonts.inter(color: Colors.white, fontSize: 13)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setDialogState(() => shift = val);
                            }
                          },
                        ),
                        const SizedBox(height: 12),

                        // Status Dropdown
                        DropdownButtonFormField<String>(
                          dropdownColor: _kCardBg,
                          value: status,
                          style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                          decoration: _buildInputDecoration("Duty Status"),
                          items: ["On Duty", "Off Duty", "On Leave"].map((st) {
                            return DropdownMenuItem(
                              value: st,
                              child: Text(st, style: GoogleFonts.inter(color: Colors.white, fontSize: 13)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setDialogState(() => status = val);
                            }
                          },
                        ),
                        const SizedBox(height: 12),

                        // Patients count
                        TextFormField(
                          style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                          keyboardType: TextInputType.number,
                          decoration: _buildInputDecoration("Active Patient Load (Count)"),
                          validator: (val) {
                            if (val != null && val.isNotEmpty) {
                              final num = int.tryParse(val);
                              if (num == null || num < 0) return "Please enter a valid number";
                            }
                            return null;
                          },
                          onSaved: (val) {
                            if (val != null && val.isNotEmpty) {
                              patientsCount = int.tryParse(val) ?? 0;
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Cancel",
                    style: GoogleFonts.inter(color: _kTextGray, fontSize: 13),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      formKey.currentState!.save();
                      setState(() {
                        _staff.add(StaffMember(
                          name: name,
                          role: role,
                          department: department,
                          shift: shift,
                          patientsCount: patientsCount,
                          status: status,
                        ));
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: _kBrandGreen,
                          behavior: SnackBarBehavior.floating,
                          content: Text(
                            "Staff member '$name' added successfully.",
                            style: GoogleFonts.inter(color: Colors.white),
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: _kBrandBlue),
                  child: Text(
                    "Add Member",
                    style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.inter(color: _kTextGray, fontSize: 12),
      filled: true,
      fillColor: const Color(0xFF1A1F3E),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: _kCardBorder),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: _kBrandBlue, width: 1.2),
        borderRadius: BorderRadius.circular(8),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: _kDangerRed),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: _kDangerRed, width: 1.2),
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }
}

class _HoverStaffCard extends StatefulWidget {
  final StaffMember member;
  const _HoverStaffCard({required this.member});

  @override
  State<_HoverStaffCard> createState() => _HoverStaffCardState();
}

class _HoverStaffCardState extends State<_HoverStaffCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final member = widget.member;

    // Determine status badge color
    Color statusBg = _kTextGray.withOpacity(0.08);
    Color statusTextColor = _kTextGray;

    if (member.status == "On Duty") {
      statusBg = _kBrandGreen.withOpacity(0.08);
      statusTextColor = _kBrandGreen;
    } else if (member.status == "On Leave") {
      statusBg = _kWarningAmber.withOpacity(0.08);
      statusTextColor = _kWarningAmber;
    }

    // Determine department icon
    IconData deptIcon = Icons.medical_services_outlined;
    switch (member.department) {
      case "Cardiology":
        deptIcon = Icons.favorite_outline;
        break;
      case "Neurology":
        deptIcon = Icons.psychology_outlined;
        break;
      case "Pulmonology":
        deptIcon = Icons.air_outlined;
        break;
      case "Orthopedics":
        deptIcon = Icons.accessibility_new_outlined;
        break;
      case "ICU":
        deptIcon = Icons.local_hospital_outlined;
        break;
      case "ER":
        deptIcon = Icons.emergency_outlined;
        break;
      case "Endocrinology":
        deptIcon = Icons.water_drop_outlined;
        break;
      case "Laboratory":
        deptIcon = Icons.science_outlined;
        break;
    }

    // Avatar initials
    final initials = member.name.startsWith("Dr.")
        ? member.name.substring(3).trim()[0]
        : (member.name.startsWith("Nurse") ? member.name.substring(5).trim()[0] : member.name.trim()[0]);

    return GestureDetector(
      onTap: () => _showStaffDetailsDialog(context, member),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0, _isHovered ? -4 : 0, 0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: _kCardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _isHovered ? _kBrandBlue.withOpacity(0.4) : _kCardBorder, width: 1.2),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: _kBrandBlue.withOpacity(0.08),
                      offset: const Offset(0, 6),
                      blurRadius: 16,
                    )
                  ]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top Row: Circle Avatar and Status Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: _kBrandBlue.withOpacity(0.12),
                    child: Text(
                      initials,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        color: _kBrandBlue,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusTextColor.withOpacity(0.2)),
                    ),
                    child: Text(
                      member.status,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: statusTextColor,
                      ),
                    ),
                  ),
                ],
              ),
  
              const SizedBox(height: 8),
  
              // Middle: Name and Title
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.name,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    member.role,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: _kTextGray,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
  
              const SizedBox(height: 8),
              const Divider(color: Colors.white12, height: 1),
              const SizedBox(height: 8),
  
              // Bottom Rows: Dept, Shift, Patient count
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Department
                    _buildDetailRow(deptIcon, member.department),
                    // Shift
                    _buildDetailRow(Icons.access_time_outlined, member.shift),
                    // Patient load
                    _buildDetailRow(
                      Icons.people_outline,
                      member.patientsCount > 0 ? "${member.patientsCount} patients" : "-",
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

  void _showStaffDetailsDialog(BuildContext context, StaffMember member) {
    String bio = "";
    if (member.name.contains("Sarah Mitchell")) {
      bio = "Dr. Sarah Mitchell is a senior Cardiologist with over 12 years of clinical experience. She specializes in advanced cardiovascular diagnostics, heart failure management, and preventive cardiology care.";
    } else if (member.name.contains("Robert Kim")) {
      bio = "Dr. Robert Kim is an accomplished Neurologist specializing in neurodegenerative diseases, stroke recovery, and clinical neurophysiology. He leads the stroke unit and oversees clinical trials.";
    } else if (member.name.contains("Angela Park")) {
      bio = "Dr. Angela Park is a dedicated Pulmonologist with expertise in sleep medicine, asthma therapies, and interstitial lung diseases. She actively contributes to clinical education.";
    } else if (member.name.contains("Michael Torres")) {
      bio = "Dr. Michael Torres is an Orthopedic Surgeon specializing in joint replacement, sports medicine, and reconstructive surgeries. He has performed over 1,500 successful operations.";
    } else if (member.name.contains("Lisa Wong")) {
      bio = "Nurse Lisa Wong is the Head Nurse of the Intensive Care Unit (ICU). She has over 15 years of critical care nursing experience and manages a team of 24 registered nurses.";
    } else if (member.name.contains("James Hall")) {
      bio = "Nurse James Hall is a Senior Registered Nurse in the Emergency Department (ER). He specializes in trauma triage, emergency wound care, and cardiac resuscitation protocols.";
    } else if (member.name.contains("Helen Wu")) {
      bio = "Dr. Helen Wu is a leading Endocrinologist focusing on diabetes management, thyroid disorders, and metabolic health. She is currently on sabbatical presenting research in Munich.";
    } else if (member.name.contains("David Lam")) {
      bio = "Technician David Lam is the Lead Laboratory Analyst. He has certifications in clinical pathology and biochemical hematology and oversees diagnostic instrument calibration.";
    } else {
      bio = "${member.name} is a dedicated ${member.role} in the ${member.department} department, committed to delivering top-tier patient care and clinical services.";
    }

    String education = "";
    if (member.role.contains("Cardiologist") || member.role.contains("Neurologist") || member.role.contains("Pulmonologist") || member.role.contains("Endocrinologist") || member.role.contains("Surgeon")) {
      education = "MD in Internal Medicine (Johns Hopkins University), Fellowship in ${member.department} (Mayo Clinic)";
    } else if (member.role.contains("Nurse")) {
      education = "Bachelor of Science in Nursing (BSN) - University of Washington, Certified Critical Care Registered Nurse (CCRN)";
    } else {
      education = "Bachelor of Science in Medical Laboratory Technology, Certified Clinical Pathologist (ASCP)";
    }

    final int hash = member.name.hashCode.abs() % 90000 + 10000;
    final String license = member.role.contains("Nurse") ? "RN-$hash" : (member.role.contains("Tech") ? "LMT-$hash" : "LIC-$hash");
    final String emailName = member.name.toLowerCase().replaceAll("dr. ", "").replaceAll("nurse ", "").replaceAll("tech. ", "").replaceAll(" ", ".");
    final String contact = "$emailName@prachtiz.com (Ext. ${member.name.hashCode.abs() % 900 + 100})";

    Color statusTextColor = _kTextGray;
    if (member.status == "On Duty") {
      statusTextColor = _kBrandGreen;
    } else if (member.status == "On Leave") {
      statusTextColor = _kWarningAmber;
    }

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
            padding: const EdgeInsets.all(24),
            constraints: const BoxConstraints(maxWidth: 520),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top Header Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: _kBrandBlue.withOpacity(0.12),
                            child: Text(
                              member.name.startsWith("Dr.")
                                  ? member.name.substring(3).trim()[0]
                                  : (member.name.startsWith("Nurse") ? member.name.substring(5).trim()[0] : member.name.trim()[0]),
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                color: _kBrandBlue,
                                fontSize: 22,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    member.name,
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: statusTextColor.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: statusTextColor.withOpacity(0.2)),
                                    ),
                                    child: Text(
                                      member.status,
                                      style: GoogleFonts.inter(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: statusTextColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                member.role,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: _kTextGray,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.white54, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: Colors.white12, height: 1),
                  const SizedBox(height: 20),

                  // Professional Bio Section
                  Text(
                    "PROFESSIONAL BIOGRAPHY",
                    style: GoogleFonts.inter(color: _kBrandBlue, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    bio,
                    style: GoogleFonts.inter(color: Colors.white.withOpacity(0.9), fontSize: 13, height: 1.5),
                  ),
                  const SizedBox(height: 20),

                  // Credentials Grid
                  Text(
                    "CLINICAL CREDENTIALS",
                    style: GoogleFonts.inter(color: _kBrandBlue, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 12),
                  _buildModalDetailRow(Icons.favorite_outline, "Department", member.department),
                  const SizedBox(height: 8),
                  _buildModalDetailRow(Icons.school_outlined, "Education", education),
                  const SizedBox(height: 8),
                  _buildModalDetailRow(Icons.badge_outlined, "License Number", license),
                  const SizedBox(height: 20),

                  // Operations info
                  Text(
                    "TODAY'S OPERATIONS",
                    style: GoogleFonts.inter(color: _kBrandBlue, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 12),
                  _buildModalDetailRow(Icons.access_time_outlined, "Shift Hours", member.shift == "-" ? "Off/On Leave" : "${member.shift} Roster"),
                  const SizedBox(height: 8),
                  _buildModalDetailRow(Icons.people_outline, "Assigned Patients", member.patientsCount > 0 ? "${member.patientsCount} patients active" : "None"),
                  const SizedBox(height: 8),
                  _buildModalDetailRow(Icons.mail_outline, "Contact Detail", contact),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildModalDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: _kTextGray),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: _kTextGray),
            ),
            const SizedBox(height: 2),
            Container(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Text(
                value,
                style: GoogleFonts.inter(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w500),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: _kTextGray),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: _kTextGray,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

