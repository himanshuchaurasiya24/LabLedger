// Add these imports to your existing file
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:labledger/models/bill_model.dart';
import 'package:labledger/models/incentive_model.dart';
import 'package:labledger/providers/incenitve_generator_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:typed_data';
import "package:flutter_riverpod/flutter_riverpod.dart";

Future<Uint8List> createPDF(
  List<DoctorReport> reports,
  List<String> selectedFields,
  bool includeGraphs,
  String reportTitle,
  WidgetRef ref,
) async {
  final pdf = pw.Document();
  // Create a page for each doctor (for easy cutting)
  for (final doctor in reports) {
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(15),
        build: (pw.Context context) {
          return _buildDoctorReportPage(
            doctor,
            selectedFields,
            reportTitle,
            ref,
          );
        },
      ),
    );
  }

  return pdf.save();
}

pw.Widget _buildDoctorReportPage(
  DoctorReport doctor,
  List<String> selectedFields,
  String reportTitle,
  WidgetRef ref,
) {
  final totalEarned = doctor.totalIncentive;
  final totalBills = doctor.bills.length;

  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      // Header with Lab branding
      _buildReportHeader(reportTitle, doctor),
      pw.SizedBox(height: 15),

      // Doctor summary card matching the UI
      _buildDoctorSummaryCard(doctor, totalEarned, totalBills, ref),
      pw.SizedBox(height: 15),

      // Bills table with exact layout from image
      pw.Text(
        'Bill Details ($totalBills bills)',
        style: pw.TextStyle(
          fontSize: 14,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.grey800,
        ),
      ),
      pw.SizedBox(height: 8),

      _buildBillsTableExactLayout(doctor.bills, selectedFields),

      // Footer with period info
      pw.Spacer(),
      _buildReportFooter(),
    ],
  );
}

pw.Widget _buildReportHeader(String reportTitle, DoctorReport doctor) {
  return pw.Container(
    padding: pw.EdgeInsets.all(12),
    decoration: pw.BoxDecoration(
      color: PdfColors.blue50,
      borderRadius: pw.BorderRadius.circular(8),
      border: pw.Border.all(color: PdfColors.blue200, width: 0.5),
    ),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'LabLedger',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue800,
              ),
            ),
            pw.Text(
              'Incentive Report',
              style: pw.TextStyle(fontSize: 12, color: PdfColors.blue600),
            ),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              DateFormat('dd MMM yyyy').format(DateTime.now()),
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              DateFormat('hh:mm a').format(DateTime.now()),
              style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
            ),
          ],
        ),
      ],
    ),
  );
}

