// screens/ui_components/cards/pending_bill_cards.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/main.dart';
import 'package:labledger/models/bill_model.dart';
import 'package:labledger/models/paginated_response.dart';
import 'package:labledger/screens/bills/add_update_bill_screen.dart';
import 'package:labledger/screens/ui_components/tinted_container.dart';

class PendingBillsCard extends StatelessWidget {
  const PendingBillsCard({
    super.key,
    required this.bills,
    required this.baseColor,
    this.onBillTap,
  });

  final List<Bill> bills;
  final Color baseColor;
  final Function(Bill bill)? onBillTap;

  Color backgroundColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? baseColor.withValues(alpha: 0.8)
        : baseColor.withValues(alpha: 0.1);
  }

  Color importantTextColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.white : baseColor;
  }

  Color subduedTextColor(BuildContext context) {
    return importantTextColor(context).withValues(alpha: 0.7);
  }

  Color accentFillColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? baseColor.withValues(alpha: 0.6)
        : baseColor.withValues(alpha: 0.15);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final pendingBillsToShow = bills.take(10).toList();

    // NEW: Give the card a consistent height to align with other cards
    return TintedContainer(
      baseColor: baseColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? accentFillColor(context)
                      : importantTextColor(context),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  "Pending Bills",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const Spacer(), // Use Spacer to push the next item to the end
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: accentFillColor(context),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${pendingBillsToShow.length} Bills",
                  style: TextStyle(
                    color: importantTextColor(context),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: defaultHeight / 2),

          // Bills List
          Expanded(
            child: pendingBillsToShow.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_outline, // Changed Icon
                          size: 80, // Adjusted size
                          color: importantTextColor(
                            context,
                          ).withValues(alpha: 0.7),
                        ),
                        SizedBox(height: defaultHeight / 2),
                        Text(
                          "All bills cleared!", // Changed Text
                          style: TextStyle(
                            color: importantTextColor(
                              context,
                            ).withValues(alpha: 0.7),
                            fontSize: 18, // Adjusted size
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: pendingBillsToShow.length,
                    separatorBuilder: (context, index) =>
                        SizedBox(height: defaultHeight / 2),
                    itemBuilder: (context, index) {
                      final bill = pendingBillsToShow[index];
                      return _buildBillItem(context, bill, index);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillItem(BuildContext context, Bill bill, int index) {
    final serviceName =
        "${bill.diagnosisTypeOutput!["category"]} ${bill.diagnosisTypeOutput!["name"]}";
    final dateString = _formatDate(bill.dateOfBill);
    final doctorName = bill.referredByDoctorOutput?['full_name'];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final statusColors = _getBillStatusChipColors(context, bill.billStatus);
    final solidChipBg = importantTextColor(context);
    final solidChipFg = isDark ? baseColor : Colors.white;

    return InkWell(
      onTap: onBillTap != null ? () => onBillTap!(bill) : null,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: backgroundColor(context),
          borderRadius: BorderRadius.circular(defaultRadius),
          border: Border.all(color: baseColor.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: accentFillColor(context),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.person_outline,
                    color: importantTextColor(context),
                    size: 28,
                  ),
                ),
                SizedBox(width: defaultWidth / 2),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bill.patientName,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: importantTextColor(context),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${bill.patientAge}y, ${bill.patientSex}",
                        style: TextStyle(
                          fontSize: 13,
                          color: subduedTextColor(context),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: defaultWidth / 2),
                Text(
                  "₹${bill.totalAmount}",
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: importantTextColor(context),
                  ),
                ),
              ],
            ),
            SizedBox(height: defaultHeight / 2),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildDetailChip(
                  context,
                  label: bill.billStatus.toUpperCase(),
                  backgroundColor: statusColors.background,
                  foregroundColor: statusColors.foreground,
                ),
                _buildDetailChip(
                  context,
                  icon: Icons.medical_services_outlined,
                  label: serviceName,
                  backgroundColor: accentFillColor(context),
                  foregroundColor: importantTextColor(context),
                ),
                _buildDetailChip(
                  context,
                  icon: Icons.calendar_today_outlined,
                  label: dateString,
                  backgroundColor: accentFillColor(context),
                  foregroundColor: importantTextColor(context),
                ),
                // if (bill.incentiveAmount > 0)
                _buildDetailChip(
                  context,
                  icon: Icons.pending_outlined,
                  label:
                      "Pending ₹${(bill.totalAmount - bill.paidAmount - bill.discByCenter - bill.discByDoctor)}",
                  backgroundColor: solidChipBg,
                  foregroundColor: solidChipFg,
                ),
                if (doctorName != null)
                  _buildDetailChip(
                    context,
                    icon: Icons.person_pin_outlined,
                    label: doctorName,
                    backgroundColor: accentFillColor(context),
                    foregroundColor: importantTextColor(context),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailChip(
    BuildContext context, {
    IconData? icon,
    required String label,
    required Color backgroundColor,
    required Color foregroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: foregroundColor),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: foregroundColor,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  ({Color background, Color foreground}) _getBillStatusChipColors(
    BuildContext context,
    String status,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = importantTextColor(context);
    final accentBg = accentFillColor(context);

    final tintedStyle = (background: accentBg, foreground: primaryText);
    final solidChipFg = isDark ? baseColor : Colors.white;
    final solidStyle = (background: primaryText, foreground: solidChipFg);

    switch (status.toLowerCase()) {
      case 'pending':
      case 'cancelled':
      case 'failed':
        return solidStyle;
      case 'paid':
      case 'completed':
      default:
        return tintedStyle;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return "Today";
    } else if (difference.inDays == 1) {
      return "Yesterday";
    } else if (difference.inDays < 7) {
      return "${difference.inDays} days ago";
    } else {
      return "${date.day}/${date.month}/${date.year.toString().substring(2)}";
    }
  }
}

  Widget buildPendingBillsCard(
    AsyncValue<PaginatedBillsResponse> unpaidBillsAsync,
    BuildContext context
  ) {
    final accentColor = Theme.of(context).colorScheme.error;
    return unpaidBillsAsync.when(
      data: (unpaidBillsAsyncResponse) {
        return PendingBillsCard(
          baseColor: unpaidBillsAsyncResponse.bills.isEmpty
              ? Theme.of(context).colorScheme.secondary
              : accentColor,
          bills: unpaidBillsAsyncResponse.bills,
          onBillTap: (bill) {
            navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (context) => AddUpdateBillScreen(
                  billId: bill.id,
                  themeColor: Theme.of(context).colorScheme.error,
                ),
              ),
            );
          },
        );
      },
      loading: () => TintedContainer(
        baseColor: accentColor,

        child: Center(child: CircularProgressIndicator(color: accentColor)),
      ),
      error: (err, _) => Center(
        child: Text(
          "Error: Failed to load pending bills.",
          style: TextStyle(color: accentColor),
        ),
      ),
    );
  }