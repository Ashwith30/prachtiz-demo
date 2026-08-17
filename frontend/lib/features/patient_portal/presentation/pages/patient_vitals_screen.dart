import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../shared/services/api_service.dart';

class PatientVitalsScreen extends StatefulWidget {
  const PatientVitalsScreen({super.key});
  @override
  State<PatientVitalsScreen> createState() => _PatientVitalsScreenState();
}

class _PatientVitalsScreenState extends State<PatientVitalsScreen> {
  List<dynamic> _vitals = [];
  bool _loading = true;
  static const Color _accent = Color(0xFFEF4444);

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService.instance.get('/patient/vitals');
      setState(() { _vitals = data as List; _loading = false; });
    } catch (_) { setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    final latest = _vitals.isNotEmpty ? _vitals.first as Map<String, dynamic> : null;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Latest reading summary
                if (latest != null) ...[
                  Text('Latest Readings',
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                  const SizedBox(height: 12),
                  _buildLatestVitals(latest).animate().fadeIn(duration: 400.ms),
                  const SizedBox(height: 24),
                ],

                Text('Vitals History',
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 12),

                if (_vitals.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0E1535),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.06)),
                    ),
                    child: Center(
                      child: Column(children: [
                        Icon(Icons.monitor_heart_outlined, size: 48, color: Colors.white.withOpacity(0.15)),
                        const SizedBox(height: 12),
                        Text('No vitals recorded yet', style: GoogleFonts.inter(fontSize: 14, color: Colors.white38)),
                        const SizedBox(height: 8),
                        Text('Your doctor will record your vitals during appointments',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(fontSize: 12, color: Colors.white24)),
                      ]),
                    ),
                  )
                else
                  ..._vitals.asMap().entries.map((e) => _buildVitalRow(e.value, e.key)),
              ]),
            ),
    );
  }

  Widget _buildLatestVitals(Map<String, dynamic> v) {
    final cards = [
      _VitalCard('Heart Rate', '${v['heart_rate'] ?? '--'}', 'bpm', Icons.favorite_outline_rounded, const Color(0xFFEF4444)),
      _VitalCard('Blood Pressure', v['blood_pressure'] ?? '--', 'mmHg', Icons.water_drop_outlined, const Color(0xFF3F8CFF)),
      _VitalCard('Temperature', '${v['temperature'] ?? '--'}', '°C', Icons.thermostat_outlined, const Color(0xFFF59E0B)),
      _VitalCard('SpO₂', '${v['spo2'] ?? '--'}', '%', Icons.air_outlined, const Color(0xFF24C06F)),
    ];
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: cards.map((c) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.color.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(c.icon, color: c.color, size: 28),
            const SizedBox(height: 8),
            RichText(text: TextSpan(
              text: c.value,
              style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white),
              children: [TextSpan(
                text: ' ${c.unit}',
                style: GoogleFonts.inter(fontSize: 12, color: Colors.white38, fontWeight: FontWeight.w400),
              )],
            )),
            const SizedBox(height: 4),
            Text(c.label, style: GoogleFonts.inter(fontSize: 12, color: Colors.white38)),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildVitalRow(Map<String, dynamic> v, int i) {
    final recorded = v['recorded_at']?.toString().split('T')[0] ?? '';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1535),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: _accent.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.monitor_heart_outlined, color: _accent, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Wrap(spacing: 16, runSpacing: 4, children: [
            _miniStat('HR', '${v['heart_rate'] ?? '--'} bpm'),
            _miniStat('BP', v['blood_pressure'] ?? '--'),
            _miniStat('Temp', '${v['temperature'] ?? '--'}°C'),
            _miniStat('SpO₂', '${v['spo2'] ?? '--'}%'),
          ]),
        ),
        Text(recorded, style: GoogleFonts.inter(fontSize: 11, color: Colors.white24)),
      ]),
    ).animate(delay: Duration(milliseconds: 50 * i)).fadeIn();
  }

  Widget _miniStat(String label, String value) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.inter(fontSize: 10, color: Colors.white38)),
      Text(value, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
    ]);
  }
}

class _VitalCard {
  final String label, value, unit;
  final IconData icon;
  final Color color;
  const _VitalCard(this.label, this.value, this.unit, this.icon, this.color);
}
