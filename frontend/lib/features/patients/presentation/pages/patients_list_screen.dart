import "package:prachtiz_flutter/core/theme/app_colors.dart";
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../theme/colors.dart';
import '../../../../theme/styles.dart';
import '../../domain/models/patient.dart';
import '../../../../shared/services/api_service.dart';
import '../../../../shared/services/auth_service.dart';

// Local high-fidelity patient record model containing table details
class PatientRecord {
  final String id;
  final String name;
  final int age;
  final String gender;
  final String contact;
  final String lastVisit;
  final String registeredDate;
  final String status; // "Stable", "Critical", "Warning"

  PatientRecord({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.contact,
    required this.lastVisit,
    required this.registeredDate,
    required this.status,
  });

  String get initials {
    List<String> parts = name.split(' ');
    if (parts.length >= 2) {
      return "${parts[0][0]}${parts[parts.length - 1][0]}".toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : "";
  }
}

class PatientsListScreen extends StatefulWidget {
  final Function(String)? onNavigate;

  const PatientsListScreen({Key? key, this.onNavigate}) : super(key: key);

  @override
  State<PatientsListScreen> createState() => _PatientsListScreenState();
}

class _PatientsListScreenState extends State<PatientsListScreen> {
  List<PatientRecord> _allPatients = [];
  bool _loading = true;
  String? _error;

  String _searchQuery = "";
  String _statusFilter = "All Status"; // "All Status", "Stable", "Warning", "Critical"
  int _currentPage = 1;
  final Set<String> _revealedContactIds = {};
  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final role = AuthService.instance.session?.role;
      final endpoint = role == UserRole.receptionist ? '/receptionist/patients' : '/doctor/patients';
      final data = await ApiService.instance.get(endpoint);
      final list = data as List;
      
      final List<PatientRecord> mapped = list.map((item) {
        final name = '${item['first_name'] ?? ''} ${item['last_name'] ?? ''}'.trim();
        final id = item['id']?.toString() ?? '';
        final age = _calculateAge(item['dob']?.toString());
        final gender = item['gender']?.toString() ?? 'Other';
        final contact = item['phone']?.toString() ?? '—';
        final lastVisit = item['last_visit']?.toString().split('T')[0] ?? '—';
        final registeredDate = item['created_at']?.toString().split('T')[0] ?? '—';
        final condition = item['condition']?.toString() ?? 'Stable';
        
        return PatientRecord(
          id: id.substring(0, math.min(8, id.length)).toUpperCase(),
          name: name.isNotEmpty ? name : 'Patient',
          age: age,
          gender: gender,
          contact: contact,
          lastVisit: lastVisit,
          registeredDate: registeredDate,
          status: condition,
        );
      }).toList();

