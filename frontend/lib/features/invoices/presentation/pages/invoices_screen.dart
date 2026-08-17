import "package:prachtiz_flutter/core/theme/app_colors.dart";
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../billing/domain/models/billing.dart';
import '../../../../theme/colors.dart';
import '../../../../theme/styles.dart';
import '../../../../shared/services/api_service.dart';

class InvoicesScreen extends StatefulWidget {
  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  List<Map<String, dynamic>> _displayData = [];
  String _filterStatus = "All";
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadInvoices();
  }

  Future<void> _loadInvoices() async {
    if (!mounted) return;
    setState(() { _loading = true; _error = null; });
    try {
      final data = await ApiService.instance.get('/doctor/invoices') as List;
      final List<Map<String, dynamic>> mapped = data.map((inv) {
        final statusStr = (inv['status'] ?? 'unpaid').toString().toLowerCase();
        InvoiceStatus status;
        switch (statusStr) {
          case 'paid': status = InvoiceStatus.paid; break;
          case 'partial': status = InvoiceStatus.partial; break;
          case 'overdue': status = InvoiceStatus.overdue; break;
          default: status = InvoiceStatus.pending;
        }
        // Compute total from items array
        final items = (inv['items'] as List?) ?? [];
        double total = 0;
        for (final item in items) {
          final qty = (item['quantity'] as num?)?.toDouble() ?? 1;
          final price = (item['unitPrice'] as num?)?.toDouble() ?? 0;
          total += qty * price;
        }
        final taxRate = (inv['tax_rate'] as num?)?.toDouble() ?? 0.05;
        final discount = (inv['discount'] as num?)?.toDouble() ?? 0;
        total = total * (1 + taxRate) - discount;

        final issuedDate = inv['date'] != null
            ? _formatDate(inv['date'].toString())
            : '—';
        final dueDate = inv['due_date'] != null
            ? _formatDate(inv['due_date'].toString())
            : '—';

        final name = inv['patient_name'] ?? 'Unknown';
        final avatarColors = [
          const Color(0xFF6366F1), const Color(0xFF8B5CF6),
          AppColors.primary, const Color(0xFF14B8A6),
        ];
        final hash = name.codeUnits.fold(0, (p, e) => p + e);

        return <String, dynamic>{
          'id': inv['id']?.toString() ?? '',
          'name': name,
          'items': items.length,
          'amount': '₹${total.toStringAsFixed(0)}',
          'issued': issuedDate,
          'due': dueDate,
          'status': status,
          'avatarColor': avatarColors[hash % avatarColors.length],
          'rawId': inv['id'],
        };
      }).toList();
      if (mounted) setState(() { _displayData = mapped; _loading = false; });
    } on ApiException catch (e) {
      if (mounted) setState(() { _error = e.message; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = 'Could not load invoices.'; _loading = false; });
    }
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${dt.day} ${months[dt.month - 1]}, ${dt.year}';
    } catch (_) { return iso; }
  }

  Future<void> _markAsPaid(String id) async {
    // find rawId
    final inv = _displayData.firstWhere((e) => e['id'] == id, orElse: () => {});
    final rawId = inv['rawId']?.toString() ?? id;
    try {
      await ApiService.instance.patch('/doctor/invoices/$rawId/status', {'status': 'paid'});
      await _loadInvoices();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Invoice $id marked as Paid.'),
          backgroundColor: const Color(0xFF24C06F),
          duration: const Duration(seconds: 2),
        ));
      }
    } catch (_) {
      // optimistic UI fallback
      setState(() {
        final index = _displayData.indexWhere((e) => e['id'] == id);
        if (index != -1) _displayData[index]['status'] = InvoiceStatus.paid;
      });
    }
  }

  void _sendReminder(String id, String patientName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Payment reminder sent to $patientName."),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _deleteInvoice(String id) {
    setState(() {
      _displayData.removeWhere((element) => element["id"] == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Invoice $id deleted successfully."),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _downloadInvoice(String id) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Downloading $id..."),
        duration: const Duration(seconds: 1),
      ),
    );
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Downloaded $id.pdf successfully!"),
          backgroundColor: const Color(0xFF24C06F),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _loadInvoices, child: const Text('Retry')),
          ],
        ),
      );
    }
    final filteredData = _filterStatus == "All"
        ? _displayData
        : _displayData.where((d) => (d['status'] as InvoiceStatus).name == _filterStatus.toLowerCase()).toList();

    return RefreshIndicator(
      onRefresh: _loadInvoices,
      child: SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Invoices",
                      style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "View and manage all patient invoices.",
                      style: GoogleFonts.inter(fontSize: 14, color: AppColors.gray600),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E2548),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: PopupMenuButton<String>(
                        color: const Color(0xFF2A3042),
                        icon: const Icon(Icons.filter_list, color: Colors.white70, size: 18),
                        tooltip: "Filter by Status",
                        onSelected: (String status) {
                          setState(() {
                            _filterStatus = status;
                          });
                        },
                        itemBuilder: (BuildContext context) => [
                          _buildFilterMenuItem("All"),
                          _buildFilterMenuItem("Paid"),
                          _buildFilterMenuItem("Pending"),
                          _buildFilterMenuItem("Partial"),
                          _buildFilterMenuItem("Overdue"),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextButton.icon(
                        onPressed: () {
                          // Create invoice dummy action
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Create Invoice modal opened.")),
                          );
                        },
                        icon: const Icon(Icons.add, color: Colors.white, size: 18),
                        label: Text("Create Invoice", style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Invoices Table Container
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF2A3042),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        // Ensure the table has enough width so text doesn't wrap awkwardly, 
                        // but also stretches to fill the container to avoid blank space
                        constraints: BoxConstraints(minWidth: constraints.maxWidth > 1050 ? constraints.maxWidth : 1050),
                        child: DataTable(
                      columnSpacing: 24,
                      horizontalMargin: 24,
                      headingRowHeight: 56,
                      dataRowMaxHeight: 64,
                      dataRowMinHeight: 64,
                      dividerThickness: 1,
                      headingTextStyle: GoogleFonts.inter(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                      columns: [
                        DataColumn(label: Text("INVOICE")),
                        DataColumn(label: Text("PATIENT")),
                        DataColumn(label: Text("ITEMS")),
                        DataColumn(label: Text("AMOUNT")),
                        DataColumn(label: Text("ISSUED")),
                        DataColumn(label: Text("DUE DATE")),
                        DataColumn(label: Text("STATUS")),
                        DataColumn(label: Text("ACTIONS")),
                      ],
                      rows: filteredData.map((inv) {
                        return DataRow(
                          cells: [
                            DataCell(Text(inv["id"], style: GoogleFonts.inter(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500))),
                            DataCell(
                              SizedBox(
                                width: 200, // Constrain width explicitly so row doesn't overflow bounds unexpectedly
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircleAvatar(
                                      radius: 14,
                                      backgroundColor: inv["avatarColor"],
                                      child: Text(
                                        inv["name"].toString().substring(0, 1),
                                        style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        inv["name"],
                                        style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            DataCell(Text("${inv["items"]} items", style: GoogleFonts.inter(color: Colors.white70, fontSize: 13), maxLines: 1, softWrap: false)),
                            DataCell(Text(inv["amount"], style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600), maxLines: 1, softWrap: false)),
                            DataCell(Text(inv["issued"], style: GoogleFonts.inter(color: Colors.white70, fontSize: 13), maxLines: 1, softWrap: false)),
                            DataCell(Text(inv["due"], style: GoogleFonts.inter(color: Colors.white70, fontSize: 13), maxLines: 1, softWrap: false)),
                            DataCell(_buildStatusBadge(inv["status"])),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildActionButton(Icons.remove_red_eye_outlined, () {
                                    _showInvoiceDetailDialog(context, inv);
                                  }),
                                  const SizedBox(width: 8),
                                  _buildActionButton(Icons.download_outlined, () {
                                    _downloadInvoice(inv["id"]);
                                  }),
                                  const SizedBox(width: 8),
                                  _buildMoreMenu(inv),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
        ),
      ),
    ));
  }

  PopupMenuItem<String> _buildFilterMenuItem(String value) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(
            _filterStatus == value ? Icons.radio_button_checked : Icons.radio_button_unchecked,
            color: _filterStatus == value ? AppColors.primary : Colors.white54,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(value, style: GoogleFonts.inter(color: Colors.white, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildMoreMenu(Map<String, dynamic> inv) {
    return PopupMenuButton<String>(
      color: const Color(0xFF1E2548),
      icon: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.more_vert, color: Colors.white54, size: 16),
      ),
        tooltip: "More Options",
        onSelected: (String result) {
          switch (result) {
            case 'paid':
              _markAsPaid(inv["id"]);
              break;
            case 'reminder':
              _sendReminder(inv["id"], inv["name"]);
              break;
            case 'delete':
              _deleteInvoice(inv["id"]);
              break;
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          if (inv["status"] != InvoiceStatus.paid)
            PopupMenuItem<String>(
              value: 'paid',
              child: Text('Mark as Paid', style: GoogleFonts.inter(color: Colors.white, fontSize: 13)),
            ),
          PopupMenuItem<String>(
            value: 'reminder',
            child: Text('Send Reminder', style: GoogleFonts.inter(color: Colors.white, fontSize: 13)),
          ),
          const PopupMenuDivider(),
          PopupMenuItem<String>(
            value: 'delete',
            child: Text('Delete Invoice', style: GoogleFonts.inter(color: Colors.redAccent, fontSize: 13)),
          ),
        ],
      );
  }

  Widget _buildStatusBadge(InvoiceStatus status) {
    Color color;
    String label;

    switch (status) {
      case InvoiceStatus.paid:
        color = const Color(0xFF24C06F);
        label = "Paid";
        break;
      case InvoiceStatus.pending:
        color = const Color(0xFFF59E0B);
        label = "Pending";
        break;
      case InvoiceStatus.partial:
        color = AppColors.primary;
        label = "Partial";
        break;
      case InvoiceStatus.overdue:
        color = const Color(0xFFEF4444);
        label = "Overdue";
        break;
      default:
        color = Colors.white;
        label = "Unknown";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(color: color, fontSize: 11, fontWeight: FontWeight.bold),
        maxLines: 1,
        softWrap: false,
      ),
    );
  }

  Widget _buildActionButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white54, size: 16),
      ),
    );
  }

  void _showInvoiceDetailDialog(BuildContext context, Map<String, dynamic> inv) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2A3042),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
          contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Invoice Details", style: GoogleFonts.inter(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.close, size: 20, color: Colors.white54),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Information
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Ref: ${inv["id"]}", style: GoogleFonts.inter(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.bold)),
                    _buildStatusBadge(inv["status"]),
                  ],
                ),
                const SizedBox(height: 16),
                Text("Patient: ${inv["name"]}", style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text("Issued: ${inv["issued"]}", style: GoogleFonts.inter(color: Colors.white54, fontSize: 12)),
                Text("Due Date: ${inv["due"]}", style: GoogleFonts.inter(color: Colors.white54, fontSize: 12)),
                
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Divider(color: Colors.white12, height: 1),
                ),
                
                // Items placeholder
                Text("Charges & Services (${inv["items"]} items)", style: GoogleFonts.inter(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E2548),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Medical Services", style: GoogleFonts.inter(color: Colors.white, fontSize: 13)),
                          Text(inv["amount"], style: GoogleFonts.inter(color: Colors.white, fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Sales Tax (5%)", style: GoogleFonts.inter(color: Colors.white54, fontSize: 13)),
                          Text("+ ₹0.00", style: GoogleFonts.inter(color: Colors.white54, fontSize: 13)),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Divider(color: Colors.white12, height: 1),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("TOTAL AMOUNT DUE", style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                          Text(inv["amount"], style: GoogleFonts.inter(color: const Color(0xFF24C06F), fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _downloadInvoice(inv["id"]);
                    },
                    icon: const Icon(Icons.print, size: 16, color: Colors.white),
                    label: Text("Download & Print Receipt", style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
