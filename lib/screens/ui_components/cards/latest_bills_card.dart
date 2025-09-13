import 'package:flutter/material.dart';
import 'package:labledger/main.dart';
import 'package:labledger/models/bill_model.dart';
import 'package:labledger/screens/bill/add_update_screen.dart';
import 'package:labledger/screens/ui_components/tinted_container.dart';

class LatestBillsCard extends StatelessWidget {
  const LatestBillsCard({
    super.key,
    required this.baseColor,
    required this.bills,
  });
  final Color baseColor;
  final List<Bill> bills;
  // Helper to get a corresponding icon and color for the bill status
  ({IconData icon, Color color}) _getStatusIcon(
    String status,
    BuildContext context,
  ) {
    switch (status.toLowerCase()) {
      case 'fully paid':
        return (icon: Icons.check_circle, color: baseColor);
      case 'unpaid':
        return (icon: Icons.error, color: Theme.of(context).colorScheme.error);
      case 'partially paid': // Assuming you might have this status
        return (icon: Icons.hourglass_bottom, color: Colors.orange.shade700);
      default:
        return (icon: Icons.receipt, color: baseColor);
    }
  }

  @override
  Widget build(BuildContext context) {
    final context =
        navigatorKey.currentContext!; // A way to get context if needed
    final theme = Theme.of(context);
    return TintedContainer(
      baseColor: baseColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Card Header ---
          Row(
            children: [
              Icon(Icons.history, color: baseColor),
              const SizedBox(width: 12),
              Text(
                'Latest Bills',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),

          // --- Bills List ---
          Expanded(
            child: bills.isEmpty
                ? const Center(child: Text('No recent bills to display.'))
                // Use ListView.separated for dividers between items
                : ListView.separated(
                    itemCount: bills.length,
                    separatorBuilder: (context, index) => Divider(
                      color: baseColor.withValues(alpha: 0.2),
                      height: 1,
                    ),
                    itemBuilder: (context, index) {
                      final bill = bills[index];
                      final status = _getStatusIcon(bill.billStatus, context);

                      return InkWell(
                        onTap: () {
                          navigatorKey.currentState?.push(
                            MaterialPageRoute(
                              builder: (context) {
                                return AddBillScreen(
                                  themeColor: status.color,
                                  billData: bill,
                                );
                              },
                            ),
                          );
                        },
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 6.0,
                            horizontal: 4.0,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: status.color.withValues(
                              alpha: 0.15,
                            ),
                            child: Icon(
                              status.icon,
                              color: status.color,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            bill.patientName,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: status.color,
                            ),
                          ),
                          subtitle: Text(
                            bill.diagnosisTypeOutput!["name"], // Using the nested object
                            style: TextStyle(
                              color: status.color.withValues(alpha: 0.7),
                            ),
                          ),
                          trailing: Text(
                            '₹${bill.totalAmount.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: status.color,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
