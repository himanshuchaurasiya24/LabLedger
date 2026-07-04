import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/models/bill_model.dart';
import 'package:labledger/models/center_detail_model_with_subscription.dart';
import 'package:labledger/providers/authentication_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';

/// Generates a PDF receipt for a single bill, matching the pdf_type1 design.
Future<Uint8List> createBillReceiptPDF({
  required Bill bill,
  required WidgetRef ref,
}) async {
  final pdf = pw.Document();

  final liteFont = await rootBundle.load("assets/fonts/Ubuntu-Regular.ttf");
  final ttf = pw.Font.ttf(liteFont);

  final boldFont = await rootBundle.load("assets/fonts/Ubuntu-Bold.ttf");
  final boldTTF = pw.Font.ttf(boldFont);

  final authResponse = await ref.read(currentUserProvider.future);
  final centerDetail = authResponse.centerDetail;

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.all(defaultPadding / microPadding),
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: _buildReceiptContent(
            bill,
            centerDetail,
            ttf,
            boldTTF,
          ),
        );
      },
    ),
  );

  return pdf.save();
}

List<pw.Widget> _buildReceiptContent(
  Bill bill,
  CenterDetail centerDetail,
  pw.Font font,
  pw.Font boldFont,
) {
  const tealColor = PdfColor.fromInt(0xFF14B8A6);
  final deepBlueColor = PdfColor.fromInt(0xFF0072B5);
  const lightBlueColor = PdfColor.fromInt(0xFFDCEEF7);

  return [
    // ── Header with gradient ──
    pw.Container(
      padding: const pw.EdgeInsets.all(mediumPadding),
      decoration: pw.BoxDecoration(
        gradient: pw.LinearGradient(
          colors: [deepBlueColor, tealColor],
          begin: pw.Alignment.centerLeft,
          end: pw.Alignment.centerRight,
        ),
        borderRadius: const pw.BorderRadius.only(
          topLeft: pw.Radius.circular(defaultRadius),
          topRight: pw.Radius.circular(defaultRadius),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Left: Bill info
          pw.Expanded(
            flex: 2,
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Bill avatar
                pw.Container(
                  width: 48,
                  height: 48,
                  decoration: pw.BoxDecoration(
                    color: PdfColors.white,
                    shape: pw.BoxShape.circle,
                    border: pw.Border.all(color: PdfColors.white, width: 2),
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      "₹",
                      style: pw.TextStyle(
                        font: boldFont,
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                        color: deepBlueColor,
                      ),
                    ),
                  ),
                ),
                pw.SizedBox(width: 14),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        "BILL RECEIPT",
                        style: pw.TextStyle(
                          font: boldFont,
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Row(
                        children: [
                          _buildInfoChip(
                            bill.billNumber ?? 'N/A',
                            font,
                            PdfColors.white,
                            PdfColors.teal,
                          ),
                          pw.SizedBox(width: smallPadding),
                          _buildInfoChip(
                            bill.billStatus,
                            font,
                            PdfColors.white,
                            bill.billStatus == 'Fully Paid'
                                ? PdfColors.green700
                                : bill.billStatus == 'Partially Paid'
                                    ? PdfColors.amber700
                                    : PdfColors.red700,
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        "Date: ${DateFormat('dd MMM yyyy, hh:mm a').format(bill.dateOfBill)}",
                        style: pw.TextStyle(
                          font: font,
                          fontSize: 8,
                          color: PdfColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Right: Center info
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                centerDetail.centerName,
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
              pw.Text(
                centerDetail.address,
                style: pw.TextStyle(
                  font: font,
                  fontSize: 10,
                  color: PdfColors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    ),

    // ── Patient Details Section ──
    pw.Container(
      padding: const pw.EdgeInsets.all(mediumPadding),
      decoration: const pw.BoxDecoration(color: lightBlueColor),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  "PATIENT DETAILS",
                  style: pw.TextStyle(
                    font: boldFont,
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    color: deepBlueColor,
                  ),
                ),
                pw.SizedBox(height: 6),
                _buildDetailRow("Name", bill.patientName, font, boldFont),
                pw.SizedBox(height: 3),
                _buildDetailRow(
                  "Age / Sex",
                  "${bill.patientAge}y / ${bill.patientSex}",
                  font,
                  boldFont,
                ),
                pw.SizedBox(height: 3),
                _buildDetailRow(
                  "Phone",
                  bill.patientPhoneNumber ?? 'N/A',
                  font,
                  boldFont,
                ),
              ],
            ),
          ),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  "REFERRAL DETAILS",
                  style: pw.TextStyle(
                    font: boldFont,
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    color: deepBlueColor,
                  ),
                ),
                pw.SizedBox(height: 6),
                _buildDetailRow(
                  "Doctor",
                  _formatDoctor(bill.referredByDoctorOutput),
                  font,
                  boldFont,
                ),
                pw.SizedBox(height: 3),
                _buildDetailRow(
                  "Franchise",
                  _formatFranchise(bill.franchiseNameOutput),
                  font,
                  boldFont,
                ),
                pw.SizedBox(height: 3),
                _buildDetailRow(
                  "Test Date",
                  DateFormat('dd MMM yyyy').format(bill.dateOfTest),
                  font,
                  boldFont,
                ),
              ],
            ),
          ),
        ],
      ),
    ),

    pw.SizedBox(height: 2),

    // ── Diagnosis Types Table ──
    pw.Table(
      border: pw.TableBorder.symmetric(
        inside: pw.BorderSide(color: PdfColors.grey200, width: 0.5),
      ),
      columnWidths: {
        0: const pw.FixedColumnWidth(30),
        1: const pw.FlexColumnWidth(3),
        2: const pw.FlexColumnWidth(2),
        3: const pw.FixedColumnWidth(80),
      },
      children: [
        // Table Header
        pw.TableRow(
          decoration: pw.BoxDecoration(color: deepBlueColor),
          children: ['#', 'Diagnosis', 'Category', 'Price'].map(
            (header) => pw.Padding(
              padding: const pw.EdgeInsets.symmetric(
                horizontal: smallPadding,
                vertical: formPadding,
              ),
              child: pw.Text(
                header,
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 8,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
                textAlign: pw.TextAlign.center,
              ),
            ),
          ).toList(),
        ),
        // Data rows
        ...?bill.diagnosisTypesOutput?.asMap().entries.map((entry) {
          final index = entry.key;
          final dt = entry.value;
          final isEven = index % 2 == 0;
          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: isEven ? PdfColors.white : PdfColors.grey50,
            ),
            children: [
              _buildCell('${index + 1}', font, 7.5),
              _buildCell(
                dt['name']?.toString() ?? 'Unknown',
                font,
                7.5,
                align: pw.TextAlign.left,
              ),
              _buildCell(
                dt['category_name']?.toString() ?? 'Unknown',
                font,
                7.5,
              ),
              _buildCell(
                "₹${NumberFormat('#,##,###').format(dt['price'] ?? 0)}",
                boldFont,
                7.5,
                color: PdfColors.grey800,
              ),
            ],
          );
        }),
      ],
    ),

    pw.SizedBox(height: 2),

    // ── Amount Summary ──
    pw.Container(
      padding: const pw.EdgeInsets.all(mediumPadding),
      decoration: const pw.BoxDecoration(
        color: PdfColor.fromInt(0xFFF0F4F8),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  "AMOUNT SUMMARY",
                  style: pw.TextStyle(
                    font: boldFont,
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    color: deepBlueColor,
                  ),
                ),
                pw.SizedBox(height: 8),
                _buildAmountRow(
                  "Total Amount",
                  bill.totalAmount,
                  font,
                  boldFont,
                  PdfColors.grey800,
                ),
                pw.SizedBox(height: 4),
                _buildAmountRow(
                  "Paid Amount",
                  bill.paidAmount,
                  font,
                  boldFont,
                  PdfColors.blue800,
                ),
                pw.SizedBox(height: 4),
                _buildAmountRow(
                  "Center Discount",
                  bill.discByCenter,
                  font,
                  boldFont,
                  PdfColors.purple700,
                ),
                pw.SizedBox(height: 4),
                _buildAmountRow(
                  "Doctor Discount",
                  bill.discByDoctor,
                  font,
                  boldFont,
                  PdfColors.orange700,
                ),
              ],
            ),
          ),
          // Grand Total
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(
              horizontal: mediumPadding,
              vertical: defaultPadding,
            ),
            decoration: pw.BoxDecoration(
              gradient: pw.LinearGradient(
                colors: [deepBlueColor, tealColor],
                begin: pw.Alignment.topLeft,
                end: pw.Alignment.bottomRight,
              ),
              borderRadius: pw.BorderRadius.circular(smallRadius),
            ),
            child: pw.Column(
              children: [
                pw.Text(
                  "TOTAL",
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 8,
                    color: PdfColors.white,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  "₹${NumberFormat('#,##,###').format(bill.totalAmount)}",
                  style: pw.TextStyle(
                    font: boldFont,
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
                pw.SizedBox(height: 4),
                _buildInfoChip(
                  bill.billStatus,
                  font,
                  PdfColors.white,
                  bill.billStatus == 'Fully Paid'
                      ? PdfColors.green700
                      : bill.billStatus == 'Partially Paid'
                          ? PdfColors.amber700
                          : PdfColors.red700,
                ),
              ],
            ),
          ),
        ],
      ),
    ),

    // ── Footer ──
    _buildModernFooter(font, tealColor),
  ];
}

