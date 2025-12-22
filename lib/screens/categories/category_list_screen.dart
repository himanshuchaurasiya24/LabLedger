import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/main.dart';
import 'package:labledger/models/diagnosis_category_model.dart';
import 'package:labledger/providers/category_provider.dart';
import 'package:labledger/providers/authentication_provider.dart';
import 'package:labledger/screens/categories/category_edit_screen.dart';
import 'package:labledger/screens/initials/window_scaffold.dart';
import 'package:labledger/screens/ui_components/custom_elevated_button.dart';
import 'package:labledger/screens/ui_components/tinted_container.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CategoryListScreen extends ConsumerWidget {
  const CategoryListScreen({super.key, this.baseColor});

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
      return 2.2; // Decreased from 2.7 for more height
    }
    if (size.width < 1200 || size.width > initialWindowWidth) {
      return 2.5; // Decreased from 3.2 for more height
    }
    return 2.2; // Decreased from 2.7 for more height
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveColor = baseColor ?? colorScheme.secondary;
    final categoriesAsync = ref.watch(categoriesProvider);

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
            MaterialPageRoute(builder: (context) => const CategoryEditScreen()),
          );
        },
        label: const Text(
          "Add Category",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        icon: const Icon(LucideIcons.plus),
      ),
      child: categoriesAsync.when(
        data: (categories) =>
            _buildCategoryList(context, ref, categories, effectiveColor),
        loading: () => _buildLoadingState(context, effectiveColor),
        error: (error, stack) =>
            _buildErrorState(context, ref, error, effectiveColor),
      ),
    );
  }

  Widget _buildCategoryList(
    BuildContext context,
    WidgetRef ref,
    List<DiagnosisCategory> categories,
    Color effectiveColor,
  ) {
    if (categories.isEmpty) {
      return _buildEmptyState(context, effectiveColor);
    }

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: getCrossAxisCount(context),
        crossAxisSpacing: defaultPadding,
        mainAxisSpacing: defaultPadding,
        childAspectRatio: getChildAspectRatio(context),
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        return _buildCategoryCard(
          context,
          ref,
          categories[index],
          effectiveColor,
        );
      },
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    WidgetRef ref,
    DiagnosisCategory category,
    Color effectiveColor,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : effectiveColor;
    final authState = ref.watch(currentUserProvider);
    final isAdmin = authState.value?.isAdmin ?? false;

    return TintedContainer(
      baseColor: effectiveColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(defaultRadius),
        onTap: isAdmin
            ? () {
                navigatorKey.currentState?.push(
                  MaterialPageRoute(
                    builder: (context) =>
                        CategoryEditScreen(category: category),
                  ),
                );
              }
            : null,
        child: Padding(
          padding: EdgeInsets.all(defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: effectiveColor.withValues(alpha: 0.2),
                    child: Icon(
                      category.isFranchiseLab
                          ? LucideIcons.building2
                          : LucideIcons.activity,
                      color: textColor,
                      size: 26,
                    ),
                  ),
                  SizedBox(width: defaultWidth),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: textColor,
                            fontSize: 20,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (category.description != null &&
                            category.description!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            category.description!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: textColor.withValues(alpha: 0.7),
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (category.isFranchiseLab)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: effectiveColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: effectiveColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.building2, size: 14, color: textColor),
                      const SizedBox(width: 6),
                      Text(
                        'Franchise Lab',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
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
    return Padding(
      padding: EdgeInsets.all(defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              CircleAvatar(radius: 28, backgroundColor: shimmerColor),
              SizedBox(width: defaultWidth),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 20,
                    width: 120,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 14,
                    width: 180,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
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
        baseColor: colorScheme.error,
        intensity: 0.1,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: colorScheme.error),
            SizedBox(height: defaultPadding),
            Text(
              'Failed to load categories',
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
                ref.invalidate(categoriesProvider);
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
        height: 400,
        width: 400,
        baseColor: effectiveColor,
        intensity: 0.08,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.tags, size: 94, color: effectiveColor),
            SizedBox(height: defaultPadding),
            Text(
              'No categories found',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first category to get started',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            CustomElevatedButton(
              width: double.infinity,
              onPressed: () {
                navigatorKey.currentState?.push(
                  MaterialPageRoute(
                    builder: (context) => const CategoryEditScreen(),
                  ),
                );
              },
              label: "Add Category",
              backgroundColor: effectiveColor,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}
