import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/screens/ui_components/window_scaffold.dart';
import 'package:labledger/screens/ui_components/tinted_container.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:labledger/screens/incentives/components/quick_stats_panel.dart';
import 'package:labledger/screens/incentives/components/action_panel.dart';
import 'package:labledger/screens/incentives/components/filter_components.dart';
import 'package:labledger/screens/incentives/methods/incentive_methods.dart';

class IncentiveGenerationScreen extends ConsumerStatefulWidget {
  const IncentiveGenerationScreen({super.key});

  @override
  ConsumerState<IncentiveGenerationScreen> createState() =>
      _IncentiveGenerationScreenState();
}

class _IncentiveGenerationScreenState
    extends ConsumerState<IncentiveGenerationScreen> {
  late final IncentiveMethods _methods;

  @override
  void initState() {
    super.initState();
    _methods = IncentiveMethods(context, ref);
    _methods.initializeData();
    _methods.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _methods.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return WindowScaffold(
      child: Padding(
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Section
            Expanded(
              flex: 2,
              child: TintedContainer(
                baseColor: theme.colorScheme.secondary,
                radius: 24,
                intensity: 0.08,
                useGradient: true,
                elevationLevel: 2,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.secondary,
                            theme.colorScheme.secondary.withValues(alpha: 0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.secondary.withValues(
                              alpha: 0.3,
                            ),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        LucideIcons.file_text,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Generate Incentive Report",
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Configure filters and generate detailed incentive reports",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.7,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: defaultHeight),

            // Date Range Section
            Expanded(
              flex: 3,
              child: TintedContainer(
                baseColor: theme.colorScheme.secondary,
                intensity: 0.08,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          LucideIcons.calendar,
                          size: 20,
                          color: theme.colorScheme.secondary,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Date Range",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: defaultHeight),
                    Expanded(child: const IncentiveDateRangePicker()),
                  ],
                ),
              ),
            ),
            SizedBox(height: defaultHeight),

            // Filters Grid
            Expanded(flex: 5, child: const IncentiveFilterPanel()),

            SizedBox(height: defaultHeight * 1.5),

            // Stats and Actions Row
            Expanded(
              flex: 3,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(flex: 3, child: QuickStatsPanel()),
                  SizedBox(width: defaultWidth),
                  Expanded(flex: 2, child: ActionPanel()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