// ── Helper widgets ──

pw.Widget _buildInfoChip(
  String text,
  pw.Font font,
  PdfColor color, [
  PdfColor? bgColor,
]) {
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: smallPadding, vertical: 3),
    decoration: pw.BoxDecoration(
      color: bgColor ?? PdfColors.teal,
      borderRadius: pw.BorderRadius.circular(tinyRadius),
    ),
    child: pw.Text(
      text,
      style: pw.TextStyle(font: font, fontSize: 8, color: color),
    ),
  );
}

pw.Widget _buildDetailRow(
  String label,
  String value,
  pw.Font font,
  pw.Font boldFont,
) {
  return pw.Row(
    children: [
      pw.SizedBox(
        width: 60,
        child: pw.Text(
          label,
          style: pw.TextStyle(
            font: font,
            fontSize: 8,
            color: PdfColors.grey600,
          ),
        ),
      ),
      pw.Text(
        ":  ",
        style: pw.TextStyle(font: font, fontSize: 8, color: PdfColors.grey600),
      ),
      pw.Expanded(
        child: pw.Text(
          value,
          style: pw.TextStyle(
            font: boldFont,
            fontSize: 8.5,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.grey800,
          ),
        ),
      ),
    ],
  );
}

pw.Widget _buildCell(
  String text,
  pw.Font font,
  double fontSize, {
  PdfColor? color,
  pw.TextAlign align = pw.TextAlign.center,
}) {
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(
      horizontal: smallPadding,
      vertical: smallPadding,
    ),
    child: pw.Text(
      text,
      style: pw.TextStyle(
        font: font,
        fontSize: fontSize,
        color: color ?? PdfColors.grey800,
      ),
      textAlign: align,
      maxLines: 3,
      overflow: pw.TextOverflow.clip,
    ),
  );
}