      if (mounted) {
        setState(() {
          _allPatients = mapped;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load patients';
          _loading = false;
        });
      }
    }
  }

  int _calculateAge(String? dobStr) {
    if (dobStr == null) return 30;
    try {
      final dob = DateTime.parse(dobStr);
      final now = DateTime.now();
      int age = now.year - dob.year;
      if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
        age--;
      }
      return age;
    } catch (_) {
      return 30;
    }
  }

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!, style: GoogleFonts.inter(color: Colors.red.shade300)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loadPatients,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobileLayout = screenWidth <= 768;

    final bool hasSearchOrFilter = _searchQuery.isNotEmpty || _statusFilter != "All Status";
    final List<PatientRecord> filteredPatients;

    final List<PatientRecord> searchFiltered = _allPatients.where((p) {
      final matchesSearch = p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.id.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesStatus = _statusFilter == "All Status" || p.status == _statusFilter;
      return matchesSearch && matchesStatus;
    }).toList();

    if (hasSearchOrFilter) {
      filteredPatients = searchFiltered;
    } else {
      final int startIndex = (_currentPage - 1) * 6;
      filteredPatients = searchFiltered.skip(startIndex).take(6).toList();
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Header Title and Subtitle matching mockup
            Text(
              "Patients",
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.gray900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Manage your patient Records efficiently",
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.gray500,
              ),
            ),
            const SizedBox(height: 20),

            // Responsive KPI metric cards matching mockup
            _buildKPICards(context),
            const SizedBox(height: 24),

            // Large main container containing search, filters, table, and pagination
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF11152D),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Search & Filter header toolbar
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: isMobileLayout
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildSearchBar(),
                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: _buildFilterDropdown(),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: 300,
                                child: _buildSearchBar(),
                              ),
                              _buildFilterDropdown(),
                            ],
                          ),
                  ),

                  const Divider(color: Colors.white12, height: 1),

                  // Scrollable Responsive Patient Data Table
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: SizedBox(
                      width: 900,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildTableHeader(),
                          const Divider(color: Colors.white12, height: 1),
                          if (filteredPatients.isEmpty)
                            _buildEmptyState()
                          else
                            ...filteredPatients.map((p) => _PatientRow(
                                  patient: p,
                                  isRevealed: _revealedContactIds.contains(p.id),
                                  onToggleReveal: () {
                                    setState(() {
                                      if (_revealedContactIds.contains(p.id)) {
                                        _revealedContactIds.remove(p.id);
                                      } else {
                                        _revealedContactIds.add(p.id);
                                      }
                                    });
                                  },
                                  onTap: () {
                                    if (widget.onNavigate != null) {
                                      widget.onNavigate!("/patient-overview");
                                    } else {
                                      context.go("/patient-overview");
                                    }
                                  },
                                )),
                        ],
                      ),
                    ),
                  ),

                  // Pagination Footer
                  const Divider(color: Colors.white12, height: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                    child: _buildPagination(filteredPatients, hasSearchOrFilter),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKPICards(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    final total = _allPatients.length;
    final followUp = _allPatients.where((p) => p.lastVisit != '—').length;
    final males = _allPatients.where((p) => p.gender.toLowerCase() == 'male').length;
    final females = _allPatients.where((p) => p.gender.toLowerCase() == 'female').length;

    final List<Widget> cards = [
      _InteractiveKPICard(
        label: "Total Patients",
        value: "$total",
        icon: Icons.people_alt_outlined,
        color: AppColors.primary,
      ),
      _InteractiveKPICard(
        label: "Follow up / Review",
        value: "$followUp",
        icon: Icons.loop_outlined,
        color: const Color(0xFFEF4444),
      ),
      _InteractiveKPICard(
        label: "Male Patients",
        value: "$males",
        icon: Icons.male,
        color: const Color(0xFF24C06F),
      ),
      _InteractiveKPICard(
        label: "Female Patients",
        value: "$females",
        icon: Icons.female,
        color: const Color(0xFFEC4899),
      ),
    ];

    if (screenWidth < 650) {
      return Column(
        children: cards.map((c) => Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: c,
        )).toList(),
      );
    } else if (screenWidth < 1100) {
      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.8,
        children: cards,
      );
    } else {
      return Row(
        children: cards.map((c) => Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            child: c,
          ),
        )).toList(),
      );
    }
  }

  Widget _buildSearchBar() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3E),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          const Icon(Icons.search, size: 16, color: AppColors.gray400),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                  _currentPage = 1;
                });
              },
              style: GoogleFonts.inter(fontSize: 12.5, color: Colors.white),
              decoration: const InputDecoration(
                isDense: true,
                hintText: "Search by name or ID...",
                hintStyle: TextStyle(color: AppColors.gray400, fontSize: 12),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, size: 14, color: AppColors.gray400),
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _searchQuery = "";
                });
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3E),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.filter_list, color: Colors.white70, size: 16),
          const SizedBox(width: 6),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              dropdownColor: const Color(0xFF11152D),
              value: _statusFilter,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white70, size: 18),
              style: GoogleFonts.inter(color: Colors.white, fontSize: 12),
              onChanged: (String? val) {
                if (val != null) {
                  setState(() {
                    _statusFilter = val;
                    _currentPage = 1;
                  });
                }
              },
              items: [
                DropdownMenuItem(value: "All Status", child: Text("All Status")),
                DropdownMenuItem(value: "Stable", child: Text("Stable")),
                DropdownMenuItem(value: "Warning", child: Text("Warning")),
                DropdownMenuItem(value: "Critical", child: Text("Critical")),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Expanded(flex: 4, child: Text("PATIENT NAME", style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text("ID", style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.bold))),
          Expanded(flex: 3, child: Text("AGE/GENDER", style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.bold))),
          Expanded(flex: 4, child: Text("CONTACT NUMBER", style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.bold))),
          Expanded(flex: 3, child: Text("LAST VISIT", style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.bold))),
          Expanded(flex: 3, child: Text("REGISTERED DATE", style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.person_search_outlined, color: Colors.white30, size: 48),
          const SizedBox(height: 12),
          Text(
            "No patients matched your search criteria.",
            style: GoogleFonts.inter(color: Colors.white54, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination(List<PatientRecord> filteredList, bool hasSearchOrFilter) {
    final int currentPageDisplay = hasSearchOrFilter ? 1 : _currentPage;
    final int totalPagesDisplay = hasSearchOrFilter ? 1 : 475;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          hasSearchOrFilter
              ? "Showing 1-${filteredList.length} of ${filteredList.length} patients"
              : "Showing ${(_currentPage == 475) ? 2842 : (_currentPage - 1) * 6 + 1}-${(_currentPage == 475) ? 2847 : _currentPage * 6} of 2,847 patients",
          style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 11),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Chevron Left
            _buildPageButton(
              child: const Icon(Icons.chevron_left, size: 14, color: Colors.white70),
              onTap: hasSearchOrFilter || _currentPage == 1
                  ? null
                  : () {
                      setState(() {
                        if (_currentPage == 475) {
                          _currentPage = 3;
                        } else {
                          _currentPage = math.max(1, _currentPage - 1);
                        }
                      });
                    },
            ),
            const SizedBox(width: 4),
            // Page 1
            _buildPageButton(
              label: "1",
              active: currentPageDisplay == 1,
              onTap: hasSearchOrFilter
                  ? null
                  : () => setState(() => _currentPage = 1),
            ),
            const SizedBox(width: 4),
            // Page 2
            _buildPageButton(
              label: "2",
              active: currentPageDisplay == 2,
              onTap: hasSearchOrFilter
                  ? null
                  : () => setState(() => _currentPage = 2),
            ),
            const SizedBox(width: 4),
            // Page 3
            _buildPageButton(
              label: "3",
              active: currentPageDisplay == 3,
              onTap: hasSearchOrFilter
                  ? null
                  : () => setState(() => _currentPage = 3),
            ),
            if (!hasSearchOrFilter) ...[
              const SizedBox(width: 4),
              Text("...", style: GoogleFonts.inter(color: Colors.white30, fontSize: 12)),
              const SizedBox(width: 4),
              // Page 475
              _buildPageButton(
                label: "475",
                active: currentPageDisplay == 475,
                onTap: () => setState(() => _currentPage = 475),
              ),
            ],
            const SizedBox(width: 4),
            // Chevron Right
            _buildPageButton(
              child: const Icon(Icons.chevron_right, size: 14, color: Colors.white70),
              onTap: hasSearchOrFilter || _currentPage == 475
                  ? null
                  : () {
                      setState(() {
                        if (_currentPage == 3) {
                          _currentPage = 475;
                        } else {
                          _currentPage = math.min(475, _currentPage + 1);
                        }
                      });
                    },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPageButton({
    String? label,
    Widget? child,
    bool active = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Color(0xFF1A1F3E),
          border: Border.all(
            color: active ? AppColors.primary : Colors.white.withOpacity(0.08),
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        alignment: Alignment.center,
        child: label != null
            ? Text(
                label,
                style: GoogleFonts.inter(
                  color: active ? Colors.white : Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              )
            : child,
      ),
    );
  }
}

// Singular interactive patient row
class _PatientRow extends StatefulWidget {
  final PatientRecord patient;
  final bool isRevealed;
  final VoidCallback onToggleReveal;
  final VoidCallback onTap;

  const _PatientRow({
    Key? key,
    required this.patient,
    required this.isRevealed,
    required this.onToggleReveal,
    required this.onTap,
  }) : super(key: key);

  @override
  State<_PatientRow> createState() => _PatientRowState();
}

class _PatientRowState extends State<_PatientRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    // Generate phone display based on masked vs revealed state
    final String basePhone = widget.patient.contact;
    final String displayPhone = widget.isRevealed 
        ? basePhone 
        : "${basePhone.substring(0, 8)}****";

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: _isHovered ? Colors.white.withOpacity(0.02) : Colors.transparent,
            border: const Border(
              bottom: BorderSide(color: Colors.white10, width: 0.8),
            ),
          ),
          child: Row(
            children: [
              // Patient Name
              Expanded(
                flex: 4,
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        widget.patient.initials,
                        style: GoogleFonts.inter(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.patient.name,
                        style: GoogleFonts.inter(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              // ID
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                    ),
                    child: Text(
                      widget.patient.id,
                      style: GoogleFonts.robotoMono(
                        color: const Color(0xFF8BA5FF),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              // Age/Gender
              Expanded(
                flex: 3,
                child: Text(
                  "${widget.patient.age} / ${widget.patient.gender}",
                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 11.5),
                ),
              ),
              // Contact Number
              Expanded(
                flex: 4,
                child: Row(
                  children: [
                    Text(
                      displayPhone,
                      style: GoogleFonts.robotoMono(color: Colors.white70, fontSize: 11),
                    ),
                    const SizedBox(width: 6),
                    IconButton(
                      icon: Icon(
                        widget.isRevealed ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        size: 13,
                        color: Colors.white38,
                      ),
                      onPressed: widget.onToggleReveal,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              // Last Visit
              Expanded(
                flex: 3,
                child: Text(
                  widget.patient.lastVisit,
                  style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 11.5),
                ),
              ),
              // Registered Date
              Expanded(
                flex: 3,
                child: Text(
                  widget.patient.registeredDate,
                  style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 11.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InteractiveKPICard extends StatefulWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _InteractiveKPICard({
    Key? key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  State<_InteractiveKPICard> createState() => _InteractiveKPICardState();
}

class _InteractiveKPICardState extends State<_InteractiveKPICard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()..translate(0.0, _isHovered ? -4.0 : 0.0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF11152D),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isHovered ? widget.color.withOpacity(0.3) : Colors.white.withOpacity(0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? widget.color.withOpacity(0.08)
                  : Colors.black.withOpacity(0.04),
              blurRadius: _isHovered ? 16 : 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF94A3B8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.value,
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: widget.color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                widget.icon,
                color: widget.color,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
