import 'package:labledger/models/center_detail_model_with_subscription.dart';
import 'package:labledger/providers/incenitve_generator_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:labledger/models/incentive_model.dart';
import 'package:pdf/pdf.dart';

List<pw.Widget> buildBillsTableType1(
  DoctorReport doctorReport,
  Map<String, bool> selectedFields,
  WidgetRef ref,
  pw.Font font,
  pw.Font boldFont,
  CenterDetail centerDetail,
) {
  const tealColor = PdfColor.fromInt(0xFF14B8A6);
  final deepBlueColor = PdfColor.fromInt(0xFF0072B5);
  const lightBlueColor = PdfColor.fromInt(0xFFDCEEF7);

  final headers = <String>[];
  final Map<int, pw.TableColumnWidth> columnWidths = {};
  final bills = doctorReport.bills;

  // Build headers dynamically
  int colIndex = 0;
  if (selectedFields['dateOfBill'] ?? false) {
    headers.add('Date');
    columnWidths[colIndex++] = const pw.FixedColumnWidth(50);
  }
  if (selectedFields['patientName'] ?? false) {
    headers.add('Patient Name');
    columnWidths[colIndex++] = const pw.FlexColumnWidth(2);
  }
  if (selectedFields['ageAndSex'] ?? false) {
    headers.add('Age/Sex');
    columnWidths[colIndex++] = const pw.FixedColumnWidth(40);
  }
  if (selectedFields['billStatus'] ?? false) {
    headers.add('Status');
    columnWidths[colIndex++] = const pw.FixedColumnWidth(55);
  }
  if (selectedFields['diagnosisTypeOutput'] ?? false) {
    headers.add('Diagnosis');
    columnWidths[colIndex++] = const pw.FlexColumnWidth(2.5);
  }
  if (selectedFields['franchiseNameOutput'] ?? false) {
    headers.add('Franchise');
    columnWidths[colIndex++] = const pw.FlexColumnWidth(1.8);
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
    headers.add("Dr. Disc");
    columnWidths[colIndex++] = const pw.FixedColumnWidth(45);
  }
  if (selectedFields['discByCenter'] ?? false) {
    headers.add("Ctr. Disc");
    columnWidths[colIndex++] = const pw.FixedColumnWidth(45);
  }
  if (selectedFields['incentivePercentage'] ?? false) {
    headers.add('Inc. %');
    columnWidths[colIndex++] = const pw.FixedColumnWidth(40);
  }
  if (selectedFields['incentiveAmount'] ?? false) {
    headers.add('Incentive');
    columnWidths[colIndex++] = const pw.FixedColumnWidth(50);
  }
  if (selectedFields['billNumber'] ?? false) {
    headers.add('Bill No.');
    columnWidths[colIndex++] = const pw.FlexColumnWidth(1.3);
  }

  if (headers.isEmpty) return [];

  return [
    // Header Section with gradient-like effect
    pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        gradient: pw.LinearGradient(
          colors: [deepBlueColor, tealColor],
          begin: pw.Alignment.centerLeft,
          end: pw.Alignment.centerRight,
        ),
        borderRadius: const pw.BorderRadius.only(
          topLeft: pw.Radius.circular(12),
          topRight: pw.Radius.circular(12),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Doctor Info Section
          pw.Expanded(
            flex: 2,
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Doctor Avatar
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
                      "${doctorReport.doctor.firstName!.isNotEmpty ? doctorReport.doctor.firstName!.substring(0, 1).toUpperCase() : ''}${doctorReport.doctor.lastName!.isNotEmpty ? doctorReport.doctor.lastName!.substring(0, 1).toUpperCase() : ''}",
                      style: pw.TextStyle(
                        font: boldFont,
                        fontSize: 18,
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
                        "Dr. ${doctorReport.doctor.firstName} ${doctorReport.doctor.lastName}",
                        style: pw.TextStyle(
                          font: boldFont,
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                      ),

                      pw.SizedBox(height: 2),

                      pw.Row(
                        children: [
                          _buildInfoChip(
                            "${doctorReport.bills.length} Referrals",
                            font,
                            PdfColors.white,
                          ),
                          pw.SizedBox(width: 8),
                          _buildInfoChip(
                            "₹${NumberFormat('#,##,###').format(doctorReport.totalIncentive)}",
                            boldFont,
                            PdfColors.white,
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        "${DateFormat("dd MMM yyyy").format(ref.read(reportStartDateProvider))} - ${DateFormat("dd MMM yyyy").format(ref.read(reportEndDateProvider))}",
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
                  font: boldFont,
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    ),

    // Table Section
    pw.Table(
      border: pw.TableBorder.symmetric(
        inside: pw.BorderSide(color: PdfColors.grey200, width: 0.5),
      ),
      columnWidths: columnWidths,
      children: [
        // Table Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: lightBlueColor),
          children: headers
              .map(
                (header) => pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 10,
                  ),
                  child: pw.Text(
                    header,
                    style: pw.TextStyle(
                      font: boldFont,
                      fontSize: 7.5,
                      fontWeight: pw.FontWeight.bold,
                      color: deepBlueColor,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              )
              .toList(),
        ),
        // Table Rows
        ...bills.asMap().entries.map((entry) {
          final index = entry.key;
          final bill = entry.value;
          final isEven = index % 2 == 0;
          final cells = <pw.Widget>[];

          if (selectedFields['dateOfBill'] ?? false) {
            cells.add(
              _buildModernCell(
                DateFormat('dd MMM\nyyyy').format(bill.dateOfBill),
                7,
                font,
                boldFont,
                isEven,
              ),
            );
          }
          if (selectedFields['patientName'] ?? false) {
            cells.add(
              _buildModernCell(
                bill.patientName,
                7.5,
                font,
                boldFont,
                isEven,
                isBold: false,
                align: pw.TextAlign.left,
              ),
            );
          }
          if (selectedFields['ageAndSex'] ?? false) {
            cells.add(
              _buildModernCell(
                "${bill.patientAge}y\n${bill.patientSex}",
                7,
                font,
                boldFont,
                isEven,
              ),
            );
          }
          if (selectedFields['billStatus'] ?? false) {
            cells.add(_buildStatusCell(bill.billStatus, font, isEven));
          }
          if (selectedFields['diagnosisTypeOutput'] ?? false) {
            cells.add(
              _buildModernCell(
                _formatDiagnosis(bill),
                7,
                font,
                boldFont,
                isEven,
                align: pw.TextAlign.left,
              ),
            );
          }
          if (selectedFields['franchiseNameOutput'] ?? false) {
            cells.add(
              _buildModernCell(
                _formatFranchise(bill),
                7,
                font,
                boldFont,
                isEven,
                align: pw.TextAlign.left,
              ),
            );
          }
          if (selectedFields['totalAmount'] ?? false) {
            cells.add(
              _buildAmountCell(
                bill.totalAmount,
                7,
                font,
                boldFont,
                isEven,
                PdfColors.grey800,
              ),
            );
          }
          if (selectedFields['paidAmount'] ?? false) {
            cells.add(
              _buildAmountCell(
                bill.paidAmount,
                7,
                font,
                boldFont,
                isEven,
                PdfColors.blue800,
              ),
            );
          }
          if (selectedFields['discByDoctor'] ?? false) {
            cells.add(
              _buildAmountCell(
                bill.discByDoctor,
                7,
                font,
                boldFont,
                isEven,
                PdfColors.orange700,
              ),
            );
          }
          if (selectedFields['discByCenter'] ?? false) {
            cells.add(
              _buildAmountCell(
                bill.discByCenter,
                7,
                font,
                boldFont,
                isEven,
                PdfColors.purple700,
              ),
            );
          }
          if (selectedFields['incentivePercentage'] ?? false) {
            cells.add(
              _buildPercentageCell(
                _getIncentivePercentage(doctorReport.doctor, bill),
                font,
                boldFont,
                isEven,
              ),
            );
          }
          if (selectedFields['incentiveAmount'] ?? false) {
            cells.add(
              _buildIncentiveAmountCell(
                bill.incentiveAmount,
                font,
                boldFont,
                isEven,
              ),
            );
          }
          if (selectedFields['billNumber'] ?? false) {
            cells.add(
              _buildModernCell(
                bill.billNumber,
                6.5,
                font,
                boldFont,
                isEven,
                color: PdfColors.grey600,
              ),
            );
          }

          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: isEven ? PdfColors.white : PdfColors.grey50,
            ),
            children: cells,
          );
        }),
      ],
    ),

    // Footer
    _buildModernFooter(font, tealColor),
  ];
}

pw.Widget _buildInfoChip(String text, pw.Font font, PdfColor color) {
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: pw.BoxDecoration(
      color: PdfColors.teal,
      borderRadius: pw.BorderRadius.circular(4),
    ),
    child: pw.Text(
      text,
      style: pw.TextStyle(font: font, fontSize: 8, color: color),
    ),
  );
}

pw.Widget _buildModernCell(
  String text,
  double fontSize,
  pw.Font font,
  pw.Font boldFont,
  bool isEven, {
  bool isBold = false,
  PdfColor? color,
  pw.TextAlign align = pw.TextAlign.center,
}) {
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    child: pw.Text(
      text,
      style: pw.TextStyle(
        font: isBold ? boldFont : font,
        fontSize: fontSize,
        color: color ?? PdfColors.grey800,
        fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
      ),
      textAlign: align,
      maxLines: 3,
      overflow: pw.TextOverflow.clip,
    ),
  );
}

pw.Widget _buildStatusCell(String status, pw.Font font, bool isEven) {
  final colors = {
    'fully paid': const [PdfColors.green100, PdfColors.green700],
    'partially paid': const [PdfColors.amber100, PdfColors.amber700],
    'unpaid': const [PdfColors.red100, PdfColors.red700],
  };
  final colorPair =
      colors[status.toLowerCase()] ?? [PdfColors.grey100, PdfColors.grey800];

  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    child: pw.Center(
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: pw.BoxDecoration(
          color: colorPair[0],
          borderRadius: pw.BorderRadius.circular(4),
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
    ),
  );
}

pw.Widget _buildAmountCell(
  int amount,
  double fontSize,
  pw.Font font,
  pw.Font boldFont,
  bool isEven,
  PdfColor color,
) {
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    child: pw.Text(
      "₹${NumberFormat('#,##,###').format(amount)}",
      style: pw.TextStyle(font: font, fontSize: fontSize, color: color),
      textAlign: pw.TextAlign.center,
    ),
  );
}

