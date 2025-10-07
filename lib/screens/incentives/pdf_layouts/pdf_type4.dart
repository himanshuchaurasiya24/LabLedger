import 'package:labledger/models/center_detail_model_with_subscription.dart';
import 'package:labledger/providers/incenitve_generator_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:labledger/models/incentive_model.dart';
import 'package:pdf/pdf.dart';

pw.Widget buildBillsTableType4(
  DoctorReport doctorReport,
  Map<String, bool> selectedFields,
  WidgetRef ref,
  pw.Font font,
  pw.Font boldFont,
  CenterDetail centerDetail,
) {
  // --- Color Palette ---
  const primaryColor = PdfColor.fromInt(0xFF0D47A1); // Deep Blue
  const secondaryColor = PdfColor.fromInt(0xFF00897B); // Teal
  const lightGreyColor = PdfColor.fromInt(0xFFF5F5F5);
  const darkGreyColor = PdfColor.fromInt(0xFF424242);
  const headerTextColor = PdfColor.fromInt(0xFFFFFFFF);

  final bills = doctorReport.bills;
  final headers = <String>[];
  final Map<int, pw.TableColumnWidth> columnWidths = {};

  // --- Dynamically Build Headers and Column Widths ---
  int colIndex = 0;
  if (selectedFields['dateOfBill'] ?? false) {
    headers.add('Date');
    columnWidths[colIndex++] = const pw.FixedColumnWidth(55);
  }
  if (selectedFields['patientName'] ?? false) {
    headers.add('Patient Name');
    columnWidths[colIndex++] = const pw.FlexColumnWidth(2.2);
  }
  if (selectedFields['ageAndSex'] ?? false) {
    headers.add('Age/Sex');
    columnWidths[colIndex++] = const pw.FixedColumnWidth(45);
  }
  if (selectedFields['diagnosisTypeOutput'] ?? false) {
    headers.add('Diagnosis');
    columnWidths[colIndex++] = const pw.FlexColumnWidth(2.5);
  }
  if (selectedFields['totalAmount'] ?? false) {
    headers.add('Total Amt.');
    columnWidths[colIndex++] = const pw.FixedColumnWidth(55);
  }
  if (selectedFields['paidAmount'] ?? false) {
    headers.add('Paid Amt.');
    columnWidths[colIndex++] = const pw.FixedColumnWidth(55);
  }
  if (selectedFields['incentiveAmount'] ?? false) {
    headers.add('Incentive');
    columnWidths[colIndex++] = const pw.FixedColumnWidth(60);
  }
  if (selectedFields['billNumber'] ?? false) {
    headers.add('Bill No.');
    columnWidths[colIndex++] = const pw.FlexColumnWidth(1.5);
  }

  if (headers.isEmpty) return pw.Container();

  // --- Calculate Totals for Summary ---
  final totalBillAmount = bills.fold(0, (sum, bill) => sum + bill.totalAmount);
  final totalPaidAmount = bills.fold(0, (sum, bill) => sum + bill.paidAmount);
  final totalDiscount = bills.fold(
    0,
    (sum, bill) => sum + bill.discByDoctor + bill.discByCenter,
  );

  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      // --- Main Header with Doctor and Center Info ---
      _buildReportHeader(
        ref,
        doctorReport,
        centerDetail,
        font,
        boldFont,
        primaryColor,
        headerTextColor,
      ), // ✅ Pass ref here
      pw.SizedBox(height: 20),

      // --- Summary Cards Section ---
      _buildSummarySection(
        font: font,
        boldFont: boldFont,
        bills: bills,
        totalBillAmount: totalBillAmount,
        totalPaidAmount: totalPaidAmount,
        totalDiscount: totalDiscount,
        totalIncentive: doctorReport.totalIncentive,
      ),
      pw.SizedBox(height: 20),

      // --- Table Title ---
      pw.Text(
        'Bill Details',
        style: pw.TextStyle(font: boldFont, fontSize: 14, color: primaryColor),
      ),
      pw.Divider(color: lightGreyColor, thickness: 1, height: 5),
      pw.SizedBox(height: 10),

      // --- Bills Table ---
      pw.Table(
        border: pw.TableBorder.all(color: lightGreyColor, width: 1),
        columnWidths: columnWidths,
        children: [
          // --- Table Header ---
          pw.TableRow(
            decoration: const pw.BoxDecoration(color: primaryColor),
            children: headers
                .map(
                  (header) => pw.Container(
                    padding: const pw.EdgeInsets.all(6),
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      header,
                      style: pw.TextStyle(
                        font: boldFont,
                        fontSize: 8,
                        color: headerTextColor,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),

          // --- Table Rows ---
          ...bills.asMap().entries.map((entry) {
            final index = entry.key;
            final bill = entry.value;
            final isEven = index % 2 == 0;
            final cells = <pw.Widget>[];

            // --- Dynamically Build Cells based on Selection ---
            if (selectedFields['dateOfBill'] ?? false) {
              cells.add(
                _buildTableCell(
                  DateFormat('dd-MM-yyyy').format(bill.dateOfBill),
                  font,
                  isEven: isEven,
                  darkColor: darkGreyColor,
                ),
              );
            }
            if (selectedFields['patientName'] ?? false) {
              cells.add(
                _buildTableCell(
                  bill.patientName,
                  font,
                  isEven: isEven,
                  alignment: pw.Alignment.centerLeft,
                  darkColor: darkGreyColor,
                ),
              );
            }
            if (selectedFields['ageAndSex'] ?? false) {
              cells.add(
                _buildTableCell(
                  "${bill.patientAge}y / ${bill.patientSex[0]}",
                  font,
                  isEven: isEven,
                  darkColor: darkGreyColor,
                ),
              );
            }
            if (selectedFields['diagnosisTypeOutput'] ?? false) {
              cells.add(
                _buildTableCell(
                  _formatDiagnosis(bill),
                  font,
                  isEven: isEven,
                  alignment: pw.Alignment.centerLeft,
                  darkColor: darkGreyColor,
                  fontSize: 7,
                ),
              );
            }
            if (selectedFields['totalAmount'] ?? false) {
              cells.add(
                _buildAmountCell(bill.totalAmount, font, isEven, darkGreyColor),
              );
            }
            if (selectedFields['paidAmount'] ?? false) {
              cells.add(
                _buildAmountCell(bill.paidAmount, font, isEven, secondaryColor),
              );
            }
            if (selectedFields['incentiveAmount'] ?? false) {
              cells.add(
                _buildIncentiveCell(
                  bill.incentiveAmount,
                  boldFont,
                  isEven,
                  secondaryColor,
                ),
              );
            }
            if (selectedFields['billNumber'] ?? false) {
              cells.add(
                _buildTableCell(
                  bill.billNumber,
                  font,
                  isEven: isEven,
                  darkColor: darkGreyColor,
                ),
              );
            }

            return pw.TableRow(
              decoration: pw.BoxDecoration(
                color: isEven ? PdfColors.white : lightGreyColor,
              ),
              children: cells,
            );
          }),
        ],
      ),
    ],
  );
}

// --- Helper Widgets for the New Layout ---

/// ✅ UPDATED: Added WidgetRef to access providers
pw.Widget _buildReportHeader(
  WidgetRef ref,
  DoctorReport doctorReport,
  CenterDetail centerDetail,
  pw.Font font,
  pw.Font boldFont,
  PdfColor primaryColor,
  PdfColor headerTextColor,
) {
  // ✅ Read start and end dates from the provider
  final startDate = ref.read(reportStartDateProvider);
  final endDate = ref.read(reportEndDateProvider);
  final dateRangeText =
      "${DateFormat("dd MMM yyyy").format(startDate)} to ${DateFormat("dd MMM yyyy").format(endDate)}";

  return pw.Container(
    padding: const pw.EdgeInsets.all(12),
    decoration: pw.BoxDecoration(
      color: primaryColor,
      borderRadius: pw.BorderRadius.circular(6),
    ),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              "Dr. ${doctorReport.doctor.firstName} ${doctorReport.doctor.lastName}",
              style: pw.TextStyle(
                font: boldFont,
                fontSize: 18,
                color: headerTextColor,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              doctorReport.doctor.hospitalName ?? 'N/A',
              style: pw.TextStyle(
                font: font,
                fontSize: 10,
                color: headerTextColor,
              ),
            ),
            pw.SizedBox(height: 6),
            // ✅ Added the date range text here
            pw.Text(
              dateRangeText,
              style: pw.TextStyle(
                font: font,
                fontSize: 9,
                color: headerTextColor,
              ),
            ),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              centerDetail.centerName,
              style: pw.TextStyle(
                font: boldFont,
                fontSize: 12,
                color: headerTextColor,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              centerDetail.address,
              style: pw.TextStyle(
                font: font,
                fontSize: 9,
                color: headerTextColor,
              ),
              textAlign: pw.TextAlign.right,
            ),
          ],
        ),
      ],
    ),
  );
}

