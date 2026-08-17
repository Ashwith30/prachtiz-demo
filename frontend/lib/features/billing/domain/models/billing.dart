enum InvoiceStatus { paid, unpaid, pending, overdue, partial }

class BillingItem {
  final String code;
  final String description;
  final double unitPrice;
  final int quantity;

  BillingItem({
    required this.code,
    required this.description,
    required this.unitPrice,
    required this.quantity,
  });

  double get total => unitPrice * quantity;
}

class Invoice {
  final String id;
  final String patientName;
  final String date;
  final String? dueDate;
  final List<BillingItem> items;
  final double discount;
  final double taxRate; // e.g. 0.05 for 5%
  final InvoiceStatus status;
  final String paymentMethod;

  Invoice({
    required this.id,
    required this.patientName,
    required this.date,
    this.dueDate,
    required this.items,
    this.discount = 0.0,
    this.taxRate = 0.05,
    required this.status,
    this.paymentMethod = "Cash",
  });

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.total);
  double get discountAmount => subtotal * (discount / 100.0);
  double get taxAmount => (subtotal - discountAmount) * taxRate;
  double get total => (subtotal - discountAmount) + taxAmount;

  Invoice copyWith({
    String? id,
    String? patientName,
    String? date,
    String? dueDate,
    List<BillingItem>? items,
    double? discount,
    double? taxRate,
    InvoiceStatus? status,
    String? paymentMethod,
  }) {
    return Invoice(
      id: id ?? this.id,
      patientName: patientName ?? this.patientName,
      date: date ?? this.date,
      dueDate: dueDate ?? this.dueDate,
      items: items ?? this.items,
      discount: discount ?? this.discount,
      taxRate: taxRate ?? this.taxRate,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }
}
