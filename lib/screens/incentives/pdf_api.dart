import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:labledger/models/bill_model.dart';
import 'package:labledger/models/center_detail_model_with_subscription.dart';
import 'package:labledger/models/incentive_model.dart';
import 'package:labledger/providers/authentication_provider.dart';
import 'package:labledger/providers/incenitve_generator_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

// --- Main PDF Creation Function ---
Future<Uint8List> createPDF({
  required List<DoctorReport> reports,
  required Map<String, bool> selectedFields,
  required String reportTitle,
  required WidgetRef ref,
}) async {
  final pdf = pw.Document();
  final currentUser = await ref.read(currentUserProvider.future);
  final centerDetail = currentUser.centerDetail;

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4.landscape,
      margin: const pw.EdgeInsets.all(25),
      build: (pw.Context context) {
        return reports.map((doctor) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // 🌟 REVISED: Professional, colorful doctor summary card
              _buildDoctorSummaryCard(doctor, ref, centerDetail, reportTitle),
              pw.SizedBox(height: 15),
              pw.Text(
                'Bill Details (${doctor.bills.length} bills)',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey800,
                ),
              ),
              pw.SizedBox(height: 5),
              _buildBillsTable(doctor.bills, selectedFields),
              // 🌟 MOVED: Footer is now per-doctor
              _buildDoctorReportFooter(),
              pw.SizedBox(height: 30), // Space between doctors
            ],
          );
        }).toList();
      },
    ),
  );

  return pdf.save();
}

// --- PDF Page Components ---

