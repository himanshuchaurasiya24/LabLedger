import 'package:labledger/constants/constants.dart';
import 'package:labledger/models/center_detail_model_with_subscription.dart';
import 'package:labledger/providers/incenitve_generator_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:labledger/models/incentive_model.dart';
import 'package:pdf/pdf.dart';

List<pw.Widget> buildBillsTableType2(
  DoctorReport doctorReport,
  Map<String, bool> selectedFields,
  WidgetRef ref,
  pw.Font font,
  pw.Font boldFont,
  CenterDetail centerDetail,
) {
  double containerBorderRadius = 8;
  const lightBlueColor = PdfColor.fromInt(0xFFE3F2FD);
  final deepBlueColor = PdfColor.fromInt(0xFF0072B5);
  final headers = <String>[];
  final Map<int, pw.TableColumnWidth> columnWidths = {};
  final bills = doctorReport.bills;

  // Dynamically build headers based on user selection
  int colIndex = 0;
  if (selectedFields['dateOfBill'] ?? false) {
    headers.add('Date Of Bill');
    columnWidths[colIndex++] = const pw.FixedColumnWidth(55);
  }
  if (selectedFields['patientName'] ?? false) {
    headers.add('Patient');
    columnWidths[colIndex++] = const pw.FlexColumnWidth(2);
  }
  if (selectedFields['ageAndSex'] ?? false) {
    headers.add('Age Sex');
    columnWidths[colIndex++] = const pw.FixedColumnWidth(40);
  }
  if (selectedFields['billStatus'] ?? false) {
    headers.add('Payment Status');
    columnWidths[colIndex++] = const pw.FixedColumnWidth(60);
  }
  if (selectedFields['diagnosisTypeOutput'] ?? false) {
    headers.add('Diagnosis');
    columnWidths[colIndex++] = const pw.FlexColumnWidth(2.5);
  }
  if (selectedFields['franchiseNameOutput'] ?? false) {
    headers.add('Franchise Lab');
    columnWidths[colIndex++] = const pw.FlexColumnWidth(2);
  }
  if (selectedFields['totalAmount'] ?? false) {
    headers.add('Total');
    columnWidths[colIndex++] = const pw.FixedColumnWidth(45);
  }
  if (selectedFields['paidAmount'] ?? false) {
    headers.add('Paid');
    columnWidths[colIndex++] = const pw.FixedColumnWidth(45);
  }
  if (selectedFields['discByDoctor'] ?? false) {
    headers.add("Doctor's Discount");
    columnWidths[colIndex++] = const pw.FixedColumnWidth(50);
  }
  if (selectedFields['discByCenter'] ?? false) {
    headers.add("Center's Discount");
    columnWidths[colIndex++] = const pw.FixedColumnWidth(50);
  }
  if (selectedFields['incentivePercentage'] ?? false) {
    headers.add('Incentive %');
    columnWidths[colIndex++] = const pw.FixedColumnWidth(45);
  }
  if (selectedFields['incentiveAmount'] ?? false) {
    headers.add('Incentive');
    columnWidths[colIndex++] = const pw.FixedColumnWidth(50);
  }
  if (selectedFields['billNumber'] ?? false) {
    headers.add('Bill Number');
    columnWidths[colIndex++] = const pw.FlexColumnWidth(1.5);
  }

  if (headers.isEmpty) return [];

  return [
    pw.Container(
      padding: pw.EdgeInsets.only(
        left: defaultPadding / 2,
        right: defaultPadding / 2,
        top: defaultPadding / 2,
      ),
      decoration: pw.BoxDecoration(
        borderRadius: pw.BorderRadius.only(
          topLeft: pw.Radius.circular(containerBorderRadius),
          topRight: pw.Radius.circular(containerBorderRadius),
        ),
      ),
      child: pw.Column(
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Row(
                children: [
                  pw.Container(
                    width: 36,
                    height: 36,
                    decoration: pw.BoxDecoration(
                      color: deepBlueColor,
                      shape: pw.BoxShape.circle,
                    ),
                    child: pw.Center(
                      child: pw.Text(
                        "${doctorReport.doctor.firstName!.isNotEmpty ? doctorReport.doctor.firstName!.substring(0, 1).toUpperCase() : ''}${doctorReport.doctor.lastName!.isNotEmpty ? doctorReport.doctor.lastName!.substring(0, 1).toUpperCase() : ''}",
                        style: pw.TextStyle(
                          font: boldFont,
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 12),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        "${doctorReport.doctor.firstName} ${doctorReport.doctor.lastName}",
                        style: pw.TextStyle(
                          font: boldFont,
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.grey900,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        "${doctorReport.bills.length} Referrals • Total ₹${doctorReport.totalIncentive} • From ${DateFormat("dd MMM yyyy").format(ref.read(reportStartDateProvider))} to ${DateFormat("dd MMM yyyy").format(ref.read(reportEndDateProvider))}",
                        style: pw.TextStyle(
                          font: font,
                          fontSize: 8,
                          color: PdfColors.grey600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: pw.BoxDecoration(
                  color: lightBlueColor,
                  borderRadius: pw.BorderRadius.circular(6),
                ),

                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      centerDetail.centerName,
                      style: pw.TextStyle(
                        font: boldFont,
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: deepBlueColor,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      centerDetail.address,
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 8,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: defaultHeight / 2),
        ],
      ),
    ),
    pw.Padding(
      padding: pw.EdgeInsets.symmetric(horizontal: defaultPadding / 2),
      child: pw.Table(
        border: pw.TableBorder.all(color: PdfColors.grey300, width: 1),
        columnWidths: columnWidths,
        children: [
          pw.TableRow(
            decoration: pw.BoxDecoration(color: deepBlueColor),
            children: headers
                .map(
                  (header) => pw.Center(
                    child: pw.Padding(
                      padding: pw.EdgeInsets.symmetric(
                        horizontal: defaultPadding / 2,
                        vertical: defaultPadding / 4,
                      ),
                      child: pw.Text(
                        header,
                        style: pw.TextStyle(
                          font: boldFont,
                          fontSize: 7.5,
                          // fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          ...bills.asMap().entries.map((entry) {
            final bill = entry.value;
            final cells = <pw.Widget>[];

            if (selectedFields['dateOfBill'] ?? false) {
              cells.add(
                _buildTableCell(
                  DateFormat('dd MMM yyyy').format(bill.dateOfBill),
                  7,
                  font,
                ),
              );
            }
            if (selectedFields['patientName'] ?? false) {
              cells.add(_buildTableCell(bill.patientName, 7, font));
            }
            if (selectedFields['ageAndSex'] ?? false) {
              cells.add(
                _buildTableCell(
                  "${bill.patientAge}y ${bill.patientSex}",
                  7,
                  font,
                ),
              );
            }
            if (selectedFields['billStatus'] ?? false) {
              cells.add(_buildPaymentStatusCell(bill.billStatus, font));
            }
            if (selectedFields['diagnosisTypeOutput'] ?? false) {
              cells.add(_buildTableCell(_formatDiagnosis(bill), 7, font));
            }
            if (selectedFields['franchiseNameOutput'] ?? false) {
              cells.add(_buildTableCell(_formatFranchise(bill), 7, font));
            }
            if (selectedFields['totalAmount'] ?? false) {
              cells.add(
                _buildTableCell(
                  "₹${NumberFormat('#,##,###').format(bill.totalAmount)}",
                  7,
                  font,
                ),
              );
            }
            if (selectedFields['paidAmount'] ?? false) {
              cells.add(
                _buildTableCell(
                  "₹${NumberFormat('#,##,###').format(bill.paidAmount)}",
                  7,
                  font,
                ),
              );
            }
            if (selectedFields['discByDoctor'] ?? false) {
              cells.add(
                _buildTableCell(
                  "₹${NumberFormat('#,##,###').format(bill.discByDoctor)}",
                  7,
                  font,
                ),
              );
            }
            if (selectedFields['discByCenter'] ?? false) {
              cells.add(
                _buildTableCell(
                  "₹${NumberFormat('#,##,###').format(bill.discByCenter)}",
                  7,
                  font,
                ),
              );
            }
            if (selectedFields['incentivePercentage'] ?? false) {
              cells.add(
                _buildTableCell(
                  _getIncentivePercentage(doctorReport.doctor, bill),
                  7,
                  font,
                ),
              );
            }
            if (selectedFields['incentiveAmount'] ?? false) {
              cells.add(_buildIncentiveCell(bill.incentiveAmount, font));
            }
            if (selectedFields['billNumber'] ?? false) {
              cells.add(_buildTableCell(bill.billNumber, 6.5, font));
            }
            return pw.TableRow(children: cells);
          }),
        ],
      ),
    ),
    _buildLabLedgerBrandingFooter(font),
  ];
}

pw.Widget _buildLabLedgerBrandingFooter(pw.Font font) {
  return pw.Padding(
    padding: pw.EdgeInsets.symmetric(
      horizontal: defaultPadding / 2,
      vertical: defaultPadding / 2,
    ),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Text(
          'Generated using LabLedger Software on ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}',
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

// --- Helper Functions and Widgets ---

pw.Widget _buildTableCell(String text, double fontSize, pw.Font font) =>
    pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: font,
          fontSize: fontSize,
          color: PdfColors.grey800,
        ),
        textAlign: pw.TextAlign.center,
        maxLines: 2,
        overflow: pw.TextOverflow.clip,
      ),
    );

pw.Widget _buildPaymentStatusCell(String status, pw.Font font) {
  final colors = {
    'fully paid': const [PdfColors.green50, PdfColors.green700],
    'partially paid': const [PdfColors.amber50, PdfColors.amber700],
    'unpaid': const [PdfColors.red50, PdfColors.red700],
  };
  final colorPair =
      colors[status.toLowerCase()] ?? [PdfColors.grey100, PdfColors.grey800];
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
    child: pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: pw.BoxDecoration(
        color: colorPair[0],
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Text(
        status,
        style: pw.TextStyle(
          font: font,
          fontSize: 6.5,
          fontWeight: pw.FontWeight.bold,
          color: colorPair[1],
        ),
        textAlign: pw.TextAlign.center,
      ),
    ),
  );
}

pw.Widget _buildIncentiveCell(int amount, pw.Font font) => pw.Container(
  padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
  child: pw.Text(
    "₹${NumberFormat('#,##,###').format(amount)}",
    style: pw.TextStyle(
      font: font,
      fontSize: 7,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.green700,
    ),
    textAlign: pw.TextAlign.center,
  ),
);

String _formatDiagnosis(IncentiveBill bill) {
  if (bill.diagnosisTypesOutput.isNotEmpty) {
    return bill.diagnosisTypesOutput
        .map((dt) => "${dt.name} (${dt.categoryName ?? 'Unknown'})")
        .join(', ');
  }
  return 'Unknown';
}

String _formatFranchise(IncentiveBill bill) {
  return bill.franchiseName?['franchise_name'] ?? 'N/A';
}

String _getIncentivePercentage(Doctor doctor, IncentiveBill bill) {
  // Get first diagnosis type's category ID for percentage calculation
  if (bill.diagnosisTypesOutput.isEmpty) {
    return '0';
  }

  final categoryId = bill.diagnosisTypesOutput[0].category;

  // Find matching category percentage from doctor's dynamic percentages
  int percentage = 0;
  if (doctor.categoryPercentages != null &&
      doctor.categoryPercentages!.isNotEmpty) {
    try {
      final matchingPercentage = doctor.categoryPercentages!.firstWhere(
        (cp) => cp.category == categoryId,
        orElse: () => DoctorCategoryPercentage(
          id: 0,
          category: 0,
          categoryName: '',
          percentage: 0,
        ),
      );
      percentage = matchingPercentage.percentage;
    } catch (e) {
      // Error finding percentage, keep default 0
    }
  }

  return percentage.toString();
}
