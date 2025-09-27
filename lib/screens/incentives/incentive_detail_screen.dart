import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/models/incentive_model.dart';
import 'package:labledger/providers/incenitve_generator_provider.dart';
import 'package:labledger/screens/initials/window_scaffold.dart';
import 'package:labledger/screens/ui_components/custom_text_field.dart';
import 'package:labledger/screens/ui_components/tinted_container.dart';
import 'package:lucide_icons/lucide_icons.dart';

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

  @override
  Widget build(BuildContext context) {
    final reportAsync = ref.watch(incentiveReportProvider);
    final theme = Theme.of(context);

    return WindowScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          _buildHeader(theme),
          SizedBox(height: defaultHeight),
          // Search Bar
          _buildSearchBar(theme),

          SizedBox(height: defaultHeight),

          // Main Content - Scrollable
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
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
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
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
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
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
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

    // Filter reports based on search query
    final filteredReports = report.where((doctor) {
      final fullName = '${doctor.firstName} ${doctor.lastName}'.toLowerCase();
      return fullName.contains(searchQuery);
    }).toList();

    if (filteredReports.isEmpty) {
      return _buildNoSearchResults(theme);
    }

    // Calculate totals for summary
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
        // Summary Cards
        _buildSummaryCards(
          filteredReports.length,
          totalIncentives,
          totalBills,
          theme,
        ),
        SizedBox(height: defaultHeight),

        // Scrollable Doctor List
        Expanded(
          child: ListView.builder(
            // padding: EdgeInsets.symmetric(horizontal: defaultPadding),
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
            mainAxisAlignment: MainAxisAlignment.start,
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

    return ExpansionTile(
      tilePadding: EdgeInsets.all(defaultPadding),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: _getDoctorCardColor(index, context), width: 1),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: _getDoctorCardColor(index, context), width: 1),
      ),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: cardColor.withValues(alpha: 0.2),
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
        "${doctor.bills.length} bills • ₹${NumberFormat.decimalPattern('en_IN').format(doctor.totalIncentive)} total incentive",
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
        ),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: cardColor.withValues(alpha: 0.2),
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

  Widget _buildBillsSection(List<BillDetail> bills, ThemeData theme) {
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
        // Scrollable horizontal table for bills
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
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
              width: 1,
            ),
            columns: const [
              DataColumn(label: Text('Bill #')),
              DataColumn(label: Text('Patient')),
              DataColumn(label: Text('Age')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Diagnosis')),
              DataColumn(label: Text('Franchise')),
              DataColumn(label: Text('Total'), numeric: true),
              DataColumn(label: Text('Incentive'), numeric: true),
              DataColumn(label: Text('Paid'), numeric: true),
            ],
            rows: bills.map((bill) {
              final statusColor = _getBillStatusColor(bill.billStatus);
              return DataRow(
                cells: [
                  DataCell(
                    Text(
                      bill.billNumber,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
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
                        if (bill.patientPhoneNumber != null)
                          Text(
                            bill.patientPhoneNumber!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
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
                        color: statusColor.withValues(alpha: 0.2),
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
                  DataCell(Text(bill.diagnosisType)),
                  DataCell(Text(bill.franchiseName ?? 'N/A')),
                  DataCell(
                    Text(
                      "₹${NumberFormat.decimalPattern('en_IN').format(bill.totalAmount)}",
                    ),
                  ),
                  DataCell(
                    Text(
                      "₹${NumberFormat.decimalPattern('en_IN').format(bill.incentiveAmount)}",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      "₹${NumberFormat.decimalPattern('en_IN').format(bill.paidAmount)}",
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
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          SizedBox(height: defaultPadding),
          Text(
            "No Incentive Data Found",
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: 8),
          Text(
            "No incentive data found for the selected filters.",
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
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
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          SizedBox(height: defaultPadding),
          Text(
            "No Results Found",
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: 8),
          Text(
            "No doctors match your search criteria.",
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
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
          Icon(LucideIcons.alertCircle, color: Colors.red, size: 48),
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
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
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
