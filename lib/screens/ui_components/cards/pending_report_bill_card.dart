import 'package:flutter/material.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/main.dart';
import 'package:labledger/models/pending_report_bill_model.dart';
import 'package:labledger/screens/bills/add_update_bill_screen.dart';
import 'package:labledger/screens/ui_components/tinted_container.dart';
import 'package:lucide_icons/lucide_icons.dart';

class PendingReportsCard extends StatelessWidget {
  const PendingReportsCard({
    super.key,
    required this.baseColor,
    required this.bills,
  });

  final Color baseColor;
  final List<PendingReportBillModel> bills;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TintedContainer(
      baseColor: baseColor,
      elevationLevel: 2,
      useGradient: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(bottom: defaultPadding),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(defaultPadding),
                  decoration: BoxDecoration(
                    color: baseColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    LucideIcons.fileClock,
                    color: baseColor,
                    size: 20,
                  ),
                ),
                SizedBox(width: defaultWidth / 2),
                Text(
                  'Pending Reports',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),

          // --- Bills List ---
          Expanded(
            child: bills.isEmpty
                ? _buildEmptyState(context)
                : ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: bills.length,
                    separatorBuilder: (context, index) => Divider(
                      color: baseColor.withValues(alpha: 0.2),
                      height: 1,
                    ),
                    itemBuilder: (context, index) {
                      final bill = bills[index];
                      final statusInfo = (
                        icon: Icons.hourglass_bottom_rounded,
                        color: baseColor,
                      );
                      return _buildBillItem(context, bill, statusInfo, theme);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // --- Empty State Widget ---
  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: baseColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              LucideIcons.fileCheck2,
              size: 32,
              color: baseColor.withValues(alpha: 0.6),
            ),
          ),
          SizedBox(height: defaultHeight / 2),
          Text(
            'No pending reports',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'All bills have their reports uploaded',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }

  // --- List Item Widget ---
  Widget _buildBillItem(
    BuildContext context,
    PendingReportBillModel bill,
    ({IconData icon, Color color}) statusInfo,
    ThemeData theme,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(defaultRadius),
        onTap: () {
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (context) => AddUpdateBillScreen(
                themeColor: statusInfo.color,
                billId: bill.id,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
          child: Row(
            children: [
              // --- Status Icon ---
              CircleAvatar(
                backgroundColor: statusInfo.color.withValues(alpha: 0.15),
                radius: 20,
                child: Icon(statusInfo.icon, color: statusInfo.color, size: 20),
              ),
              SizedBox(width: defaultWidth),

              // --- Bill Details (Left Side) ---
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Patient Name
                    Text(
                      bill.patientName,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: statusInfo.color,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    // Diagnosis Type
                    Text(
                      bill.diagnosisType.name,
                      style: TextStyle(
                        color: statusInfo.color.withValues(alpha: 0.7),
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: defaultWidth),

              // --- Price (Right Side) ---
              Text(
                '₹${bill.diagnosisType.price}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: statusInfo.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