pw.Widget _buildDoctorSummaryCard(
  DoctorReport doctor,
  int totalEarned,
  int totalBills,
  WidgetRef ref,
) {
  return pw.Container(
    padding: pw.EdgeInsets.all(16),
    decoration: pw.BoxDecoration(
      color: PdfColors.teal50,
      borderRadius: pw.BorderRadius.circular(8),
      border: pw.Border.all(color: PdfColors.teal200, width: 1),
    ),
    child: pw.Row(
      children: [
        // Doctor avatar
        pw.Container(
          width: 50,
          height: 50,
          decoration: pw.BoxDecoration(
            color: PdfColors.teal300,
            borderRadius: pw.BorderRadius.circular(25),
          ),
          child: pw.Center(
            child: pw.Text(
              "${doctor.firstName[0]}${doctor.lastName[0]}",
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
            ),
          ),
        ),
        pw.SizedBox(width: 16),

        // Doctor details
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "${doctor.firstName} ${doctor.lastName}",
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey800,
                ),
              ),
              pw.Text(
                "$totalBills bills • From ${DateFormat("dd MMM yyyy").format(ref.read(reportStartDateProvider))} to ${DateFormat("dd MMM yyyy").format(ref.read(reportEndDateProvider))}",
                style: pw.TextStyle(fontSize: 11, color: PdfColors.grey600),
              ),
            ],
          ),
        ),

        // Incentive amount
        pw.Container(
          padding: pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: pw.BoxDecoration(
            color: PdfColors.teal100,
            borderRadius: pw.BorderRadius.circular(16),
          ),
          child: pw.Row(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.Text(
                '₹',
                style: pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.teal800,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                NumberFormat.decimalPattern('en_IN').format(totalEarned),
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.teal800,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

pw.Widget _buildBillsTableExactLayout(
  List<Bill> bills,
  List<String> selectedFields,
) {
  // Define all columns exactly as in the image
  final columns = [
    'Date Of Bill',
    'Patient',
    'Age Sex',
    'Payment Status',
    'Diagnosis',
    'Franchise Lab',
    'Total',
    'Paid',
    'Doctor\'s Discount',
    'Center\'s Discount',
    'Incentive %',
    'Incentive',
    'Bill #',
  ];

  return pw.Container(
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
      borderRadius: pw.BorderRadius.circular(6),
    ),
    child: pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      columnWidths: {
        0: pw.FixedColumnWidth(55), // Date
        1: pw.FixedColumnWidth(65), // Patient
        2: pw.FixedColumnWidth(35), // Age Sex
        3: pw.FixedColumnWidth(45), // Status
        4: pw.FixedColumnWidth(75), // Diagnosis
        5: pw.FixedColumnWidth(60), // Franchise
        6: pw.FixedColumnWidth(40), // Total
        7: pw.FixedColumnWidth(40), // Paid
        8: pw.FixedColumnWidth(35), // Doc Disc
        9: pw.FixedColumnWidth(35), // Center Disc
        10: pw.FixedColumnWidth(30), // Incentive %
        11: pw.FixedColumnWidth(40), // Incentive
        12: pw.FixedColumnWidth(50), // Bill #
      },
      children: [
        // Header row
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColors.blue100),
          children: columns
              .map(
                (header) => pw.Container(
                  padding: pw.EdgeInsets.all(4),
                  child: pw.Text(
                    header,
                    style: pw.TextStyle(
                      fontSize: 7,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue800,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              )
              .toList(),
        ),

        // Data rows
        ...bills.asMap().entries.map((entry) {
          final index = entry.key;
          final bill = entry.value;
          final isEvenRow = index % 2 == 0;

          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: isEvenRow ? PdfColors.grey50 : PdfColors.white,
            ),
            children: [
              _buildTableCell(
                DateFormat('dd MMM yyyy').format(bill.dateOfBill),
                6,
              ),
              _buildTableCell(_formatPatientInfo(bill), 6),
              _buildTableCell("${bill.patientAge}y ${bill.patientSex}", 6),
              _buildPaymentStatusCell(bill.billStatus),
              _buildTableCell(_formatDiagnosis(bill), 6),
              _buildTableCell(_formatFranchise(bill), 6),
              _buildTableCell(
                "₹${NumberFormat.decimalPattern('en_IN').format(bill.totalAmount)}",
                6,
              ),
              _buildTableCell(
                "₹${NumberFormat.decimalPattern('en_IN').format(bill.paidAmount)}",
                6,
              ),
              _buildTableCell(
                "₹${NumberFormat.decimalPattern('en_IN').format(bill.discByDoctor)}",
                6,
              ),
              _buildTableCell(
                "₹${NumberFormat.decimalPattern('en_IN').format(bill.discByCenter)}",
                6,
              ),
              _buildTableCell(_getIncentivePercentage(bill), 6),
              _buildIncentiveCell(bill.incentiveAmount),
              _buildTableCell(bill.billNumber ?? "N/A", 5),
            ],
          );
        }),
      ],
    ),
  );
}

pw.Widget _buildTableCell(String text, double fontSize) {
  return pw.Container(
    padding: pw.EdgeInsets.all(3),
    child: pw.Text(
      text,
      style: pw.TextStyle(fontSize: fontSize, color: PdfColors.grey800),
      textAlign: pw.TextAlign.center,
      maxLines: 2,
      overflow: pw.TextOverflow.clip,
    ),
  );
}

