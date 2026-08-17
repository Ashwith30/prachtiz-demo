import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../shared/services/api_service.dart';

class PatientPrescriptionsScreen extends StatefulWidget {
  const PatientPrescriptionsScreen({super.key});
  @override
  State<PatientPrescriptionsScreen> createState() => _PatientPrescriptionsScreenState();
}

class _PatientPrescriptionsScreenState extends State<PatientPrescriptionsScreen> {
  List<dynamic> _prescriptions = [];
  bool _loading = true;
  static const Color _accent = Color(0xFF3F8CFF);

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService.instance.get('/patient/prescriptions');
      setState(() { _prescriptions = data as List; _loading = false; });
    } catch (_) { setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _prescriptions.isEmpty
              ? _buildEmpty()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _prescriptions.length,
                  itemBuilder: (_, i) => _buildCard(_prescriptions[i], i),
                ),
    );
  }

  Widget _buildCard(Map<String, dynamic> rx, int i) {
    final meds = (rx['medications'] ?? []) as List;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1535),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: _accent.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.medication_outlined, color: _accent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Dr. ${rx['doctor_name'] ?? 'Unknown'}',
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
            Text('${rx['date'] ?? ''} · ${meds.length} medication(s)',
              style: GoogleFonts.inter(fontSize: 12, color: Colors.white38)),
          ])),
        ]),
        if (meds.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Divider(color: Colors.white12),
          const SizedBox(height: 8),
          ...meds.map((m) {
            if (m is Map) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(children: [
                  const Icon(Icons.circle, size: 6, color: Color(0xFF3F8CFF)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(
                    '${m['name'] ?? 'Medicine'} — ${m['dose'] ?? ''} ${m['frequency'] ?? ''}',
                    style: GoogleFonts.inter(fontSize: 13, color: Colors.white.withOpacity(0.8)),
                  )),
                ]),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
        if (rx['notes'] != null) ...[
          const SizedBox(height: 8),
          Text('Note: ${rx['notes']}', style: GoogleFonts.inter(fontSize: 12, color: Colors.white38, fontStyle: FontStyle.italic)),
        ],
      ]),
    ).animate(delay: Duration(milliseconds: 60 * i)).fadeIn(duration: 300.ms);
  }

  Widget _buildEmpty() => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Icon(Icons.medication_outlined, size: 48, color: Colors.white.withOpacity(0.15)),
    const SizedBox(height: 12),
    Text('No prescriptions yet', style: GoogleFonts.inter(fontSize: 14, color: Colors.white38)),
  ]));
}
