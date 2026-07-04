import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/main.dart';
import 'package:labledger/models/incentive_model.dart';
import 'package:labledger/screens/bills/add_update_bill_screen.dart';
import 'package:labledger/screens/ui_components/app_inkwell.dart';
import 'package:labledger/screens/ui_components/snackbar_utils.dart';
import 'package:labledger/screens/ui_components/tinted_container.dart';

class IncentiveSummaryCards extends StatelessWidget {
  final int doctorCount;
  final int totalIncentives;
  final int totalBills;
  final ThemeData theme;

  const IncentiveSummaryCards({
    super.key,
    required this.doctorCount,
    required this.totalIncentives,
    required this.totalBills,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: IncentiveSummaryCard(
            icon: LucideIcons.users,
            title: "Doctors",
            value: doctorCount.toString(),
            color: theme.colorScheme.secondary,
            theme: theme,
          ),
        ),
        SizedBox(width: defaultWidth * 2),
        Expanded(
          child: IncentiveSummaryCard(
            icon: LucideIcons.indian_rupee,
            title: "Total Incentives",
            value:
                "₹${NumberFormat.decimalPattern('en_IN').format(totalIncentives)}",
            color: _getIncentiveColor(totalIncentives, theme),
            theme: theme,
          ),
        ),
        SizedBox(width: defaultWidth * 2),
        Expanded(
          child: IncentiveSummaryCard(
            icon: LucideIcons.file_text,
            title: "Bills",
            value: totalBills.toString(),
            color: Colors.orange,
            theme: theme,
          ),
        ),
      ],
    );
  }

  Color _getIncentiveColor(int amount, ThemeData theme) {
    if (amount < 0) {
      return theme.colorScheme.error;
    }
    if (amount == 0) {
      return Colors.amber;
    }
    return theme.colorScheme.secondary;
  }
}

class IncentiveSummaryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final ThemeData theme;

  const IncentiveSummaryCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return TintedContainer(
      baseColor: color,
      height: 70,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: smallPadding),
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
}

class DoctorIncentiveExpansionTile extends StatelessWidget {
  final DoctorReport doctorReport;
  final int index;
  final ThemeData theme;
  final DateTime startDate;
  final DateTime endDate;

  const DoctorIncentiveExpansionTile({
    super.key,
    required this.doctorReport,
    required this.index,
    required this.theme,
    required this.startDate,
    required this.endDate,
  });

  Color _getDoctorCardColor(int index, BuildContext context) {
    final colors = [
      Theme.of(context).colorScheme.primary,
      Theme.of(context).colorScheme.secondary,
    ];
    return colors[index % colors.length];
  }

  Color _getIncentiveColor(int amount, ThemeData theme) {
    if (amount < 0) {
      return theme.colorScheme.error;
    }
    if (amount == 0) {
      return Colors.amber;
    }
    return theme.colorScheme.secondary;
  }

  Color _getBillStatusColor(String status, BuildContext context) {
    switch (status.toLowerCase()) {
      case 'fully paid':
        return Theme.of(context).colorScheme.secondary;
      case 'partially paid':
        return Colors.amber;
      case 'unpaid':
        return Theme.of(context).colorScheme.error;
      default:
        return Colors.grey;
    }
  }

  String _getInitials(String firstName, String lastName) {
    final firstInitial = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final lastInitial = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$firstInitial$lastInitial';
  }

  Widget _getIncentivePercentage(Doctor doctor, IncentiveBill bill) {
    if (bill.diagnosisTypesOutput.isEmpty) {
      return const Text('0');
    }

    final categoryId = bill.diagnosisTypesOutput[0].category;

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

    return Text(percentage.toString());
  }

