import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/main.dart';
import 'package:labledger/models/diagnosis_type_model.dart';
import 'package:labledger/providers/diagnosis_type_provider.dart';
import 'package:labledger/screens/diagnosis_types/diagnosis_type_bills_list_screen.dart';
import 'package:labledger/screens/diagnosis_types/diagnosis_type_edit_screen.dart';
import 'package:labledger/screens/initials/window_scaffold.dart';
import 'package:labledger/screens/ui_components/custom_elevated_button.dart';
import 'package:labledger/screens/ui_components/tinted_container.dart';
import 'package:lucide_icons/lucide_icons.dart';

class DiagnosisTypesListScreen extends ConsumerWidget {
  const DiagnosisTypesListScreen({super.key, this.baseColor});

  final Color? baseColor;

  // Reusing the exact same responsive logic from previous screens
  int getCrossAxisCount(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if (size.width < initialWindowWidth && size.width > 1200) {
      return 3;
    }
    if (size.width < 1200) {
      return 2;
    }
    return 4;
  }

  // Reusing the exact same responsive logic
  double getChildAspectRatio(BuildContext context) {
    final size = MediaQuery.of(context).size;

    if (size.width < initialWindowWidth && size.width > 1200) {
      return 2.0; // Increased from 2.3
    }
    if (size.width < 1200 || size.width > initialWindowWidth) {
      return 2.4; // Increased from 2.7
    }

    return 2.0; // Increased from 2.3
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveColor = baseColor ?? colorScheme.secondary;
    // Watching the diagnosis type provider
    final diagnosisTypesAsync = ref.watch(diagnosisTypeProvider);

    return WindowScaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: baseColor ?? colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(defaultRadius),
        ),
        onPressed: () async {
          navigatorKey.currentState?.push(
            MaterialPageRoute(builder: (context) => DiagnosisTypeEditScreen()),
          );
        },
        label: const Text(
          "Add Diagnosis Type", // Updated Label
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        icon: const Icon(LucideIcons.plus),
      ),
      child: diagnosisTypesAsync.when(
        data: (types) =>
            _buildDiagnosisTypeList(context, ref, types, effectiveColor),
        loading: () => _buildLoadingState(context, effectiveColor),
        error: (error, stack) =>
            _buildErrorState(context, ref, error, effectiveColor),
      ),
    );
  }

  Widget _buildDiagnosisTypeList(
    BuildContext context,
    WidgetRef ref,
    List<DiagnosisType> types, // Updated model type
    Color effectiveColor,
  ) {
    if (types.isEmpty) {
      return _buildEmptyState(context, effectiveColor);
    }

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: getCrossAxisCount(context),
        crossAxisSpacing: defaultPadding,
        mainAxisSpacing: defaultPadding,
        childAspectRatio: getChildAspectRatio(context),
      ),
      itemCount: types.length,
      itemBuilder: (context, index) {
        return _buildDiagnosisTypeCard(
          context,
          types[index],
          effectiveColor,
          () {
            navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (context) {
                  return DiagnosisTypeBillsListScreen(id: types[index].id!);
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDiagnosisTypeCard(
    BuildContext context,
    DiagnosisType diagnosis, // Updated model type
    Color effectiveColor,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : effectiveColor;

    return TintedContainer(
      baseColor: effectiveColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(defaultRadius),
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: effectiveColor.withValues(alpha: 0.2),
              child: Text(
                _getInitials(diagnosis.name),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: defaultWidth),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    diagnosis.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      fontSize: 22,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    diagnosis.categoryName ?? 'Unknown',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: textColor,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${diagnosis.price}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context, Color effectiveColor) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final shimmerColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: getCrossAxisCount(context),
        crossAxisSpacing: defaultPadding,
        mainAxisSpacing: defaultPadding,
        childAspectRatio: getChildAspectRatio(context),
      ),
      itemCount: 8,
      itemBuilder: (context, index) {
        return TintedContainer(
          baseColor: effectiveColor,
          intensity: 0.05,
          child: _buildSkeletonLoader(shimmerColor),
        );
      },
    );
  }

  Widget _buildSkeletonLoader(Color shimmerColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        CircleAvatar(radius: 40, backgroundColor: shimmerColor),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 22,
              width: 180,
              decoration: BoxDecoration(
                color: shimmerColor,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 16,
              width: 150,
              decoration: BoxDecoration(
                color: shimmerColor,
                borderRadius: BorderRadius.circular(7),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    WidgetRef ref,
    Object error,
    Color effectiveColor,
  ) {
    final theme = Theme.of(context);
    return Center(
      child: TintedContainer(
        baseColor: Theme.of(context).colorScheme.error,
        intensity: 0.1,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            SizedBox(height: defaultPadding),
            Text(
              'Failed to load diagnosis types', // Updated text
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: defaultPadding),
            ElevatedButton.icon(
              onPressed: () => ref.invalidate(diagnosisTypeProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: effectiveColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, Color effectiveColor) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: TintedContainer(
        height: 400,
        width: 400,
        baseColor: effectiveColor,
        intensity: 0.08,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FontAwesomeIcons.microscope,
              size: 94,
              color: effectiveColor,
            ), // Updated Icon
            SizedBox(height: defaultPadding),
            Text(
              'No diagnosis type found', // Updated Text
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add a diagnosis type to get started', // Updated Text
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            Spacer(),
            CustomElevatedButton(
              width: double.infinity,
              onPressed: () {
                navigatorKey.currentState?.push(
                  MaterialPageRoute(
                    builder: (context) {
                      return DiagnosisTypeEditScreen();
                    },
                  ),
                );
              },
              label: "Add a diagnosis type",
              backgroundColor: effectiveColor,
              icon: Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '??';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else {
      return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
    }
  }
}
