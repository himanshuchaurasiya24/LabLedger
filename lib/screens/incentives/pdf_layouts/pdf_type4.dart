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
  const tealColor = PdfColor.fromInt(0xFF0D9488);
  // const lightTealColor = PdfColor.fromInt(0xFFCCFBF1);
  final deepBlueColor = PdfColor.fromInt(0xFF0072B5);
  const darkBlueColor = PdfColor.fromInt(0xFF1E3A8A);
  // const accentGold = PdfColor.fromInt(0xFFF59E0B);

  final headers = <String>[];
  final Map<int, pw.TableColumnWidth> columnWidths = {};
  final bills = doctorReport.bills;

  // Build headers dynamically
  int colIndex = 0;
  if (selectedFields['dateOfBill'] ?? false) {
    headers.add('DATE');
    columnWidths[colIndex++] = const pw.FixedColumnWidth(48);
  }
  if (selectedFields['patientName'] ?? false) {
    headers.add('PATIENT NAME');
    columnWidths[colIndex++] = const pw.FlexColumnWidth(2.2);
  }
  if (selectedFields['ageAndSex'] ?? false) {
    headers.add('AGE/SEX');
    columnWidths[colIndex++] = const pw.FixedColumnWidth(42);
  }
  if (selectedFields['billStatus'] ?? false) {
    headers.add('STATUS');
    columnWidths[colIndex++] = const pw.FixedColumnWidth(56);
  }
  if (selectedFields['diagnosisTypeOutput'] ?? false) {
    headers.add('DIAGNOSIS');
    columnWidths[colIndex++] = const pw.FlexColumnWidth(2.5);
  }
  if (selectedFields['franchiseNameOutput'] ?? false) {
    headers.add('FRANCHISE LAB');
    columnWidths[colIndex++] = const pw.FlexColumnWidth(1.8);
  }
  if (selectedFields['totalAmount'] ?? false) {
    headers.add('TOTAL');
    columnWidths[colIndex++] = const pw.FixedColumnWidth(48);
  }
  if (selectedFields['paidAmount'] ?? false) {
    headers.add('PAID');
    columnWidths[colIndex++] = const pw.FixedColumnWidth(48);
  }
  if (selectedFields['discByDoctor'] ?? false) {
    headers.add("DR. DISC");
    columnWidths[colIndex++] = const pw.FixedColumnWidth(48);
  }
  if (selectedFields['discByCenter'] ?? false) {
    headers.add("CTR. DISC");
    columnWidths[colIndex++] = const pw.FixedColumnWidth(48);
  }
  if (selectedFields['incentivePercentage'] ?? false) {
    headers.add('RATE %');
    columnWidths[colIndex++] = const pw.FixedColumnWidth(42);
  }
  if (selectedFields['incentiveAmount'] ?? false) {
    headers.add('INCENTIVE');
    columnWidths[colIndex++] = const pw.FixedColumnWidth(55);
  }
  if (selectedFields['billNumber'] ?? false) {
    headers.add('BILL NUMBER');
    columnWidths[colIndex++] = const pw.FlexColumnWidth(1.4);
  }

  if (headers.isEmpty) return pw.Container();

  return pw.Container(
    margin: const pw.EdgeInsets.only(bottom: 24),
    decoration: pw.BoxDecoration(
      color: PdfColors.white,
      borderRadius: pw.BorderRadius.circular(0),
      border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
    ),
    child: pw.Column(
      children: [
        // Professional Header with clean design
        pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border(
              bottom: pw.BorderSide(color: tealColor, width: 3),
            ),
          ),
          child: pw.Column(
            children: [
              // Top section with center info
              pw.Container(
                padding: const pw.EdgeInsets.fromLTRB(20, 16, 20, 12),
                decoration: pw.BoxDecoration(color: PdfColors.grey50),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'INCENTIVE REPORT',
                          style: pw.TextStyle(
                            font: boldFont,
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.grey700,
                            letterSpacing: 1.2,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          '${DateFormat("dd MMM yyyy").format(ref.read(reportStartDateProvider))} - ${DateFormat("dd MMM yyyy").format(ref.read(reportEndDateProvider))}',
                          style: pw.TextStyle(
                            font: font,
                            fontSize: 9,
                            color: PdfColors.grey600,
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
                            fontSize: 11,
                            fontWeight: pw.FontWeight.bold,
                            color: darkBlueColor,
                          ),
                        ),
                        pw.SizedBox(height: 3),
                        pw.Container(
                          constraints: const pw.BoxConstraints(maxWidth: 200),
                          child: pw.Text(
                            centerDetail.address,
                            style: pw.TextStyle(
                              font: font,
                              fontSize: 8,
                              color: PdfColors.grey700,
                            ),
                            textAlign: pw.TextAlign.right,
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Doctor information section
              pw.Container(
                padding: const pw.EdgeInsets.fromLTRB(20, 16, 20, 16),
                color: PdfColors.white,
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Row(
                      children: [
                        // Professional doctor avatar
                        pw.Container(
                          width: 56,
                          height: 56,
                          decoration: pw.BoxDecoration(
                            shape: pw.BoxShape.circle,
                            color: deepBlueColor,
                            border: pw.Border.all(color: tealColor, width: 2.5),
                          ),
                          child: pw.Center(
                            child: pw.Text(
                              "${doctorReport.doctor.firstName!.isNotEmpty ? doctorReport.doctor.firstName!.substring(0, 1).toUpperCase() : ''}${doctorReport.doctor.lastName!.isNotEmpty ? doctorReport.doctor.lastName!.substring(0, 1).toUpperCase() : ''}",
                              style: pw.TextStyle(
                                font: boldFont,
                                fontSize: 20,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.white,
                              ),
                            ),
                          ),
                        ),
                        pw.SizedBox(width: 16),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              "Dr. ${doctorReport.doctor.firstName} ${doctorReport.doctor.lastName}",
                              style: pw.TextStyle(
                                font: boldFont,
                                fontSize: 15,
                                fontWeight: pw.FontWeight.bold,
                                color: darkBlueColor,
                              ),
                            ),
                            pw.SizedBox(height: 4),
                            pw.Text(
                              "Referring Physician",
                              style: pw.TextStyle(
                                font: font,
                                fontSize: 9,
                                color: PdfColors.grey600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Summary cards
                    pw.Row(
                      children: [
                        _buildSummaryCard(
                          'Total Referrals',
                          '${doctorReport.bills.length}',
                          font,
                          boldFont,
                          deepBlueColor,
                        ),
                        pw.SizedBox(width: 12),
                        _buildSummaryCard(
                          'Total Incentive',
                          '₹${NumberFormat('#,##,###').format(doctorReport.totalIncentive)}',
                          font,
                          boldFont,
                          tealColor,
                          isHighlight: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Professional Table
        pw.Table(
          border: pw.TableBorder.symmetric(
            inside: pw.BorderSide(color: PdfColors.grey200, width: 0.5),
            outside: pw.BorderSide.none,
          ),
          columnWidths: columnWidths,
          children: [
            // Table Header - Executive style
            pw.TableRow(
              decoration: pw.BoxDecoration(color: darkBlueColor),
              children: headers
                  .map(
                    (header) => pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 11,
                      ),
                      child: pw.Text(
                        header,
                        style: pw.TextStyle(
                          font: boldFont,
                          fontSize: 7,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                          letterSpacing: 0.5,
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
              final cells = <pw.Widget>[];

              if (selectedFields['dateOfBill'] ?? false) {
                cells.add(
                  _buildProfessionalCell(
                    DateFormat('dd MMM\nyyyy').format(bill.dateOfBill),
                    6.5,
                    font,
                    boldFont,
                    index,
                    isBold: true,
                  ),
                );
              }
              if (selectedFields['patientName'] ?? false) {
                cells.add(
                  _buildProfessionalCell(
                    bill.patientName,
                    7.5,
                    font,
                    boldFont,
                    index,
                    align: pw.TextAlign.left,
                    isBold: true,
                  ),
                );
              }
              if (selectedFields['ageAndSex'] ?? false) {
                cells.add(
                  _buildProfessionalCell(
                    "${bill.patientAge}y\n${bill.patientSex}",
                    6.5,
                    font,
                    boldFont,
                    index,
                  ),
                );
              }
              if (selectedFields['billStatus'] ?? false) {
                cells.add(
                  _buildProfessionalStatusCell(
                    bill.billStatus,
                    font,
                    boldFont,
                    index,
                  ),
                );
              }
              if (selectedFields['diagnosisTypeOutput'] ?? false) {
                cells.add(
                  _buildProfessionalCell(
                    _formatDiagnosis(bill),
                    7,
                    font,
                    boldFont,
                    index,
                    align: pw.TextAlign.left,
                  ),
                );
              }
              if (selectedFields['franchiseNameOutput'] ?? false) {
                cells.add(
                  _buildProfessionalCell(
                    _formatFranchise(bill),
                    7,
                    font,
                    boldFont,
                    index,
                    align: pw.TextAlign.left,
                  ),
                );
              }
              if (selectedFields['totalAmount'] ?? false) {
                cells.add(
                  _buildProfessionalAmountCell(
                    bill.totalAmount,
                    font,
                    boldFont,
                    index,
                    PdfColors.grey800,
                  ),
                );
              }
              if (selectedFields['paidAmount'] ?? false) {
                cells.add(
                  _buildProfessionalAmountCell(
                    bill.paidAmount,
                    font,
                    boldFont,
                    index,
                    deepBlueColor,
                    isBold: true,
                  ),
                );
              }
              if (selectedFields['discByDoctor'] ?? false) {
                cells.add(
                  _buildProfessionalAmountCell(
                    bill.discByDoctor,
                    font,
                    boldFont,
                    index,
                    const PdfColor.fromInt(0xFFEA580C),
                  ),
                );
              }
              if (selectedFields['discByCenter'] ?? false) {
                cells.add(
                  _buildProfessionalAmountCell(
                    bill.discByCenter,
                    font,
                    boldFont,
                    index,
                    const PdfColor.fromInt(0xFF9333EA),
                  ),
                );
              }
              if (selectedFields['incentivePercentage'] ?? false) {
                cells.add(
                  _buildProfessionalPercentageCell(
                    _getIncentivePercentage(doctorReport.doctor, bill),
                    font,
                    boldFont,
                    index,
                  ),
                );
              }
              if (selectedFields['incentiveAmount'] ?? false) {
                cells.add(
                  _buildProfessionalIncentiveCell(
                    bill.incentiveAmount,
                    font,
                    boldFont,
                    index,
                  ),
                );
              }
              if (selectedFields['billNumber'] ?? false) {
                cells.add(
                  _buildProfessionalCell(
                    bill.billNumber,
                    6.5,
                    font,
                    boldFont,
                    index,
                    color: PdfColors.grey600,
                  ),
                );
              }

              return pw.TableRow(
                decoration: pw.BoxDecoration(
                  color: index % 2 == 0 ? PdfColors.white : PdfColors.grey50,
                ),
                children: cells,
              );
            }),
          ],
        ),

        // Executive Footer
        _buildExecutiveFooter(font, boldFont, tealColor),
      ],
    ),
  );
}

pw.Widget _buildSummaryCard(
  String label,
  String value,
  pw.Font font,
  pw.Font boldFont,
  PdfColor color, {
  bool isHighlight = false,
}) {
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: pw.BoxDecoration(
      color: isHighlight ? color.flatten() : PdfColors.grey50,
      borderRadius: pw.BorderRadius.circular(6),
      border: pw.Border.all(
        color: isHighlight ? color : PdfColors.grey200,
        width: isHighlight ? 1.5 : 1,
      ),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            font: font,
            fontSize: 7.5,
            color: PdfColors.grey600,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: pw.TextStyle(
            font: boldFont,
            fontSize: isHighlight ? 16 : 14,
            fontWeight: pw.FontWeight.bold,
            color: isHighlight ? color : const PdfColor.fromInt(0xFF1F2937),
          ),
        ),
      ],
    ),
  );
}

pw.Widget _buildProfessionalCell(
  String text,
  double fontSize,
  pw.Font font,
  pw.Font boldFont,
  int index, {
  bool isBold = false,
  PdfColor? color,
  pw.TextAlign align = pw.TextAlign.center,
}) {
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 10),
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

pw.Widget _buildProfessionalStatusCell(
  String status,
  pw.Font font,
  pw.Font boldFont,
  int index,
) {
  final colors = {
    'fully paid': const [
      PdfColors.green50,
      PdfColors.green700,
      PdfColors.green200,
    ],
    'partially paid': const [
      PdfColors.orange50,
      PdfColors.orange700,
      PdfColors.orange200,
    ],
    'unpaid': const [PdfColors.red50, PdfColors.red700, PdfColors.red200],
  };
  final colorSet =
      colors[status.toLowerCase()] ??
      [PdfColors.grey100, PdfColors.grey800, PdfColors.grey300];

  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 10),
    child: pw.Center(
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: pw.BoxDecoration(
          color: colorSet[0],
          borderRadius: pw.BorderRadius.circular(3),
          border: pw.Border.all(color: colorSet[2], width: 0.5),
        ),
        child: pw.Text(
          status.toUpperCase(),
          style: pw.TextStyle(
            font: boldFont,
            fontSize: 6,
            fontWeight: pw.FontWeight.bold,
            color: colorSet[1],
            letterSpacing: 0.3,
          ),
          textAlign: pw.TextAlign.center,
        ),
      ),
    ),
  );
}

pw.Widget _buildProfessionalAmountCell(
  int amount,
  pw.Font font,
  pw.Font boldFont,
  int index,
  PdfColor color, {
  bool isBold = false,
}) {
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 10),
    child: pw.Text(
      "₹${NumberFormat('#,##,###').format(amount)}",
      style: pw.TextStyle(
        font: isBold ? boldFont : font,
        fontSize: 7,
        color: color,
        fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
      ),
      textAlign: pw.TextAlign.center,
    ),
  );
}

pw.Widget _buildProfessionalPercentageCell(
  String percentage,
  pw.Font font,
  pw.Font boldFont,
  int index,
) {
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 10),
    child: pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: pw.BoxDecoration(
        color: const PdfColor.fromInt(0xFFDCEEF7),
        borderRadius: pw.BorderRadius.circular(3),
        border: pw.Border.all(
          color: const PdfColor.fromInt(0xFF0072B5),
          width: 0.5,
        ),
      ),
      child: pw.Text(
        "$percentage%",
        style: pw.TextStyle(
          font: boldFont,
          fontSize: 7,
          fontWeight: pw.FontWeight.bold,
          color: const PdfColor.fromInt(0xFF0072B5),
        ),
        textAlign: pw.TextAlign.center,
      ),
    ),
  );
}

