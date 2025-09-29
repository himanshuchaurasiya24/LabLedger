import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/main.dart';
import 'package:labledger/models/bill_model.dart';
import 'package:labledger/models/incentive_model.dart';
import 'package:labledger/providers/diagnosis_type_provider.dart';
import 'package:labledger/providers/doctor_provider.dart';
import 'package:labledger/providers/franchise_provider.dart';
import 'package:labledger/providers/incenitve_generator_provider.dart';
import 'package:labledger/screens/bills/add_update_bill_screen.dart';
import 'package:labledger/screens/incentives/pdf_api.dart';
import 'package:labledger/screens/initials/window_scaffold.dart';
import 'package:labledger/screens/ui_components/custom_text_field.dart';
import 'package:labledger/screens/ui_components/tinted_container.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:universal_html/html.dart' as html;

// Main Screen Widget
class IncentiveDetailScreen extends ConsumerStatefulWidget {
  const IncentiveDetailScreen({super.key});

  @override
  ConsumerState<IncentiveDetailScreen> createState() =>
      _IncentiveDetailScreenState();
}

class _IncentiveDetailScreenState extends ConsumerState<IncentiveDetailScreen> {
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- PDF Generation and Dialog Logic ---

  Future<void> _showReportGenerationDialog(BuildContext context) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ReportGenerationDialog(); // 🌟 This widget now comes from pdf_api.dart
      },
    );

    if (result != null && result['generate'] == true) {
      final selectedFields = result['selectedFields'] as Map<String, bool>;
      final reportTitle = result['reportTitle'] as String;

      _showProgressDialog();

      await _generatePDFReport(selectedFields, reportTitle);

      // ignore: use_build_context_synchronously
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  void _showProgressDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Dialog(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("Generating Report..."),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _generatePDFReport(
    Map<String, bool> selectedFields,
    String reportTitle,
  ) async {
    try {
      final reportAsync = ref.read(incentiveReportProvider);

       reportAsync.when(
        data: (report) async {
          if (report.isEmpty) {
            _showSnackBar('No data available for report generation', isError: true);
            return;
          }

          final filteredReports = report.where((doctor) {
            final fullName =
                '${doctor.firstName} ${doctor.lastName}'.toLowerCase();
            return fullName.contains(searchQuery);
          }).toList();

          if (filteredReports.isEmpty) {
            _showSnackBar('No filtered data to generate report', isError: true);
            return;
          }
          
          // 🌟 Call the createPDF function from pdf_api.dart
          final pdfBytes = await createPDF(
            reports: filteredReports,
            selectedFields: selectedFields,
            reportTitle: reportTitle,
            ref: ref,
          );

          if (kIsWeb) {
            _downloadPdfWeb(pdfBytes, reportTitle);
          } else {
            await Printing.layoutPdf(
              onLayout: (PdfPageFormat format) async => pdfBytes,
              name: '${reportTitle.replaceAll(' ', '_')}.pdf',
            );
          }
          _showSnackBar('Report generated successfully!', isError: false);
        },
        loading: () =>
            _showSnackBar('Please wait for data to load', isError: false),
        error: (err, stack) =>
            _showSnackBar('Error generating report: $err', isError: true),
      );
    } catch (e) {
      _showSnackBar('Failed to generate report: $e', isError: true);
    }
  }

  void _downloadPdfWeb(Uint8List pdfBytes, String reportTitle) {
    final blob = html.Blob([pdfBytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..style.display = 'none'
      ..download = '${reportTitle.replaceAll(' ', '_')}.pdf';
    html.document.body!.children.add(anchor);
    anchor.click();
    html.document.body!.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }

  void _showSnackBar(String message, {required bool isError}) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor:
              isError ? Theme.of(context).colorScheme.error : Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final reportAsync = ref.watch(incentiveReportProvider);
    final theme = Theme.of(context);

    return WindowScaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showReportGenerationDialog(context),
        label: const Text("Generate Report"),
        icon: const Icon(Icons.picture_as_pdf_outlined),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(theme),
          SizedBox(height: defaultHeight),
          _buildSearchBar(theme),
          SizedBox(height: defaultHeight),
          Expanded(
            child: reportAsync.when(
              data: (report) => _buildReportContent(report, theme),
              loading: () => _buildLoadingState(),
              error: (err, stack) => _buildErrorState(err, theme),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(defaultPadding),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withAlpha(77),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            LucideIcons.trendingUp,
            color: theme.colorScheme.primary,
            size: 28,
          ),
        ),
        SizedBox(width: defaultPadding),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Incentive Reports",
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Doctor performance and earnings overview",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(178),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(LucideIcons.refreshCw, color: theme.colorScheme.primary),
          tooltip: "Refresh Report",
          onPressed: () => ref.invalidate(incentiveReportProvider),
        ),
      ],
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withAlpha(128),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withAlpha(51)),
      ),
      child: CustomTextField(
        tintColor: theme.colorScheme.secondary,
        controller: _searchController,
        label: "Search doctors...",
        onChanged: (value) {
          setState(() {
            searchQuery = value.toLowerCase();
          });
        },
      ),
    );
  }

  Widget _buildReportContent(List<DoctorReport> report, ThemeData theme) {
    if (report.isEmpty) {
      return _buildEmptyState(theme);
    }

    final filteredReports = report.where((doctor) {
      final fullName = '${doctor.firstName} ${doctor.lastName}'.toLowerCase();
      return fullName.contains(searchQuery);
    }).toList();

    if (filteredReports.isEmpty) {
      return _buildNoSearchResults(theme);
    }

    final totalIncentives = filteredReports.fold<int>(
      0,
      (sum, doctor) => sum + doctor.totalIncentive,
    );
    final totalBills = filteredReports.fold<int>(
      0,
      (sum, doctor) => sum + doctor.bills.length,
    );

    return Column(
      children: [
        _buildSummaryCards(
          filteredReports.length,
          totalIncentives,
          totalBills,
          theme,
        ),
        SizedBox(height: defaultHeight),
        Expanded(
          child: ListView.builder(
            itemCount: filteredReports.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(bottom: defaultPadding),
                child: _buildDoctorExpansionTile(
                  filteredReports[index],
                  index,
                  theme,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCards(
    int doctorCount,
    int totalIncentives,
    int totalBills,
    ThemeData theme,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            icon: LucideIcons.users,
            title: "Doctors",
            value: doctorCount.toString(),
            color: Colors.teal,
            theme: theme,
          ),
        ),
        SizedBox(width: defaultWidth * 2),
        Expanded(
          child: _buildSummaryCard(
            icon: LucideIcons.indianRupee,
            title: "Total Incentives",
            value:
                "₹${NumberFormat.decimalPattern('en_IN').format(totalIncentives)}",
            color: theme.colorScheme.primary,
            theme: theme,
          ),
        ),
        SizedBox(width: defaultWidth * 2),
        Expanded(
          child: _buildSummaryCard(
            icon: LucideIcons.fileText,
            title: "Bills",
            value: totalBills.toString(),
            color: Colors.orange,
            theme: theme,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required ThemeData theme,
  }) {
    return TintedContainer(
      baseColor: color,
      height: 70,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorExpansionTile(
    DoctorReport doctor,
    int index,
    ThemeData theme,
  ) {
    final cardColor = _getDoctorCardColor(index, context);
    final subtitleText =
        "${doctor.bills.length} bills • From ${DateFormat("dd MMM yyyy").format(ref.read(reportStartDateProvider))} to ${DateFormat("dd MMM yyyy").format(ref.read(reportEndDateProvider))}";

    return ExpansionTile(
      tilePadding: EdgeInsets.all(defaultPadding),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cardColor, width: 1),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cardColor, width: 1),
      ),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: cardColor.withAlpha(51),
        child: Text(
          "${doctor.firstName[0]}${doctor.lastName[0]}",
          style: TextStyle(
            color: cardColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      title: Text(
        "${doctor.firstName} ${doctor.lastName}",
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        subtitleText,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withAlpha(178),
        ),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: cardColor.withAlpha(51),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.indianRupee, color: cardColor, size: 16),
            Text(
              NumberFormat.decimalPattern(
                'en_IN',
              ).format(doctor.totalIncentive),
              style: TextStyle(color: cardColor, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      children: [_buildBillsSection(doctor.bills, theme)],
    );
  }

  Widget _buildBillsSection(List<Bill> bills, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            "Bill Details (${bills.length} bills)",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowHeight: 40,
            dataRowMinHeight: 35,
            dataRowMaxHeight: 45,
            headingTextStyle: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
            border: TableBorder.all(
              color: theme.colorScheme.outline.withAlpha(51),
              borderRadius: BorderRadius.circular(6),
              width: 1,
            ),
            columns: const [
              DataColumn(label: Text('Date Of Bill')),
              DataColumn(label: Text('Patient')),
              DataColumn(label: Text('Age Sex')),
              DataColumn(label: Text('Payment Status')),
              DataColumn(label: Text('Diagnosis')),
              DataColumn(label: Text('Franchise Lab')),
              DataColumn(label: Text('Total'), numeric: true),
              DataColumn(label: Text('Paid'), numeric: true),
              DataColumn(label: Text('Doctor\'s Discount'), numeric: true),
              DataColumn(label: Text('Center\'s Discount'), numeric: true),
              DataColumn(label: Text('Incentive %'), numeric: true),
              DataColumn(label: Text('Incentive'), numeric: true),
              DataColumn(label: Text('Bill #')),
            ],
            rows: bills.map((bill) {
              final statusColor = _getBillStatusColor(bill.billStatus);
              return DataRow(
                cells: [
                  DataCell(
                    Text(DateFormat("dd MMM yyyy").format(bill.dateOfBill)),
                  ),
                  DataCell(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          bill.patientName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (bill.patientPhoneNumber != null &&
                            bill.patientPhoneNumber!.isNotEmpty)
                          Text(
                            bill.patientPhoneNumber!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withAlpha(153),
                              fontSize: 10,
                            ),
                          ),
                      ],
                    ),
                  ),
                  DataCell(Text("${bill.patientAge}y ${bill.patientSex}")),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withAlpha(51),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        bill.billStatus,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    ref
                        .watch(diagnosisTypeDetailProvider(bill.diagnosisType))
                        .when(
                          data: (diag) =>
                              Text("${diag.name} (${diag.category})"),
                          loading: () => const Text("..."),
                          error: (err, stack) => const Text("Error"),
                        ),
                  ),
                  DataCell(
                    bill.franchiseName != null
                        ? ref
                            .watch(
                              singleFranchiseProvider(bill.franchiseName!),
                            )
                            .when(
                              data: (fran) =>
                                  Text(fran.franchiseName ?? "N/A"),
                              loading: () => const Text("..."),
                              error: (err, stack) => const Text("Error"),
                            )
                        : const Text("N/A"),
                  ),
                  DataCell(
                    Text(
                      "₹${NumberFormat.decimalPattern('en_IN').format(bill.totalAmount)}",
                    ),
                  ),
                  DataCell(
                    Text(
                      "₹${NumberFormat.decimalPattern('en_IN').format(bill.paidAmount)}",
                    ),
                  ),
                  DataCell(
                    Text(
                      "₹${NumberFormat.decimalPattern('en_IN').format(bill.discByDoctor)}",
                    ),
                  ),
                  DataCell(
                    Text(
                      "₹${NumberFormat.decimalPattern('en_IN').format(bill.discByCenter)}",
                    ),
                  ),
                  DataCell(
                    ref
                        .watch(
                          singleDoctorProvider(
                            bill.referredByDoctorOutput!['id'],
                          ),
                        )
                        .when(
                          data: (doctor) {
                            final category = bill
                                .diagnosisTypeOutput!['category']
                                ?.toString()
                                .toLowerCase();
                            String percentage = "0";
                            if (category == "ultrasound") {
                              percentage =
                                  doctor.ultrasoundPercentage.toString();
                            } else if (category == "ecg") {
                              percentage = doctor.ecgPercentage.toString();
                            } else if (category == "x-ray") {
                              percentage = doctor.xrayPercentage.toString();
                            } else if (category == "pathology") {
                              percentage =
                                  doctor.pathologyPercentage.toString();
                            } else if (category == "franchise lab") {
                              percentage =
                                  doctor.franchiseLabPercentage.toString();
                            }
                            return Text(percentage);
                          },
                          loading: () => const Text("..."),
                          error: (err, stack) => const Text("Error"),
                        ),
                  ),
                  DataCell(
                    Text(
                      "₹${NumberFormat.decimalPattern('en_IN').format(bill.incentiveAmount)}",
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  DataCell(
                    GestureDetector(
                      onDoubleTap: () {
                        Clipboard.setData(
                          ClipboardData(text: bill.billNumber ?? ""),
                        );
                        _showSnackBar(
                          'Bill number "${bill.billNumber}" copied!',
                          isError: false,
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () => navigatorKey.currentState?.push(
                              MaterialPageRoute(
                                builder: (context) => AddBillScreen(
                                  themeColor: _getBillStatusColor(
                                    bill.billStatus,
                                  ),
                                  billData: bill,
                                ),
                              ),
                            ),
                            child: Text(
                              bill.billNumber ?? "",
                              style: const TextStyle(
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: "Copy bill number",
                            icon: Icon(
                              Icons.copy,
                              color: Theme.of(context).colorScheme.outline,
                              size: 14,
                            ),
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(text: bill.billNumber ?? ""),
                              );
                              _showSnackBar(
                                'Bill number "${bill.billNumber}" copied!',
                                isError: false,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.fileX,
            size: 64,
            color: theme.colorScheme.onSurface.withAlpha(102),
          ),
          SizedBox(height: defaultPadding),
          Text(
            "No Incentive Data Found",
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(178),
            ),
          ),
          SizedBox(height: 8),
          Text(
            "No incentive data found for the selected filters.",
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(128),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoSearchResults(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.searchX,
            size: 64,
            color: theme.colorScheme.onSurface.withAlpha(102),
          ),
          SizedBox(height: defaultPadding),
          Text(
            "No Results Found",
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(178),
            ),
          ),
          SizedBox(height: 8),
          Text(
            "No doctors match your search criteria.",
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(128),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text("Loading incentive reports..."),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.alertCircle, color: Colors.red, size: 48),
          SizedBox(height: defaultPadding),
          Text(
            "Failed to Load Report",
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            error.toString(),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(178),
            ),
          ),
          SizedBox(height: defaultPadding),
          ElevatedButton.icon(
            onPressed: () => ref.invalidate(incentiveReportProvider),
            icon: const Icon(LucideIcons.refreshCw),
            label: const Text("Retry"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Color _getDoctorCardColor(int index, BuildContext context) {
    final colors = [
      Theme.of(context).colorScheme.primary,
      Theme.of(context).colorScheme.secondary,
    ];
    return colors[index % colors.length];
  }

  Color _getBillStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'fully paid':
        return Colors.green;
      case 'partially paid':
        return Colors.amber;
      case 'unpaid':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}