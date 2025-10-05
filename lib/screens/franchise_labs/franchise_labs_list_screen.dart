import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/main.dart';
import 'package:labledger/models/franchise_model.dart';
import 'package:labledger/providers/franchise_provider.dart';
import 'package:labledger/screens/franchise_labs/franchise_edit_screen.dart';
import 'package:labledger/screens/franchise_labs/franchise_lab_bills_list_screen.dart';
import 'package:labledger/screens/initials/window_scaffold.dart';
import 'package:labledger/screens/ui_components/tinted_container.dart';
import 'package:lucide_icons/lucide_icons.dart';

extension ColorValues on Color {
  Color withValues({double? alpha, double? red, double? green, double? blue}) {
    Color updatedColor = this;
    if (alpha != null) {
      updatedColor = updatedColor.withAlpha((alpha * 255).round());
    }
    if (red != null) {
      updatedColor = updatedColor.withRed((red * 255).round());
    }
    if (green != null) {
      updatedColor = updatedColor.withGreen((green * 255).round());
    }
    if (blue != null) {
      updatedColor = updatedColor.withBlue((blue * 255).round());
    }
    return updatedColor;
  }
}

class FranchiseListScreen extends ConsumerWidget {
  const FranchiseListScreen({super.key, this.baseColor});

  final Color? baseColor;
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

  double getChildAspectRatio(BuildContext context) {
    final size = MediaQuery.of(context).size;

    if (size.width < initialWindowWidth && size.width > 1200) {
      return 2.3;
    }
    if (size.width < 1200 || size.width > initialWindowWidth) {
      return 2.7;
    }

    return 2.3;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveColor = baseColor ?? colorScheme.secondary;
    final franchisesAsync = ref.watch(franchiseProvider);

    return WindowScaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: baseColor ?? Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(defaultRadius),
        ),
        onPressed: () async {
          navigatorKey.currentState?.push(
            MaterialPageRoute(builder: (context) => FranchiseEditScreen()),
          );
        },
        label: const Text(
          "Add Franchise Lab", // Updated Label
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        icon: const Icon(LucideIcons.plus),
      ),
      child: franchisesAsync.when(
        data: (franchises) =>
            _buildFranchiseList(context, ref, franchises, effectiveColor),
        loading: () => _buildLoadingState(context, effectiveColor),
        error: (error, stack) =>
            _buildErrorState(context, ref, error, effectiveColor),
      ),
    );
  }

  Widget _buildFranchiseList(
    BuildContext context,
    WidgetRef ref,
    List<FranchiseName> franchises, // Updated model type
    Color effectiveColor,
  ) {
    if (franchises.isEmpty) {
      return _buildEmptyState(context, effectiveColor);
    }

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: getCrossAxisCount(context),
        crossAxisSpacing: defaultPadding,
        mainAxisSpacing: defaultPadding,
        childAspectRatio: getChildAspectRatio(context),
      ),
      itemCount: franchises.length,
      itemBuilder: (context, index) {
        return _buildFranchiseCard(
          context,
          franchises[index],
          effectiveColor,
          () {
            navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (context) {
                  return FranchiseBillsListScreen(id: franchises[index].id!);
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFranchiseCard(
    BuildContext context,
    FranchiseName franchise, // Updated model type
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
                _getInitials(
                  franchise.franchiseName,
                ), // Using new initials logic
                style: theme.textTheme.titleMedium?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: defaultWidth),
            // Use Expanded to prevent text overflow issues with long names/addresses
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    franchise.franchiseName ?? 'Unnamed Lab',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      fontSize: 22,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (franchise.address != null &&
                      franchise.address!.isNotEmpty) ...[
                    Text(
                      franchise.address!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: textColor,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (franchise.phoneNumber != null &&
                      franchise.phoneNumber!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(LucideIcons.phone, size: 16, color: textColor),
                        const SizedBox(width: 4),
                        Text(
                          franchise.phoneNumber!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: textColor,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
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
          child: _buildSkeletonLoader(context, shimmerColor),
        );
      },
    );
  }

  Widget _buildSkeletonLoader(BuildContext context, Color shimmerColor) {
    // This is identical to the DoctorsListScreen skeleton loader
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        CircleAvatar(radius: 40, backgroundColor: shimmerColor),
        SizedBox(width: defaultWidth),
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
    final colorScheme = theme.colorScheme;

    return Center(
      child: TintedContainer(
        baseColor: Colors.red,
        intensity: 0.1,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: defaultPadding),
            Text(
              'Failed to load franchise labs', // Updated text
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: defaultPadding),
            ElevatedButton.icon(
              onPressed: () {
                ref.invalidate(
                  franchiseProvider,
                ); // Invalidate correct provider
              },
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
        baseColor: effectiveColor,
        intensity: 0.08,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.building,
              size: 64,
              color: effectiveColor,
            ), // Updated Icon
            SizedBox(height: defaultPadding),
            Text(
              'No franchise labs found', // Updated Text
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first franchise lab to get started', // Updated Text
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: defaultPadding),
            ElevatedButton.icon(
              onPressed: () {
                navigatorKey.currentState?.push(
                  MaterialPageRoute(
                    builder: (context) {
                      return FranchiseEditScreen();
                    },
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Franchise Lab'), // Updated Text
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

  // Helper method to get initials from the franchise name
  String _getInitials(String? name) {
    if (name == null || name.isEmpty) {
      return '??';
    }
    // Split the name by spaces to get words
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      // Return the first letter of the first two words
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else {
      // If only one word, return the first two letters
      return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
    }
  }
}
