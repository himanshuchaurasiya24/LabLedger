// screens/ui_components/cards/chart_stats_card.dart

import 'package:flutter/material.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/models/referral_and_bill_chart_model.dart';
import 'package:labledger/screens/ui_components/tinted_container.dart';

class ChartStatsCard extends StatefulWidget {
  final String title;
  final List<ChartData> data;
  final Color baseColor;

  const ChartStatsCard({
    super.key,
    required this.title,
    required this.data,
    required this.baseColor,
  });

  @override
  State<ChartStatsCard> createState() => _ChartStatsCardState();
}

class _ChartStatsCardState extends State<ChartStatsCard> {
  int get totalBills => widget.data.fold<int>(0, (sum, e) => sum + e.total);

  Map<String, int> get breakdown {
    final Map<String, int> agg = {
      'ECG': 0,
      'FRANCHISE LAB': 0,
      'PATHOLOGY': 0,
      'ULTRASOUND': 0,
      'X-RAY': 0,
    };

    for (final e in widget.data) {
      agg['ECG'] = agg['ECG']! + e.ecg;
      agg['FRANCHISE LAB'] = agg['FRANCHISE LAB']! + e.franchiseLab;
      agg['PATHOLOGY'] = agg['PATHOLOGY']! + e.pathology;
      agg['ULTRASOUND'] = agg['ULTRASOUND']! + e.ultrasound;
      agg['X-RAY'] = agg['X-RAY']! + e.xray;
    }
    return agg;
  }

  Color get importantTextColor {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.white : widget.baseColor;
  }

  Color get accentFillColor {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? widget.baseColor.withValues(alpha: 0.6)
        : widget.baseColor.withValues(alpha: 0.15);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final calculatedMaxValue = (breakdown.values.isNotEmpty)
        ? breakdown.values.reduce((a, b) => a > b ? a : b)
        : 0;
    final maxValue = calculatedMaxValue > 0 ? calculatedMaxValue : 1;

    // NEW: Set a minimum height for the card
    return TintedContainer(
      baseColor: widget.baseColor,
      // CHANGED: Make the card's content scrollable
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                _buildBadge(context, isDark),
                const SizedBox(width: 8), // Add a gap
                Expanded(
                  // NEW: Make the title flexible
                  child: Text(
                    widget.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: importantTextColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end, // Align to the right
                  ),
                ),
              ],
            ),
            SizedBox(height: defaultHeight / 2),

            // Total Bills
            _buildInfoTile(
              Icons.receipt_long,
              "Total Bills",
              totalBills.toString(),
              CrossAxisAlignment.start,
            ),
            SizedBox(height: defaultHeight / 2),

            // Breakdown
            Text(
              "Breakdown",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: importantTextColor,
              ),
            ),
            SizedBox(height: defaultHeight / 2),

            // NEW: Use Column instead of mapping directly for better performance in a scroll view
            Column(
              children: [
                for (final entry in breakdown.entries)
                  _buildBreakdownRow(entry, maxValue),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // NEW: Extracted breakdown row to its own method
  Widget _buildBreakdownRow(MapEntry<String, int> entry, int maxValue) {
    final label = entry.key;
    final value = entry.value;
    final barWidth = (value / maxValue);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label.toUpperCase(),
              style: TextStyle(color: importantTextColor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: accentFillColor,
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: barWidth,
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: importantTextColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: defaultWidth),
                Text(
                  "$value",
                  style: TextStyle(
                    color: importantTextColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // CHANGED: Made the info tile responsive, identical to the one in ReferralCard
  Widget _buildInfoTile(
    IconData icon,
    String label,
    String value,
    CrossAxisAlignment crossAxisAlignment,
  ) {
    return Row(
      children: [
        Container(
          height: 55,
          width: 55,
          decoration: BoxDecoration(
            color: accentFillColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: importantTextColor, size: 40),
        ),
        const SizedBox(width: 12),
        Expanded(
          // NEW: Allow the column to take the remaining space
          child: Column(
            crossAxisAlignment: crossAxisAlignment,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(color: importantTextColor, fontSize: 12),
              ),
              Text(
                value,
                style: TextStyle(
                  color: importantTextColor,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
                maxLines: 1, // NEW: Prevent wrapping
                overflow:
                    TextOverflow.ellipsis, // NEW: Add ellipsis if too long
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? accentFillColor : importantTextColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: const Center(
        child: Text(
          "Growth Bar",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
