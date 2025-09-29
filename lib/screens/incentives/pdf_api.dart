import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/models/center_detail_model_with_subscription.dart';
import 'package:labledger/models/incentive_model.dart';
import 'package:labledger/providers/authentication_provider.dart';
import 'package:labledger/providers/incenitve_generator_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

Future<Uint8List> createPDF({
  required List<DoctorReport> reports,
  required Map<String, bool> selectedFields,
  required String reportTitle,
  required WidgetRef ref,
}) async {
  final pdf = pw.Document();

  // Load a font that supports the Rupee symbol
  final liteFont = await rootBundle.load(
    "assets/fonts/GoogleSansDisplay-Regular.ttf",
  );
  final ttf = pw.Font.ttf(liteFont);

  final boldFont = await rootBundle.load(
    "assets/fonts/GoogleSansDisplay-Bold.ttf",
  );
  final boldTTF = pw.Font.ttf(boldFont);
  // Get center details
  final authResponse = await ref.read(currentUserProvider.future);
  final centerDetail = authResponse.centerDetail;

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4.portrait,
      margin: pw.EdgeInsets.all(defaultPadding / 2),
      build: (pw.Context context) {
        return reports.map((doctorReport) {
          return pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.start,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildBillsTable(
                doctorReport,
                selectedFields,
                ref,
                ttf,
                boldTTF,
                centerDetail,
              ),
              pw.SizedBox(height: 5),
            ],
          );
        }).toList();
      },
    ),
  );

  return pdf.save();
}

pw.Widget _buildBillsTable(
  DoctorReport doctorReport,
  Map<String, bool> selectedFields,
  WidgetRef ref,
  pw.Font font,
  pw.Font boldFont,
  CenterDetail centerDetail,
) {
  const lightBlueColor = PdfColor.fromInt(0xFFE3F2FD);

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

  if (headers.isEmpty) return pw.Container();
  double containerBorderRadius = 8;
  return pw.Container(
    decoration: pw.BoxDecoration(
      borderRadius: pw.BorderRadius.circular(containerBorderRadius),
      border: pw.Border.all(color: PdfColor.fromHex("#0072B5"), width: 0.6),
    ),
    child: pw.Column(
      children: [
        pw.Container(
          padding: pw.EdgeInsets.only(
            left: defaultPadding,
            right: defaultPadding,
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
                          color: lightBlueColor,
                          shape: pw.BoxShape.circle,
                        ),
                        child: pw.Center(
                          child: pw.Text(
                            "${doctorReport.doctor.firstName!.isNotEmpty ? doctorReport.doctor.firstName!.substring(0, 1).toUpperCase() : ''}${doctorReport.doctor.lastName!.isNotEmpty ? doctorReport.doctor.lastName!.substring(0, 1).toUpperCase() : ''}",
                            style: pw.TextStyle(
                              font: boldFont,
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColor.fromHex("#0072B5"),
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
                            "${doctorReport.bills.length} bills • Total ₹${doctorReport.totalIncentive}• From ${DateFormat("dd MMM yyyy").format(ref.read(reportStartDateProvider))} to ${DateFormat("dd MMM yyyy").format(ref.read(reportEndDateProvider))}",
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
                            color: PdfColor.fromHex("#0072B5"),
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
                decoration: pw.BoxDecoration(color: lightBlueColor),
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
                              color: PdfColor.fromHex("#0072B5"),
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
      ],
    ),
  );
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

// --- Report Generation Dialog Widget ---
class ReportGenerationDialog extends StatefulWidget {
  const ReportGenerationDialog({super.key});

  @override
  State<ReportGenerationDialog> createState() => _ReportGenerationDialogState();
}

class _ReportGenerationDialogState extends State<ReportGenerationDialog> {
  final _titleController = TextEditingController(text: 'Incentive Report');

  final Map<String, bool> _selectedFields = {
    'dateOfBill': true,
    'patientName': true,
    'ageAndSex': true,
    'billStatus': true,
    'diagnosisTypeOutput': true,
    'franchiseNameOutput': false,
    'totalAmount': true,
    'paidAmount': true,
    'discByDoctor': false,
    'discByCenter': false,
    'incentivePercentage': true,
    'incentiveAmount': true,
    'billNumber': true,
  };

  final Map<String, String> _fieldLabels = {
    'dateOfBill': 'Date of Bill',
    'patientName': 'Patient Name',
    'ageAndSex': 'Age/Sex',
    'billStatus': 'Payment Status',
    'diagnosisTypeOutput': 'Diagnosis',
    'franchiseNameOutput': 'Franchise Lab',
    'totalAmount': 'Total Amount',
    'paidAmount': 'Paid Amount',
    'discByDoctor': "Doctor's Discount",
    'discByCenter': "Center's Discount",
    'incentivePercentage': 'Incentive %',
    'incentiveAmount': 'Incentive Amount',
    'billNumber': 'Bill Number',
  };

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _onGeneratePressed() {
    if (_selectedFields.values.any((isSelected) => isSelected)) {
      Navigator.of(context).pop({
        'generate': true,
        'selectedFields': _selectedFields,
        'reportTitle': _titleController.text.trim(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 600,
        height: 700,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withAlpha(77),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.picture_as_pdf,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Generate PDF Report',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Select fields to include in your report',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withAlpha(178),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () =>
                      Navigator.of(context).pop({'generate': false}),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Report Title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Select Fields to Include',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: theme.colorScheme.outline.withAlpha(51),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest
                            .withAlpha(128),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                      child: Row(
                        children: [
                          TextButton.icon(
                            onPressed: () => setState(
                              () => _selectedFields.updateAll(
                                (key, value) => true,
                              ),
                            ),
                            icon: const Icon(Icons.select_all, size: 16),
                            label: const Text('Select All'),
                          ),
                          const SizedBox(width: 8),
                          TextButton.icon(
                            onPressed: () => setState(
                              () => _selectedFields.updateAll(
                                (key, value) => false,
                              ),
                            ),
                            icon: const Icon(Icons.deselect, size: 16),
                            label: const Text('Select None'),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(12),
                        children: _selectedFields.keys.map((key) {
                          return CheckboxListTile(
                            value: _selectedFields[key],
                            onChanged: (bool? value) => setState(
                              () => _selectedFields[key] = value ?? false,
                            ),
                            title: Text(
                              _fieldLabels[key] ?? key,
                              style: theme.textTheme.bodyMedium,
                            ),
                            dense: true,
                            controlAffinity: ListTileControlAffinity.leading,
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).pop({'generate': false}),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _onGeneratePressed,
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Generate PDF'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
