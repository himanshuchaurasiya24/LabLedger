import 'package:flutter/material.dart';
import 'package:labledger/models/bill_model.dart';
import 'package:labledger/providers/custom_providers.dart';

class BillCard extends StatelessWidget {
  final Bill bill;
  final VoidCallback? onTap;

  const BillCard({super.key, required this.bill, this.onTap});

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

  Color _getPaymentStatusColor() {
    switch (_paymentStatus) {
      case PaymentStatus.fullPaid:
        return Colors.green[600]!;
      case PaymentStatus.partiallyPaid:
        return Colors.amber[600]!;
      case PaymentStatus.unpaid:
        return Colors.red[600]!;
    }
  }

  Color _getBackgroundColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (_paymentStatus) {
      case PaymentStatus.fullPaid:
        return isDark ? Colors.green[700]! : Colors.green[50]!;
      case PaymentStatus.partiallyPaid:
        return isDark ? Colors.amber[700]! : Colors.amber[50]!;
      case PaymentStatus.unpaid:
        return isDark ? Colors.red[700]! : Colors.red[50]!;
    }
  }

  Color _getTextColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isDark) {
      return Colors.white;
    } else {
      switch (_paymentStatus) {
        case PaymentStatus.fullPaid:
          return Colors.green[800]!;
        case PaymentStatus.partiallyPaid:
          return Colors.amber[800]!;
        case PaymentStatus.unpaid:
          return Colors.red[800]!;
      }
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
    final statusColor = _getPaymentStatusColor();
    final backgroundColor = _getBackgroundColor(context);
    final textColor = _getTextColor(context);
    final theme = Theme.of(context);

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
        margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: statusColor.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: statusColor.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
                        color: _getTextColor(context),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _paymentStatus == PaymentStatus.fullPaid
                            ? 'PAID'
                            : _paymentStatus == PaymentStatus.partiallyPaid
                            ? 'PARTIAL'
                            : 'UNPAID',
                        style: amountStyle!.copyWith(
                          fontSize: 14,
                          // fontWeight: FontWeight.b,
                        ),
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

              const SizedBox(height: 12),

              // Doctor Name Row
              Row(
                children: [
                  Icon(
                    Icons.local_hospital,
                    size: 16,
                    color: textColor.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      bill.referredByDoctorOutput?['name'] ??
                          'Dr. ${bill.referredByDoctorOutput!["first_name"]} ${bill.referredByDoctorOutput!["last_name"]}',
                      style: bodyStyle?.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

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

              SizedBox(height: defaultHeight),

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

                  // Pending Amount (if not fully paid)
                  Visibility(
                    visible: (bill.billStatus == "Partially Paid"),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Pending',
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

                  Visibility(
                    visible: bill.discByDoctor > 0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Doctor\'s Discount',
                          style: bodyStyle?.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          _formatCurrency(bill.discByDoctor),
                          style: amountStyle.copyWith(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: bill.discByCenter > 0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Center Discount',
                          style: bodyStyle?.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          _formatCurrency(bill.discByCenter),
                          style: amountStyle.copyWith(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  // Total Amount
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Total',
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

              // Incentive Amount (if available)
              if (bill.incentiveAmount > 0) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.card_giftcard,
                      size: 16,
                      color: _getTextColor(context),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Incentive: ',
                      style: bodyStyle?.copyWith(
                        fontSize: 12,
                        color: _getTextColor(context),
                      ),
                    ),
                    Text(
                      _formatCurrency(bill.incentiveAmount),
                      style: bodyStyle?.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        // color: Colors.teal[700],
                        color: _getTextColor(context),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Payment Status Enum
enum PaymentStatus { fullPaid, partiallyPaid, unpaid }