pw.Widget _buildPaymentStatusCell(String status) {
  PdfColor bgColor;
  PdfColor textColor;

  switch (status.toLowerCase()) {
    case 'fully paid':
      bgColor = PdfColors.green100;
      textColor = PdfColors.green800;
      break;
    case 'partially paid':
      bgColor = PdfColors.amber100;
      textColor = PdfColors.amber800;
      break;
    default:
      bgColor = PdfColors.red100;
      textColor = PdfColors.red800;
  }

  return pw.Container(
    padding: pw.EdgeInsets.all(3),
    child: pw.Container(
      padding: pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: pw.BoxDecoration(
        color: bgColor,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Text(
        status,
        style: pw.TextStyle(
          fontSize: 5.5,
          fontWeight: pw.FontWeight.bold,
          color: textColor,
        ),
        textAlign: pw.TextAlign.center,
      ),
    ),
  );
}

pw.Widget _buildIncentiveCell(int amount) {
  return pw.Container(
    padding: pw.EdgeInsets.all(3),
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
}

String _formatPatientInfo(Bill bill) {
  final name = bill.patientName.length > 12
      ? "${bill.patientName.substring(0, 12)}..."
      : bill.patientName;
  final phone =
      bill.patientPhoneNumber?.substring(bill.patientPhoneNumber!.length - 4) ??
      "";
  return phone.isNotEmpty ? "$name\n*$phone" : name;
}

String _formatDiagnosis(Bill bill) {
  if (bill.diagnosisTypeOutput != null) {
    final name = bill.diagnosisTypeOutput!['name'] ?? '';
    final category = bill.diagnosisTypeOutput!['category'] ?? '';
    return name.length > 15
        ? "${name.substring(0, 15)}..."
        : "$name ($category)";
  }
  return 'N/A';
}

String _formatFranchise(Bill bill) {
  if (bill.franchiseNameOutput != null) {
    final name = bill.franchiseNameOutput!['franchise_name'] ?? 'N/A';
    return name.length > 12 ? "${name.substring(0, 12)}..." : name;
  }
  return 'N/A';
}

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

pw.Widget _buildReportFooter() {
  return pw.Container(
    padding: pw.EdgeInsets.all(8),
    decoration: pw.BoxDecoration(
      color: PdfColors.grey100,
      borderRadius: pw.BorderRadius.circular(6),
    ),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          'Generated by LabLedger',
          style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
        ),
        pw.Text(
          'Confidential Report',
          style: pw.TextStyle(
            fontSize: 8,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.grey600,
          ),
        ),
      ],
    ),
  );
}

// Report Generation Dialog Widget
class ReportGenerationDialog extends StatefulWidget {
  final Function(List<String>, bool, String) onGenerateReport;

  const ReportGenerationDialog({super.key, required this.onGenerateReport});

  @override
  State<ReportGenerationDialog> createState() => _ReportGenerationDialogState();
}

class _ReportGenerationDialogState extends State<ReportGenerationDialog> {
  final TextEditingController _titleController = TextEditingController(
    text: 'Incentive Report',
  );

  bool includeGraphs = true;

  final Map<String, bool> selectedFields = {
    'dateOfBill': true,
    'patientName': true,
    'patientAge': false,
    'patientSex': false,
    'patientPhoneNumber': false,
    'billStatus': true,
    'diagnosisTypeOutput': true,
    'franchiseNameOutput': false,
    'totalAmount': true,
    'paidAmount': true,
    'discByDoctor': false,
    'discByCenter': false,
    'incentiveAmount': true,
    'billNumber': false,
  };

  final Map<String, String> fieldLabels = {
    'dateOfBill': 'Date of Bill',
    'patientName': 'Patient Name',
    'patientAge': 'Patient Age',
    'patientSex': 'Patient Sex',
    'patientPhoneNumber': 'Patient Phone',
    'billStatus': 'Payment Status',
    'diagnosisTypeOutput': 'Diagnosis',
    'franchiseNameOutput': 'Franchise Lab',
    'totalAmount': 'Total Amount',
    'paidAmount': 'Paid Amount',
    'discByDoctor': 'Doctor\'s Discount',
    'discByCenter': 'Center\'s Discount',
    'incentiveAmount': 'Incentive Amount',
    'billNumber': 'Bill Number',
  };

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 600,
        height: 700,
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(
                      alpha: 0.3,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.picture_as_pdf,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
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
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),

