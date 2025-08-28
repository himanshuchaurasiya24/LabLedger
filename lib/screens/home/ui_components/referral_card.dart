// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:labledger/models/referral_and_bill_chart_model.dart';
import 'package:labledger/providers/custom_providers.dart';
import 'dart:async';

class ReferralCard extends StatefulWidget {
  const ReferralCard({
    super.key,
    required this.referrals,
    required this.selectedPeriod,
    this.width,
    this.height,
    required this.accentColor,
    required this.liteModeTextColor,
    required this.darkModeTextColor,
    required this.liteAccentColor,
    required this.darkAccentColor,
  });

  final List<ReferralStat> referrals;
  final String selectedPeriod;
  final double? width;
  final double? height;
  final Color accentColor;

  final Color liteModeTextColor;
  final Color darkModeTextColor;
  final Color liteAccentColor;
  final Color darkAccentColor;

  @override
  State<ReferralCard> createState() => _ReferralCardState();
}

class _ReferralCardState extends State<ReferralCard> {
  late PageController _pageController;
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoSwipe();
  }

  void _startAutoSwipe() {
    if (widget.referrals.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
        if (_currentIndex < widget.referrals.take(3).length - 1) {
          _currentIndex++;
        } else {
          _currentIndex = 0;
        }
        if (_pageController.hasClients) {
          _pageController.animateToPage(
            _currentIndex,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  Color getBackgroundColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return widget.darkAccentColor;
    }
    return widget.liteAccentColor;
  }

  Color getTextColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isDark) {
      return Colors.white;
    } else {
      return widget.darkModeTextColor;
    }
  }

  Color getAccentColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return widget.darkAccentColor;
    }
    return widget.liteAccentColor;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topReferrers = widget.referrals.take(3).toList();

    return SizedBox(
      height: widget.height ?? 300,
      width: widget.width ?? double.infinity,
      child: topReferrers.isEmpty
          ? _buildEmptyState()
          : PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemCount: topReferrers.length,
              itemBuilder: (context, index) {
                final referrer = topReferrers[index];
                return _buildReferrerCard(referrer, index);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.accentColor.withOpacity(0.1),
            widget.accentColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.accentColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text(
              "No referrals found",
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReferrerCard(ReferralStat referrer, int index) {
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
    return Container(
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
          // Header with period and rank
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
                    "Top Incentive #${index + 1}",
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
                referrer.doctorFullName.isNotEmpty
                    ? referrer.doctorFullName
                    : "Unknown Doctor",
                style: titleStyle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          SizedBox(height: defaultHeight),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
                      Text("${referrer.total}", style: totalStyle),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    height: 55,
                    width: 55,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: getAccentColor(context).withValues(alpha: 0.1),

                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.currency_rupee,
                      color: getTextColor(context),
                      size: 40,
                    ),
                  ),
                  SizedBox(width: defaultWidth),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Total Incentives",
                        style: diagnosisStyle?.copyWith(fontSize: 12),
                      ),
                      Text("${referrer.incentiveAmount}", style: totalStyle),
                    ],
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: defaultHeight),
          // Breakdown
          Text("Breakdown", style: titleStyle?.copyWith(fontSize: 16)),

          SizedBox(height: defaultHeight),
          Expanded(
            child: Column(
              children: _getServiceBreakdown(referrer).entries.map((entry) {
                final percentage = referrer.total > 0
                    ? (entry.value / referrer.total * 100)
                    : 0.0;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          entry.key.toUpperCase(),
                          style: diagnosisStyle?.copyWith(fontSize: 14),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Spacer(),
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
                                      color: widget.accentColor.withValues(
                                        alpha: 0.2,
                                      ),
                                    ),
                                  ),
                                  FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: percentage / 100,
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
                          ],
                        ),
                      ),
                      SizedBox(width: defaultWidth),
                      Text(
                        entry.value.toString(),
                        style: diagnosisStyle!.copyWith(
                          color: getTextColor(context).withValues(alpha: 0.8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, int> _getServiceBreakdown(ReferralStat referrer) {
    final allServices = {
      'ECG': referrer.ecg,
      'FRANCHISE LAB': referrer.franchiseLab,
      'PATHOLOGY': referrer.pathology,
      'ULTRASOUND': referrer.ultrasound,
      'X-RAY': referrer.xray,
    };

    // Filter out services with 0 values
    return Map.fromEntries(
      allServices.entries.where((entry) => entry.value > 0),
    );
  }
}