// 🌟 REVISED: This is the new professional doctor header
pw.Widget _buildDoctorSummaryCard(
  DoctorReport doctor,
  WidgetRef ref,
  CenterDetail centerDetail,
  String reportTitle,
) {
  const tealColor = PdfColor.fromInt(0xFF008080); // Teal
  const lightTealColor = PdfColor.fromInt(0xFFE0F2F1); // Light Teal background

  return pw.Container(
    padding: const pw.EdgeInsets.all(12),
    decoration: pw.BoxDecoration(
      color: lightTealColor,
      borderRadius: pw.BorderRadius.circular(6),
      border: pw.Border.all(color: tealColor, width: 0.5),
    ),
    child: pw.Column(
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              "${doctor.firstName} ${doctor.lastName}",
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
                color: tealColor,
              ),
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  "Total Incentive",
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey700,
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  "₹${NumberFormat.decimalPattern('en_IN').format(doctor.totalIncentive)}",
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.green700,
                  ),
                ),
              ],
            ),
          ],
        ),
        pw.Divider(color: tealColor.shade(0.5), height: 15, thickness: 0.5),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  "${centerDetail.centerName}, ${centerDetail.address}",
                  style: const pw.TextStyle(
                    fontSize: 9,
                    color: PdfColors.blueGrey500,
                  ),
                ),
                pw.SizedBox(height: 3),
                pw.Text(
                  "Report Period: ${DateFormat("dd MMM yyyy").format(ref.read(reportStartDateProvider))} to ${DateFormat("dd MMM yyyy").format(ref.read(reportEndDateProvider))}",
                  style: const pw.TextStyle(
                    fontSize: 9,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),
            pw.Text(
              "Total Bills: ${doctor.bills.length}",
              style: pw.TextStyle(
                fontSize: 9,
                color: PdfColors.grey700,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

pw.Widget _buildBillsTable(List<Bill> bills, Map<String, bool> selectedFields) {
  final headers = <String>[];
  final Map<int, pw.TableColumnWidth> columnWidths = {};

  int colIndex = 0;
  if (selectedFields['dateOfBill'] ?? false) {
    headers.add('Date');
    columnWidths[colIndex++] = const pw.FixedColumnWidth(55);
  }
  if (selectedFields['patientName'] ?? false) {
    headers.add('Patient');
    columnWidths[colIndex++] = const pw.FlexColumnWidth(2);
  }
  if (selectedFields['ageAndSex'] ?? false) {
    headers.add('Age/Sex');
    columnWidths[colIndex++] = const pw.FixedColumnWidth(40);
  }
  if (selectedFields['billStatus'] ?? false) {
    headers.add('Status');
    columnWidths[colIndex++] = const pw.FixedColumnWidth(45);
  }
  if (selectedFields['diagnosisTypeOutput'] ?? false) {
    headers.add('Diagnosis');
    columnWidths[colIndex++] = const pw.FlexColumnWidth(2.5);
  }
  if (selectedFields['franchiseNameOutput'] ?? false) {
    headers.add('Franchise');
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
    headers.add('Doc Disc');
    columnWidths[colIndex++] = const pw.FixedColumnWidth(35);
  }
  if (selectedFields['discByCenter'] ?? false) {
    headers.add('Cen Disc');
    columnWidths[colIndex++] = const pw.FixedColumnWidth(35);
  }
  if (selectedFields['incentivePercentage'] ?? false) {
    headers.add('Inc %');
    columnWidths[colIndex++] = const pw.FixedColumnWidth(30);
  }
  if (selectedFields['incentiveAmount'] ?? false) {
    headers.add('Incentive');
    columnWidths[colIndex++] = const pw.FixedColumnWidth(45);
  }
  if (selectedFields['billNumber'] ?? false) {
    headers.add('Bill #');
    columnWidths[colIndex++] = const pw.FlexColumnWidth(1.5);
  }

  if (headers.isEmpty) return pw.Container();

  return pw.Table(
    border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
    columnWidths: columnWidths,
    children: [
      pw.TableRow(
        // 🌟 REVISED: Table header color changed
        decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFF0072B5)),
        children: headers
            .map(
              (header) => pw.Container(
                padding: const pw.EdgeInsets.all(4),
                child: pw.Text(
                  header,
                  style: pw.TextStyle(
                    fontSize: 7,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white, // Text color to white
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ),
            )
            .toList(),
      ),
      ...bills.asMap().entries.map((entry) {
        final bill = entry.value;
        final isEvenRow = entry.key % 2 == 0;
        final cells = <pw.Widget>[];

        if (selectedFields['dateOfBill'] ?? false) {
          cells.add(
            _buildTableCell(DateFormat('dd-MM-yy').format(bill.dateOfBill), 6),
          );
        }
        if (selectedFields['patientName'] ?? false) {
          cells.add(_buildTableCell(bill.patientName, 6));
        }
        if (selectedFields['ageAndSex'] ?? false) {
          cells.add(
            _buildTableCell("${bill.patientAge}y ${bill.patientSex}", 6),
          );
        }
        if (selectedFields['billStatus'] ?? false) {
          cells.add(_buildPaymentStatusCell(bill.billStatus));
        }
        if (selectedFields['diagnosisTypeOutput'] ?? false) {
          cells.add(_buildTableCell(_formatDiagnosis(bill), 6));
        }
        if (selectedFields['franchiseNameOutput'] ?? false) {
          cells.add(_buildTableCell(_formatFranchise(bill), 6));
        }
        if (selectedFields['totalAmount'] ?? false) {
          cells.add(
            _buildTableCell(
              "₹${NumberFormat.decimalPattern('en_IN').format(bill.totalAmount)}",
              6,
            ),
          );
        }
        if (selectedFields['paidAmount'] ?? false) {
          cells.add(
            _buildTableCell(
              "₹${NumberFormat.decimalPattern('en_IN').format(bill.paidAmount)}",
              6,
            ),
          );
        }
        if (selectedFields['discByDoctor'] ?? false) {
          cells.add(
            _buildTableCell(
              "₹${NumberFormat.decimalPattern('en_IN').format(bill.discByDoctor)}",
              6,
            ),
          );
        }
        if (selectedFields['discByCenter'] ?? false) {
          cells.add(
            _buildTableCell(
              "₹${NumberFormat.decimalPattern('en_IN').format(bill.discByCenter)}",
              6,
            ),
          );
        }
        if (selectedFields['incentivePercentage'] ?? false) {
          cells.add(_buildTableCell(_getIncentivePercentage(bill), 6));
        }
        if (selectedFields['incentiveAmount'] ?? false) {
          cells.add(_buildIncentiveCell(bill.incentiveAmount));
        }
        if (selectedFields['billNumber'] ?? false) {
          cells.add(_buildTableCell(bill.billNumber ?? 'N/A', 5));
        }

        return pw.TableRow(
          decoration: pw.BoxDecoration(
            color: isEvenRow ? PdfColors.white : PdfColors.grey50,
          ),
          children: cells,
        );
      }),
    ],
  );
}

// 🌟 NEW: This is the per-doctor footer
pw.Widget _buildDoctorReportFooter() {
  return pw.Container(
    padding: const pw.EdgeInsets.only(top: 8),
    margin: const pw.EdgeInsets.only(top: 8),
    decoration: const pw.BoxDecoration(
      border: pw.Border(
        top: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
      ),
    ),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Text(
          'Generated by LabLedger on ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}',
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
        ),
      ],
    ),
  );
}

// --- Helper Functions and Widgets ---

pw.Widget _buildTableCell(String text, double fontSize) => pw.Container(
  padding: const pw.EdgeInsets.all(3),
  child: pw.Text(
    text,
    style: pw.TextStyle(fontSize: fontSize, color: PdfColors.grey800),
    textAlign: pw.TextAlign.center,
    maxLines: 2,
    overflow: pw.TextOverflow.clip,
  ),
);

pw.Widget _buildPaymentStatusCell(String status) {
  final colors = {
    'fully paid': const [PdfColors.green100, PdfColors.green800],
    'partially paid': const [PdfColors.amber100, PdfColors.amber800],
    'unpaid': const [PdfColors.red100, PdfColors.red800],
  };
  final colorPair =
      colors[status.toLowerCase()] ?? [PdfColors.grey100, PdfColors.grey800];
  return pw.Container(
    padding: const pw.EdgeInsets.all(3),
    child: pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: pw.BoxDecoration(
        color: colorPair[0],
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Text(
        status,
        style: pw.TextStyle(
          fontSize: 5.5,
          fontWeight: pw.FontWeight.bold,
          color: colorPair[1],
        ),
        textAlign: pw.TextAlign.center,
      ),
    ),
  );
}

pw.Widget _buildIncentiveCell(int amount) => pw.Container(
  padding: const pw.EdgeInsets.all(3),
  child: pw.Text(
    "₹${NumberFormat.decimalPattern('en_IN').format(amount)}",
    style: pw.TextStyle(
      fontSize: 6,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.green800,
    ),
    textAlign: pw.TextAlign.center,
  ),
);

String _formatDiagnosis(Bill bill) => bill.diagnosisTypeOutput != null
    ? "${bill.diagnosisTypeOutput!['name'] ?? ''} (${bill.diagnosisTypeOutput!['category'] ?? ''})"
    : 'N/A';
String _formatFranchise(Bill bill) => bill.franchiseNameOutput != null
    ? bill.franchiseNameOutput!['franchise_name'] ?? 'N/A'
    : 'N/A';
String _getIncentivePercentage(Bill bill) {
  if (bill.referredByDoctorOutput != null && bill.diagnosisTypeOutput != null) {
    final category = bill.diagnosisTypeOutput!['category']
        ?.toString()
        .toLowerCase();
    final doctorData = bill.referredByDoctorOutput!;
    switch (category) {
      case 'ultrasound':
        return doctorData['ultrasound_percentage']?.toString() ?? '0';
      case 'ecg':
        return doctorData['ecg_percentage']?.toString() ?? '0';
      case 'x-ray':
        return doctorData['xray_percentage']?.toString() ?? '0';
      case 'pathology':
        return doctorData['pathology_percentage']?.toString() ?? '0';
      case 'franchise lab':
        return doctorData['franchise_lab_percentage']?.toString() ?? '0';
      default:
        return '0';
    }
  }
  return '0';
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
