import 'package:flutter/material.dart';
import 'package:labledger/screens/ui_components/app_inkwell.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/main.dart';
import 'package:labledger/models/diagnosis_category_model.dart';
import 'package:labledger/providers/category_provider.dart';
import 'package:labledger/providers/authentication_provider.dart';
import 'package:labledger/screens/categories/category_edit_screen.dart';
import 'package:labledger/screens/ui_components/window_scaffold.dart';
import 'package:labledger/methods/custom_methods.dart';
import 'package:labledger/screens/categories/methods/category_methods.dart';
import 'package:labledger/screens/ui_components/custom_empty_state_widget.dart';
import 'package:labledger/screens/ui_components/custom_error_state_widget.dart';
import 'package:labledger/screens/ui_components/tinted_container.dart';
import 'package:labledger/screens/ui_components/status_badge.dart';
import 'package:labledger/methods/responsive_helpers.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:labledger/utils/controller_disposer.dart';

class CategoryListScreen extends ConsumerStatefulWidget {
  const CategoryListScreen({super.key, this.baseColor});

  final Color? baseColor;

  @override
  ConsumerState<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends ConsumerState<CategoryListScreen>
    with ControllerDisposer {
  late final TextEditingController searchController;
  final FocusNode searchFocusNode = FocusNode();
  late CategoryMethods _methods;

  @override
  void initState() {
    super.initState();
    _methods = CategoryMethods(context, ref);
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
    final categoriesAsync = ref.watch(categoriesProvider);

    return WindowScaffold(
      centerWidget: CenterSearchBar(
        controller: searchController,
        searchFocusNode: searchFocusNode,
        hintText: "Search Categories...",
        width: 400,
        onSearch: _methods.onSearchChanged,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: widget.baseColor ?? colorScheme.primary,
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
        data: (categories) {
          final filteredCategories = _methods.filterCategories(categories);
          return _buildCategoryList(
            context,
            ref,
            filteredCategories,
            effectiveColor,
          );
        },
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
        crossAxisCount: getResponsiveCrossAxisCount(context),
        crossAxisSpacing: defaultPadding,
        mainAxisSpacing: defaultPadding,
        childAspectRatio: getResponsiveAspectRatio(
          context,
          baseSmall: 2.2,
          baseLarge: 2.5,
        ),
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
      child: AppInkWell(
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
                          ? LucideIcons.building_2
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
                StatusBadge(
                  text: 'Franchise Lab',
                  color: textColor,
                  icon: LucideIcons.building_2,
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
        crossAxisCount: getResponsiveCrossAxisCount(context),
        crossAxisSpacing: defaultPadding,
        mainAxisSpacing: defaultPadding,
        childAspectRatio: getResponsiveAspectRatio(
          context,
          baseSmall: 2.2,
          baseLarge: 2.5,
        ),
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

    return buildErrorState(
      context: context,
      error: error,
      theme: theme,
      onTap: () => ref.invalidate(categoriesProvider),
      errorHeading: 'Failed to load categories',
      errorTitle: error.toString(),
      buttonLabel: 'Retry',
      icon: const Icon(Icons.refresh),
    );
  }

  Widget _buildEmptyState(BuildContext context, Color effectiveColor) {
    return buildEmptyState(
      context: context,
      effectiveColor: effectiveColor,
      onAddPressed: () {
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (context) => const CategoryEditScreen()),
        );
      },
      title: 'No categories found',
      subtitle: 'Add your first category to get started',
      icon: LucideIcons.tags,
      label: 'Add Category',
    );
  }
}
