import "package:prachtiz_flutter/core/theme/app_colors.dart";
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../billing/domain/models/billing.dart';
import '../../../../theme/colors.dart';
import '../../../../theme/styles.dart';

class InvoicesScreen extends StatefulWidget {
  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  late List<Map<String, dynamic>> _displayData;
  String _filterStatus = "All";

  @override
  void initState() {
    super.initState();
    _displayData = [
      {"id": "INV-2401", "name": "Margaret Chen", "items": 3, "amount": "₹15,000", "issued": "Feb 27, 2026", "due": "Mar 13, 2026", "status": InvoiceStatus.paid, "avatarColor": const Color(0xFF6366F1)},
      {"id": "INV-2402", "name": "James O'Sullivan", "items": 8, "amount": "₹45,000", "issued": "Feb 27, 2026", "due": "Mar 13, 2026", "status": InvoiceStatus.pending, "avatarColor": const Color(0xFF8B5CF6)},
      {"id": "INV-2403", "name": "Aisha Rahman", "items": 12, "amount": "₹1,20,000", "issued": "Feb 26, 2026", "due": "Mar 12, 2026", "status": InvoiceStatus.partial, "avatarColor": AppColors.primary},
      {"id": "INV-2404", "name": "Elena Vasquez", "items": 2, "amount": "₹8,500", "issued": "Feb 26, 2026", "due": "Mar 12, 2026", "status": InvoiceStatus.paid, "avatarColor": const Color(0xFF14B8A6)},
      {"id": "INV-2405", "name": "Thomas Bergstrom", "items": 5, "amount": "₹22,000", "issued": "Feb 25, 2026", "due": "Mar 11, 2026", "status": InvoiceStatus.overdue, "avatarColor": const Color(0xFF6366F1)},
      {"id": "INV-2406", "name": "Priya Patel", "items": 7, "amount": "₹35,000", "issued": "Feb 25, 2026", "due": "Mar 11, 2026", "status": InvoiceStatus.paid, "avatarColor": const Color(0xFF8B5CF6)},
      {"id": "INV-2407", "name": "William Frost", "items": 4, "amount": "₹18,200", "issued": "Feb 24, 2026", "due": "Mar 10, 2026", "status": InvoiceStatus.paid, "avatarColor": AppColors.primary},
      {"id": "INV-2408", "name": "Robert Nakamura", "items": 9, "amount": "₹67,500", "issued": "Feb 24, 2026", "due": "Mar 10, 2026", "status": InvoiceStatus.pending, "avatarColor": const Color(0xFF6366F1)},
    ];
  }

  void _markAsPaid(String id) {
    setState(() {
      final index = _displayData.indexWhere((element) => element["id"] == id);
      if (index != -1) {
        _displayData[index]["status"] = InvoiceStatus.paid;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Invoice $id marked as Paid."),
        backgroundColor: const Color(0xFF24C06F),
        duration: const Duration(seconds: 2),
      ),
    );
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
    final filteredData = _filterStatus == "All" 
        ? _displayData 
        : _displayData.where((d) => (d["status"] as InvoiceStatus).name == _filterStatus.toLowerCase()).toList();

    return SingleChildScrollView(
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
    );
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
