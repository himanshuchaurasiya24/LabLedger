// widgets/chart_stats_card.dart
import 'package:flutter/material.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/models/referral_and_bill_chart_model.dart';

class ChartStatsCard extends StatefulWidget {
  final String title;
  final List<ChartData> data;
  final Color accentColor;
  final double? height;
  final double? width;

  const ChartStatsCard({
    super.key,
    required this.title,
    required this.data,
    required this.accentColor,
    this.height,
    this.width,
  });

  @override
  State<ChartStatsCard> createState() => _ChartStatsCardState();
}

class _ChartStatsCardState extends State<ChartStatsCard> {
  /// Total bills across all data
  int get totalBills => widget.data.fold<int>(0, (sum, e) => sum + e.total);

  /// Breakdown aggregation
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

  /// Background color
  Color get backgroundColor {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? widget.accentColor.withValues(alpha: 0.8) // darker bg in dark mode
        : widget.accentColor.withValues(alpha: 0.1); // lighter bg in light mode
  }

  /// Text color - Use accent color at full opacity in light mode
Color get importantTextColor {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  if (isDark) {
    return Colors.white; // Keep white for dark mode
  } else {
    // Use accent color with guaranteed full opacity.
    return widget.accentColor.withValues(alpha:  1.0);
  }
}

  Color get normalTextColor {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.white70 : Colors.black87;
  }

  Color get accentFillColor {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? widget.accentColor.withValues(alpha: 0.6)
        : widget.accentColor.withValues(alpha: 0.15);
  }

  /// Bar color for the breakdown charts
  Color get barColor {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? Colors.white.withValues(alpha: 0.9)
        : widget.accentColor; // Use accent color for bars in light mode
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final maxValue = (breakdown.values.isNotEmpty)
        ? breakdown.values.reduce((a, b) => a > b ? a : b)
        : 1;

    return Container(
      height: widget.height ?? 300,
      width: widget.width ?? double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: defaultPadding,
        vertical: defaultPadding / 2,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(defaultRadius),
        border: Border.all(
          color: widget.accentColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBadge(context, isDark),
              Text(
                widget.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: importantTextColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          SizedBox(height: defaultHeight),

          // Total Bills
          _buildInfoTile(
            Icons.receipt_long,
            "Total Bills",
            totalBills.toString(),
          ),
          SizedBox(height: defaultHeight),

          // Breakdown
          Text(
            "Breakdown",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: importantTextColor,
            ),
          ),
          SizedBox(height: defaultHeight),

          Column(
            children: breakdown.entries.map((entry) {
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
                    Expanded(
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
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            ),
          ],
        ),
      ],
    );
  }

  /// Badge widget
  Widget _buildBadge(BuildContext context, bool isDark) {
    return Container(
      height: 40,
      width: 200,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark ? accentFillColor : importantTextColor,
        borderRadius: BorderRadius.circular(defaultRadius * 3),
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
