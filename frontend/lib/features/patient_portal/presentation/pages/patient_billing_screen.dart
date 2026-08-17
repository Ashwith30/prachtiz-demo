import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../shared/services/api_service.dart';

class PatientBillingScreen extends StatefulWidget {
  const PatientBillingScreen({super.key});

  @override
  State<PatientBillingScreen> createState() => _PatientBillingScreenState();
}

class _PatientBillingScreenState extends State<PatientBillingScreen> {
  List<dynamic> _invoices = [];
  bool _loading = true;
  static const Color _accent = Color(0xFF8B5CF6); // Patient purple

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService.instance.get('/patient/invoices');
      setState(() {
        _invoices = data as List;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Color _statusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'paid':
        return const Color(0xFF24C06F); // Green
      case 'unpaid':
        return const Color(0xFFEF4444); // Red
      case 'pending':
        return const Color(0xFFF59E0B); // Orange
      case 'overdue':
        return const Color(0xFFEF4444); // Red
      default:
        return Colors.white38;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _invoices.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long_outlined,
                          size: 48, color: Colors.white.withOpacity(0.15)),
                      const SizedBox(height: 12),
                      Text('No invoices yet',
                          style: GoogleFonts.inter(
                              fontSize: 14, color: Colors.white38)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _invoices.length,
                  itemBuilder: (_, i) {
                    final inv = _invoices[i] as Map<String, dynamic>;
                    final status = inv['status'] as String?;
                    final sc = _statusColor(status);
                    final date = inv['date']?.toString().split('T')[0] ?? '';
                    final dueDate = inv['due_date']?.toString().split('T')[0] ?? '';
                    final items = (inv['items'] ?? []) as List;

                    // Calculate total
                    double total = 0.0;
                    for (var item in items) {
                      if (item is Map) {
                        final price = double.tryParse(item['unitPrice']?.toString() ?? '0') ?? 0.0;
                        final qty = int.tryParse(item['quantity']?.toString() ?? '1') ?? 1;
                        total += price * qty;
                      }
                    }
                    final discount = double.tryParse(inv['discount']?.toString() ?? '0') ?? 0.0;
                    final taxRate = double.tryParse(inv['tax_rate']?.toString() ?? '0.05') ?? 0.05;
                    final discounted = total * (1 - discount / 100);
                    final finalTotal = discounted * (1 + taxRate);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0E1535),
                        borderRadius: BorderRadius.circular(14),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.06)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                    color: _accent.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10)),
                                child: const Icon(Icons.receipt_long_outlined,
                                    color: _accent, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Invoice #${inv['id'].toString().substring(0, 8).toUpperCase()}',
                                        style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white)),
                                    Text('Dr. ${inv['doctor_name'] ?? 'Unknown'} · Date: $date',
                                        style: GoogleFonts.inter(
                                            fontSize: 12,
                                            color: Colors.white38)),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: sc.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: sc.withOpacity(0.3)),
                                ),
                                child: Text(status?.toUpperCase() ?? 'UNPAID',
                                    style: GoogleFonts.inter(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: sc)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(color: Colors.white10),
                          const SizedBox(height: 8),
                          // List items
                          ...items.map((item) {
                            if (item is Map) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  children: [
                                    Text('${item['description'] ?? 'Service'}',
                                        style: GoogleFonts.inter(
                                            fontSize: 13,
                                            color: Colors.white.withOpacity(0.8))),
                                    const Spacer(),
                                    Text('${item['quantity'] ?? 1} x ₹${item['unitPrice'] ?? 0}',
                                        style: GoogleFonts.inter(
                                            fontSize: 13,
                                            color: Colors.white60)),
                                  ],
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          }),
                          const SizedBox(height: 8),
                          const Divider(color: Colors.white10),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text('Due Date: $dueDate',
                                  style: GoogleFonts.inter(
                                      fontSize: 12, color: Colors.white38)),
                              const Spacer(),
                              Text('Total: ₹${finalTotal.toStringAsFixed(2)}',
                                  style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white)),
                            ],
                          ),
                        ],
                      ),
                    ).animate(delay: Duration(milliseconds: 60 * i)).fadeIn(duration: 300.ms);
                  },
                ),
    );
  }
}
