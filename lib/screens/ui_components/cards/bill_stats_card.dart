import 'dart:async';

import 'package:flutter/material.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/models/bill_stats_model.dart';
import 'package:labledger/screens/ui_components/cards/chart_stats_card.dart';
import 'package:labledger/models/referral_and_bill_chart_model.dart';
import 'package:labledger/screens/ui_components/tinted_container.dart';

class BillStatsCard extends StatefulWidget {
  final String title;
  final BillPeriodStats currentPeriod;
  final BillPeriodStats previousPeriod;
  final Color positiveColor;
  final Color negativeColor;
  final bool autoSwipe;
  final int autoSwipeDurationSeconds;

  const BillStatsCard({
    super.key,
    required this.title,
    required this.currentPeriod,
    required this.previousPeriod,
    this.positiveColor = Colors.teal,
    this.negativeColor = Colors.red,
    this.autoSwipe = false,
    this.autoSwipeDurationSeconds = 5,
  });

  @override
  State<BillStatsCard> createState() => _BillStatsCardState();
}

class _BillStatsCardState extends State<BillStatsCard> {
  late PageController _pageController;
  int _currentIndex = 0;
  Timer? _timer;

  // ✨ FIXED: Matched the key casing to your JSON data
  final List<String> serviceKeys = const [
    'ECG',
    'Franchise Lab',
    'Pathology',
    'Ultrasound',
    'X-Ray',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoSwipe();
  }

  void _startAutoSwipe() {
    if (widget.autoSwipe) {
      _timer = Timer.periodic(
        Duration(seconds: widget.autoSwipeDurationSeconds),
        (timer) {
          final nextPage = (_currentIndex + 1) % 2;
          if (_pageController.hasClients) {
            _pageController.animateToPage(
              nextPage,
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
            );
          }
        },
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final currentBills = widget.currentPeriod.totalBills;
    final previousBills = widget.previousPeriod.totalBills;
    final isPositive = currentBills >= previousBills;
    final baseColor = isPositive ? widget.positiveColor : widget.negativeColor;

    final currentServicesCount = widget.currentPeriod.diagnosisCounts.length;
    final previousServicesCount = widget.previousPeriod.diagnosisCounts.length;
    final servicesGrowth = previousServicesCount == 0
        ? (currentServicesCount > 0 ? 100.0 : 0.0)
        : ((currentServicesCount - previousServicesCount) /
                  previousServicesCount) *
              100;

    // ✨ FIXED: Replaced .withValues with standard .withValues
    final Color backgroundColor = isDark
        ? baseColor.withValues(alpha: 0.8)
        : baseColor.withValues(alpha: 0.1);
    final Color importantTextColor = isDark ? Colors.white : baseColor;
    final Color accentFillColor = isDark
        ? baseColor.withValues(alpha: 0.6)
        : baseColor.withValues(alpha: 0.15);

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: 2,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          itemBuilder: (context, index) {
            if (index == 0) {
              return _buildInfoPage(
                data: widget.currentPeriod,
                servicesGrowth: servicesGrowth,
                colors: (
                  background: backgroundColor,
                  text: importantTextColor,
                  accent: accentFillColor,
                  base: baseColor,
                ),
              );
            } else {
              final prevData = widget.previousPeriod;
              final chartDataObject = ChartData(
                day: 'Previous Period',
                total: prevData.totalBills,
                ultrasound: prevData.diagnosisCounts['Ultrasound'] ?? 0,
                ecg: prevData.diagnosisCounts['ECG'] ?? 0,
                xray: prevData.diagnosisCounts['X-Ray'] ?? 0,
                pathology: prevData.diagnosisCounts['Pathology'] ?? 0,
                franchiseLab: prevData.diagnosisCounts['Franchise Lab'] ?? 0,
              );
              return ChartStatsCard(
                title: "Previous Period",
                data: [chartDataObject],
                baseColor: baseColor,
              );
            }
          },
        ),
        Padding(
          padding: EdgeInsets.only(bottom: defaultPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              2,
              (index) => _buildIndicator(
                isActive: _currentIndex == index,
                activeColor: importantTextColor,
                inactiveColor: accentFillColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoPage({
    required BillPeriodStats data,
    required double servicesGrowth,
    required ({Color background, Color text, Color accent, Color base}) colors,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TintedContainer(
      baseColor: colors.base,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(isDark, colors.accent, colors.text),
          SizedBox(height: defaultHeight),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoTile(
                Icons.receipt_long,
                "Total Bills",
                data.totalBills.toString(),
                colors.accent,
                colors.text,
                CrossAxisAlignment.start,
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: defaultPadding * 1.5,
                  vertical: defaultPadding * 0.75,
                ),
                decoration: BoxDecoration(
                  // ✨ FIXED: Replaced .withValues with standard .withValues
                  color: colors.accent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        servicesGrowth >= 0
                            ? Icons.trending_up
                            : Icons.trending_down,
                        color: colors.text,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "${servicesGrowth >= 0 ? '+' : ''}${servicesGrowth.toStringAsFixed(1)}%",
                        style: TextStyle(
                          fontSize: 14,
                          color: colors.text,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: defaultHeight / 2),
          Text(
            "Breakdown",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.text,
            ),
          ),
          SizedBox(height: defaultHeight / 2),
          _buildBreakdownList(data, (text: colors.text, accent: colors.accent)),
        ],
      ),
    );
  }

  // --- Other helper widgets remain the same ---

  Widget _buildHeader(bool isDark, Color accent, Color text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? accent : text,
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
        ),
        Text(
          widget.title,
          textAlign: TextAlign.end,
          maxLines: 2,

          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: text,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildBreakdownList(
    BillPeriodStats data,
    ({Color text, Color accent}) colors,
  ) {
    return Expanded(
      child: serviceKeys.isEmpty
          ? Center(
              child: Text(
                "No breakdown data available.",
                // ✨ FIXED: Replaced .withValues with standard .withValues
                style: TextStyle(color: colors.text.withValues(alpha: 0.7)),
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: serviceKeys.length,
              itemBuilder: (context, i) {
                final key = serviceKeys[i];
                final value = data.diagnosisCounts[key] ?? 0;
                final percentage = data.totalBills > 0
                    ? (value / data.totalBills)
                    : 0.0;
                return _buildBreakdownRow(
                  key,
                  value,
                  percentage,
                  colors.text,
                  colors.accent,
                );
              },
            ),
    );
  }

  Widget _buildBreakdownRow(
    String key,
    int value,
    double percentage,
    Color textColor,
    Color accentColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              key.toUpperCase(),
              style: TextStyle(color: textColor),
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
                          color: accentColor,
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: percentage,
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: textColor,
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
                    color: textColor,
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

  Widget _buildInfoTile(
    IconData icon,
    String label,
    String value,
    Color accentColor,
    Color textColor,
    CrossAxisAlignment crossAxisAlignment,
  ) {
    return Row(
      children: [
        Container(
          height: 55,
          width: 55,
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: textColor, size: 32),
        ),
        SizedBox(width: defaultWidth),
        Column(
          crossAxisAlignment: crossAxisAlignment,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: TextStyle(color: textColor, fontSize: 12)),
            Text(
              value,
              style: TextStyle(
                color: textColor,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIndicator({
    required bool isActive,
    required Color activeColor,
    required Color inactiveColor,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 8.0,
      width: isActive ? 24.0 : 8.0,
      decoration: BoxDecoration(
        color: isActive ? activeColor : inactiveColor,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
