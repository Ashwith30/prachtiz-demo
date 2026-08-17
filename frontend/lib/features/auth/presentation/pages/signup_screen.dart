import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../shared/services/auth_service.dart';
import '../../../../shared/services/api_service.dart';
import '../../../../app/navigation/app_route_paths.dart';

class SignupScreen extends StatefulWidget {
  final UserRole role;
  const SignupScreen({super.key, required this.role});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  int _step = 0; // 0 = personal info, 1 = doctor selection (receptionist/patient)

  // Common fields
  final _firstNameCtrl  = TextEditingController();
  final _lastNameCtrl   = TextEditingController();
  final _emailCtrl      = TextEditingController();
  final _phoneCtrl      = TextEditingController();
  final _passCtrl       = TextEditingController();
  final _confirmCtrl    = TextEditingController();
  bool _obscure = true;

  // Doctor-specific fields
  final _specialtyCtrl  = TextEditingController();
  final _licenseCtrl    = TextEditingController();

  // Receptionist-specific fields
  final _empIdCtrl      = TextEditingController();
  final _deptCtrl       = TextEditingController();
  String _selectedShift = 'Morning';

  // Patient-specific fields
  String? _selectedGender;
  String? _selectedBloodGroup;
  String? _selectedInsurance;
  DateTime? _dob;
  final _allergiesCtrl  = TextEditingController();

  // Doctor search (for receptionist + patient)
  String? _selectedDoctorId;
  String? _selectedDoctorName;
  String? _selectedSpecialtyFilter = 'All';
  List<Map<String, dynamic>> _doctors = [];
  List<String> _specialties = ['All'];
  bool _loadingDoctors = false;

  late _RoleStyle _style;

  @override
  void initState() {
    super.initState();
    _style = _RoleStyle.of(widget.role);
    if (widget.role != UserRole.doctor) _fetchSpecialties();
  }

  @override
  void dispose() {
    for (final c in [_firstNameCtrl, _lastNameCtrl, _emailCtrl, _phoneCtrl,
        _passCtrl, _confirmCtrl, _specialtyCtrl, _licenseCtrl,
        _empIdCtrl, _deptCtrl, _allergiesCtrl]) { c.dispose(); }
    super.dispose();
  }

  Future<void> _fetchSpecialties() async {
    try {
      final data = await ApiService.instance.get('/public/specialties');
      setState(() {
        _specialties = ['All', ...(data as List).map((s) => s.toString())];
      });
    } catch (_) {}
  }

