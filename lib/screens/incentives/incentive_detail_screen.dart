import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/models/incentive_model.dart';
import 'package:labledger/providers/incenitve_generator_provider.dart';
import 'package:labledger/screens/initials/window_scaffold.dart';
import 'package:lucide_icons/lucide_icons.dart';

class IncentiveDetailScreen extends ConsumerStatefulWidget {
  const IncentiveDetailScreen({super.key});

  @override
  ConsumerState<IncentiveDetailScreen> createState() =>
      _IncentiveDetailScreenState();
}

class _IncentiveDetailScreenState
    extends ConsumerState<IncentiveDetailScreen> {
  // State to manage which doctor's panel is expanded
  late List<bool> _isPanelExpanded;

  @override
  void initState() {
    super.initState();
    _isPanelExpanded = [];
  }

  @override
  Widget build(BuildContext context) {
    // Watch the main provider to get the data
    final reportAsync = ref.watch(incentiveReportProvider);
    final theme = Theme.of(context);

    return WindowScaffold(
      child: Padding(
        padding:  EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Screen Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Incentive Report",
                  style: theme.textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.refreshCw),
                  tooltip: "Refresh Report",
                  onPressed: () => ref.invalidate(incentiveReportProvider),
                )
              ],
            ),
             SizedBox(height: defaultPadding),

            // Main Content Area
            Expanded(
              child: Card(
                elevation: 2,
                child: reportAsync.when(
                  data: (report) {
                    // This check ensures the expansion state list is the correct size.
                    if (_isPanelExpanded.length != report.length) {
                      _isPanelExpanded = List.generate(report.length, (_) => false);
                    }

                    if (report.isEmpty) {
                      return const Center(
                        child: Text("No incentive data found for the selected filters."),
                      );
                    }

                    // The main expandable list of doctors
                    return SingleChildScrollView(
                      child: ExpansionPanelList(
                        expansionCallback: (index, isExpanded) {
                          setState(() {
                            _isPanelExpanded[index] = !isExpanded;
                          });
                        },
                        children: report.asMap().entries.map<ExpansionPanel>((entry) {
                          int index = entry.key;
                          DoctorReport doctorReport = entry.value;
                          return ExpansionPanel(
                            isExpanded: _isPanelExpanded[index],
                            canTapOnHeader: true,
                            headerBuilder: (context, isExpanded) => ListTile(
                              leading: CircleAvatar(
                                child: Text("${doctorReport.firstName[0]}${doctorReport.lastName[0]}"),
                              ),
                              title: Text(
                                "${doctorReport.firstName} ${doctorReport.lastName}",
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              trailing: Chip(
                                label: Text(
                                  "Total Incentive: ₹${NumberFormat.decimalPattern('en_IN').format(doctorReport.totalIncentive)}",
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                backgroundColor: theme.colorScheme.secondaryContainer.withValues(alpha:  0.5),
                              ),
                            ),
                            body: _buildBillsDataTable(doctorReport.bills),
                          );
                        }).toList(),
                      ),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Failed to generate report."),
                        const SizedBox(height: 8),
                        Text(err.toString()),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => ref.invalidate(incentiveReportProvider),
                          child: const Text("Retry"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to build the data table for each doctor's bills
  Widget _buildBillsDataTable(List<BillDetail> bills) {
    return SizedBox(
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowHeight: 40,
          dataRowMinHeight: 40,
          dataRowMaxHeight: 50,
          columns: const [
            DataColumn(label: Text('Bill #')),
            DataColumn(label: Text('Patient')),
            DataColumn(label: Text('Diagnosis Type')),
            DataColumn(label: Text('Franchise')),
            DataColumn(label: Text('Total Amt'), numeric: true),
            DataColumn(label: Text('Incentive'), numeric: true),
            DataColumn(label: Text('Dr. Disc'), numeric: true),
            DataColumn(label: Text('Center Disc'), numeric: true),
          ],
          rows: bills.map((bill) => DataRow(
            cells: [
              DataCell(Text(bill.billNumber)),
              DataCell(Text(bill.patientName)),
              DataCell(Text(bill.diagnosisType)),
              DataCell(Text(bill.franchiseName ?? 'N/A')),
              DataCell(Text("₹${bill.totalAmount}")),
              DataCell(Text("₹${bill.incentiveAmount}")),
              DataCell(Text("₹${bill.discByDoctor}")),
              DataCell(Text("₹${bill.discByCenter}")),
            ],
          )).toList(),
        ),
      ),
    );
  }
}