            SizedBox(height: 24),

            // Report Title
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Report Title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: Icon(Icons.title),
              ),
            ),

            SizedBox(height: 24),

            // Field Selection
            Text(
              'Select Fields to Include',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),

            SizedBox(height: 12),

            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    // Select All/None buttons
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.5),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                      child: Row(
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                selectedFields.updateAll((key, value) => true);
                              });
                            },
                            icon: Icon(Icons.select_all, size: 16),
                            label: Text('Select All'),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                selectedFields.updateAll((key, value) => false);
                              });
                            },
                            icon: Icon(Icons.deselect, size: 16),
                            label: Text('Select None'),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Field checkboxes
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.all(12),
                        children: selectedFields.entries.map((entry) {
                          return CheckboxListTile(
                            value: entry.value,
                            onChanged: (bool? value) {
                              setState(() {
                                selectedFields[entry.key] = value ?? false;
                              });
                            },
                            title: Text(
                              fieldLabels[entry.key] ?? entry.key,
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

            SizedBox(height: 20),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel'),
                ),
                SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: selectedFields.values.any((selected) => selected)
                      ? () {
                          final selectedFieldsList = selectedFields.entries
                              .where((entry) => entry.value)
                              .map((entry) => entry.key)
                              .toList();

                          widget.onGenerateReport(
                            selectedFieldsList,
                            includeGraphs,
                            _titleController.text.trim(),
                          );
                          Navigator.of(context).pop();
                        }
                      : null,
                  icon: Icon(Icons.picture_as_pdf),
                  label: Text('Generate PDF'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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

// // Report Generation Dialog Widget
// class ReportGenerationDialog extends StatefulWidget {
//   final Function(List<String>, bool, String) onGenerateReport;

//   const ReportGenerationDialog({super.key, required this.onGenerateReport});

//   @override
//   State<ReportGenerationDialog> createState() => _ReportGenerationDialogState();
// }

// class _ReportGenerationDialogState extends State<ReportGenerationDialog> {
//   final TextEditingController _titleController = TextEditingController(
//     text: 'Incentive Report',
//   );

//   bool includeGraphs = true;

//   final Map<String, bool> selectedFields = {
//     'dateOfBill': true,
//     'patientName': true,
//     'patientAge': false,
//     'patientSex': false,
//     'patientPhoneNumber': false,
//     'billStatus': true,
//     'diagnosisTypeOutput': true,
//     'franchiseNameOutput': false,
//     'totalAmount': true,
//     'paidAmount': true,
//     'discByDoctor': false,
//     'discByCenter': false,
//     'incentiveAmount': true,
//     'billNumber': false,
//   };

//   final Map<String, String> fieldLabels = {
//     'dateOfBill': 'Date of Bill',
//     'patientName': 'Patient Name',
//     'patientAge': 'Patient Age',
//     'patientSex': 'Patient Sex',
//     'patientPhoneNumber': 'Patient Phone',
//     'billStatus': 'Payment Status',
//     'diagnosisTypeOutput': 'Diagnosis',
//     'franchiseNameOutput': 'Franchise Lab',
//     'totalAmount': 'Total Amount',
//     'paidAmount': 'Paid Amount',
//     'discByDoctor': 'Doctor\'s Discount',
//     'discByCenter': 'Center\'s Discount',
//     'incentiveAmount': 'Incentive Amount',
//     'billNumber': 'Bill Number',
//   };

//   @override
//   void dispose() {
//     _titleController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Dialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Container(
//         width: 600,
//         height: 700,
//         padding: EdgeInsets.all(24),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Header
//             Row(
//               children: [
//                 Container(
//                   padding: EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: theme.colorScheme.primaryContainer.withValues(
//                       alpha: 0.3,
//                     ),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Icon(
//                     Icons.picture_as_pdf,
//                     color: theme.colorScheme.primary,
//                     size: 24,
//                   ),
//                 ),
//                 SizedBox(width: 16),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Generate PDF Report',
//                         style: theme.textTheme.headlineSmall?.copyWith(
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       Text(
//                         'Select fields to include in your report',
//                         style: theme.textTheme.bodyMedium?.copyWith(
//                           color: theme.colorScheme.onSurface.withValues(
//                             alpha: 0.7,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.close),
//                   onPressed: () => Navigator.of(context).pop(),
//                 ),
//               ],
//             ),

//             SizedBox(height: 24),

//             // Report Title
//             TextField(
//               controller: _titleController,
//               decoration: InputDecoration(
//                 labelText: 'Report Title',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 prefixIcon: Icon(Icons.title),
//               ),
//             ),

//             SizedBox(height: 24),

//             // Field Selection
//             Text(
//               'Select Fields to Include',
//               style: theme.textTheme.titleMedium?.copyWith(
//                 fontWeight: FontWeight.w600,
//               ),
//             ),

//             SizedBox(height: 12),

//             Expanded(
//               child: Container(
//                 decoration: BoxDecoration(
//                   border: Border.all(
//                     color: theme.colorScheme.outline.withValues(alpha: 0.2),
//                   ),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Column(
//                   children: [
//                     // Select All/None buttons
//                     Container(
//                       padding: EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: theme.colorScheme.surfaceContainerHighest
//                             .withValues(alpha: 0.5),
//                         borderRadius: BorderRadius.only(
//                           topLeft: Radius.circular(8),
//                           topRight: Radius.circular(8),
//                         ),
//                       ),
//                       child: Row(
//                         children: [
//                           TextButton.icon(
//                             onPressed: () {
//                               setState(() {
//                                 selectedFields.updateAll((key, value) => true);
//                               });
//                             },
//                             icon: Icon(Icons.select_all, size: 16),
//                             label: Text('Select All'),
//                             style: TextButton.styleFrom(
//                               padding: EdgeInsets.symmetric(
//                                 horizontal: 12,
//                                 vertical: 6,
//                               ),
//                             ),
//                           ),
//                           SizedBox(width: 8),
//                           TextButton.icon(
//                             onPressed: () {
//                               setState(() {
//                                 selectedFields.updateAll((key, value) => false);
//                               });
//                             },
//                             icon: Icon(Icons.deselect, size: 16),
//                             label: Text('Select None'),
//                             style: TextButton.styleFrom(
//                               padding: EdgeInsets.symmetric(
//                                 horizontal: 12,
//                                 vertical: 6,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),

//                     // Field checkboxes
//                     Expanded(
//                       child: ListView(
//                         padding: EdgeInsets.all(12),
//                         children: selectedFields.entries.map((entry) {
//                           return CheckboxListTile(
//                             value: entry.value,
//                             onChanged: (bool? value) {
//                               setState(() {
//                                 selectedFields[entry.key] = value ?? false;
//                               });
//                             },
//                             title: Text(
//                               fieldLabels[entry.key] ?? entry.key,
//                               style: theme.textTheme.bodyMedium,
//                             ),
//                             dense: true,
//                             controlAffinity: ListTileControlAffinity.leading,
//                           );
//                         }).toList(),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             SizedBox(height: 20),

//             // Action buttons
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 TextButton(
//                   onPressed: () => Navigator.of(context).pop(),
//                   child: Text('Cancel'),
//                 ),
//                 SizedBox(width: 12),
//                 ElevatedButton.icon(
//                   onPressed: selectedFields.values.any((selected) => selected)
//                       ? () {
//                           final selectedFieldsList = selectedFields.entries
//                               .where((entry) => entry.value)
//                               .map((entry) => entry.key)
//                               .toList();

//                           widget.onGenerateReport(
//                             selectedFieldsList,
//                             includeGraphs,
//                             _titleController.text.trim(),
//                           );
//                           Navigator.of(context).pop();
//                         }
//                       : null,
//                   icon: Icon(Icons.picture_as_pdf),
//                   label: Text('Generate PDF'),
//                   style: ElevatedButton.styleFrom(
//                     padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
