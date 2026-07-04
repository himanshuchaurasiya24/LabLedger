import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/main.dart';
import 'package:labledger/models/franchise_model.dart';
import 'package:labledger/providers/franchise_lab_provider.dart';
import 'package:labledger/screens/franchise_labs/franchise_edit_screen.dart';
import 'package:labledger/screens/franchise_labs/franchise_lab_bills_list_screen.dart';
import 'package:labledger/screens/ui_components/window_scaffold.dart';
import 'package:labledger/methods/custom_methods.dart';
import 'package:labledger/screens/ui_components/custom_empty_state_widget.dart';
import 'package:labledger/screens/ui_components/tinted_container.dart';
import 'package:labledger/screens/franchise_labs/methods/franchise_lab_methods.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:labledger/utils/controller_disposer.dart';
import 'package:labledger/screens/ui_components/shared_components.dart';
import 'package:labledger/methods/responsive_helpers.dart';
import 'package:labledger/screens/ui_components/skeleton_loaders.dart';
import 'package:labledger/methods/string_utils.dart';

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

class FranchiseListScreen extends ConsumerStatefulWidget {
  const FranchiseListScreen({super.key, this.baseColor});

  final Color? baseColor;

  @override
  ConsumerState<FranchiseListScreen> createState() =>
      _FranchiseListScreenState();
}

class _FranchiseListScreenState extends ConsumerState<FranchiseListScreen>
    with ControllerDisposer {
  late final TextEditingController searchController;
  final FocusNode searchFocusNode = FocusNode();
  late final FranchiseLabMethods _methods;

  @override
  void initState() {
    super.initState();
    _methods = FranchiseLabMethods(context, ref);
    _methods.addListener(() {
      if (mounted) setState(() {});
    });
    searchController = createController();
    searchFocusNode.requestFocus();
  }

  @override
  void dispose() {
    _methods.dispose();
    disposeControllers();
    searchFocusNode.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveColor = widget.baseColor ?? colorScheme.secondary;
    final franchisesAsync = ref.watch(franchiseProvider);

    return WindowScaffold(
      centerWidget: CenterSearchBar(
        controller: searchController,
        searchFocusNode: searchFocusNode,
        hintText: "Search Franchise Labs...",
        width: 400,
        onSearch: _methods.onSearchChanged,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor:
            widget.baseColor ?? Theme.of(context).colorScheme.primary,
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
        data: (franchises) {
          final filteredFranchises = _methods.filterFranchises(franchises);
          return _buildFranchiseList(
            context,
            ref,
            filteredFranchises,
            effectiveColor,
          );
        },
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
      return buildEmptyState(
        context: context,
        onAddPressed: () {
          navigatorKey.currentState?.push(
            MaterialPageRoute(builder: (context) => FranchiseEditScreen()),
          );
        },
        title: "No Franchise Labs Found",
        subtitle: "Try adjusting your search or add a new franchise lab.",
        label: "Add Franchise Lab",
        effectiveColor: effectiveColor,
        icon: LucideIcons.building,
      );
    }

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: getResponsiveCrossAxisCount(context),
        crossAxisSpacing: defaultPadding,
        mainAxisSpacing: defaultPadding,
        childAspectRatio: getResponsiveAspectRatio(context),
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
      onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: effectiveColor.withValues(alpha: 0.2),
              child: Text(
                getInitials(
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
                    const SizedBox(height: minimalPadding),
                    Row(
                      children: [
                        Icon(LucideIcons.phone, size: 16, color: textColor),
                        const SizedBox(width: minimalPadding),
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
    );
  }

  Widget _buildLoadingState(BuildContext context, Color effectiveColor) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final shimmerColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: getResponsiveCrossAxisCount(context),
        crossAxisSpacing: defaultPadding,
        mainAxisSpacing: defaultPadding,
        childAspectRatio: getResponsiveAspectRatio(context),
      ),
      itemCount: 8,
      itemBuilder: (context, index) {
        return TintedContainer(
          baseColor: effectiveColor,
          intensity: 0.05,
          child: buildEntitySkeletonLoader(context, shimmerColor),
        );
      },
    );
  }



  Widget _buildErrorState(
    BuildContext context,
    WidgetRef ref,
    Object error,
    Color effectiveColor,
  ) {
    return CustomErrorState(error: error, onTap: () => ref.invalidate(franchiseProvider), errorHeading: 'Failed to load franchise labs', errorTitle: error.toString(), buttonLabel: 'Retry', icon: const Icon(Icons.refresh));
  }

}
