import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/main.dart';
import 'package:labledger/providers/incenitve_generator_provider.dart';
import 'package:labledger/screens/incentives/incentive_detail_screen.dart';
import 'package:labledger/screens/ui_components/app_inkwell.dart';
import 'package:labledger/screens/ui_components/tinted_container.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ActionPanel extends ConsumerWidget {
  const ActionPanel({super.key});

  void _clearFilters(WidgetRef ref) {
    ref.invalidate(selectedDoctorIdsProvider);
    ref.invalidate(selectedFranchiseIdsProvider);
    ref.invalidate(selectedDiagnosisTypeIdsProvider);
    ref.read(selectedBillStatusesProvider.notifier).state = {'Fully Paid'};
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    ref.read(reportStartDateProvider.notifier).state = firstDayOfMonth;
    ref.read(reportEndDateProvider.notifier).state = now;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return TintedContainer(
      height: 130,
      baseColor: theme.colorScheme.secondary,
      intensity: 0.08,
      child: Column(
        children: [
          Expanded(
            child: AppInkWell(
              borderRadius: BorderRadius.circular(defaultRadius),
              onTap: () {
                navigatorKey.currentState?.push(
                  MaterialPageRoute(
                    builder: (context) => IncentiveDetailScreen(),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.secondary,
                      theme.colorScheme.secondary.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(defaultRadius),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.secondary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.fileText, color: Colors.white, size: 20),
                    SizedBox(width: 10),
                    Text(
                      "Generate Report",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: defaultHeight / 2),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: Icon(
                LucideIcons.rotateCcw,
                size: 16,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              label: Text(
                "Clear Filters",
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
              ),
              onPressed: () => _clearFilters(ref),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12),
                side: BorderSide(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(defaultRadius),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
