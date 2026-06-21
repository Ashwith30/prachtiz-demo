import "package:prachtiz_flutter/core/theme/app_colors.dart";
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/models/billing.dart';
import '../../../../theme/colors.dart';
import '../../../../shared/utils/print_helper.dart';

class BillingScreen extends StatefulWidget {
  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  // Active catalog category tab
  String _activeTab = "Services";

  // Diagnostic laboratory parameters marketplace catalog
  final List<Map<String, dynamic>> _diagnosticCatalog = [
    {"code": "LAB-01", "name": "Thyroid Profile (T3, T4, TSH)", "price": 450.0, "icon": Icons.biotech_outlined},
    {"code": "LAB-02", "name": "Lipid Profile (Cholesterol)", "price": 350.0, "icon": Icons.science_outlined},
    {"code": "LAB-03", "name": "HbA1c (Glycated Hemoglobin)", "price": 280.0, "icon": Icons.bloodtype_outlined},
    {"code": "LAB-04", "name": "Liver Function Test (LFT)", "price": 550.0, "icon": Icons.analytics_outlined},
    {"code": "LAB-05", "name": "Renal Function Test (RFT)", "price": 480.0, "icon": Icons.opacity_outlined},
    {"code": "LAB-06", "name": "Vitamin D (25-Hydroxy)", "price": 850.0, "icon": Icons.wb_sunny_outlined},
    {"code": "LAB-07", "name": "Urine Culture & Sensitivity", "price": 300.0, "icon": Icons.bubble_chart_outlined},
    {"code": "LAB-08", "name": "Diabetes Screening Package", "price": 600.0, "icon": Icons.assignment_ind_outlined},
  ];

  // Available clinical services catalog
  final List<Map<String, dynamic>> _catalog = [
    {"code": "SRV-01", "name": "General Physician Consultation", "price": 50.0, "icon": Icons.medical_services_outlined},
    {"code": "SRV-02", "name": "Electrocardiogram (ECG)", "price": 40.0, "icon": Icons.monitor_heart_outlined},
    {"code": "SRV-03", "name": "Complete Blood Count (CBC)", "price": 30.0, "icon": Icons.biotech_outlined},
    {"code": "SRV-04", "name": "Hepatitis B Vaccine Shot", "price": 25.0, "icon": Icons.vaccines_outlined},
    {"code": "SRV-05", "name": "Chest X-Ray Imaging", "price": 60.0, "icon": Icons.settings_accessibility_outlined},
    {"code": "SRV-06", "name": "Urinalysis Diagnostic", "price": 15.0, "icon": Icons.opacity_outlined},
    {"code": "SRV-07", "name": "Physiotherapy Session (45m)", "price": 45.0, "icon": Icons.accessibility_new_outlined},
    {"code": "SRV-08", "name": "Echocardiography (Echo)", "price": 120.0, "icon": Icons.favorite_border_outlined},
  ];

  // Active items in the checkout cart
  final List<BillingItem> _cart = [];
  
  // Search and payment settings
  String _searchQuery = "";
  String _selectedPaymentMethod = "Cash"; // "Cash", "Card", "UPI", "Insurance"
  double _discountPercent = 0.0;
  
  final _patientNameController = TextEditingController(text: "Marcus Vance");
  final _insuranceProviderController = TextEditingController(text: "Blue Cross Blue Shield");
  double _copayPercent = 20.0;

  // Invoices Ledger state populated with mockup initial items
  final List<Invoice> _recentInvoices = [
    Invoice(
      id: "INV-1092",
      patientName: "Marcus Vance",
      date: "2026-06-12",
      status: InvoiceStatus.paid,
      paymentMethod: "Card",
      items: [
        BillingItem(code: "SRV-01", description: "General Physician Consultation", unitPrice: 50.0, quantity: 1),
        BillingItem(code: "SRV-02", description: "Electrocardiogram (ECG)", unitPrice: 40.0, quantity: 1),
      ],
      discount: 10,
    ),
    Invoice(
      id: "INV-1093",
      patientName: "Emily Watson",
      date: "2026-06-11",
      status: InvoiceStatus.pending,
      paymentMethod: "Insurance",
      items: [
        BillingItem(code: "SRV-01", description: "General Physician Consultation", unitPrice: 50.0, quantity: 1),
      ],
    ),
    Invoice(
      id: "INV-1094",
      patientName: "John Doe",
      date: "2026-06-05",
      status: InvoiceStatus.overdue,
      paymentMethod: "Cash",
      items: [
        BillingItem(code: "SRV-01", description: "General Physician Consultation", unitPrice: 50.0, quantity: 1),
        BillingItem(code: "SRV-03", description: "Complete Blood Count (CBC)", unitPrice: 30.0, quantity: 2),
      ],
    ),
  ];

  void _quickAddService(Map<String, dynamic> item) {
    setState(() {
      String code = item['code'];
      String name = item['name'];
      double price = item['price'];

      int existingIdx = _cart.indexWhere((c) => c.code == code);
      if (existingIdx != -1) {
        BillingItem current = _cart[existingIdx];
        _cart[existingIdx] = BillingItem(
          code: code,
          description: name,
          unitPrice: price,
          quantity: current.quantity + 1,
        );
      } else {
        _cart.add(BillingItem(
          code: code,
          description: name,
          unitPrice: price,
          quantity: 1,
        ));
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF24C06F),
        duration: const Duration(milliseconds: 700),
        content: Text("Added ${item['name']} to cart.", style: GoogleFonts.inter(color: Colors.white, fontSize: 11)),
      ),
    );
  }

