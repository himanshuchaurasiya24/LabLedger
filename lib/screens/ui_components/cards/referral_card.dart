// screens/ui_components/cards/referral_card.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/models/referral_and_bill_chart_model.dart';
import 'package:labledger/screens/ui_components/tinted_container.dart';

class ReferralCard extends StatefulWidget {
  const ReferralCard({
    super.key,
    required this.referrals,
    required this.selectedPeriod,
    this.width,
    this.height,
    required this.baseColor,
  });

  final List<ReferralStat> referrals;
  final String selectedPeriod;
  final double? width;
  final double? height;
  final Color baseColor;

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
  }

  void _goToPage(int index) {
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  List<ReferralStat> _getDisplayReferrers() {
    final sortedReferrers = List<ReferralStat>.from(widget.referrals)
      ..sort((a, b) => b.incentiveAmount.compareTo(a.incentiveAmount));

    final topReferrers = sortedReferrers.take(3).toList();

    if (topReferrers.isEmpty) {
      final dummyReferrer = ReferralStat(
        referredByDoctorId: 0,
        doctorFullName: widget.selectedPeriod,
        incentiveAmount: 0,
        total: 0,
        ecg: 0,
        franchiseLab: 0,
        pathology: 0,
        ultrasound: 0,
        xray: 0,
      );
      return [dummyReferrer];
    } else {
      return topReferrers;
    }
  }

  // --- 🎨 Color Logic ---
  Color get backgroundColor {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? widget.baseColor.withValues(alpha: 0.8)
        : widget.baseColor.withValues(alpha: 0.1);
  }

  Color get importantTextColor {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return Colors.white;
    } else {
      return widget.baseColor.withValues(alpha: 1.0);
    }
  }

  Color get normalTextColor {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.white70 : Colors.black87;
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
    final displayReferrers = _getDisplayReferrers();

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        SizedBox(
          // NEW: Use a reasonable minimum height for the card
          height: widget.height ?? 350,
          width: widget.width ?? double.infinity,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: displayReferrers.length,
            itemBuilder: (context, index) {
              final referrer = displayReferrers[index];
              return _buildReferrerCard(referrer, index);
            },
          ),
        ),

        if (displayReferrers.length > 1)
          Positioned(
            // NEW: Use Positioned for better control
            bottom: 12.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                displayReferrers.length,
                (index) => GestureDetector(
                  onTap: () => _goToPage(index),
                  child: _buildIndicator(
                    isActive: _currentIndex == index,
                    activeColor: importantTextColor,
                    inactiveColor: accentFillColor,
                  ),
                ),
              ),
            ),
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

  Widget _buildReferrerCard(ReferralStat referrer, int index) {
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bool isDummy = referrer.referredByDoctorId == 0;
    final String cardTitle = isDummy
        ? "No Referrals"
        : "Top Incentive #${index + 1}";

    return TintedContainer(
      baseColor: widget.baseColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isDark ? accentFillColor : importantTextColor,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  cardTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8), // Add a gap
              Expanded(
                child: Text(
                  referrer.doctorFullName.isNotEmpty
                      ? referrer.doctorFullName
                      : "Unknown Doctor",
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: importantTextColor,
                  ),
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          /// Totals
          // CHANGED: This entire Row is now responsive
          Row(
            children: [
              Expanded(
                child: _buildInfoTile(
                  Icons.receipt_long,
                  "Total Bills",
                  referrer.total.toString(),
                ),
              ),
              const SizedBox(width: 16), // Add a gap between tiles
              Expanded(
                child: _buildInfoTile(
                  Icons.currency_rupee,
                  "Total Incentives",
                  referrer.incentiveAmount.toString(),
                ),
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

          /// Breakdown List
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: _getServiceBreakdown(referrer).entries.map((entry) {
                final percentage = referrer.total > 0
                    ? entry.value / referrer.total
                    : 0.0;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          entry.key.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: importantTextColor),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2, // Give more flex to this part
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
                                    alignment: Alignment.centerLeft,
                                    widthFactor: percentage,
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

  // CHANGED: Made the info tile itself responsive
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
        Expanded(
          // NEW: Allow the column to take the remaining space
          child: Column(
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

  Map<String, int> _getServiceBreakdown(ReferralStat referrer) {
    final allServices = {
      'ECG': referrer.ecg,
      'FRANCHISE LAB': referrer.franchiseLab,
      'PATHOLOGY': referrer.pathology,
      'ULTRASOUND': referrer.ultrasound,
      'X-RAY': referrer.xray,
    };
    return allServices;
  }
}