pw.Widget _buildProfessionalIncentiveCell(
  int amount,
  pw.Font font,
  pw.Font boldFont,
  int index,
) {
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 10),
    decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFF0FDFA)),
    child: pw.Text(
      "₹${NumberFormat('#,##,###').format(amount)}",
      style: pw.TextStyle(
        font: boldFont,
        fontSize: 7.5,
        fontWeight: pw.FontWeight.bold,
        color: const PdfColor.fromInt(0xFF0D9488),
      ),
      textAlign: pw.TextAlign.center,
    ),
  );
}

pw.Widget _buildExecutiveFooter(
  pw.Font font,
  pw.Font boldFont,
  PdfColor tealColor,
) {
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    decoration: pw.BoxDecoration(
      color: PdfColors.grey50,
      border: pw.Border(
        top: pw.BorderSide(color: PdfColors.grey200, width: 0.5),
      ),
    ),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Row(
          children: [
            pw.Container(
              padding: const pw.EdgeInsets.all(6),
              decoration: pw.BoxDecoration(
                color: tealColor,
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Text(
                'LL',
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 8,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            pw.SizedBox(width: 8),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'LabLedger Healthcare Solutions',
                  style: pw.TextStyle(
                    font: boldFont,
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey800,
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  'Professional Lab Management Software',
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 7,
                    color: PdfColors.grey600,
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
              'Report Generated',
              style: pw.TextStyle(
                font: font,
                fontSize: 7,
                color: PdfColors.grey600,
              ),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now()),
              style: pw.TextStyle(
                font: boldFont,
                fontSize: 7.5,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey700,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

String _formatDiagnosis(IncentiveBill bill) {
  final name = bill.diagnosisType.name;
  final category = bill.diagnosisType.category;
  return "$name ($category)";
}

String _formatFranchise(IncentiveBill bill) {
  return bill.franchiseName?.franchiseName ?? 'N/A';
}

String _getIncentivePercentage(Doctor doctor, IncentiveBill bill) {
  final category = bill.diagnosisType.category.toLowerCase();

  switch (category) {
    case 'ultrasound':
      return doctor.ultrasoundPercentage?.toString() ?? '0';
    case 'ecg':
      return doctor.ecgPercentage?.toString() ?? '0';
    case 'x-ray':
      return doctor.xrayPercentage?.toString() ?? '0';
    case 'pathology':
      return doctor.pathologyPercentage?.toString() ?? '0';
    case 'franchise lab':
      return doctor.franchiseLabPercentage?.toString() ?? '0';
    default:
      return '0';
  }
}