  void _incrementQty(int index) {
    setState(() {
      BillingItem current = _cart[index];
      _cart[index] = BillingItem(
        code: current.code,
        description: current.description,
        unitPrice: current.unitPrice,
        quantity: current.quantity + 1,
      );
    });
  }

  void _decrementQty(int index) {
    setState(() {
      BillingItem current = _cart[index];
      if (current.quantity > 1) {
        _cart[index] = BillingItem(
          code: current.code,
          description: current.description,
          unitPrice: current.unitPrice,
          quantity: current.quantity - 1,
        );
      } else {
        _cart.removeAt(index);
      }
    });
  }

  void _processCheckoutComplete(double total, double subtotal, double discountAmount, double taxAmount) {
    final String generatedId = "INV-${math.Random().nextInt(9000) + 1000}";
    final String currentDate = DateTime.now().toString().substring(0, 10);
    
    // Create new Invoice record
    final Invoice newInvoice = Invoice(
      id: generatedId,
      patientName: _patientNameController.text,
      date: currentDate,
      items: List.from(_cart),
      discount: _discountPercent,
      paymentMethod: _selectedPaymentMethod == "Insurance" 
          ? "Insurance (${_insuranceProviderController.text})"
          : _selectedPaymentMethod,
      status: _selectedPaymentMethod == "Insurance" ? InvoiceStatus.pending : InvoiceStatus.paid,
    );

    setState(() {
      _recentInvoices.insert(0, newInvoice);
      _cart.clear();
    });

    // Reset settings
    _discountPercent = 0.0;

    // Show printable receipt modal
    _showReceiptModal(newInvoice);
  }

  void _processCheckout(double total, double subtotal, double discountAmount, double taxAmount) {
    if (_cart.isEmpty) return;

    if (_selectedPaymentMethod == "UPI" || _selectedPaymentMethod == "Card") {
      _showSimulatedPaymentGatewayDialog(total, subtotal, discountAmount, taxAmount);
    } else {
      _processCheckoutComplete(total, subtotal, discountAmount, taxAmount);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic computations for the KPI Cards
    double totalBilled = _recentInvoices.fold(0.0, (sum, inv) => sum + inv.total);
    int processedCount = _recentInvoices.length;
    double outstandingBalance = _recentInvoices
        .where((inv) => inv.status == InvoiceStatus.pending || inv.status == InvoiceStatus.overdue)
        .fold(0.0, (sum, inv) => sum + inv.total);
    double avgInvoice = processedCount > 0 ? totalBilled / processedCount : 0.0;

    // Cart totals
    double cartSubtotal = _cart.fold(0.0, (sum, item) => sum + item.total);
    double cartDiscountAmount = cartSubtotal * (_discountPercent / 100.0);
    double cartTaxAmount = (cartSubtotal - cartDiscountAmount) * 0.05;
    double cartTotal = (cartSubtotal - cartDiscountAmount) + cartTaxAmount;

    // Filter catalog based on search query and active tab
    final activeCatalogList = _activeTab == "Services" ? _catalog : _diagnosticCatalog;
    final filteredCatalog = activeCatalogList.where((item) {
      final name = item['name'].toString().toLowerCase();
      final code = item['code'].toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || code.contains(query);
    }).toList();

    bool isMobile = MediaQuery.of(context).size.width <= 1024;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              "POS Clinical Billing Console",
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.gray900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Configure point-of-sale receipts, track revenue, and process patient billing invoices",
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF24C06F),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),

            // Billing statistics KPI cards
            _buildKPIsRow(totalBilled, processedCount, outstandingBalance, avgInvoice),
            const SizedBox(height: 24),

