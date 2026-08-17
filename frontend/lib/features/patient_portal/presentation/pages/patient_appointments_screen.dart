import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../shared/services/api_service.dart';

class PatientAppointmentsScreen extends StatefulWidget {
  const PatientAppointmentsScreen({super.key});
  @override
  State<PatientAppointmentsScreen> createState() => _PatientAppointmentsScreenState();
}

class _PatientAppointmentsScreenState extends State<PatientAppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _appointments = [];
  List<dynamic> _doctors = [];
  bool _loading = true;
  bool _showBookingForm = false;

  static const Color _accent = Color(0xFF8B5CF6);

  // Booking form state
  String? _selectedDoctorId;
  String? _selectedDate;
  String? _selectedTime;
  String _selectedType = 'Consultation';
  final _symptomsCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _symptomsCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final appts   = await ApiService.instance.get('/patient/appointments');
      final doctors = await ApiService.instance.get('/patient/doctors');
      setState(() {
        _appointments = appts as List;
        _doctors = doctors as List;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _bookAppointment() async {
    if (_selectedDoctorId == null || _selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }
    try {
      await ApiService.instance.post('/patient/appointments', {
        'doctor_id': _selectedDoctorId,
        'date': _selectedDate,
        'time': _selectedTime,
        'type': _selectedType,
        'symptoms': _symptomsCtrl.text.trim(),
      });
      setState(() => _showBookingForm = false);
      _symptomsCtrl.clear();
      _selectedDoctorId = null;
      _selectedDate = null;
      _selectedTime = null;
      _load();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Appointment booked!')),
      );
    } on ApiException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.message}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now().toIso8601String().split('T')[0];
    final upcoming = _appointments.where((a) {
      final dateStr = (a['date'] ?? '').toString().split('T')[0];
      return dateStr.compareTo(now) >= 0 && a['status'] != 'cancelled';
    }).toList();
    final past     = _appointments.where((a) {
      final dateStr = (a['date'] ?? '').toString().split('T')[0];
      return dateStr.compareTo(now) < 0 || a['status'] == 'cancelled';
    }).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => setState(() => _showBookingForm = !_showBookingForm),
        backgroundColor: _accent,
        icon: Icon(_showBookingForm ? Icons.close : Icons.add),
        label: Text(_showBookingForm ? 'Cancel' : 'Book Appointment',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Booking form panel
                if (_showBookingForm)
                  _buildBookingForm().animate().fadeIn(duration: 300.ms).slideY(begin: -0.1),

                // Tab bar
                Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0E1535),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.06)),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white38,
                    labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
                    unselectedLabelStyle: GoogleFonts.inter(fontSize: 13),
                    indicator: BoxDecoration(
                      color: _accent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _accent.withOpacity(0.4)),
                    ),
                    indicatorPadding: const EdgeInsets.all(4),
                    tabs: [
                      Tab(text: 'Upcoming (${upcoming.length})'),
                      Tab(text: 'Past (${past.length})'),
                    ],
                  ),
                ),

                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildApptList(upcoming, showCancel: true),
                      _buildApptList(past),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildBookingForm() {
    final times = ['09:00','09:30','10:00','10:30','11:00','11:30',
                   '12:00','13:00','13:30','14:00','14:30','15:00','15:30','16:00'];
    final types = ['Consultation', 'Follow-up', 'Check-up', 'Telehealth', 'Emergency'];

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1535),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _accent.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Book New Appointment',
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 16),

          // Doctor picker
          DropdownButtonFormField<String>(
            value: _selectedDoctorId,
            hint: Text('Select Doctor', style: GoogleFonts.inter(fontSize: 13, color: Colors.white38)),
            dropdownColor: const Color(0xFF0E1535),
            style: GoogleFonts.inter(fontSize: 14, color: Colors.white),
            decoration: _inputDecoration('Doctor'),
            items: _doctors.map((d) => DropdownMenuItem(
              value: d['id'].toString(),
              child: Text('Dr. ${d['first_name']} ${d['last_name']} · ${d['specialty'] ?? ''}'),
            )).toList(),
            onChanged: (v) => setState(() => _selectedDoctorId = v),
          ),
          const SizedBox(height: 12),

          Row(children: [
            Expanded(child: GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 1)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 90)),
                  builder: (ctx, child) => Theme(
                    data: Theme.of(ctx).copyWith(colorScheme: const ColorScheme.dark(primary: _accent)),
                    child: child!,
                  ),
                );
                if (picked != null) setState(() => _selectedDate = picked.toIso8601String().split('T')[0]);
              },
              child: Container(
                height: 52, padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B1226),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: Row(children: [
                  const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.white38),
                  const SizedBox(width: 8),
                  Text(_selectedDate ?? 'Select Date',
                    style: GoogleFonts.inter(fontSize: 13, color: _selectedDate != null ? Colors.white : Colors.white38)),
                ]),
              ),
            )),
            const SizedBox(width: 12),
            Expanded(child: DropdownButtonFormField<String>(
              value: _selectedTime,
              hint: Text('Time', style: GoogleFonts.inter(fontSize: 13, color: Colors.white38)),
              dropdownColor: const Color(0xFF0E1535),
              style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
              decoration: _inputDecoration('Time'),
              items: times.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (v) => setState(() => _selectedTime = v),
            )),
          ]),
          const SizedBox(height: 12),

          DropdownButtonFormField<String>(
            value: _selectedType,
            dropdownColor: const Color(0xFF0E1535),
            style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
            decoration: _inputDecoration('Appointment Type'),
            items: types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
            onChanged: (v) => setState(() => _selectedType = v!),
          ),
          const SizedBox(height: 12),

          TextFormField(
            controller: _symptomsCtrl,
            maxLines: 2,
            style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
            decoration: _inputDecoration('Symptoms / Reason for visit (optional)'),
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _bookAppointment,
              style: ElevatedButton.styleFrom(
                backgroundColor: _accent, foregroundColor: Colors.white, elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('Confirm Booking', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.inter(fontSize: 12, color: Colors.white38),
      filled: true, fillColor: const Color(0xFF0B1226),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.08))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.08))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _accent, width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
  }

  Widget _buildApptList(List<dynamic> appts, {bool showCancel = false}) {
    if (appts.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.event_outlined, size: 48, color: Colors.white.withOpacity(0.15)),
          const SizedBox(height: 12),
          Text('No appointments', style: GoogleFonts.inter(fontSize: 14, color: Colors.white38)),
        ]),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: appts.length,
      itemBuilder: (ctx, i) {
        final a = appts[i] as Map<String, dynamic>;
        final status = a['status'] ?? '';
        final statusColor = {
          'pending': const Color(0xFFF59E0B),
          'confirmed': const Color(0xFF3F8CFF),
          'inProgress': const Color(0xFF24C06F),
          'completed': Colors.white38,
          'cancelled': const Color(0xFFEF4444),
        }[status] ?? Colors.white38;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF0E1535),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(
                  child: Text('Dr. ${a['doctor_name'] ?? 'Unknown'}',
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Text(status, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: statusColor)),
                ),
              ]),
              const SizedBox(height: 6),
              Text('${a['date']} at ${a['time']} · ${a['type'] ?? ''}',
                style: GoogleFonts.inter(fontSize: 12, color: Colors.white38)),
              if (a['specialty'] != null) ...[
                const SizedBox(height: 4),
                Text(a['specialty'], style: GoogleFonts.inter(fontSize: 12, color: _accent.withOpacity(0.7))),
              ],
              if (showCancel && status == 'pending') ...[
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () async {
                    try {
                      await ApiService.instance.patch('/patient/appointments/${a['id']}/cancel', {});
                      _load();
                    } catch (_) {}
                  },
                  child: Text('Cancel Appointment',
                    style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFEF4444), fontWeight: FontWeight.w600)),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
