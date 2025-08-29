import 'dart:async';

import 'package:flutter/material.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/models/referral_and_bill_chart_model.dart';

class ReferralCard extends StatefulWidget {
  const ReferralCard({
    super.key,
    required this.referrals,
    required this.selectedPeriod,
    this.width,
    this.height,
    required this.baseColor, // 👈 only one color
  });

  final List<ReferralStat> referrals;
  final String selectedPeriod;
  final double? width;
  final double? height;
  final Color baseColor; // 👈 single source of truth

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
      _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
        if (_currentIndex < widget.referrals.take(3).length - 1) {
          _currentIndex++;
        } else {
          _currentIndex = 0;
        }
        if (_pageController.hasClients) {
          _pageController.animateToPage(
            _currentIndex,
            duration: const Duration(milliseconds: 2500),
            curve: Curves.fastOutSlowIn,
          );
        }
      });
    }
  }

  /// ----- 🎨 Derived Colors from baseColor -----
  Color get backgroundColor {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? widget.baseColor.withValues(alpha: 0.8) // darker bg in dark mode
        : widget.baseColor.withValues(alpha: 0.1); // lighter bg in light mode
  }

  Color get importantTextColor {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.white : widget.baseColor; // info color
  }

  Color get normalTextColor {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.white70 : Colors.black87; // readable neutral text
  }

  Color get accentFillColor {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? widget.baseColor.withValues(alpha: 0.6)
        : widget.baseColor.withValues(alpha: 0.15);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Make a copy so original list is not mutated
    final sortedReferrers = List<ReferralStat>.from(widget.referrals);

    // Sort by incentiveAmount descending
    sortedReferrers.sort(
      (a, b) => b.incentiveAmount.compareTo(a.incentiveAmount),
    );

    // Take top 3 after sorting
    final topReferrers = sortedReferrers.take(3).toList();

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
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: widget.baseColor.withValues(alpha: 0.2)),
      ),
      child: Center(
        child: Text(
          "No referrals found",
          style: TextStyle(color: normalTextColor),
        ),
      ),
    );
  }

  Widget _buildReferrerCard(ReferralStat referrer, int index) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: defaultPadding,
        vertical: defaultPadding / 2,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(defaultRadius),
        border: Border.all(color: widget.baseColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: widget.baseColor,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  "Top Incentive #${index + 1}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                referrer.doctorFullName.isNotEmpty
                    ? referrer.doctorFullName
                    : "Unknown Doctor",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: importantTextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          /// Totals
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoTile(
                Icons.receipt_long,
                "Total Bills",
                referrer.total.toString(),
              ),
              _buildInfoTile(
                Icons.currency_rupee,
                "Total Incentives",
                referrer.incentiveAmount.toString(),
              ),
            ],
          ),

          SizedBox(height: defaultHeight),

          /// Breakdown
          Text(
            "Breakdown",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: importantTextColor,
            ),
          ),
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
                          maxLines: 1,

                          style: TextStyle(color: importantTextColor),
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
                                      color: widget.baseColor.withValues(
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
                                        color:
                                            importantTextColor, // 👈 highlight
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              entry.value.toString(),
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
              style: TextStyle(
                color: importantTextColor,
                fontSize: 12,
                // fontWeight: FontWeight.bold,
              ),
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

  Map<String, int> _getServiceBreakdown(ReferralStat referrer) {
    final allServices = {
      'ECG': referrer.ecg,
      'FRANCHISE LAB': referrer.franchiseLab,
      'PATHOLOGY': referrer.pathology,
      'ULTRASOUND': referrer.ultrasound,
      'X-RAY': referrer.xray,
    };
    return Map.fromEntries(
      allServices.entries.where((entry) => entry.value > 0),
    );
  }
}