            // POS Split Console Layout
            isMobile
                ? Column(
                    children: [
                      _buildLeftConsole(filteredCatalog),
                      const SizedBox(height: 16),
                      _buildRightCartSummary(cartSubtotal, cartDiscountAmount, cartTaxAmount, cartTotal, isExpanded: false),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: _buildLeftConsole(filteredCatalog),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 4,
                        child: _buildRightCartSummary(cartSubtotal, cartDiscountAmount, cartTaxAmount, cartTotal, isExpanded: false),
                      ),
                    ],
                  ),
            const SizedBox(height: 24),

            // Past transactions registry ledger
            _buildInvoicesLedgerCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildKPIsRow(double revenue, int invoicesCount, double outstanding, double average) {
    final double screenWidth = MediaQuery.of(context).size.width;

    final List<Widget> cards = [
      _InteractiveKPICard(label: "Daily Revenue Today", value: "₹${revenue.toStringAsFixed(2)}", icon: Icons.monetization_on_outlined, color: AppColors.primary),
      _InteractiveKPICard(label: "Invoices Processed", value: "$invoicesCount", icon: Icons.receipt_long_outlined, color: const Color(0xFF8B5CF6)),
      _InteractiveKPICard(label: "Outstanding Unpaid", value: "₹${outstanding.toStringAsFixed(2)}", icon: Icons.warning_amber_outlined, color: const Color(0xFFF59E0B)),
      _InteractiveKPICard(label: "Average Invoice Billed", value: "₹${average.toStringAsFixed(2)}", icon: Icons.analytics_outlined, color: const Color(0xFF0EA5E9)),
    ];

    if (screenWidth < 650) {
      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.3,
        children: cards,
      );
    } else {
      return Row(
        children: cards.map((c) => Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: c,
          ),
        )).toList(),
      );
    }
  }

  Widget _buildLeftConsole(List<Map<String, dynamic>> filteredCatalog) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Configuration Card
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: const Color(0xFF11152D),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("POS Checkout Setup", style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
              const Divider(color: Colors.white12, height: 20),
              
              // Patient Name Row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _patientNameController,
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                      decoration: _buildInputDecoration("Billed Patient Name", Icons.person_outline),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Payment Method Selectors
              Text("Payment Method", style: GoogleFonts.inter(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              _buildPaymentMethodSelector(),
              const SizedBox(height: 16),

              // Insurance fields shown conditionally
              if (_selectedPaymentMethod == "Insurance") ...[
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _insuranceProviderController,
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                        decoration: _buildInputDecoration("Insurance Provider", Icons.shield_outlined),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: StatefulBuilder(
                        builder: (context, setStateSlider) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Co-pay: ${_copayPercent.toInt()}%", style: GoogleFonts.inter(color: Colors.white70, fontSize: 10)),
                              Slider(
                                value: _copayPercent,
                                min: 0,
                                max: 100,
                                divisions: 20,
                                activeColor: AppColors.primary,
                                inactiveColor: Colors.white12,
                                onChanged: (val) => setStateSlider(() => _copayPercent = val),
                              ),
                            ],
                          );
                        }
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // Discount offer slider
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Discount Offer: ${_discountPercent.toInt()}%", style: GoogleFonts.inter(color: Colors.white70, fontSize: 11)),
                  Text("-₹${(_cart.fold(0.0, (sum, i) => sum + i.total) * (_discountPercent / 100)).toStringAsFixed(2)}", style: GoogleFonts.inter(color: const Color(0xFFEF4444), fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
              Slider(
                value: _discountPercent,
                min: 0,
                max: 50,
                divisions: 10,
                activeColor: AppColors.primary,
                inactiveColor: Colors.white12,
                onChanged: (val) => setState(() => _discountPercent = val),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Quick Catalog Grid Card
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: const Color(0xFF11152D),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Tab selectors for Services vs Diagnostic Marketplace
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildCatalogTab("Services", Icons.medical_services_outlined),
                      const SizedBox(width: 8),
                      _buildCatalogTab("Diagnostics", Icons.science_outlined),
                    ],
                  ),
                  // Search Box
                  SizedBox(
                    width: 200,
                    height: 32,
                    child: TextField(
                      onChanged: (val) => setState(() => _searchQuery = val),
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 11.5),
                      decoration: InputDecoration(
                        hintText: "Search catalog...",
                        hintStyle: GoogleFonts.inter(color: Colors.white30, fontSize: 11.5),
                        filled: true,
                        fillColor: const Color(0xFF1E2548),
                        isDense: true,
                        prefixIcon: const Icon(Icons.search, color: Colors.white38, size: 14),
                        contentPadding: const EdgeInsets.symmetric(vertical: 6),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.primary),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(color: Colors.white12, height: 20),
              
              if (filteredCatalog.isEmpty)
                Container(
                  height: 100,
                  alignment: Alignment.center,
                  child: Text("No matching catalog items found.", style: GoogleFonts.inter(color: Colors.white38, fontSize: 12)),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: screenWidth < 600 ? 1 : (screenWidth < 900 ? 2 : 3),
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: screenWidth < 600 ? 3.2 : (screenWidth < 1200 ? 2.4 : 2.2),
                  ),
                  itemCount: filteredCatalog.length,
                  itemBuilder: (context, index) {
                    final service = filteredCatalog[index];
                    return _ServiceCatalogTile(
                      item: service,
                      onTap: () => _quickAddService(service),
                      accentColor: _getItemColor(service['code']),
                    );
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getItemColor(String code) {
    switch (code) {
      case 'SRV-01': return const Color(0xFF3F8CFF); // General Physician: Blue
      case 'SRV-02': return const Color(0xFFEF4444); // ECG: Coral/Red
      case 'SRV-03': return const Color(0xFF8B5CF6); // CBC: Purple
      case 'SRV-04': return const Color(0xFFF59E0B); // Vaccine: Orange
      case 'SRV-05': return const Color(0xFF0EA5E9); // Chest X-Ray: Cyan
      case 'SRV-06': return const Color(0xFF0D9488); // Urinalysis: Teal
      case 'SRV-07': return const Color(0xFFEC4899); // Physiotherapy: Pink
      case 'SRV-08': return const Color(0xFFF43F5E); // Echo: Rose
      
      case 'LAB-01': return const Color(0xFF8B5CF6); // Thyroid: Purple
      case 'LAB-02': return const Color(0xFFF59E0B); // Lipid: Orange
      case 'LAB-03': return const Color(0xFFF43F5E); // HbA1c: Rose
      case 'LAB-04': return const Color(0xFF0D9488); // Liver: Teal
      case 'LAB-05': return const Color(0xFF0EA5E9); // Renal: Cyan
      case 'LAB-06': return const Color(0xFFEAB308); // Vitamin D: Yellow
      case 'LAB-07': return const Color(0xFF10B981); // Urine: Emerald
      case 'LAB-08': return const Color(0xFF3F8CFF); // Diabetes: Blue
      default: return const Color(0xFF3F8CFF);
    }
  }

  Widget _buildPaymentMethodSelector() {
    final List<Map<String, dynamic>> methods = [
      {"name": "Cash", "icon": Icons.payments_outlined},
      {"name": "Card", "icon": Icons.credit_card_outlined},
      {"name": "UPI", "icon": Icons.qr_code_2_outlined},
      {"name": "Insurance", "icon": Icons.shield_outlined},
    ];

    return Row(
      children: methods.map((m) {
        final bool isSelected = _selectedPaymentMethod == m['name'];
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedPaymentMethod = m['name']),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary.withOpacity(0.15) : Color(0xFF1E2548),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(m['icon'], size: 16, color: isSelected ? AppColors.primary : Colors.white54),
                  const SizedBox(height: 4),
                  Text(
                    m['name'],
                    style: GoogleFonts.inter(
                      color: isSelected ? Colors.white : Colors.white60,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRightCartSummary(double subtotal, double discount, double tax, double total, {required bool isExpanded}) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF11152D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Checkout Cart Summary", style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.12), borderRadius: BorderRadius.circular(4)),
                child: Text(
                  "${_cart.fold(0, (sum, i) => sum + i.quantity)} items",
                  style: GoogleFonts.inter(color: AppColors.primary, fontSize: 9.5, fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
          const Divider(color: Colors.white12, height: 20),

          // Cart Items List
          if (isExpanded)
            Expanded(
              child: _cart.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.shopping_cart_outlined, color: Colors.white24, size: 36),
                          const SizedBox(height: 12),
                          Text("Roster checkout cart is empty.", style: GoogleFonts.inter(color: Colors.white24, fontSize: 11)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: _cart.length,
                      itemBuilder: (context, index) {
                        final item = _cart[index];
                        return _buildCartItemRow(item, index);
                      },
                    ),
            )
          else
            _cart.isEmpty
                ? Container(
                    height: 120,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.shopping_cart_outlined, color: Colors.white24, size: 24),
                        const SizedBox(height: 8),
                        Text("Roster checkout cart is empty.", style: GoogleFonts.inter(color: Colors.white24, fontSize: 11)),
                      ],
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _cart.length,
                    itemBuilder: (context, index) {
                      final item = _cart[index];
                      return _buildCartItemRow(item, index);
                    },
                  ),

          const Divider(color: Colors.white12, height: 20),

          // Total Invoice calculations
          _buildReceiptRow("Subtotal", "₹${subtotal.toStringAsFixed(2)}"),
          _buildReceiptRow("Discount Offer (${_discountPercent.toInt()}%)", "-₹${discount.toStringAsFixed(2)}", isDiscount: true),
          _buildReceiptRow("Sales Tax (5%)", "+₹${tax.toStringAsFixed(2)}"),
          const Divider(color: Colors.white12, height: 16),
          _buildReceiptRow("TOTAL DUE", "₹${total.toStringAsFixed(2)}", isTotal: true),
          const SizedBox(height: 16),

          // Action Button
          SizedBox(
            height: 40,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.check, size: 16, color: Colors.white),
              label: Text(
                "Generate Invoice & Checkout",
                style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF24C06F),
                disabledBackgroundColor: Colors.white10,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              onPressed: _cart.isEmpty 
                  ? null 
                  : () => _processCheckout(total, subtotal, discount, tax),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptRow(String label, String val, {bool isTotal = false, bool isDiscount = false}) {
    Color valColor = Colors.white70;
    if (isTotal) {
      valColor = const Color(0xFF24C06F);
    } else if (isDiscount) {
      valColor = const Color(0xFFEF4444);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              color: isTotal ? Colors.white : Colors.white54,
              fontSize: isTotal ? 13 : 11,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            val,
            style: GoogleFonts.inter(
              color: valColor,
              fontSize: isTotal ? 15 : 11,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoicesLedgerCard() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF11152D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text("Recent Transactions & Invoices", style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
          const Divider(color: Colors.white12, height: 20),
          
          LayoutBuilder(
            builder: (context, constraints) {
              final bool isScreenSmall = constraints.maxWidth < 800;
              final double minWidth = isScreenSmall ? 800.0 : constraints.maxWidth;
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: minWidth,
                  child: Table(
                    columnWidths: const {
                      0: FlexColumnWidth(1.2), // Invoice ID
                      1: FlexColumnWidth(2.0), // Patient Name
                      2: FlexColumnWidth(1.5), // Date
                      3: FlexColumnWidth(1.5), // Total Amount
                      4: FlexColumnWidth(1.5), // Payment Method
                      5: FlexColumnWidth(1.2), // Status
                      6: FlexColumnWidth(1.2), // Actions
                    },
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: [
                      // Header Row
                      TableRow(
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: Colors.white12, width: 1)),
                        ),
                        children: [
                          _buildTableHeaderCell("INVOICE ID"),
                          _buildTableHeaderCell("PATIENT NAME"),
                          _buildTableHeaderCell("DATE"),
                          _buildTableHeaderCell("TOTAL AMOUNT"),
                          _buildTableHeaderCell("PAYMENT METHOD"),
                          _buildTableHeaderCell("STATUS"),
                          _buildTableHeaderCell("ACTIONS"),
                        ],
                      ),
                      // Data Rows
                      ..._recentInvoices.map((inv) {
                        final Color statusColor;
                        switch (inv.status) {
                          case InvoiceStatus.paid:
                            statusColor = const Color(0xFF24C06F);
                            break;
                          case InvoiceStatus.pending:
                            statusColor = const Color(0xFFF59E0B);
                            break;
                          case InvoiceStatus.overdue:
                            statusColor = const Color(0xFFEF4444);
                            break;
                          default:
                            statusColor = AppColors.primary;
                        }

                        return TableRow(
                          decoration: const BoxDecoration(
                            border: Border(bottom: BorderSide(color: Colors.white10, width: 1)),
                          ),
                          children: [
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10.0),
                                child: Text(inv.id, style: GoogleFonts.inter(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10.0),
                                child: Text(inv.patientName, style: GoogleFonts.inter(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10.0),
                                child: Text(inv.date, style: GoogleFonts.inter(color: Colors.white54, fontSize: 10.5)),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10.0),
                                child: Text("₹${inv.total.toStringAsFixed(2)}", style: GoogleFonts.inter(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10.0),
                                child: Text(inv.paymentMethod, style: GoogleFonts.inter(color: Colors.white54, fontSize: 10.5)),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10.0),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: statusColor.withOpacity(0.35)),
                                    ),
                                    child: Text(
                                      inv.status.name.toUpperCase(),
                                      style: GoogleFonts.inter(color: statusColor, fontSize: 8, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.visibility_outlined, size: 14, color: Colors.white70),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      onPressed: () => _showReceiptModal(inv),
                                    ),
                                    const SizedBox(width: 8),
                                    if (inv.status != InvoiceStatus.paid)
                                      IconButton(
                                        icon: const Icon(Icons.check_circle_outline, size: 14, color: Color(0xFF24C06F)),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        onPressed: () {
                                          setState(() {
                                            int idx = _recentInvoices.indexWhere((i) => i.id == inv.id);
                                            if (idx != -1) {
                                              _recentInvoices[idx] = _recentInvoices[idx].copyWith(status: InvoiceStatus.paid);
                                            }
                                          });
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              backgroundColor: const Color(0xFF24C06F),
                                              content: Text("Invoice ${inv.id} marked as Paid.", style: GoogleFonts.inter(color: Colors.white)),
                                            ),
                                          );
                                        },
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeaderCell(String text) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          text,
          style: GoogleFonts.inter(
            color: Colors.white54,
            fontSize: 9.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showReceiptModal(Invoice inv) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0C0E1F),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.white.withOpacity(0.08)),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Clinical Receipt - Details",
                style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 18, color: Colors.white70),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          content: SizedBox(
            width: 350,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Invoice details header
                Text("PraCHtiz EMR Clinic POS", style: GoogleFonts.inter(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                Text("Clinical Checkout Receipt", style: GoogleFonts.inter(color: Colors.white54, fontSize: 10), textAlign: TextAlign.center),
                const SizedBox(height: 12),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Invoice Ref: ${inv.id}", style: GoogleFonts.inter(color: Colors.white70, fontSize: 10.5, fontWeight: FontWeight.bold)),
                    Text("Date: ${inv.date}", style: GoogleFonts.inter(color: Colors.white30, fontSize: 9.5)),
                  ],
                ),
                const SizedBox(height: 2),
                Text("Patient: ${inv.patientName}", style: GoogleFonts.inter(color: Colors.white70, fontSize: 10.5)),
                Text("Status: ${inv.status.name.toUpperCase()}", style: GoogleFonts.inter(color: inv.status == InvoiceStatus.paid ? const Color(0xFF24C06F) : const Color(0xFFF59E0B), fontSize: 9.5, fontWeight: FontWeight.bold)),
                
                const Divider(color: Colors.white12, height: 20),

                // Itemized bill lines
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: inv.items.length,
                  itemBuilder: (context, index) {
                    final item = inv.items[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              "${item.quantity} x ${item.description}",
                              style: GoogleFonts.inter(color: Colors.white70, fontSize: 10.5),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "₹${item.total.toStringAsFixed(2)}",
                            style: GoogleFonts.inter(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const Divider(color: Colors.white12, height: 20),

                // Total calculations
                _buildModalReceiptRow("Subtotal", "₹${inv.subtotal.toStringAsFixed(2)}"),
                _buildModalReceiptRow("Discount Offered (${inv.discount.toInt()}%)", "-₹${inv.discountAmount.toStringAsFixed(2)}", isDiscount: true),
                _buildModalReceiptRow("Sales Tax (5%)", "+₹${inv.taxAmount.toStringAsFixed(2)}"),
                const Divider(color: Colors.white12, height: 12),
                _buildModalReceiptRow("TOTAL AMOUNT DUE", "₹${inv.total.toStringAsFixed(2)}", isTotal: true),
                _buildModalReceiptRow("Payment Method", inv.paymentMethod),
                
                const SizedBox(height: 16),

                // High fidelity barcode mockup
                _buildBarcodeMockup(),
                const SizedBox(height: 6),
                Text(
                  "Thank you for choosing PraCHtiz EMR.",
                  style: GoogleFonts.inter(color: Colors.white24, fontSize: 8.5),
                  textAlign: TextAlign.center,
                ),
                Text(
                  "Powered by CallHealth POS Billing Suite.",
                  style: GoogleFonts.inter(color: Colors.white24, fontSize: 8.5),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          actions: [
            OutlinedButton.icon(
              icon: const Icon(Icons.download, size: 14, color: Color(0xFF3F8CFF)),
              label: Text("Download PDF", style: GoogleFonts.inter(color: const Color(0xFF3F8CFF), fontSize: 11.5, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF3F8CFF)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              onPressed: () {
                Navigator.pop(context);
                PrintHelper.downloadInvoicePdf(inv);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: const Color(0xFF24C06F),
                    content: Text("Generating & downloading PDF for INV-${inv.id}...", style: GoogleFonts.inter(color: Colors.white)),
                  ),
                );
              },
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.print, size: 14, color: Colors.white),
              label: Text("Print Receipt", style: GoogleFonts.inter(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              onPressed: () {
                Navigator.pop(context);
                PrintHelper.printInvoice(inv);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: const Color(0xFF24C06F),
                    content: Text("Opening print stream for INV-${inv.id} receipt...", style: GoogleFonts.inter(color: Colors.white)),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildModalReceiptRow(String label, String value, {bool isTotal = false, bool isDiscount = false}) {
    Color valColor = Colors.white70;
    if (isTotal) {
      valColor = const Color(0xFF24C06F);
    } else if (isDiscount) {
      valColor = const Color(0xFFEF4444);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              color: isTotal ? Colors.white : Colors.white54,
              fontSize: isTotal ? 11.5 : 10,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              color: valColor,
              fontSize: isTotal ? 13 : 10,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarcodeMockup() {
    final math.Random random = math.Random(12345); // Seeded for consistency
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(45, (index) {
          final isBlack = index % 2 == 0;
          final double barWidth = isBlack ? (random.nextInt(3) + 1.0) : (random.nextInt(2) + 1.0);
          return Container(
            width: barWidth,
            height: 30,
            color: isBlack ? Colors.white : Colors.transparent,
          );
        }),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.inter(color: AppColors.gray400, fontSize: 11),
      prefixIcon: Icon(icon, color: Colors.white38, size: 16),
      filled: true,
      fillColor: const Color(0xFF1E2548),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
        borderRadius: BorderRadius.circular(6),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.primary),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }

  Widget _buildCartItemRow(BillingItem item, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.description,
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  "Unit Price: ₹${item.unitPrice.toStringAsFixed(2)}",
                  style: GoogleFonts.inter(color: Colors.white38, fontSize: 9),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E2548),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => _decrementQty(index),
                  child: Container(
                    padding: const EdgeInsets.all(4.0),
                    child: const Icon(Icons.remove, size: 11, color: Colors.white70),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: Text(
                    "${item.quantity}",
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
                GestureDetector(
                  onTap: () => _incrementQty(index),
                  child: Container(
                    padding: const EdgeInsets.all(4.0),
                    child: const Icon(Icons.add, size: 11, color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            "₹${item.total.toStringAsFixed(2)}",
            style: GoogleFonts.inter(color: Colors.white70, fontSize: 11.5, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.close, size: 14, color: Color(0xFFEF4444)),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => setState(() => _cart.removeAt(index)),
          ),
        ],
      ),
    );
  }

  Widget _buildCatalogTab(String label, IconData icon) {
    final bool isActive = _activeTab == label;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isActive ? AppColors.primary : Colors.white12,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: isActive ? AppColors.primary : Colors.white54),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                color: isActive ? Colors.white : Colors.white54,
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _buildGatewayInputDeco(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.inter(color: Colors.white30, fontSize: 11),
      filled: true,
      fillColor: const Color(0xFF1E2548),
      isDense: true,
      prefixIcon: Icon(icon, color: Colors.white38, size: 14),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
        borderRadius: BorderRadius.circular(6),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.primary),
        borderRadius: BorderRadius.circular(6),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFFEF4444)),
        borderRadius: BorderRadius.circular(6),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFFEF4444)),
        borderRadius: BorderRadius.circular(6),
      ),
      errorStyle: GoogleFonts.inter(color: const Color(0xFFEF4444), fontSize: 9),
    );
  }

  void _showSimulatedPaymentGatewayDialog(double total, double subtotal, double discountAmount, double taxAmount) {
    final cardNumberController = TextEditingController();
    final expiryController = TextEditingController();
    final cvvController = TextEditingController();
    final nameController = TextEditingController(text: _patientNameController.text);
    
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        String gatewayStep = "Initial";
        String gatewayMessage = "";
        double chargeTotal = total;

        return StatefulBuilder(
          builder: (context, setGatewayState) {
            Widget bodyContent;
            
            if (gatewayStep == "Processing") {
              bodyContent = Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 24),
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 3.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Simulating Gateway Transaction",
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    gatewayMessage,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(color: Colors.white54, fontSize: 12),
                  ),
                  const SizedBox(height: 24),
                ],
              );
            } else if (gatewayStep == "Success") {
              bodyContent = Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 24),
                  const CircleAvatar(
                    backgroundColor: Color(0xFF1B4D3E),
                    radius: 28,
                    child: Icon(Icons.check_circle_outline, color: Color(0xFF24C06F), size: 36),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Payment Successful!",
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Simulated Stripe/Razorpay captures complete.",
                    style: GoogleFonts.inter(color: Colors.white54, fontSize: 12),
                  ),
                  const SizedBox(height: 24),
                ],
              );
            } else {
              if (_selectedPaymentMethod == "UPI") {
                bodyContent = Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
                    Text(
                      "Scan QR Code to pay via UPI",
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Simulated Razorpay UPI Dynamic QR Intent",
                      style: GoogleFonts.inter(color: Colors.white30, fontSize: 10),
                    ),
                    const SizedBox(height: 20),
                    
                    Container(
                      width: 160,
                      height: 160,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.02),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: CustomPaint(
                        painter: _QRCodePainter(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    Text(
                      "Amount to Pay: ₹${chargeTotal.toStringAsFixed(2)}",
                      style: GoogleFonts.inter(color: const Color(0xFF24C06F), fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Merchant: CallHealth Diagnostics Ltd.",
                      style: GoogleFonts.inter(color: Colors.white54, fontSize: 11),
                    ),
                    const SizedBox(height: 24),
                    
                    ElevatedButton(
                      onPressed: () {
                        setGatewayState(() {
                          gatewayStep = "Processing";
                          gatewayMessage = "Generating secure UPI payment request link...";
                        });
                        
                        Timer(const Duration(milliseconds: 1000), () {
                          if (!context.mounted) return;
                          setGatewayState(() {
                            gatewayMessage = "Waiting for patient to authorize UPI intent alert...";
                          });
                          
                          Timer(const Duration(milliseconds: 1500), () {
                            if (!context.mounted) return;
                            setGatewayState(() {
                              gatewayMessage = "NPCI network response: Success. finalising transfer...";
                            });
                            
                            Timer(const Duration(milliseconds: 1000), () {
                              if (!context.mounted) return;
                              setGatewayState(() {
                                gatewayStep = "Success";
                              });
                              
                              Timer(const Duration(milliseconds: 1000), () {
                                if (!context.mounted) return;
                                Navigator.pop(context);
                                _processCheckoutComplete(chargeTotal, subtotal, discountAmount, taxAmount);
                              });
                            });
                          });
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: Text("Simulate Patient Scan & Pay", style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ],
                );
              } else {
                bodyContent = Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        "Secure Card Payment Terminal",
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Simulated Stripe Card Tokenization Integration",
                        style: GoogleFonts.inter(color: Colors.white30, fontSize: 10),
                      ),
                      const Divider(color: Colors.white12, height: 24),
                      
                      TextFormField(
                        controller: nameController,
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 12.5),
                        decoration: _buildGatewayInputDeco("Cardholder Name", Icons.person_outline),
                        validator: (value) => value == null || value.isEmpty ? "Enter cardholder name" : null,
                      ),
                      const SizedBox(height: 12),
                      
                      TextFormField(
                        controller: cardNumberController,
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 12.5),
                        keyboardType: TextInputType.number,
                        decoration: _buildGatewayInputDeco("Card Number (16 Digits)", Icons.credit_card_outlined),
                        validator: (value) {
                          if (value == null || value.isEmpty) return "Enter card number";
                          if (value.replaceAll(' ', '').length != 16) return "Must be exactly 16 digits";
                          return null;
                        },
                        onChanged: (val) {
                          String text = val.replaceAll(' ', '');
                          if (text.length > 16) text = text.substring(0, 16);
                          String formatted = "";
                          for (int i = 0; i < text.length; i++) {
                            if (i > 0 && i % 4 == 0) formatted += " ";
                            formatted += text[i];
                          }
                          if (formatted != val) {
                            cardNumberController.value = TextEditingValue(
                              text: formatted,
                              selection: TextSelection.collapsed(offset: formatted.length),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: expiryController,
                              style: GoogleFonts.inter(color: Colors.white, fontSize: 12.5),
                              keyboardType: TextInputType.number,
                              decoration: _buildGatewayInputDeco("Expiry (MM/YY)", Icons.calendar_today_outlined),
                              validator: (value) {
                                if (value == null || value.isEmpty) return "Required";
                                if (!value.contains('/')) return "Use MM/YY";
                                return null;
                              },
                              onChanged: (val) {
                                String text = val.replaceAll('/', '');
                                if (text.length > 4) text = text.substring(0, 4);
                                String formatted = text;
                                if (text.length > 2) {
                                  formatted = "${text.substring(0, 2)}/${text.substring(2)}";
                                }
                                if (formatted != val) {
                                  expiryController.value = TextEditingValue(
                                    text: formatted,
                                    selection: TextSelection.collapsed(offset: formatted.length),
                                  );
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: cvvController,
                              style: GoogleFonts.inter(color: Colors.white, fontSize: 12.5),
                              keyboardType: TextInputType.number,
                              obscureText: true,
                              decoration: _buildGatewayInputDeco("CVV (3 Digits)", Icons.lock_outline),
                              validator: (value) {
                                if (value == null || value.isEmpty) return "Required";
                                if (value.length != 3) return "Must be 3 digits";
                                return null;
                              },
                              onChanged: (val) {
                                if (val.length > 3) {
                                  cvvController.value = TextEditingValue(
                                    text: val.substring(0, 3),
                                    selection: const TextSelection.collapsed(offset: 3),
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            setGatewayState(() {
                              gatewayStep = "Processing";
                              gatewayMessage = "Authorizing credit transaction token...";
                            });
                            
                            Timer(const Duration(milliseconds: 1200), () {
                              if (!context.mounted) return;
                              setGatewayState(() {
                                gatewayMessage = "Processing 3D-Secure bank challenge authorization...";
                              });
                              
                              Timer(const Duration(milliseconds: 1500), () {
                                if (!context.mounted) return;
                                setGatewayState(() {
                                  gatewayMessage = "Transaction authorized. Capturing funds...";
                                });
                                
                                Timer(const Duration(milliseconds: 1000), () {
                                  if (!context.mounted) return;
                                  setGatewayState(() {
                                    gatewayStep = "Success";
                                  });
                                  
                                  Timer(const Duration(milliseconds: 1000), () {
                                    if (!context.mounted) return;
                                    Navigator.pop(context);
                                    _processCheckoutComplete(chargeTotal, subtotal, discountAmount, taxAmount);
                                  });
                                });
                              });
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF24C06F),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text("Pay ₹${chargeTotal.toStringAsFixed(2)} Now", style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ],
                  ),
                );
              }
            }

            return Dialog(
              backgroundColor: const Color(0xFF0F132E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.white.withOpacity(0.08)),
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                constraints: const BoxConstraints(maxWidth: 450),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.payment, color: Color(0xFF3F8CFF), size: 20),
                              const SizedBox(width: 10),
                              Text(
                                "CallHealth Secure Pay",
                                style: GoogleFonts.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          if (gatewayStep == "Initial")
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close, color: Colors.white54, size: 18),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      bodyContent,
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _InteractiveKPICard extends StatefulWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _InteractiveKPICard({
    Key? key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  State<_InteractiveKPICard> createState() => _InteractiveKPICardState();
}

class _InteractiveKPICardState extends State<_InteractiveKPICard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()..translate(0.0, _isHovered ? -4.0 : 0.0),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF11152D),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isHovered ? widget.color.withOpacity(0.3) : Colors.white.withOpacity(0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? widget.color.withOpacity(0.08)
                  : Colors.black.withOpacity(0.04),
              blurRadius: _isHovered ? 16 : 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.label,
                    style: GoogleFonts.inter(
                      fontSize: 9.5,
                      color: const Color(0xFF94A3B8),
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    widget.value,
                    style: GoogleFonts.inter(
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: widget.color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                widget.icon,
                color: widget.color,
                size: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QRCodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    double cellSize = size.width / 21;
    
    void drawFinderPattern(double ox, double oy) {
      canvas.drawRect(Rect.fromLTWH(ox, oy, cellSize * 7, cellSize * 7), paint);
      canvas.drawRect(Rect.fromLTWH(ox + cellSize, oy + cellSize, cellSize * 5, cellSize * 5), Paint()..color = const Color(0xFF0F132E));
      canvas.drawRect(Rect.fromLTWH(ox + cellSize * 2, oy + cellSize * 2, cellSize * 3, cellSize * 3), paint);
    }

    drawFinderPattern(0, 0);
    drawFinderPattern(size.width - cellSize * 7, 0);
    drawFinderPattern(0, size.height - cellSize * 7);

    final random = math.Random(42);
    for (int r = 0; r < 21; r++) {
      for (int c = 0; c < 21; c++) {
        if (r < 8 && c < 8) continue;
        if (r < 8 && c > 12) continue;
        if (r > 12 && c < 8) continue;
        
        if (random.nextBool()) {
          canvas.drawRect(Rect.fromLTWH(c * cellSize, r * cellSize, cellSize, cellSize), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ServiceCatalogTile extends StatefulWidget {
  final Map<String, dynamic> item;
  final VoidCallback onTap;
  final Color accentColor;

  const _ServiceCatalogTile({
    Key? key,
    required this.item,
    required this.onTap,
    required this.accentColor,
  }) : super(key: key);

  @override
  State<_ServiceCatalogTile> createState() => _ServiceCatalogTileState();
}

class _ServiceCatalogTileState extends State<_ServiceCatalogTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: _isHovered 
            ? (Matrix4.identity()..translate(0, -2, 0)) 
            : Matrix4.identity(),
        decoration: BoxDecoration(
          color: _isHovered ? const Color(0xFF1C2252) : const Color(0xFF15193B),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _isHovered 
                ? widget.accentColor.withOpacity(0.35) 
                : Colors.white.withOpacity(0.04),
            width: 1.2,
          ),
          boxShadow: _isHovered 
              ? [
                  BoxShadow(
                    color: widget.accentColor.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ] 
              : [],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: _isHovered 
                              ? widget.accentColor.withOpacity(0.20) 
                              : widget.accentColor.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          widget.item['icon'] as IconData,
                          size: 13,
                          color: widget.accentColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.item['name'],
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.item['code'],
                        style: GoogleFonts.inter(
                          color: Colors.white30,
                          fontSize: 8.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        "₹${widget.item['price'].toStringAsFixed(2)}",
                        style: GoogleFonts.inter(
                          color: const Color(0xFF24C06F),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
