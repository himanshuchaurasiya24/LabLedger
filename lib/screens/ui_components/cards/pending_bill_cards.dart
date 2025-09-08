import 'package:flutter/material.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/models/bill_model.dart';
import 'package:labledger/screens/ui_components/tinted_container.dart';

class PendingBillsCard extends StatelessWidget {
  const PendingBillsCard({
    super.key,
    required this.bills,
    required this.baseColor,
    this.height,
    this.width,
    this.onBillTap, // <-- Kept the callback for tapping a single bill
    // this.onViewAllTap, // <-- REMOVED
  });

  final List<Bill> bills;
  final Color baseColor;
  final double? height;
  final double? width;
  final Function(Bill bill)? onBillTap;
  // final VoidCallback? onViewAllTap; // <-- REMOVED

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

  Color normalTextColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.white70 : Colors.black87;
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

    return TintedContainer(
      baseColor: baseColor,
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // "Pending Bills" Title Pill
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

              // --- REVERTED TO OLD DESIGN ---
              // This is the original static pill
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
                  "${pendingBillsToShow.length} Bills", // Shows count of visible bills
                  style: TextStyle(
                    color: importantTextColor(context),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Bills List (keeps the new item UI)
          Expanded(
            child: pendingBillsToShow.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 128,
                          color: importantTextColor(context),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No pending bills found",
                          style: TextStyle(
                            color: importantTextColor(context),
                            fontSize: 24,
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
                        SizedBox(height: defaultHeight),
                    itemBuilder: (context, index) {
                      final bill = pendingBillsToShow[index];
                      // Calls the new, interactive bill item
                      return _buildBillItem(context, bill, index);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // This is the new, improved item layout (tappable)
  Widget _buildBillItem(BuildContext context, Bill bill, int index) {
    final serviceName =
        bill.diagnosisTypeOutput!["category"] +
            " ${bill.diagnosisTypeOutput!["name"]} " ??
        'N/A';
    final dateString = _formatDate(bill.dateOfBill);
    final doctorName = bill.referredByDoctorOutput?['full_name'];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final statusColors = _getBillStatusChipColors(context, bill.billStatus);
    final solidChipBg = importantTextColor(context);
    final solidChipFg = isDark ? baseColor : Colors.white;

    return GestureDetector(
      onTap: onBillTap != null ? () => onBillTap!(bill) : null,
      child: Container(
        padding: EdgeInsets.all(8),
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
                const SizedBox(width: 12),
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
                const SizedBox(width: 12),
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
            const SizedBox(height: 12),
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
                if (bill.incentiveAmount > 0)
                  _buildDetailChip(
                    context,
                    icon: Icons.pending_outlined,
                    label: "₹${bill.incentiveAmount}",
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

  // New chip helper widget
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

  // New color logic method (no hard-coded colors)
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

  // Date formatter helper
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
