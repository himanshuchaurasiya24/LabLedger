import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/models/bill_stats_model.dart';
import 'package:labledger/screens/ui_components/animated_progress_indicator.dart';
import 'package:labledger/screens/ui_components/cards/bill_stats_card.dart';
import 'package:labledger/constants/constants.dart';

class BillGrowthStatsView extends StatelessWidget {
  final AsyncValue<BillStats> statsProvider;
  final VoidCallback onRetry;

  const BillGrowthStatsView({
    super.key,
    required this.statsProvider,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
     Color positiveColor =Theme.of(context).colorScheme.secondary;
     Color negativeColor = Theme.of(context).colorScheme.error;

    return Container(
      height: tintedContainerHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(defaultRadius),
      ),
      child: statsProvider.when(
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
        loading: () =>  Center(
          child: AnimatedLabProgressIndicator(
            firstColor: positiveColor,
            secondColor: negativeColor,
          ),
        ),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Error loading stats: $err"),
              const SizedBox(height: 10),
              ElevatedButton(onPressed: onRetry, child: const Text("Retry")),
            ],
          ),
        ),
      ),
    );
  }
}
