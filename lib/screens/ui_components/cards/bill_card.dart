import 'package:flutter/material.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/models/bill_model.dart';

class BillCard extends StatelessWidget {
  final Bill bill;
  final VoidCallback? onTap;
  final Color? fullyPaidColor;
  final Color? partiallyPaidColor;
  final Color? unpaidColor;

  const BillCard({
    super.key,
    required this.bill,
    this.onTap,
    this.fullyPaidColor,
    this.partiallyPaidColor,
    this.unpaidColor,
  });

  // Payment status logic
  PaymentStatus get _paymentStatus {
    if (bill.billStatus == "Fully Paid") {
      return PaymentStatus.fullPaid;
    } else if (bill.billStatus == "Partially Paid") {
      return PaymentStatus.partiallyPaid;
    } else {
      return PaymentStatus.unpaid;
    }
  }

  int get _pendingAmount =>
      bill.totalAmount -
      bill.paidAmount -
      bill.discByCenter -
      bill.discByDoctor;

  String _formatCurrency(int amount) {
    // Check if amount is negative
    bool isNegative = amount < 0;
    // Work with absolute value
    int absAmount = amount.abs();

    // Format the number with commas
    String formatted = absAmount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );

    // Add Rupee symbol and negative sign if needed
    return isNegative ? '₹-$formatted' : '₹$formatted';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year.toString().substring(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // --- 🎨 Color Logic ---
    // 1. Determine the base color based on payment status and optional inputs.
    Color baseColor;
    switch (_paymentStatus) {
      case PaymentStatus.fullPaid:
        baseColor = fullyPaidColor ?? Theme.of(context).colorScheme.secondary;
        break;
      case PaymentStatus.partiallyPaid:
        baseColor = partiallyPaidColor ?? Colors.amber;
        break;
      case PaymentStatus.unpaid:
        baseColor = unpaidColor ?? Theme.of(context).colorScheme.error;
        break;
    }

    // 2. Helper to safely derive colors, handling both MaterialColor and generic Color.
    ({Color background, Color text, Color accent}) getDerivedColors(
      Color baseColor,
    ) {
      // For Background Color
      final Color bg = (baseColor is MaterialColor)
          ? (isDark
                ? baseColor.shade900.withValues(alpha: 0.4)
                : baseColor.shade50)
          : (isDark
                ? Color.alphaBlend(
                    baseColor.withValues(alpha: 0.2),
                    Colors.black,
                  )
                : Color.alphaBlend(
                    baseColor.withValues(alpha: 0.1),
                    Colors.white,
                  ));

      // For Important Text Color
      final Color txt = (isDark)
          ? Colors.white
          : (baseColor is MaterialColor)
          ? baseColor.shade900
          : HSLColor.fromColor(baseColor).withLightness(0.2).toColor();

      // For Accent Color (used for borders, shadows, highlights)
      final Color acc = (baseColor is MaterialColor)
          ? (isDark ? baseColor.shade200 : baseColor.shade600)
          : (isDark
                ? HSLColor.fromColor(baseColor).withLightness(0.7).toColor()
                : HSLColor.fromColor(baseColor).withLightness(0.4).toColor());

      return (background: bg, text: txt, accent: acc);
    }

    // 3. Get the final derived colors.
    final derivedColors = getDerivedColors(baseColor);
    final Color backgroundColor = derivedColors.background;
    final Color textColor = derivedColors.text;
    final Color accentColor = derivedColors.accent;

    // --- 📝 Text Styles ---
    final titleStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.bold,
      color: textColor,
    );

    final bodyStyle = theme.textTheme.bodyMedium?.copyWith(
      color: textColor.withValues(alpha: 0.8),
      fontWeight: FontWeight.w500,
    );

    final amountStyle = theme.textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.bold,
      color: textColor,
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: accentColor.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: defaultPadding,
              vertical: defaultPadding / 4,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row - Patient Name and Payment Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        bill.patientName.isNotEmpty
                            ? bill.patientName
                            : 'Unknown Patient',
                        style: titleStyle?.copyWith(fontSize: 24),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _paymentStatus == PaymentStatus.fullPaid
                              ? Icons.check_circle
                              : _paymentStatus == PaymentStatus.partiallyPaid
                              ? Icons.access_time_filled
                              : Icons.error,
                          color: textColor,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _paymentStatus == PaymentStatus.fullPaid
                              ? 'PAID'
                              : _paymentStatus == PaymentStatus.partiallyPaid
                              ? 'PARTIAL'
                              : 'UNPAID',
                          style: amountStyle!.copyWith(fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: defaultHeight),
                // Patient Details Row
                Row(
                  children: [
                    // Age and Sex
                    Row(
                      children: [
                        Icon(
                          bill.patientSex.toLowerCase() == 'male'
                              ? Icons.male
                              : bill.patientSex.toLowerCase() == 'female'
                              ? Icons.female
                              : Icons.person,
                          size: 18,
                          color: textColor.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${bill.patientAge}y, ${bill.patientSex.toUpperCase()}',
                          style: bodyStyle?.copyWith(fontSize: 14),
                        ),
                      ],
                    ),

                    const SizedBox(width: 16),

                    // Date
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: textColor.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(bill.dateOfBill),
                          style: bodyStyle?.copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: defaultHeight),

                // Doctor Name Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      Icons.local_hospital,
                      size: 16,
                      color: textColor.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Dr. ${bill.referredByDoctorOutput!["first_name"]} ${bill.referredByDoctorOutput!["last_name"]}',
                        style: bodyStyle?.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Incentive Amount (if available)
                    if (bill.incentiveAmount > 0) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.card_giftcard, size: 16, color: textColor),
                          const SizedBox(width: 6),
                          Text(
                            'Incentive: ',
                            style: bodyStyle?.copyWith(
                              fontSize: 12,
                              color: textColor,
                            ),
                          ),
                          Text(
                            _formatCurrency(bill.incentiveAmount),
                            style: bodyStyle?.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),

                SizedBox(height: defaultHeight),

                // Diagnosis and Franchise Row
                Row(
                  children: [
                    Icon(
                      Icons.medical_services,
                      size: 16,
                      color: textColor.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        "${bill.diagnosisTypeOutput?['category']} ${bill.diagnosisTypeOutput?['name']}",
                        style: bodyStyle?.copyWith(fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: defaultHeight * 1.5),

                // Amount Information Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Paid Amount
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Paid',
                          style: bodyStyle?.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          _formatCurrency(bill.paidAmount),
                          style: amountStyle.copyWith(fontSize: 16),
                        ),
                      ],
                    ),
                    Spacer(),
                    // Pending Amount (if not fully paid)
                    Visibility(
                      visible: (bill.billStatus == "Partially Paid"),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Pending',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: bodyStyle?.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            _formatCurrency(_pendingAmount),
                            style: amountStyle.copyWith(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    Spacer(),

                    Visibility(
                      visible: bill.discByCenter > 0 || bill.discByDoctor > 0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Discount',
                            style: bodyStyle?.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "${bill.discByDoctor > 0 ? "${_formatCurrency(bill.discByDoctor)} Doc" : ""}"
                            " "
                            "${(bill.discByCenter > 0 ? "${_formatCurrency(bill.discByCenter)} Center" : "")}",
                            style: amountStyle.copyWith(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    Spacer(),

                    // Total Amount
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Total',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: bodyStyle?.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          _formatCurrency(bill.totalAmount),
                          style: amountStyle.copyWith(fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Payment Status Enum
enum PaymentStatus { fullPaid, partiallyPaid, unpaid }
