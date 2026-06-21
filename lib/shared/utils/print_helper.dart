import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../features/billing/domain/models/billing.dart';

class PrintHelper {
  static Future<void> printInvoice(Invoice invoice) async {
    final pdfBytes = await generatePdf(invoice);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: 'Invoice-${invoice.id}',
    );
  }

  static Future<void> downloadInvoicePdf(Invoice invoice) async {
    final pdfBytes = await generatePdf(invoice);
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: 'Invoice-${invoice.id}.pdf',
    );
  }

  static Future<Uint8List> generatePdf(Invoice invoice) async {
    final pdf = pw.Document();

    final primaryColor = PdfColor.fromHex('#3F8CFF');
    final secondaryColor = PdfColor.fromHex('#24C06F');
    final textDark = PdfColor.fromHex('#0F172A');
    final textLight = PdfColor.fromHex('#64748B');
    final borderLight = PdfColor.fromHex('#E2E8F0');
    final bgLight = PdfColor.fromHex('#F8FAFC');
    final borderSubtle = PdfColor.fromHex('#F1F5F9');

    // Load fonts dynamically from Google Fonts for Rupee symbol support
    pw.Font? fontRegular;
    pw.Font? fontBold;
    try {
      fontRegular = await PdfGoogleFonts.interRegular();
      fontBold = await PdfGoogleFonts.interBold();
    } catch (e) {
      // Offline fallback
      fontRegular = pw.Font.helvetica();
      fontBold = pw.Font.helveticaBold();
    }

    // Load praCHtiz logo image
    pw.MemoryImage? logoImage;
    try {
      final ByteData logoData = await rootBundle.load('assets/logos/praCHtiz_logo.png');
      final Uint8List logoBytes = logoData.buffer.asUint8List();
      logoImage = pw.MemoryImage(logoBytes);
    } catch (e) {
      // Fallback if logo fails to load
    }

    final theme = pw.ThemeData.withFont(
      base: fontRegular,
      bold: fontBold,
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: theme,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // Header Row
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      if (logoImage != null) ...[
                        pw.Container(
                          height: 38,
                          child: pw.Image(logoImage, fit: pw.BoxFit.contain),
                        ),
                        pw.SizedBox(width: 12),
                      ] else ...[
                        pw.Text(
                          'praCHtiz™',
                          style: pw.TextStyle(
                            color: primaryColor,
                            fontSize: 22,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(width: 12),
                      ],
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'CallHealth® CheKUp',
                            style: pw.TextStyle(
                              color: primaryColor,
                              fontSize: 13,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            'Healthcare at Your Doorstep',
                            style: pw.TextStyle(
                              color: textLight,
                              fontSize: 8.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'INVOICE RECEIPT',
                        style: pw.TextStyle(
                          color: textDark,
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Invoice #: ${invoice.id}',
                        style: pw.TextStyle(
                          color: textLight,
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        'Date: ${invoice.date}',
                        style: pw.TextStyle(
                          color: textLight,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 16),
              pw.Divider(color: borderLight, thickness: 1.5),
              pw.SizedBox(height: 16),

              // Metadata Row
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'BILLED TO (PATIENT)',
                        style: pw.TextStyle(
                          color: textLight,
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        invoice.patientName,
                        style: pw.TextStyle(
                          color: textDark,
                          fontSize: 13,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'PAYMENT INFORMATION',
                        style: pw.TextStyle(
                          color: textLight,
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Method: ${invoice.paymentMethod}',
                        style: pw.TextStyle(
                          color: textDark,
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        'Status: PAID',
                        style: pw.TextStyle(
                          color: secondaryColor,
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 24),

              // Table
              pw.Table(
                border: pw.TableBorder(
                  bottom: pw.BorderSide(color: borderLight, width: 1),
                  horizontalInside: pw.BorderSide(color: borderSubtle, width: 0.5),
                ),
                columnWidths: const {
                  0: pw.FlexColumnWidth(3.5), // Description & Code
                  1: pw.FlexColumnWidth(1.0), // Qty
                  2: pw.FlexColumnWidth(1.5), // Unit Price
                  3: pw.FlexColumnWidth(1.5), // Amount
                },
                children: [
                  // Table Header
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: bgLight),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                        child: pw.Text('DESCRIPTION', style: pw.TextStyle(color: textLight, fontSize: 9, fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                        child: pw.Text('QTY', style: pw.TextStyle(color: textLight, fontSize: 9, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                        child: pw.Align(
                          alignment: pw.Alignment.centerRight,
                          child: pw.Text('UNIT PRICE', style: pw.TextStyle(color: textLight, fontSize: 9, fontWeight: pw.FontWeight.bold)),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                        child: pw.Align(
                          alignment: pw.Alignment.centerRight,
                          child: pw.Text('AMOUNT', style: pw.TextStyle(color: textLight, fontSize: 9, fontWeight: pw.FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                  // Table Rows
                  ...invoice.items.map((item) {
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(item.description, style: pw.TextStyle(color: textDark, fontSize: 11, fontWeight: pw.FontWeight.bold)),
                              pw.SizedBox(height: 2),
                              pw.Text(item.code, style: pw.TextStyle(color: textLight, fontSize: 9)),
                            ],
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                          child: pw.Text('${item.quantity}', style: pw.TextStyle(color: textDark, fontSize: 11), textAlign: pw.TextAlign.center),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                          child: pw.Align(
                            alignment: pw.Alignment.centerRight,
                            child: pw.Text('₹${item.unitPrice.toStringAsFixed(2)}', style: pw.TextStyle(color: textDark, fontSize: 11)),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                          child: pw.Align(
                            alignment: pw.Alignment.centerRight,
                            child: pw.Text('₹${item.total.toStringAsFixed(2)}', style: pw.TextStyle(color: textDark, fontSize: 11, fontWeight: pw.FontWeight.bold)),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),

              pw.SizedBox(height: 20),

              // Summary Section
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Container(
                    width: 250,
                    child: pw.Column(
                      children: [
                        _buildSummaryRow('Subtotal', '₹${invoice.subtotal.toStringAsFixed(2)}', textLight, textDark),
                        pw.SizedBox(height: 4),
                        _buildSummaryRow('Discount (${invoice.discount.toInt()}%)', '-₹${invoice.discountAmount.toStringAsFixed(2)}', textLight, PdfColor.fromHex('#EF4444')),
                        pw.SizedBox(height: 4),
                        _buildSummaryRow('Sales Tax (5%)', '+₹${invoice.taxAmount.toStringAsFixed(2)}', textLight, textDark),
                        pw.SizedBox(height: 8),
                        pw.Divider(color: borderLight, thickness: 1),
                        pw.SizedBox(height: 8),
                        _buildSummaryRow('Total Due', '₹${invoice.total.toStringAsFixed(2)}', textDark, secondaryColor, isTotal: true),
                      ],
                    ),
                  ),
                ],
              ),

              pw.Spacer(),

              // Barcode and Footer
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Container(
                    width: 200,
                    height: 45,
                    child: pw.BarcodeWidget(
                      barcode: pw.Barcode.code128(),
                      data: invoice.id,
                      drawText: false,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    invoice.id,
                    style: pw.TextStyle(color: textLight, fontSize: 9, letterSpacing: 1),
                  ),
                  pw.SizedBox(height: 15),
                  pw.Text(
                    'Thank you for choosing PraCHtiz EMR.',
                    style: pw.TextStyle(color: textLight, fontSize: 9, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    'Powered by CallHealth POS Billing Suite.',
                    style: pw.TextStyle(color: textLight, fontSize: 8),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildSummaryRow(String label, String value, PdfColor labelColor, PdfColor valueColor, {bool isTotal = false}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            color: labelColor,
            fontSize: isTotal ? 12 : 10,
            fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            color: valueColor,
            fontSize: isTotal ? 14 : 10,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
