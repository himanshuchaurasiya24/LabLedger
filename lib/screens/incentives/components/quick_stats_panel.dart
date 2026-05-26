import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/providers/incenitve_generator_provider.dart';
import 'package:labledger/screens/ui_components/tinted_container.dart';
import 'package:lucide_icons/lucide_icons.dart';

class QuickStatsPanel extends ConsumerWidget {
  const QuickStatsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDoctors = ref.watch(selectedDoctorIdsProvider);
    final selectedFranchises = ref.watch(selectedFranchiseIdsProvider);
    final selectedDiagnosisTypes = ref.watch(selectedDiagnosisTypeIdsProvider);
    final selectedBillStatuses = ref.watch(selectedBillStatusesProvider);
    final Color cardColor = Theme.of(context).colorScheme.secondary;

    return Row(
      children: [
        Expanded(
          child: StatCard(
            count: selectedDoctors.length,
            label: "Doctors",
            icon: LucideIcons.userCheck,
            color: cardColor,
          ),
        ),
        SizedBox(width: defaultWidth),
        Expanded(
          child: StatCard(
            count: selectedFranchises.length,
            label: "Labs",
            icon: LucideIcons.building,
            color: cardColor,
          ),
        ),
        SizedBox(width: defaultWidth),
        Expanded(
          child: StatCard(
            count: selectedDiagnosisTypes.length,
            label: "Types",
            icon: LucideIcons.clipboardList,
            color: cardColor,
          ),
        ),
        SizedBox(width: defaultWidth),
        Expanded(
          child: StatCard(
            count: selectedBillStatuses.length,
            label: "Statuses",
            icon: LucideIcons.creditCard,
            color: cardColor,
          ),
        ),
      ],
    );
  }
}

class StatCard extends StatelessWidget {
  final int count;
  final String label;
  final IconData icon;
  final Color color;

  const StatCard({
    super.key,
    required this.count,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TintedContainer(
      baseColor: color,
      height: 130,
      intensity: 0.08,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 8),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
