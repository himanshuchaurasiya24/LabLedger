import 'package:flutter/material.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/methods/custom_methods.dart';
import 'package:labledger/models/bill_stats_model.dart';

class BillStatsCard extends StatelessWidget {
  final String title;
  final BillPeriodStats currentPeriod;
  final BillPeriodStats previousPeriod;

  const BillStatsCard({
    super.key,
    required this.title,
    required this.currentPeriod,
    required this.previousPeriod,
  });

  Color getBackgroundColor(BuildContext context, bool isPositive) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isPositive) {
      return isDark ? Colors.green[700]! : Colors.green[50]!;
    } else {
      return isDark ? Colors.red[700]! : Colors.red[50]!;
    }
  }

  Color getAccentColor(
    bool isPositive,
    BuildContext context, {
    bool? isContainerColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isContainerColor != null && isContainerColor) {
      if (isDark) {
        return isPositive ? Colors.green[100]! : Colors.red[100]!;
      }
      return isPositive ? Colors.green[600]! : Colors.red[600]!;
    }
    return isPositive ? Colors.green[600]! : Colors.red[600]!;
  }

  Color getTextColor(BuildContext context, bool isPositive) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isDark) {
      return Colors.white;
    } else {
      return isPositive ? Colors.green[800]! : Colors.red[800]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = currentPeriod.totalBills;
    final previous = previousPeriod.totalBills;

    final growth = previous == 0
        ? 0.0
        : ((current - previous) / previous) * 100;
    final isPositive = growth >= 0;
    final theme = Theme.of(context);

    final titleStyle = theme.textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.bold,
      color: getTextColor(context, isPositive),
    );

    final totalStyle = theme.textTheme.headlineMedium?.copyWith(
      fontWeight: FontWeight.w800,
      color: getTextColor(context, isPositive),
    );

    final diagnosisStyle = theme.textTheme.bodyMedium?.copyWith(
      color: getTextColor(context, isPositive).withValues(alpha: 0.8),
      fontWeight: FontWeight.w500,
    );

    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        decoration: BoxDecoration(
          color: getBackgroundColor(context, isPositive),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: getAccentColor(isPositive, context).withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: getAccentColor(isPositive, context).withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and growth indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: titleStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: getAccentColor(
                        isContainerColor: true,
                        isPositive,
                        context,
                      ).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPositive ? Icons.trending_up : Icons.trending_down,
                          color: getTextColor(context, isPositive),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "${isPositive ? '+' : ''}${growth.toStringAsFixed(1)}%",
                          style: TextStyle(
                            fontSize: 14,
                            color: getTextColor(context, isPositive),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: defaultHeight),

              // Total bills count with icon
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: getAccentColor(
                        isPositive,
                        context,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.receipt_long,
                      color: getTextColor(context, isPositive),
                      size: 30,
                    ),
                  ),
                  SizedBox(width: defaultWidth),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Total Bills",
                        style: diagnosisStyle?.copyWith(fontSize: 12),
                      ),
                      Text(current.toString(), style: totalStyle),
                    ],
                  ),
                ],
              ),

              SizedBox(height: defaultHeight),

              // Diagnosis breakdown
              if (currentPeriod.diagnosisCounts.isNotEmpty) ...[
                Text("Breakdown", style: titleStyle?.copyWith(fontSize: 16)),
                SizedBox(height: defaultHeight),

                // Diagnosis items in a scrollable list to show all items
                Expanded(
                  child: ScrollConfiguration(
                    behavior: NoThumbScrollBehavior(),
                    child: SingleChildScrollView(
                      child: Column(
                        children: currentPeriod.diagnosisCounts.entries.map((
                          entry,
                        ) {
                          final percentage = current > 0
                              ? (entry.value / current * 100)
                              : 0.0;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    entry.key.toUpperCase(),
                                    style: diagnosisStyle?.copyWith(
                                      fontSize: 12,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: getAccentColor(
                                        isPositive,
                                        context,
                                      ).withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: FractionallySizedBox(
                                      alignment: Alignment.centerLeft,
                                      widthFactor: percentage / 100,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: getTextColor(
                                            context,
                                            isPositive,
                                          ).withValues(alpha: 0.8),

                                          borderRadius: BorderRadius.circular(
                                            3,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 30,
                                  child: Text(
                                    entry.value.toString(),
                                    style: diagnosisStyle?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