pw.Widget _buildAmountRow(
  String label,
  int amount,
  pw.Font font,
  pw.Font boldFont,
  PdfColor valueColor,
) {
  return pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: [
      pw.Text(
        label,
        style: pw.TextStyle(font: font, fontSize: 9, color: PdfColors.grey700),
      ),
      pw.Text(
        "₹${NumberFormat('#,##,###').format(amount)}",
        style: pw.TextStyle(
          font: boldFont,
          fontSize: 9,
          fontWeight: pw.FontWeight.bold,
          color: valueColor,
        ),
      ),
    ],
  );
}

pw.Widget _buildModernFooter(pw.Font font, PdfColor tealColor) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(defaultPadding),
    decoration: const pw.BoxDecoration(
      color: PdfColors.grey50,
      borderRadius: pw.BorderRadius.only(
        bottomLeft: pw.Radius.circular(defaultRadius),
        bottomRight: pw.Radius.circular(defaultRadius),
      ),
    ),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Row(
          children: [
            pw.Container(
              width: 3,
              height: 12,
              decoration: pw.BoxDecoration(
                color: tealColor,
                borderRadius: pw.BorderRadius.circular(microRadius),
              ),
            ),
            pw.SizedBox(width: 6),
            pw.Text(
              'Powered by LabLedger',
              style: pw.TextStyle(
                font: font,
                fontSize: 7.5,
                color: PdfColors.grey700,
              ),
            ),
          ],
        ),
        pw.Text(
          'Generated on ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}',
          style: pw.TextStyle(
            font: font,
            fontSize: 7,
            color: PdfColors.grey600,
          ),
        ),
      ],
    ),
  );
}

String _formatDoctor(Map<String, dynamic>? doctorOutput) {
  if (doctorOutput == null) return 'N/A';
  final firstName = doctorOutput['first_name'] ?? '';
  final lastName = doctorOutput['last_name'] ?? '';
  if (firstName.isEmpty && lastName.isEmpty) return 'N/A';
  return 'Dr. $firstName $lastName'.trim();
}

String _formatFranchise(Map<String, dynamic>? franchiseOutput) {
  if (franchiseOutput == null) return 'N/A';
  return franchiseOutput['franchise_name']?.toString() ?? 'N/A';
}