  Future<void> _fetchDoctors(String specialty) async {
    setState(() => _loadingDoctors = true);
    try {
      final suffix = (specialty == 'All') ? '' : '?specialty=${Uri.encodeComponent(specialty)}';
      final data = await ApiService.instance.get('/public/doctors$suffix');
      setState(() {
        _doctors = (data as List).map((d) => d as Map<String, dynamic>).toList();
        _loadingDoctors = false;
      });
    } catch (_) {
      setState(() => _loadingDoctors = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (widget.role != UserRole.doctor && _selectedDoctorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a doctor first')),
      );
      return;
    }

    final auth = AuthService.instance;
    Map<String, dynamic> payload = {
      'first_name': _firstNameCtrl.text.trim(),
      'last_name':  _lastNameCtrl.text.trim(),
      'email':      _emailCtrl.text.trim(),
      'password':   _passCtrl.text.trim(),
      'phone':      _phoneCtrl.text.trim(),
    };

    switch (widget.role) {
      case UserRole.doctor:
        payload['specialty'] = _specialtyCtrl.text.trim();
        payload['license']   = _licenseCtrl.text.trim();
        break;
      case UserRole.receptionist:
        payload['employee_id'] = _empIdCtrl.text.trim();
        payload['department']  = _deptCtrl.text.trim();
        payload['shift']       = _selectedShift;
        payload['doctor_id']   = _selectedDoctorId;
        break;
      case UserRole.patient:
        payload['dob']               = _dob?.toIso8601String().split('T')[0];
        payload['gender']            = _selectedGender;
        payload['blood_group']       = _selectedBloodGroup;
        payload['allergies']         = _allergiesCtrl.text.trim().isNotEmpty
            ? _allergiesCtrl.text.trim().split(',').map((s) => s.trim()).toList()
            : [];
        payload['insurance_partner'] = _selectedInsurance;
        payload['doctor_id']         = _selectedDoctorId;
        break;
    }

    final ok = await auth.signup(widget.role, payload);
    if (!mounted) return;
    if (ok) {
      switch (widget.role) {
        case UserRole.doctor:       context.go(AppRoutePaths.dashboard); break;
        case UserRole.receptionist: context.go(AppRoutePaths.receptionistDashboard); break;
        case UserRole.patient:      context.go(AppRoutePaths.patientHome); break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080D1F),
      body: Stack(
        children: [
          Positioned(
            top: -80, right: -80,
            child: Container(
              width: 400, height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [_style.color.withOpacity(0.1), Colors.transparent]),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back button
                      GestureDetector(
                        onTap: () => context.go(AppRoutePaths.loginPath(widget.role.name)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.arrow_back_rounded, size: 18, color: Colors.white.withOpacity(0.5)),
                            const SizedBox(width: 6),
                            Text('Back to Login', style: GoogleFonts.inter(fontSize: 13, color: Colors.white.withOpacity(0.5))),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Header
                      _buildHeader(),
                      const SizedBox(height: 32),

                      // Form
                      ListenableBuilder(
                        listenable: AuthService.instance,
                        builder: (context, _) {
                          final auth = AuthService.instance;
                          return Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ── Step 0: Personal Info ─────────────────
                                _buildSection('Personal Information', [
                                  Row(children: [
                                    Expanded(child: _buildField(_firstNameCtrl, 'First Name', Icons.person_outline,
                                      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null)),
                                    const SizedBox(width: 12),
                                    Expanded(child: _buildField(_lastNameCtrl, 'Last Name', Icons.person_outline,
                                      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null)),
                                  ]),
                                  _buildField(_emailCtrl, 'Email Address', Icons.email_outlined,
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (v) => (v == null || !v.contains('@')) ? 'Valid email required' : null),
                                  _buildField(_phoneCtrl, 'Phone Number', Icons.phone_outlined,
                                    keyboardType: TextInputType.phone),
                                  _buildField(_passCtrl, 'Password', Icons.lock_outline_rounded,
                                    obscure: _obscure,
                                    suffixIcon: IconButton(
                                      icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18, color: Colors.white38),
                                      onPressed: () => setState(() => _obscure = !_obscure),
                                    ),
                                    validator: (v) => (v == null || v.length < 6) ? 'Min 6 characters' : null),
                                  _buildField(_confirmCtrl, 'Confirm Password', Icons.lock_outline_rounded,
                                    obscure: true,
                                    validator: (v) => v != _passCtrl.text ? 'Passwords do not match' : null),
                                ]),

                                // ── Role-specific fields ───────────────────
                                if (widget.role == UserRole.doctor) ...[
                                  const SizedBox(height: 24),
                                  _buildSection('Professional Details', [
                                    _buildField(_specialtyCtrl, 'Specialty (e.g. Cardiologist)', Icons.medical_information_outlined),
                                    _buildField(_licenseCtrl, 'Medical License Number', Icons.badge_outlined),
                                  ]),
                                ],

                                if (widget.role == UserRole.receptionist) ...[
                                  const SizedBox(height: 24),
                                  _buildSection('Work Details', [
                                    _buildField(_empIdCtrl, 'Employee ID', Icons.badge_outlined),
                                    _buildField(_deptCtrl, 'Department', Icons.business_outlined),
                                    _buildDropdown('Shift', _selectedShift, ['Morning', 'Afternoon', 'Evening'],
                                      onChanged: (v) => setState(() => _selectedShift = v!)),
                                  ]),
                                ],

                                if (widget.role == UserRole.patient) ...[
                                  const SizedBox(height: 24),
                                  _buildSection('Medical Profile', [
                                    _buildDropdown('Gender', _selectedGender, ['Male', 'Female', 'Other'],
                                      onChanged: (v) => setState(() => _selectedGender = v), placeholder: 'Select gender'),
                                    _buildDropdown('Blood Group', _selectedBloodGroup,
                                      ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'],
                                      onChanged: (v) => setState(() => _selectedBloodGroup = v), placeholder: 'Select blood group'),
                                    _buildDropdown('Insurance Partner', _selectedInsurance,
                                      ['Self-Pay', 'CH', 'HDFC', 'SBI', 'CircleBlue'],
                                      onChanged: (v) => setState(() => _selectedInsurance = v == 'Self-Pay' ? null : v),
                                      placeholder: 'Select insurer'),
                                    _buildField(_allergiesCtrl, 'Known Allergies (comma-separated)', Icons.warning_amber_outlined),
                                    _buildDatePicker(context),
                                  ]),
                                ],

                                // ── Doctor selection (receptionist + patient) ──
                                if (widget.role != UserRole.doctor) ...[
                                  const SizedBox(height: 24),
                                  _buildDoctorSelector(),
                                ],

                                // Error
                                if (auth.error != null) ...[
                                  const SizedBox(height: 12),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                                    ),
                                    child: Text(auth.error!, style: GoogleFonts.inter(fontSize: 13, color: Colors.red.shade300)),
                                  ),
                                ],
                                const SizedBox(height: 24),

                                // Submit button
                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed: auth.loading ? null : _submit,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _style.color,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    child: auth.loading
                                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                        : Text('Create Account', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700)),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ).animate().fadeIn(duration: 400.ms),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _style.color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _style.color.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_style.icon, size: 14, color: _style.color),
              const SizedBox(width: 6),
              Text(_style.label.toUpperCase(),
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: _style.color, letterSpacing: 1)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text('Create your account', style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white)),
        const SizedBox(height: 4),
        Text('Set up your ${_style.label.toLowerCase()} profile to get started',
          style: GoogleFonts.inter(fontSize: 13, color: Colors.white.withOpacity(0.45))),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.5), letterSpacing: 0.5)),
        const SizedBox(height: 12),
        ...children.map((w) => Padding(padding: const EdgeInsets.only(bottom: 12), child: w)),
      ],
    );
  }

  Widget _buildField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    bool obscure = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.inter(fontSize: 14, color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(fontSize: 13, color: Colors.white38),
        prefixIcon: Icon(icon, size: 18, color: Colors.white38),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFF0E1535),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.08))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.08))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _style.color, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red)),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String? value,
    List<String> items, {
    required ValueChanged<String?> onChanged,
    String? placeholder,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      hint: Text(placeholder ?? 'Select', style: GoogleFonts.inter(fontSize: 13, color: Colors.white38)),
      dropdownColor: const Color(0xFF0E1535),
      style: GoogleFonts.inter(fontSize: 14, color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(fontSize: 13, color: Colors.white38),
        filled: true,
        fillColor: const Color(0xFF0E1535),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.08))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.08))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _style.color, width: 1.5)),
      ),
      items: items.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime(1990, 1, 1),
          firstDate: DateTime(1920),
          lastDate: DateTime.now(),
          builder: (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(colorScheme: ColorScheme.dark(primary: _style.color)),
            child: child!,
          ),
        );
        if (picked != null) setState(() => _dob = picked);
      },
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF0E1535),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined, size: 18, color: Colors.white38),
            const SizedBox(width: 12),
            Text(
              _dob != null ? '${_dob!.day}/${_dob!.month}/${_dob!.year}' : 'Date of Birth',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: _dob != null ? Colors.white : Colors.white38,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Your Doctor',
          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.5), letterSpacing: 0.5)),
        const SizedBox(height: 12),

        // Specialty filter
        DropdownButtonFormField<String>(
          value: _selectedSpecialtyFilter,
          dropdownColor: const Color(0xFF0E1535),
          style: GoogleFonts.inter(fontSize: 14, color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Filter by Specialty',
            labelStyle: GoogleFonts.inter(fontSize: 13, color: Colors.white38),
            prefixIcon: const Icon(Icons.filter_list_rounded, size: 18, color: Colors.white38),
            filled: true,
            fillColor: const Color(0xFF0E1535),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.08))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.08))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _style.color, width: 1.5)),
          ),
          items: _specialties.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
          onChanged: (v) {
            setState(() => _selectedSpecialtyFilter = v);
            _fetchDoctors(v ?? 'All');
          },
        ),
        const SizedBox(height: 12),

        // Doctor list
        if (_loadingDoctors)
          const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()))
        else if (_doctors.isEmpty && _selectedSpecialtyFilter != 'All')
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0E1535),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Text('No doctors found. Try a different specialty.',
              style: GoogleFonts.inter(fontSize: 13, color: Colors.white38)),
          )
        else if (_doctors.isNotEmpty)
          ...(_doctors.map((doc) {
            final isSelected = _selectedDoctorId == doc['id'];
            return GestureDetector(
              onTap: () => setState(() {
                _selectedDoctorId = doc['id'];
                _selectedDoctorName = 'Dr. ${doc['first_name']} ${doc['last_name']}';
              }),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSelected ? _style.color.withOpacity(0.12) : const Color(0xFF0E1535),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? _style.color : Colors.white.withOpacity(0.08),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: _style.color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          '${doc['first_name'][0]}${doc['last_name'][0]}'.toUpperCase(),
                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: _style.color),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Dr. ${doc['first_name']} ${doc['last_name']}',
                            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                          if (doc['specialty'] != null)
                            Text(doc['specialty'],
                              style: GoogleFonts.inter(fontSize: 12, color: Colors.white38)),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(Icons.check_circle_rounded, color: _style.color, size: 20),
                  ],
                ),
              ),
            );
          })),

        if (_selectedDoctorId != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                Icon(Icons.check_circle_outline, color: _style.color, size: 14),
                const SizedBox(width: 6),
                Text('Selected: $_selectedDoctorName',
                  style: GoogleFonts.inter(fontSize: 12, color: _style.color, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
      ],
    );
  }
}

class _RoleStyle {
  final Color color;
  final IconData icon;
  final String label;

  const _RoleStyle({required this.color, required this.icon, required this.label});

  static _RoleStyle of(UserRole role) {
    switch (role) {
      case UserRole.doctor:       return const _RoleStyle(color: Color(0xFF3F8CFF), icon: Icons.medical_services_outlined, label: 'Doctor');
      case UserRole.receptionist: return const _RoleStyle(color: Color(0xFF24C06F), icon: Icons.support_agent_outlined, label: 'Receptionist');
      case UserRole.patient:      return const _RoleStyle(color: Color(0xFF8B5CF6), icon: Icons.person_outlined, label: 'Patient');
    }
  }
}