pw.Widget _buildSummarySection({
  required pw.Font font,
  required pw.Font boldFont,
  required List<IncentiveBill> bills,
  required int totalBillAmount,
  required int totalPaidAmount,
  required int totalDiscount,
  required int totalIncentive,
}) {
  return pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      _buildSummaryCard(
        "Total Referrals",
        bills.length.toString(),
        font,
        boldFont,
      ),
      _buildSummaryCard(
        "Total Bill Amount",
        "₹${NumberFormat('#,##,###').format(totalBillAmount)}",
        font,
        boldFont,
      ),
      _buildSummaryCard(
        "Total Paid Amount",
        "₹${NumberFormat('#,##,###').format(totalPaidAmount)}",
        font,
        boldFont,
      ),
      _buildSummaryCard(
        "Total Discount",
        "₹${NumberFormat('#,##,###').format(totalDiscount)}",
        font,
        boldFont,
      ),
      _buildSummaryCard(
        "Total Incentive",
        "₹${NumberFormat('#,##,###').format(totalIncentive)}",
        font,
        boldFont,
        isHighlighted: true,
      ),
    ],
  );
}

pw.Widget _buildSummaryCard(
  String title,
  String value,
  pw.Font font,
  pw.Font boldFont, {
  bool isHighlighted = false,
}) {
  final primaryColor = isHighlighted
      ? const PdfColor.fromInt(0xFF00897B)
      : const PdfColor.fromInt(0xFF0D47A1);
  final backgroundColor = isHighlighted
      ? const PdfColor.fromInt(0xFFE0F2F1)
      : const PdfColor.fromInt(0xFFE3F2FD);

  return pw.Container(
    padding: const pw.EdgeInsets.all(8),
    decoration: pw.BoxDecoration(
      color: backgroundColor,
      borderRadius: pw.BorderRadius.circular(4),
      border: pw.Border.all(color: primaryColor),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(font: font, fontSize: 8, color: primaryColor),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: pw.TextStyle(
            font: boldFont,
            fontSize: 12,
            color: primaryColor,
          ),
        ),
      ],
    ),
  );
}

