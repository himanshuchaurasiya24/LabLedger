// Create a new file: labledger/screens/ui_components/doctor_stats_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/providers/referral_and_bill_chart_provider.dart';
import 'package:labledger/screens/ui_components/animated_progress_indicator.dart';
import 'package:labledger/screens/ui_components/cards/bill_stats_card.dart'; // Assuming you reuse this card
import 'package:labledger/constants/constants.dart';

class DoctorStatsView extends ConsumerWidget {
  final int doctorId;

  const DoctorStatsView({
    super.key,
    required this.doctorId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the new family provider with the doctor's ID
    final statsAsync = ref.watch(doctorGrowthStatsProvider(doctorId));

    // Define colors for the cards
    const Color positiveColor = Colors.teal;
    const Color negativeColor = Colors.red;

    return Container(
      height: tintedContainerHeight, // From your constants
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(defaultRadius),
      ),
      child: statsAsync.when(
        data: (stats) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: BillStatsCard(
                  title: "Monthly Growth",
                  currentPeriod: stats.currentMonth,
                  previousPeriod: stats.previousMonth,
                  positiveColor: positiveColor,
                  negativeColor: negativeColor,
                ),
              ),
              SizedBox(width: defaultWidth),
              Expanded(
                child: BillStatsCard(
                  title: "Quarterly Growth",
                  currentPeriod: stats.currentQuarter,
                  previousPeriod: stats.previousQuarter,
                  positiveColor: positiveColor,
                  negativeColor: negativeColor,
                ),
              ),
              SizedBox(width: defaultWidth),
              Expanded(
                child: BillStatsCard(
                  title: "Yearly Growth",
                  currentPeriod: stats.currentYear,
                  previousPeriod: stats.previousYear,
                  positiveColor: positiveColor,
                  negativeColor: negativeColor,
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: AnimatedLabProgressIndicator(
            firstColor: positiveColor,
            secondColor: negativeColor,
          ),
        ),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Error loading stats: ${err.toString()}",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => ref.invalidate(doctorGrowthStatsProvider(doctorId)),
                  child: const Text("Retry"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}