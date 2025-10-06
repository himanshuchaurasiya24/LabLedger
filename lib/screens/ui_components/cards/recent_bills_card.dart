import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/main.dart';
import 'package:labledger/models/bill_model.dart';
import 'package:labledger/screens/bills/add_update_bill_screen.dart';
import 'package:labledger/screens/ui_components/tinted_container.dart';

class RecentBillsCard extends StatelessWidget {
  const RecentBillsCard({
    super.key,
    required this.baseColor,
    required this.bills,
  });

  final Color baseColor;
  final List<Bill> bills;

  ({IconData icon, Color color, String label}) _getStatusInfo(
    String status,
    BuildContext context,
  ) {
    switch (status.toLowerCase()) {
      case 'fully paid':
        return (
          icon: Icons.check_circle_rounded,
          color: baseColor, // Use base color for fully paid
          label: 'Paid',
        );
      case 'unpaid':
        return (
          icon: Icons.error_rounded,
          color: Theme.of(context).colorScheme.error, // Red for unpaid
          label: 'Pending',
        );
      case 'partially paid':
        return (
          icon: Icons.hourglass_bottom_rounded,
          color: Colors.amber.shade700, // Amber for partially paid
          label: 'Partial',
        );
      default:
        return (
          icon: Icons.receipt_rounded,
          color: baseColor,
          label: 'Unknown',
        );
    }
  }

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
                  child: Icon(Icons.history, color: baseColor, size: 20),
                ),
                SizedBox(width: defaultWidth / 2),
                Text(
                  'Recent Bills',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),

          // --- Enhanced Bills List ---
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
                      final statusInfo = _getStatusInfo(
                        bill.billStatus,
                        context,
                      );

                      return _buildBillItem(context, bill, statusInfo, theme);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline, // Changed Icon
            size: 80, // Adjusted size
            color: Theme.of(context).colorScheme.secondary,
          ),
          SizedBox(height: defaultHeight / 2),
          Text(
            "No Recent Bills Found!",
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontSize: 18, // Adjusted size
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillItem(
    BuildContext context,
    Bill bill,
    ({IconData icon, Color color, String label}) statusInfo,
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
                    ),
                    const SizedBox(height: 2),
                    // Diagnosis Type
                    Text(
                      bill.diagnosisTypeOutput?["name"] ?? 'Unknown Test',
                      style: TextStyle(
                        color: statusInfo.color.withValues(alpha: 0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              // --- Amount (Right Side) ---
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${bill.totalAmount}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: statusInfo.color,
                    ),
                  ),
                  // Show pending amount for unpaid or partially paid bills
                  if ((bill.paidAmount +
                          bill.discByCenter +
                          bill.discByDoctor) <
                      bill.totalAmount)
                    Text(
                      '₹${bill.totalAmount - bill.paidAmount - bill.discByCenter - bill.discByDoctor} pending',
                      style: TextStyle(
                        fontSize: 12,
                        color: statusInfo.color.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget buildRecentBillsCard(
  AsyncValue<List<Bill>> recentBillsAsync,
  Color? baseColor,
  BuildContext context,
) {
  final Color accentColor = baseColor ?? Theme.of(context).colorScheme.primary;
  final Color errorColor = Theme.of(context).colorScheme.error;

  return recentBillsAsync.when(
    data: (bills) {
      return RecentBillsCard(bills: bills, baseColor: accentColor);
    },
    loading: () => TintedContainer(
      baseColor: accentColor,
      elevationLevel: 2,
      child: Column(
        children: [
          // Header shimmer
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              SizedBox(width: defaultWidth / 2),
              Container(
                width: 100,
                height: 20,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          SizedBox(height: defaultHeight),
          // Content shimmer
          Expanded(
            child: Center(
              child: CircularProgressIndicator(
                color: accentColor,
                strokeWidth: 2,
              ),
            ),
          ),
        ],
      ),
    ),
    error: (err, _) => TintedContainer(
      baseColor: errorColor,
      elevationLevel: 1,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, color: errorColor, size: 32),
          SizedBox(height: defaultHeight / 2),
          Text(
            "Failed to load bills",
            style: TextStyle(color: errorColor, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: defaultHeight / 2),
          Text(
            "Tap to retry",
            style: TextStyle(
              color: errorColor.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    ),
  );
}