  Widget _buildBillNumberCell(IncentiveBill bill, ThemeData theme, BuildContext context) {
    return AppInkWell(
      onDoubleTap: () {
        Clipboard.setData(ClipboardData(text: bill.billNumber));
        showSuccessSnackBar(
          context,
          'Bill number "${bill.billNumber}" copied!',
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppInkWell(
            onTap: () {
              navigatorKey.currentState?.push(
                MaterialPageRoute(
                  builder: (context) => AddUpdateBillScreen(
                    themeColor: _getBillStatusColor(bill.billStatus, context),
                    billId: bill.id,
                  ),
                ),
              );
            },
            child: Text(
              bill.billNumber,
              style: const TextStyle(decoration: TextDecoration.underline),
            ),
          ),
          IconButton(
            tooltip: "Copy bill number",
            icon: Icon(Icons.copy, color: theme.colorScheme.outline, size: 14),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: bill.billNumber));
              showSuccessSnackBar(
                context,
                'Bill number "${bill.billNumber}" copied!',
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBillsSection(DoctorReport doctorReport, ThemeData theme, BuildContext context) {
    final bills = doctorReport.bills;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: defaultPadding),
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
              borderRadius: BorderRadius.circular(minimalBorderRadius),
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
              final statusColor = _getBillStatusColor(bill.billStatus, context);
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
                        if (bill.patientPhoneNumber != null)
                          Text(
                            bill.patientPhoneNumber.toString(),
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
                        horizontal: smallPadding,
                        vertical: microPadding,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withAlpha(51),
                        borderRadius: BorderRadius.circular(defaultRadius),
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
                    Text(
                      bill.diagnosisTypesOutput.isNotEmpty
                          ? bill.diagnosisTypesOutput
                                .map(
                                  (dt) =>
                                      "${dt.name} (${dt.categoryName ?? 'Unknown'})",
                                )
                                .join(', ')
                          : 'Unknown',
                    ),
                  ),
                  DataCell(
                    bill.franchiseName != null
                        ? Text(bill.franchiseName!['franchise_name'] ?? 'N/A')
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
                  DataCell(_getIncentivePercentage(doctorReport.doctor, bill)),
                  DataCell(
                    Text(
                      "₹${NumberFormat.decimalPattern('en_IN').format(bill.incentiveAmount)}",
                      style: TextStyle(
                        color: _getIncentiveColor(
                          bill.incentiveAmount,
                          Theme.of(context),
                        ),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  DataCell(_buildBillNumberCell(bill, theme, context)),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = _getDoctorCardColor(index, context);
    final incentiveColor = _getIncentiveColor(
      doctorReport.totalIncentive,
      theme,
    );
    final subtitleText =
        "${doctorReport.bills.length} bills • From ${DateFormat("dd MMM yyyy").format(startDate)} to ${DateFormat("dd MMM yyyy").format(endDate)}";

    final firstName = doctorReport.doctor.firstName ?? '';
    final lastName = doctorReport.doctor.lastName ?? '';
    final initials = _getInitials(firstName, lastName);

    return ExpansionTile(
      tilePadding: EdgeInsets.all(defaultPadding),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(defaultRadius),
        side: BorderSide(color: cardColor, width: 1),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(defaultRadius),
        side: BorderSide(color: cardColor, width: 1),
      ),
      childrenPadding: const EdgeInsets.fromLTRB(mediumPadding, 0, mediumPadding, mediumPadding),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: cardColor.withAlpha(51),
        child: Text(
          initials,
          style: TextStyle(
            color: cardColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      title: Text(
        "$firstName $lastName",
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        subtitleText,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface,
        ),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: defaultPadding, vertical: tinyPadding),
        decoration: BoxDecoration(
          color: incentiveColor.withAlpha(51),
          borderRadius: BorderRadius.circular(largeRadius),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.indian_rupee, color: incentiveColor, size: 16),
            Text(
              NumberFormat.decimalPattern(
                'en_IN',
              ).format(doctorReport.totalIncentive),
              style: TextStyle(
                color: incentiveColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      children: [_buildBillsSection(doctorReport, theme, context)],
    );
  }
}

class IncentiveEmptyState extends StatelessWidget {
  final ThemeData theme;

  const IncentiveEmptyState({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.file_x,
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
          const SizedBox(height: smallPadding),
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
}

class IncentiveNoSearchResults extends StatelessWidget {
  final ThemeData theme;

  const IncentiveNoSearchResults({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.search_x,
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
          const SizedBox(height: smallPadding),
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
}
