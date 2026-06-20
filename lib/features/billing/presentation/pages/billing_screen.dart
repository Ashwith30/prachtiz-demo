import "package:prachtiz_flutter/core/theme/app_colors.dart";
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/models/billing.dart';
import '../../../../theme/colors.dart';
import '../../../../theme/styles.dart';

class BillingScreen extends StatefulWidget {
  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
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

  void _processCheckout(double total, double subtotal, double discountAmount, double taxAmount) {
    if (_cart.isEmpty) return;

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

    // Filter catalog based on search query
    final filteredCatalog = _catalog.where((item) {
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
                      _buildRightCartSummary(cartSubtotal, cartDiscountAmount, cartTaxAmount, cartTotal),
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
                        child: _buildRightCartSummary(cartSubtotal, cartDiscountAmount, cartTaxAmount, cartTotal),
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
                  Text("Quick Add Catalog Services", style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
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
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1.6,
                  ),
                  itemCount: filteredCatalog.length,
                  itemBuilder: (context, index) {
                    final service = filteredCatalog[index];
                    return _buildServiceTile(service);
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildServiceTile(Map<String, dynamic> item) {
    return InkWell(
      onTap: () => _quickAddService(item),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF15193B),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.04)),
        ),
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.12),
                  radius: 12,
                  child: Icon(item['icon'] as IconData, size: 12, color: AppColors.primary),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item['name'],
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(item['code'], style: GoogleFonts.inter(color: Colors.white30, fontSize: 8)),
                Text("₹${item['price'].toStringAsFixed(2)}", style: GoogleFonts.inter(color: const Color(0xFF24C06F), fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
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

  Widget _buildRightCartSummary(double subtotal, double discount, double tax, double total) {
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
          if (_cart.isEmpty)
            Container(
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
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _cart.length,
              itemBuilder: (context, index) {
                final item = _cart[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Row(
                    children: [
                      // Item Name & Sub details
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

                      // Quantity Adjuster Controls
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

                      // Item Total Price
                      Text(
                        "₹${item.total.toStringAsFixed(2)}",
                        style: GoogleFonts.inter(color: Colors.white70, fontSize: 11.5, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 4),

                      // Delete complete
                      IconButton(
                        icon: const Icon(Icons.close, size: 14, color: Color(0xFFEF4444)),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => setState(() => _cart.removeAt(index)),
                      ),
                    ],
                  ),
                );
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
          
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 800),
              child: DataTable(
                columnSpacing: 24,
                showCheckboxColumn: false,
                headingRowHeight: 32,
                dataRowHeight: 40,
                horizontalMargin: 8,
                columns: [
                  DataColumn(label: Text("INVOICE ID", style: GoogleFonts.inter(color: Colors.white54, fontSize: 9.5, fontWeight: FontWeight.bold))),
                  DataColumn(label: Text("PATIENT NAME", style: GoogleFonts.inter(color: Colors.white54, fontSize: 9.5, fontWeight: FontWeight.bold))),
                  DataColumn(label: Text("DATE", style: GoogleFonts.inter(color: Colors.white54, fontSize: 9.5, fontWeight: FontWeight.bold))),
                  DataColumn(label: Text("TOTAL AMOUNT", style: GoogleFonts.inter(color: Colors.white54, fontSize: 9.5, fontWeight: FontWeight.bold))),
                  DataColumn(label: Text("PAYMENT METHOD", style: GoogleFonts.inter(color: Colors.white54, fontSize: 9.5, fontWeight: FontWeight.bold))),
                  DataColumn(label: Text("STATUS", style: GoogleFonts.inter(color: Colors.white54, fontSize: 9.5, fontWeight: FontWeight.bold))),
                  DataColumn(label: Text("ACTIONS", style: GoogleFonts.inter(color: Colors.white54, fontSize: 9.5, fontWeight: FontWeight.bold))),
                ],
                rows: _recentInvoices.map((inv) {
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
                  
                  return DataRow(
                    cells: [
                      DataCell(Text(inv.id, style: GoogleFonts.inter(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold))),
                      DataCell(Text(inv.patientName, style: GoogleFonts.inter(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600))),
                      DataCell(Text(inv.date, style: GoogleFonts.inter(color: Colors.white54, fontSize: 10.5))),
                      DataCell(Text("₹${inv.total.toStringAsFixed(2)}", style: GoogleFonts.inter(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                      DataCell(Text(inv.paymentMethod, style: GoogleFonts.inter(color: Colors.white54, fontSize: 10.5))),
                      DataCell(
                        Container(
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
                      DataCell(
                        Row(
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
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
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
            ElevatedButton.icon(
              icon: const Icon(Icons.print, size: 14, color: Colors.white),
              label: Text("Print Invoice Receipt", style: GoogleFonts.inter(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: const Color(0xFF24C06F),
                    content: Text("Simulated sending INV-${inv.id} receipt to clinic printer.", style: GoogleFonts.inter(color: Colors.white)),
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
