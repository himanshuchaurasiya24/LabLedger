import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/models/bill_model.dart';
import 'package:labledger/models/center_detail_model_with_subscription.dart';
import 'package:labledger/providers/authentication_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';

/// Generates a multi-bill PDF export report matching the pdf_type1 design.
Future<Uint8List> createBillsExportPDF({
  required List<Bill> bills,
  required Map<String, bool> selectedFields,
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
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4.landscape,
      margin: pw.EdgeInsets.all(defaultPadding / microPadding),
      build: (pw.Context context) {
        return _buildExportContent(
          bills,
          selectedFields,
          centerDetail,
          ttf,
          boldTTF,
        );
      },
    ),
  );

  return pdf.save();
}

List<pw.Widget> _buildExportContent(
  List<Bill> bills,
  Map<String, bool> selectedFields,
  CenterDetail centerDetail,
  pw.Font font,
  pw.Font boldFont,
) {
  const tealColor = PdfColor.fromInt(0xFF14B8A6);
  final deepBlueColor = PdfColor.fromInt(0xFF0072B5);
  const lightBlueColor = PdfColor.fromInt(0xFFDCEEF7);

  // Build dynamic headers and column widths
  final headers = <String>[];
  final Map<int, pw.TableColumnWidth> columnWidths = {};
  int colIndex = 0;

  if (selectedFields['dateOfBill'] ?? false) {
    headers.add('Date');
    columnWidths[colIndex++] = const pw.FixedColumnWidth(55);
  }
  if (selectedFields['billNumber'] ?? false) {
    headers.add('Bill No.');
    columnWidths[colIndex++] = const pw.FlexColumnWidth(1.5);
  }
  if (selectedFields['patientName'] ?? false) {
    headers.add('Patient Name');
    columnWidths[colIndex++] = const pw.FlexColumnWidth(2);
  }
  if (selectedFields['ageAndSex'] ?? false) {
    headers.add('Age/Sex');
    columnWidths[colIndex++] = const pw.FixedColumnWidth(45);
  }
  if (selectedFields['patientPhone'] ?? false) {
    headers.add('Phone');
    columnWidths[colIndex++] = const pw.FixedColumnWidth(65);
  }
  if (selectedFields['diagnosisType'] ?? false) {
    headers.add('Diagnosis');
    columnWidths[colIndex++] = const pw.FlexColumnWidth(2.5);
  }
  if (selectedFields['franchiseName'] ?? false) {
    headers.add('Franchise');
    columnWidths[colIndex++] = const pw.FlexColumnWidth(1.5);
  }
  if (selectedFields['referredByDoctor'] ?? false) {
    headers.add('Ref. Doctor');
    columnWidths[colIndex++] = const pw.FlexColumnWidth(1.5);
  }
  if (selectedFields['billStatus'] ?? false) {
    headers.add('Status');
    columnWidths[colIndex++] = const pw.FixedColumnWidth(55);
  }
  if (selectedFields['totalAmount'] ?? false) {
    headers.add('Total');
    columnWidths[colIndex++] = const pw.FixedColumnWidth(50);
  }
  if (selectedFields['paidAmount'] ?? false) {
    headers.add('Paid');
    columnWidths[colIndex++] = const pw.FixedColumnWidth(50);
  }
  if (selectedFields['discByCenter'] ?? false) {
    headers.add("Ctr. Disc");
    columnWidths[colIndex++] = const pw.FixedColumnWidth(50);
  }
  if (selectedFields['discByDoctor'] ?? false) {
    headers.add("Dr. Disc");
    columnWidths[colIndex++] = const pw.FixedColumnWidth(50);
  }
  if (selectedFields['incentiveAmount'] ?? false) {
    headers.add('Incentive');
    columnWidths[colIndex++] = const pw.FixedColumnWidth(55);
  }
  if (selectedFields['testDoneBy'] ?? false) {
    headers.add('Test By');
    columnWidths[colIndex++] = const pw.FlexColumnWidth(1.3);
  }

  if (headers.isEmpty) return [];

  // Calculate totals
  final totalAmount = bills.fold<int>(0, (sum, b) => sum + b.totalAmount);
  final totalPaid = bills.fold<int>(0, (sum, b) => sum + b.paidAmount);
  final totalIncentive = bills.fold<int>(0, (sum, b) => sum + b.incentiveAmount);

  return [
    // ── Header Section ──
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
          pw.Expanded(
            flex: 2,
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Icon avatar
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
                      "LL",
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
                        "Bills Export Report",
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
                            "${bills.length} Bills",
                            font,
                            PdfColors.white,
                            PdfColors.teal,
                          ),
                          pw.SizedBox(width: smallPadding),
                          _buildInfoChip(
                            "₹${NumberFormat('#,##,###').format(totalAmount)}",
                            boldFont,
                            PdfColors.white,
                            PdfColors.teal,
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        "Generated on ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}",
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

    // ── Table Section ──
    pw.Table(
      border: pw.TableBorder.symmetric(
        inside: pw.BorderSide(color: PdfColors.grey200, width: 0.5),
      ),
      columnWidths: columnWidths,
      children: [
        // Table Header Row
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: lightBlueColor),
          children: headers.map(
            (header) => pw.Padding(
              padding: const pw.EdgeInsets.symmetric(
                horizontal: smallPadding,
                vertical: formPadding,
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
          ).toList(),
        ),
        // Data Rows
        ...bills.asMap().entries.map((entry) {
          final index = entry.key;
          final bill = entry.value;
          final isEven = index % 2 == 0;
          final cells = <pw.Widget>[];

          if (selectedFields['dateOfBill'] ?? false) {
            cells.add(_buildModernCell(
              DateFormat('dd MMM\nyyyy').format(bill.dateOfBill),
              7, font, isEven,
            ));
          }
          if (selectedFields['billNumber'] ?? false) {
            cells.add(_buildModernCell(
              bill.billNumber ?? 'N/A',
              6.5, font, isEven,
              color: PdfColors.grey600,
            ));
          }
          if (selectedFields['patientName'] ?? false) {
            cells.add(_buildModernCell(
              bill.patientName,
              7.5, font, isEven,
              align: pw.TextAlign.left,
            ));
          }
          if (selectedFields['ageAndSex'] ?? false) {
            cells.add(_buildModernCell(
              "${bill.patientAge}y\n${bill.patientSex}",
              7, font, isEven,
            ));
          }
          if (selectedFields['patientPhone'] ?? false) {
            cells.add(_buildModernCell(
              bill.patientPhoneNumber ?? 'N/A',
              7, font, isEven,
            ));
          }
          if (selectedFields['diagnosisType'] ?? false) {
            cells.add(_buildModernCell(
              _formatDiagnosis(bill),
              7, font, isEven,
              align: pw.TextAlign.left,
            ));
          }
          if (selectedFields['franchiseName'] ?? false) {
            cells.add(_buildModernCell(
              _formatFranchise(bill),
              7, font, isEven,
              align: pw.TextAlign.left,
            ));
          }
          if (selectedFields['referredByDoctor'] ?? false) {
            cells.add(_buildModernCell(
              _formatDoctor(bill),
              7, font, isEven,
              align: pw.TextAlign.left,
            ));
          }
          if (selectedFields['billStatus'] ?? false) {
            cells.add(_buildStatusCell(bill.billStatus, font, isEven));
          }
          if (selectedFields['totalAmount'] ?? false) {
            cells.add(_buildAmountCell(bill.totalAmount, font, isEven, PdfColors.grey800));
          }
          if (selectedFields['paidAmount'] ?? false) {
            cells.add(_buildAmountCell(bill.paidAmount, font, isEven, PdfColors.blue800));
          }
          if (selectedFields['discByCenter'] ?? false) {
            cells.add(_buildAmountCell(bill.discByCenter, font, isEven, PdfColors.purple700));
          }
          if (selectedFields['discByDoctor'] ?? false) {
            cells.add(_buildAmountCell(bill.discByDoctor, font, isEven, PdfColors.orange700));
          }
          if (selectedFields['incentiveAmount'] ?? false) {
            cells.add(_buildIncentiveAmountCell(bill.incentiveAmount, font, boldFont, isEven));
          }
          if (selectedFields['testDoneBy'] ?? false) {
            cells.add(_buildModernCell(
              _formatTestDoneBy(bill),
              7, font, isEven,
              align: pw.TextAlign.left,
            ));
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

    // ── Summary Row ──
    pw.Container(
      padding: const pw.EdgeInsets.symmetric(
        horizontal: mediumPadding,
        vertical: defaultPadding,
      ),
      decoration: pw.BoxDecoration(
        color: lightBlueColor,
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            "Total: ${bills.length} bills",
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
              color: deepBlueColor,
            ),
          ),
          pw.Row(
            children: [
              if (selectedFields['totalAmount'] ?? false)
                _buildSummaryChip("Total: ₹${NumberFormat('#,##,###').format(totalAmount)}", boldFont, deepBlueColor),
              if (selectedFields['paidAmount'] ?? false) ...[
                pw.SizedBox(width: smallPadding),
                _buildSummaryChip("Paid: ₹${NumberFormat('#,##,###').format(totalPaid)}", boldFont, PdfColors.blue800),
              ],
              if (selectedFields['incentiveAmount'] ?? false) ...[
                pw.SizedBox(width: smallPadding),
                _buildSummaryChip("Incentive: ₹${NumberFormat('#,##,###').format(totalIncentive)}", boldFont, PdfColors.teal700),
              ],
            ],
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

pw.Widget _buildSummaryChip(String text, pw.Font boldFont, PdfColor color) {
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: smallPadding, vertical: 3),
    decoration: pw.BoxDecoration(
      color: color.shade(0.1),
      borderRadius: pw.BorderRadius.circular(tinyRadius),
    ),
    child: pw.Text(
      text,
      style: pw.TextStyle(
        font: boldFont,
        fontSize: 7.5,
        fontWeight: pw.FontWeight.bold,
        color: color,
      ),
    ),
  );
}

pw.Widget _buildModernCell(
  String text,
  double fontSize,
  pw.Font font,
  bool isEven, {
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

pw.Widget _buildStatusCell(String status, pw.Font font, bool isEven) {
  final colors = {
    'fully paid': const [PdfColors.green100, PdfColors.green700],
    'partially paid': const [PdfColors.amber100, PdfColors.amber700],
    'unpaid': const [PdfColors.red100, PdfColors.red700],
  };
  final colorPair =
      colors[status.toLowerCase()] ?? [PdfColors.grey100, PdfColors.grey800];

  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(
      horizontal: smallPadding,
      vertical: smallPadding,
    ),
    child: pw.Center(
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(
          horizontal: smallPadding,
          vertical: minimalPadding,
        ),
        decoration: pw.BoxDecoration(
          color: colorPair[0],
          borderRadius: pw.BorderRadius.circular(tinyRadius),
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
  pw.Font font,
  bool isEven,
  PdfColor color,
) {
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(
      horizontal: smallPadding,
      vertical: smallPadding,
    ),
    child: pw.Text(
      "₹${NumberFormat('#,##,###').format(amount)}",
      style: pw.TextStyle(font: font, fontSize: 7, color: color),
      textAlign: pw.TextAlign.center,
    ),
  );
}

pw.Widget _buildIncentiveAmountCell(
  int amount,
  pw.Font font,
  pw.Font boldFont,
  bool isEven,
) {
  final isNegative = amount < 0;
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(
      horizontal: smallPadding,
      vertical: smallPadding,
    ),
    decoration: pw.BoxDecoration(
      color: isNegative
          ? const PdfColor.fromInt(0xFFFFEBEE)
          : amount == 0
              ? const PdfColor.fromInt(0xFFF3F4F6)
              : const PdfColor.fromInt(0xFFCCFBF1),
    ),
    child: pw.Text(
      "₹${NumberFormat('#,##,###').format(amount)}",
      style: pw.TextStyle(
        font: boldFont,
        fontSize: 7.5,
        fontWeight: pw.FontWeight.bold,
        color: isNegative
            ? const PdfColor.fromInt(0xFFC62828)
            : amount == 0
                ? const PdfColor.fromInt(0xFF1F2937)
                : const PdfColor.fromInt(0xFF0F766E),
      ),
      textAlign: pw.TextAlign.center,
    ),
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

String _formatDiagnosis(Bill bill) {
  if (bill.diagnosisTypesOutput != null && bill.diagnosisTypesOutput!.isNotEmpty) {
    return bill.diagnosisTypesOutput!
        .map((dt) => "${dt['name'] ?? 'Unknown'} (${dt['category_name'] ?? 'Unknown'})")
        .join(', ');
  }
  return 'N/A';
}

String _formatFranchise(Bill bill) {
  return bill.franchiseNameOutput?['franchise_name']?.toString() ?? 'N/A';
}

String _formatDoctor(Bill bill) {
  final doc = bill.referredByDoctorOutput;
  if (doc == null) return 'N/A';
  final first = doc['first_name'] ?? '';
  final last = doc['last_name'] ?? '';
  if (first.isEmpty && last.isEmpty) return 'N/A';
  return 'Dr. $first $last'.trim();
}

String _formatTestDoneBy(Bill bill) {
  final tdb = bill.testDoneBy;
  if (tdb == null) return 'N/A';
  final first = tdb['first_name'] ?? '';
  final last = tdb['last_name'] ?? '';
  if (first.isEmpty && last.isEmpty) return 'N/A';
  return '$first $last'.trim();
}