pw.Widget _buildPercentageCell(
  String percentage,
  pw.Font font,
  pw.Font boldFont,
  bool isEven,
) {
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    child: pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: pw.BoxDecoration(
        color: const PdfColor.fromInt(0xFFE0F2FE),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Text(
        "$percentage%",
        style: pw.TextStyle(
          font: boldFont,
          fontSize: 7,
          fontWeight: pw.FontWeight.bold,
          color: const PdfColor.fromInt(0xFF0369A1),
        ),
        textAlign: pw.TextAlign.center,
      ),
    ),
  );
}

pw.Widget _buildIncentiveAmountCell(
  int amount,
  pw.Font font,
  pw.Font boldFont,
  bool isEven,
) {
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    decoration: pw.BoxDecoration(color: const PdfColor.fromInt(0xFFCCFBF1)),
    child: pw.Text(
      "₹${NumberFormat('#,##,###').format(amount)}",
      style: pw.TextStyle(
        font: boldFont,
        fontSize: 7.5,
        fontWeight: pw.FontWeight.bold,
        color: const PdfColor.fromInt(0xFF0F766E),
      ),
      textAlign: pw.TextAlign.center,
    ),
  );
}

pw.Widget _buildModernFooter(pw.Font font, PdfColor tealColor) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(12),
    decoration: const pw.BoxDecoration(
      color: PdfColors.grey50,
      borderRadius: pw.BorderRadius.only(
        bottomLeft: pw.Radius.circular(12),
        bottomRight: pw.Radius.circular(12),
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
                borderRadius: pw.BorderRadius.circular(2),
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
