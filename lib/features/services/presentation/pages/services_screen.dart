import "package:prachtiz_flutter/core/theme/app_colors.dart";
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../theme/colors.dart';
import '../../../../theme/styles.dart';

class ServicePriceItem {
  String code;
  String name;
  String category;
  double price;
  bool isActive;

  ServicePriceItem({
    required this.code,
    required this.name,
    required this.category,
    required this.price,
    this.isActive = true,
  });
}

class ServicesScreen extends StatefulWidget {
  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final List<ServicePriceItem> _services = [
    ServicePriceItem(code: "SRV-01", name: "General Physician Consultation", category: "Consultation", price: 500.0),
    ServicePriceItem(code: "SRV-02", name: "Electrocardiogram (ECG) Test", category: "Diagnostic", price: 1200.0),
    ServicePriceItem(code: "SRV-03", name: "Complete Blood Count (CBC) Panel", category: "Diagnostic", price: 800.0),
    ServicePriceItem(code: "SRV-04", name: "Hepatitis B Vaccine Dose", category: "Vaccination", price: 650.0),
    ServicePriceItem(code: "SRV-05", name: "Telemedicine Video Consultation", category: "Consultation", price: 450.0, isActive: false),
    ServicePriceItem(code: "SRV-06", name: "Physical Therapy Session", category: "Therapy", price: 1500.0),
  ];

  void _deleteService(String code) {
    setState(() {
      _services.removeWhere((element) => element.code == code);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Service $code deleted successfully."),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _toggleServiceStatus(ServicePriceItem service) {
    setState(() {
      service.isActive = !service.isActive;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${service.name} marked as ${service.isActive ? 'Active' : 'Inactive'}."),
        backgroundColor: service.isActive ? const Color(0xFF24C06F) : Colors.orangeAccent,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showServiceDialog(BuildContext context, {ServicePriceItem? service}) {
    final bool isEdit = service != null;
    final codeController = TextEditingController(text: isEdit ? service.code : "");
    final nameController = TextEditingController(text: isEdit ? service.name : "");
    final priceController = TextEditingController(text: isEdit ? service.price.toStringAsFixed(2) : "");
    String selectedCategory = isEdit ? service.category : "Consultation";

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF2A3042),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
              contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(isEdit ? "Edit Service" : "Add New Service", style: GoogleFonts.inter(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
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
                    const SizedBox(height: 16),
                    _buildInputField("Service Code", codeController, enabled: !isEdit),
                    const SizedBox(height: 16),
                    _buildInputField("Service Name", nameController),
                    const SizedBox(height: 16),
                    Text("Category", style: GoogleFonts.inter(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E2548),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedCategory,
                          isExpanded: true,
                          dropdownColor: const Color(0xFF1E2548),
                          style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white54),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setDialogState(() {
                                selectedCategory = newValue;
                              });
                            }
                          },
                          items: <String>['Consultation', 'Diagnostic', 'Vaccination', 'Therapy', 'Other']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInputField("Base Tariff (₹)", priceController, isNumber: true),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("Cancel", style: GoogleFonts.inter(color: Colors.white54, fontSize: 13)),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () {
                            double? price = double.tryParse(priceController.text);
                            if (codeController.text.isNotEmpty && nameController.text.isNotEmpty && price != null) {
                              setState(() {
                                if (isEdit) {
                                  service.name = nameController.text;
                                  service.price = price;
                                  service.category = selectedCategory;
                                } else {
                                  _services.add(ServicePriceItem(
                                    code: codeController.text,
                                    name: nameController.text,
                                    category: selectedCategory,
                                    price: price,
                                  ));
                                }
                              });
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(isEdit ? "Service updated successfully." : "Service added successfully."),
                                  backgroundColor: const Color(0xFF24C06F),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          child: Text("Save", style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, {bool isNumber = false, bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
          style: GoogleFonts.inter(color: enabled ? Colors.white : Colors.white38, fontSize: 13),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF1E2548),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.white12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.primary),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
                      "Clinical Services & Tariffs",
                      style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Update and manage clinic consulting fees and lab diagnostic prices.",
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
                      child: TextButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("All tariffs synced successfully."),
                              backgroundColor: Color(0xFF24C06F),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: const Icon(Icons.sync, color: Colors.white70, size: 18),
                        label: Text("Sync Tariffs", style: GoogleFonts.inter(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextButton.icon(
                        onPressed: () => _showServiceDialog(context),
                        icon: const Icon(Icons.add, color: Colors.white, size: 18),
                        label: Text("Add Service", style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
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

            // Services Table Container
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
                            DataColumn(label: Text("SERVICE CODE")),
                            DataColumn(label: Text("SERVICE NAME")),
                            DataColumn(label: Text("CATEGORY")),
                            DataColumn(label: Text("BASE TARIFF (₹)")),
                            DataColumn(label: Text("STATUS")),
                            DataColumn(label: Text("ACTIONS")),
                          ],
                          rows: _services.map((srv) {
                            return DataRow(
                              color: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
                                if (!srv.isActive) return Colors.white.withOpacity(0.02);
                                return null; // Default color
                              }),
                              cells: [
                                DataCell(Text(srv.code, style: GoogleFonts.inter(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500))),
                                DataCell(
                                  SizedBox(
                                    width: 250,
                                    child: Text(
                                      srv.name,
                                      style: GoogleFonts.inter(
                                        color: srv.isActive ? Colors.white : Colors.white54, 
                                        fontSize: 13, 
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                DataCell(_buildCategoryBadge(srv.category)),
                                DataCell(Text("₹${srv.price.toStringAsFixed(2)}", style: GoogleFonts.inter(color: srv.isActive ? Colors.white : Colors.white54, fontSize: 13, fontWeight: FontWeight.w600), maxLines: 1, softWrap: false)),
                                DataCell(_buildStatusBadge(srv)),
                                DataCell(
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _buildActionButton(Icons.edit_outlined, () => _showServiceDialog(context, service: srv)),
                                      const SizedBox(width: 8),
                                      _buildActionButton(
                                        srv.isActive ? Icons.visibility_off_outlined : Icons.visibility_outlined, 
                                        () => _toggleServiceStatus(srv)
                                      ),
                                      const SizedBox(width: 8),
                                      _buildActionButton(Icons.delete_outline, () => _deleteService(srv.code), isDanger: true),
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

  Widget _buildCategoryBadge(String category) {
    Color color;
    switch (category) {
      case 'Consultation':
        color = const Color(0xFF6366F1);
        break;
      case 'Diagnostic':
        color = const Color(0xFF8B5CF6);
        break;
      case 'Vaccination':
        color = const Color(0xFF14B8A6);
        break;
      case 'Therapy':
        color = const Color(0xFFF59E0B);
        break;
      default:
        color = AppColors.primary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        category,
        style: GoogleFonts.inter(color: color, fontSize: 11, fontWeight: FontWeight.bold),
        maxLines: 1,
        softWrap: false,
      ),
    );
  }

  Widget _buildStatusBadge(ServicePriceItem service) {
    Color color = service.isActive ? const Color(0xFF24C06F) : Colors.white54;
    String label = service.isActive ? "Active" : "Inactive";

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

  Widget _buildActionButton(IconData icon, VoidCallback onTap, {bool isDanger = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: isDanger ? Colors.redAccent.withOpacity(0.8) : Colors.white54, size: 16),
      ),
    );
  }
}
