import 'package:flutter/material.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/methods/custom_methods.dart';
import 'package:labledger/models/bill_stats_model.dart';

class BillStatsCard extends StatelessWidget {
  final String title;
  final BillPeriodStats currentPeriod;
  final BillPeriodStats previousPeriod;
  final Color? positiveColor;
  final Color? negativeColor;

  const BillStatsCard({
    super.key,
    required this.title,
    required this.currentPeriod,
    required this.previousPeriod,
    this.positiveColor,
    this.negativeColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final current = currentPeriod.totalBills;
    final previous = previousPeriod.totalBills;

    final growth = previous == 0
        ? 0.0
        : ((current - previous) / previous) * 100;
    final isPositive = growth >= 0;

    // --- 🎨 Color Logic ---
    // Use provided colors or default to teal/red.
    final Color effectivePositiveColor = positiveColor ?? Colors.teal;
    final Color effectiveNegativeColor = negativeColor ?? Colors.red;

    // Helper function to safely derive colors, handling both MaterialColor and generic Color.
    ({Color background, Color text, Color accent}) getDerivedColors(
      Color baseColor,
    ) {
      // For Background Color
      final Color bg = (baseColor is MaterialColor)
          ? (isDark ? baseColor.shade900.withValues(alpha:0.4) : baseColor.shade50)
          : (isDark
                ? Color.alphaBlend(baseColor.withValues(alpha:0.2), Colors.black)
                : Color.alphaBlend(baseColor.withValues(alpha:0.1), Colors.white));

      // For Important Text Color
      final Color txt = (isDark)
          ? Colors.white
          : (baseColor is MaterialColor)
          ? baseColor.shade900
          : HSLColor.fromColor(
              baseColor,
            ).withLightness(0.2).toColor(); // Darken generic color

      // For Accent Color
      final Color acc = (baseColor is MaterialColor)
          ? (isDark ? baseColor.shade200 : baseColor.shade600)
          : (isDark
                ? HSLColor.fromColor(baseColor).withLightness(0.7).toColor()
                : HSLColor.fromColor(baseColor).withLightness(0.4).toColor());

      return (background: bg, text: txt, accent: acc);
    }

    final derivedColors = isPositive
        ? getDerivedColors(effectivePositiveColor)
        : getDerivedColors(effectiveNegativeColor);

    final Color backgroundColor = derivedColors.background;
    final Color importantTextColor = derivedColors.text;
    final Color accentColor = derivedColors.accent;

    // --- 📝 Text Styles ---
    final titleStyle = theme.textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.bold,
      color: importantTextColor,
    );

    final totalStyle = theme.textTheme.headlineMedium?.copyWith(
      fontWeight: FontWeight.w800,
      color: importantTextColor,
    );

    final diagnosisStyle = theme.textTheme.bodyMedium?.copyWith(
      color: importantTextColor.withValues(alpha:0.8),
      fontWeight: FontWeight.w500,
    );

    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accentColor.withValues(alpha:0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha:0.1),
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
                      color: accentColor.withValues(alpha:0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPositive ? Icons.trending_up : Icons.trending_down,
                          color: importantTextColor,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "${isPositive ? '+' : ''}${growth.toStringAsFixed(1)}%",
                          style: TextStyle(
                            fontSize: 14,
                            color: importantTextColor,
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
                      color: accentColor.withValues(alpha:0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.receipt_long,
                      color: importantTextColor,
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

                // Diagnosis items in a scrollable list
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
                                      color: accentColor.withValues(alpha:0.2),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: FractionallySizedBox(
                                      alignment: Alignment.centerLeft,
                                      widthFactor: percentage / 100,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: importantTextColor.withValues(alpha:
                                            0.8,
                                          ),
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
