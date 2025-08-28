// widgets/chart_stats_card.dart
import 'package:flutter/material.dart';
import 'package:labledger/models/referral_and_bill_chart_model.dart';
import 'package:labledger/providers/custom_providers.dart';

class ChartStatsCard extends StatelessWidget {
  final String title;
  final List<ChartData> data;
  final Color accentColor;
  final double? height;
  final double? width;
  final Color liteModeTextColor;
  final Color darkModeTextColor;
  final Color liteAccentColor;
  final Color darkAccentColor;

  const ChartStatsCard({
    super.key,
    required this.title,
    required this.data,
    required this.accentColor,
    this.height,
    this.width,
    required this.liteModeTextColor,
    required this.darkModeTextColor,
    required this.liteAccentColor,
    required this.darkAccentColor,
  });

  int get totalBills => data.fold<int>(0, (sum, e) => sum + (e.total));

  Map<String, int> get breakdown {
    final Map<String, int> agg = {
      'ECG': 0,
      'FRANCHISE LAB': 0,
      'PATHOLOGY': 0,
      'ULTRASOUND': 0,
      'X-RAY': 0,
    };
    for (final e in data) {
      agg['ECG'] = agg['ECG']! + e.ecg;
      agg['FRANCHISE LAB'] = agg['FRANCHISE LAB']! + e.franchiseLab;
      agg['PATHOLOGY'] = agg['PATHOLOGY']! + e.pathology;
      agg['ULTRASOUND'] = agg['ULTRASOUND']! + e.ultrasound;
      agg['X-RAY'] = agg['X-RAY']! + e.xray;
    }
    return agg;
  }

  Color getBackgroundColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return darkAccentColor;
    }
    return liteAccentColor;
  }

  Color getTextColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isDark) {
      return Colors.white;
    } else {
      return darkModeTextColor;
    }
  }

  Color getAccentColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return darkAccentColor;
    }
    return liteAccentColor;
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = getBackgroundColor(context);
    final textColor = getTextColor(context);
    final theme = Theme.of(context);

    final titleStyle = theme.textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.bold,
      color: textColor,
    );

    final totalStyle = theme.textTheme.headlineMedium?.copyWith(
      fontWeight: FontWeight.w800,
      color: textColor,
    );

    final diagnosisStyle = theme.textTheme.bodyMedium?.copyWith(
      color: textColor.withValues(alpha: 0.8),
      fontWeight: FontWeight.w500,
    );

    final maxValue = (breakdown.values.isNotEmpty)
        ? breakdown.values.reduce((a, b) => a > b ? a : b)
        : 1;
    return Container(
      height: height ?? 300,
      width: width ?? double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: defaultPadding,
        vertical: defaultPadding / 2,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(defaultRadius),
        border: Border.all(color: accentColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 40,
                width: 200,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(defaultRadius * 3),
                ),
                child: Center(
                  child: Text(
                    "Growth Bar",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              // Doctor name
              Text(
                title,
                style: titleStyle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          SizedBox(height: defaultHeight),

          // Total Bills
          Row(
            children: [
              Container(
                height: 55,
                width: 55,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: getAccentColor(context),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.receipt_long,
                  color: getTextColor(context),
                  size: 30,
                ),
              ),
              SizedBox(width: defaultWidth),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Total Bills",
                    style: diagnosisStyle?.copyWith(fontSize: 12),
                  ),
                  Text("$totalBills", style: totalStyle),
                ],
              ),
            ],
          ),
          SizedBox(height: defaultHeight),

          // Breakdown
          Text("Breakdown", style: titleStyle?.copyWith(fontSize: 16)),
          SizedBox(height: defaultHeight),

          Column(
            children: breakdown.entries.map((entry) {
              final label = entry.key;
              final value = entry.value;
              final barWidth = (value / maxValue);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        label.toUpperCase(),
                        style: diagnosisStyle?.copyWith(fontSize: 14),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Stack(
                              children: [
                                Container(
                                  height: 8,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    color: accentColor.withValues(alpha: 0.2),
                                  ),
                                ),
                                FractionallySizedBox(
                                  widthFactor: barWidth,
                                  child: Container(
                                    height: 8,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      color: getTextColor(
                                        context,
                                      ).withValues(alpha: 0.8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: defaultWidth),
                          Text(
                            "$value",
                            style: diagnosisStyle!.copyWith(
                              color: getTextColor(
                                context,
                              ).withValues(alpha: 0.8),
                              fontWeight: FontWeight.w600,
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
}