pw.Widget _buildTableCell(
  String text,
  pw.Font font, {
  required bool isEven,
  pw.Alignment alignment = pw.Alignment.center,
  double fontSize = 8,
  required PdfColor darkColor,
}) {
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 6),
    alignment: alignment,
    child: pw.Text(
      text,
      style: pw.TextStyle(font: font, fontSize: fontSize, color: darkColor),
      textAlign: pw.TextAlign.left,
    ),
  );
}

pw.Widget _buildAmountCell(
  int amount,
  pw.Font font,
  bool isEven,
  PdfColor color,
) {
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 6),
    alignment: pw.Alignment.centerRight,
    child: pw.Text(
      "₹${NumberFormat('#,##,###').format(amount)}",
      style: pw.TextStyle(font: font, fontSize: 8, color: color),
    ),
  );
}

pw.Widget _buildIncentiveCell(
  int amount,
  pw.Font boldFont,
  bool isEven,
  PdfColor color,
) {
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 6),
    alignment: pw.Alignment.centerRight,
    decoration: pw.BoxDecoration(color: color),
    child: pw.Text(
      "₹${NumberFormat('#,##,###').format(amount)}",
      style: pw.TextStyle(font: boldFont, fontSize: 8.5, color: color),
    ),
  );
}

String _formatDiagnosis(IncentiveBill bill) {
  final name = bill.diagnosisType.name;
  final category = bill.diagnosisType.category;
  return "$name ($category)";
}
