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
    this.autoSwipe = true,
    this.autoSwipeDurationSeconds = 5,
  });

  final List<ReferralStat> referrals;
  final String selectedPeriod;
  final double? width;
  final double? height;
  final Color baseColor;
  final bool autoSwipe;
  final int autoSwipeDurationSeconds;

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
    if (widget.autoSwipe && widget.referrals.length > 1) {
      _timer = Timer.periodic(
        Duration(seconds: widget.autoSwipeDurationSeconds),
        (timer) {
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
        },
      );
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
    final sortedReferrers = List<ReferralStat>.from(widget.referrals)
      ..sort((a, b) => b.incentiveAmount.compareTo(a.incentiveAmount));

    final topReferrers = sortedReferrers.take(3).toList();

    List<ReferralStat> displayReferrers;
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
      displayReferrers = [dummyReferrer];
    } else {
      displayReferrers = topReferrers;
    }

    return SizedBox(
      height: widget.height ?? 302,
      width: widget.width ?? double.infinity,
      child: PageView.builder(
        physics: displayReferrers.length > 1
            ? const AlwaysScrollableScrollPhysics()
            : const NeverScrollableScrollPhysics(),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
          // 👇 The 'if (!isDummy)' checks are removed to ensure this section always shows.
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
                    ? entry.value / referrer.total
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
                              entry.value.toString(), // This will show "0"
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
          // 🗑️ Removed the conditional Spacer.
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

  // ✨ This method now returns all services, even if their value is 0.
  Map<String, int> _getServiceBreakdown(ReferralStat referrer) {
    final allServices = {
      'ECG': referrer.ecg,
      'FRANCHISE LAB': referrer.franchiseLab,
      'PATHOLOGY': referrer.pathology,
      'ULTRASOUND': referrer.ultrasound,
      'X-RAY': referrer.xray,
    };
    // The filter that removed zero-value entries has been removed.
    return allServices;
  }
}
