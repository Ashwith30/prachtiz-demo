import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../shared/services/api_service.dart';

class PatientLabResultsScreen extends StatefulWidget {
  const PatientLabResultsScreen({super.key});
  @override
  State<PatientLabResultsScreen> createState() => _PatientLabResultsScreenState();
}

class _PatientLabResultsScreenState extends State<PatientLabResultsScreen> {
  List<dynamic> _results = [];
  bool _loading = true;
  static const Color _accent = Color(0xFF24C06F);

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService.instance.get('/patient/lab-results');
      setState(() { _results = data as List; _loading = false; });
    } catch (_) { setState(() => _loading = false); }
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'ready':    return const Color(0xFF24C06F);
      case 'reviewed': return const Color(0xFF3F8CFF);
      case 'pending':  return const Color(0xFFF59E0B);
      default:         return Colors.white38;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _results.isEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.biotech_outlined, size: 48, color: Colors.white.withOpacity(0.15)),
                  const SizedBox(height: 12),
                  Text('No lab results available', style: GoogleFonts.inter(fontSize: 14, color: Colors.white38)),
                ]))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _results.length,
                  itemBuilder: (_, i) {
                    final r = _results[i] as Map<String, dynamic>;
                    final status = r['status'] as String?;
                    final sc = _statusColor(status);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0E1535),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white.withOpacity(0.06)),
                      ),
                      child: Row(children: [
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(color: _accent.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.biotech_outlined, color: _accent, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(r['test_name'] ?? 'Lab Test',
                            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                          Text('Dr. ${r['doctor_name'] ?? 'Unknown'} · ${r['date'] ?? ''}',
                            style: GoogleFonts.inter(fontSize: 12, color: Colors.white38)),
                          if (r['result'] != null) ...[
                            const SizedBox(height: 4),
                            Text('Result: ${r['result']}', style: GoogleFonts.inter(fontSize: 12, color: Colors.white70)),
                          ],
                        ])),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: sc.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: sc.withOpacity(0.3)),
                          ),
                          child: Text(status ?? 'pending',
                            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: sc)),
                        ),
                      ]),
                    ).animate(delay: Duration(milliseconds: 60 * i)).fadeIn();
                  },
                ),
    );
  }
}
