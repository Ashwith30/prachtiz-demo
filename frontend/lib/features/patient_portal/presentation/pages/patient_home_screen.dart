import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../shared/services/auth_service.dart';
import '../../../../shared/services/api_service.dart';
import '../../../../app/navigation/app_route_paths.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});
  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  Map<String, dynamic>? _profile;
  List<dynamic> _upcomingAppts = [];
  bool _loading = true;

  static const Color _accent = Color(0xFF8B5CF6);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final profile = await ApiService.instance.get('/patient/profile');
      final appts   = await ApiService.instance.get('/patient/appointments');
      setState(() {
        _profile = profile as Map<String, dynamic>;
        final all = appts as List;
        final now = DateTime.now().toIso8601String().split('T')[0];
        _upcomingAppts = all.where((a) {
          final dateStr = (a['date'] ?? '').toString().split('T')[0];
          return dateStr.compareTo(now) >= 0 && a['status'] != 'cancelled';
        }).take(3).toList();
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthService.instance;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_accent.withOpacity(0.15), _accent.withOpacity(0.05)],
                          begin: Alignment.topLeft, end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _accent.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: _accent.withOpacity(0.2),
                            child: Text(auth.session?.initials ?? 'P',
                              style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: _accent)),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('Welcome back,', style: GoogleFonts.inter(fontSize: 13, color: Colors.white.withOpacity(0.5))),
                              Text(auth.session?.fullName ?? 'Patient',
                                style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                              if (_profile?['condition'] != null)
                                Text(_profile!['condition'], style: GoogleFonts.inter(fontSize: 12, color: _accent)),
                            ]),
                          ),
                          if (_profile?['insurance_partner'] != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.white.withOpacity(0.12)),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(_profile!['insurance_partner'],
                                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
                                  Text('Insured', style: GoogleFonts.inter(fontSize: 9, color: Colors.white38)),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 400.ms),
                    const SizedBox(height: 20),

                    // Quick actions
                    Row(
                      children: [
                        Expanded(child: _quickAction(
                          Icons.add_circle_outline_rounded, 'Book Appointment', _accent,
                          () => context.go(AppRoutePaths.patientAppointments),
                        )),
                        const SizedBox(width: 12),
                        Expanded(child: _quickAction(
                          Icons.medication_outlined, 'Prescriptions', const Color(0xFF3F8CFF),
                          () => context.go(AppRoutePaths.patientPrescriptions),
                        )),
                        const SizedBox(width: 12),
                        Expanded(child: _quickAction(
                          Icons.biotech_outlined, 'Lab Results', const Color(0xFF24C06F),
                          () => context.go(AppRoutePaths.patientLabResults),
                        )),
                      ],
                    ).animate().fadeIn(delay: 150.ms),
                    const SizedBox(height: 24),

                    // Profile summary
                    if (_profile != null) ...[
                      Text('Health Profile',
                        style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                      const SizedBox(height: 12),
                      _buildProfileCard(_profile!).animate().fadeIn(delay: 200.ms),
                      const SizedBox(height: 24),
                    ],

                    // Upcoming appointments
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Upcoming Appointments',
                          style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                        GestureDetector(
                          onTap: () => context.go(AppRoutePaths.patientAppointments),
                          child: Text('View All',
                            style: GoogleFonts.inter(fontSize: 12, color: _accent, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ).animate().fadeIn(delay: 250.ms),
                    const SizedBox(height: 12),

                    if (_upcomingAppts.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0E1535),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.06)),
                        ),
                        child: Row(children: [
                          Icon(Icons.event_available_outlined, size: 20, color: _accent.withOpacity(0.5)),
                          const SizedBox(width: 12),
                          Text('No upcoming appointments', style: GoogleFonts.inter(fontSize: 13, color: Colors.white38)),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => context.go(AppRoutePaths.patientAppointments),
                            child: Text('Book now →',
                              style: GoogleFonts.inter(fontSize: 12, color: _accent, fontWeight: FontWeight.w600)),
                          ),
                        ]),
                      ).animate().fadeIn(delay: 300.ms)
                    else
                      ..._upcomingAppts.asMap().entries.map((e) =>
                        _buildApptCard(e.value, e.key)),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _quickAction(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white, height: 1.3)),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(Map<String, dynamic> profile) {
    final fields = [
      ['Blood Group', profile['blood_group'] ?? '—'],
      ['Gender', profile['gender'] ?? '—'],
      ['Insurance', profile['insurance_partner'] ?? 'Self-Pay'],
      ['DOB', profile['dob']?.toString().split('T')[0] ?? '—'],
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1535),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Wrap(
        spacing: 24, runSpacing: 12,
        children: fields.map((f) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(f[0], style: GoogleFonts.inter(fontSize: 11, color: Colors.white38)),
            const SizedBox(height: 2),
            Text(f[1], style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
          ],
        )).toList(),
      ),
    );
  }

  Widget _buildApptCard(Map<String, dynamic> appt, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1535),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: _accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.calendar_today_outlined, color: _accent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Dr. ${appt['doctor_name'] ?? 'Unknown'}',
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
              Text('${appt['date']} at ${appt['time']} · ${appt['type'] ?? 'Consultation'}',
                style: GoogleFonts.inter(fontSize: 12, color: Colors.white38)),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF3F8CFF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF3F8CFF).withOpacity(0.3)),
            ),
            child: Text(appt['status'] ?? '',
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF3F8CFF))),
          ),
        ],
      ),
    ).animate(delay: Duration(milliseconds: 300 + 80 * index)).fadeIn();
  }
}
