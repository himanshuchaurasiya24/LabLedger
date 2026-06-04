import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/main.dart';
import 'package:labledger/providers/incenitve_generator_provider.dart';
import 'package:labledger/screens/incentives/incentive_detail_screen.dart';
import 'package:labledger/screens/ui_components/custom_elevated_button.dart';
import 'package:labledger/screens/ui_components/custom_outlined_button.dart';
import 'package:labledger/screens/ui_components/tinted_container.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

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
      baseColor: theme.colorScheme.secondary,
      intensity: 0.08,
      child: Column(
        children: [
          Expanded(
            child: SizedBox(
              width: double.infinity,
              child: CustomElevatedButton(
                onPressed: () {
                  navigatorKey.currentState?.push(
                    MaterialPageRoute(
                      builder: (context) => IncentiveDetailScreen(),
                    ),
                  );
                },
                backgroundColor: theme.colorScheme.secondary,
                icon: Icon(LucideIcons.file_text),
                label: "Generate Report",
              ),
            ),
          ),
          SizedBox(height: defaultHeight / 2),
          Expanded(
            child: SizedBox(
              width: double.infinity,
              child: CustomOutlinedButton(
                onPressed: () => _clearFilters(ref),
                icon: Icon(LucideIcons.rotate_ccw),
                label: "Clear Filters",
              ),
            ),
          ),
        ],
      ),
    );
  }
}
