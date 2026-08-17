import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/services/auth_service.dart';
import '../../../../shared/services/api_service.dart';
import '../../../../app/navigation/app_route_paths.dart';

class ReceptionistDashboardScreen extends StatefulWidget {
  const ReceptionistDashboardScreen({super.key});
  @override
  State<ReceptionistDashboardScreen> createState() => _ReceptionistDashboardScreenState();
}

class _ReceptionistDashboardScreenState extends State<ReceptionistDashboardScreen> {
  List<dynamic> _appointments = [];
  bool _loading = true;
  String? _error;

  static const Color _accent = Color(0xFF24C06F);

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await ApiService.instance.get('/receptionist/appointments');
      setState(() { _appointments = data as List; _loading = false; });
    } on ApiException catch (e) {
      setState(() { _error = e.message; _loading = false; });
    } catch (_) {
      setState(() { _error = 'Failed to load appointments'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthService.instance;
    final total = _appointments.length;
    final confirmed = _appointments.where((a) => a['status'] == 'confirmed').length;
    final pending = _appointments.where((a) => a['status'] == 'pending').length;
    final inProgress = _appointments.where((a) => a['status'] == 'inProgress').length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        onRefresh: _loadAppointments,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0D2A1B), Color(0xFF0A1F15)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _accent.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Good morning, ${auth.session?.firstName ?? 'Receptionist'}!',
                            style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
                          const SizedBox(height: 4),
                          Text('Here\'s today\'s appointment summary',
                            style: GoogleFonts.inter(fontSize: 13, color: Colors.white.withOpacity(0.5))),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => context.go(AppRoutePaths.receptionistPatients),
                      icon: const Icon(Icons.person_add_outlined, size: 16),
                      label: Text('Register Patient', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accent, foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms),
              const SizedBox(height: 20),

              // Stat cards
              _buildStatsRow(total, confirmed, pending, inProgress).animate().fadeIn(delay: 150.ms),
              const SizedBox(height: 24),

              // Today's appointments
              Row(
                children: [
                  Text("Today's Appointments",
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _loadAppointments,
                    icon: const Icon(Icons.refresh_rounded, size: 16, color: Color(0xFF24C06F)),
                    label: Text('Refresh', style: GoogleFonts.inter(fontSize: 12, color: Color(0xFF24C06F))),
                  ),
                ],
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 12),

              if (_loading) const Center(child: CircularProgressIndicator())
              else if (_error != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Text(_error!, style: GoogleFonts.inter(fontSize: 13, color: Colors.red.shade300)),
                )
              else if (_appointments.isEmpty)
                _buildEmptyState()
              else
                ..._appointments.asMap().entries.map((e) =>
                  _buildAppointmentCard(e.value, e.key)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(int total, int confirmed, int pending, int inProgress) {
    return LayoutBuilder(builder: (ctx, constraints) {
      final isWide = constraints.maxWidth > 600;
      final cards = [
        _StatCard(label: 'Total Today', value: '$total', icon: Icons.calendar_today_outlined, color: _accent),
        _StatCard(label: 'Confirmed', value: '$confirmed', icon: Icons.check_circle_outline, color: const Color(0xFF3F8CFF)),
        _StatCard(label: 'Pending', value: '$pending', icon: Icons.hourglass_empty_rounded, color: const Color(0xFFF59E0B)),
        _StatCard(label: 'In Progress', value: '$inProgress', icon: Icons.play_circle_outline, color: const Color(0xFFEF4444)),
      ];
      if (isWide) {
        return Row(children: cards.map((c) => Expanded(child: Padding(
          padding: const EdgeInsets.only(right: 12), child: _buildStatCard(c)))).toList());
      }
      return Column(children: [
        Row(children: [
          Expanded(child: _buildStatCard(cards[0])), const SizedBox(width: 12),
          Expanded(child: _buildStatCard(cards[1])),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _buildStatCard(cards[2])), const SizedBox(width: 12),
          Expanded(child: _buildStatCard(cards[3])),
        ]),
      ]);
    });
  }

  Widget _buildStatCard(_StatCard c) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1226),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: c.color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
            child: Icon(c.icon, color: c.color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(c.value, style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
              Text(c.label, style: GoogleFonts.inter(fontSize: 11, color: Colors.white38)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appt, int index) {
    final status = appt['status'] ?? 'pending';
    final statusColors = {
      'confirmed': const Color(0xFF3F8CFF),
      'pending': const Color(0xFFF59E0B),
      'inProgress': const Color(0xFF24C06F),
      'completed': Colors.white38,
      'cancelled': const Color(0xFFEF4444),
    };
    final statusColor = statusColors[status] ?? Colors.white38;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1226),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: _accent.withOpacity(0.12),
            child: Text(
              (appt['patient_name'] ?? 'P').split(' ').take(2).map((p) => p[0]).join().toUpperCase(),
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: _accent),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(appt['patient_name'] ?? 'Unknown',
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
              Text('${appt['time'] ?? ''} · ${appt['type'] ?? 'Consultation'}',
                style: GoogleFonts.inter(fontSize: 12, color: Colors.white38)),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusColor.withOpacity(0.3)),
            ),
            child: Text(status,
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor)),
          ),
          const SizedBox(width: 8),
          if (status == 'confirmed' || status == 'pending')
            IconButton(
              icon: Icon(Icons.login_rounded, color: _accent, size: 20),
              onPressed: () async {
                try {
                  await ApiService.instance.patch('/receptionist/appointments/${appt['id']}/checkin', {});
                  _loadAppointments();
                } catch (_) {}
              },
              tooltip: 'Check In',
              padding: EdgeInsets.zero, constraints: const BoxConstraints(),
            ),
        ],
      ),
    ).animate(delay: Duration(milliseconds: 50 * index)).fadeIn(duration: 300.ms);
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1226),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Center(
        child: Column(children: [
          Icon(Icons.event_available_outlined, size: 48, color: _accent.withOpacity(0.4)),
          const SizedBox(height: 12),
          Text('No appointments today', style: GoogleFonts.inter(fontSize: 14, color: Colors.white38)),
        ]),
      ),
    );
  }
}

class _StatCard {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});
}
