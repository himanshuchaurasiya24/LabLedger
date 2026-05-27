import 'package:flutter/material.dart';
import 'package:labledger/screens/ui_components/app_inkwell.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/main.dart';
import 'package:labledger/models/diagnosis_type_model.dart';
import 'package:labledger/providers/diagnosis_type_provider.dart';
import 'package:labledger/screens/diagnosis_types/diagnosis_type_bills_list_screen.dart';
import 'package:labledger/screens/diagnosis_types/diagnosis_type_edit_screen.dart';
import 'package:labledger/screens/initials/window_scaffold.dart';
import 'package:labledger/methods/custom_methods.dart';
import 'package:labledger/screens/ui_components/custom_empty_state_widget.dart';
import 'package:labledger/screens/ui_components/custom_error_state_widget.dart';
import 'package:labledger/screens/ui_components/tinted_container.dart';
import 'package:labledger/methods/responsive_helpers.dart';
import 'package:labledger/methods/string_utils.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:labledger/utils/controller_disposer.dart';

class DiagnosisTypesListScreen extends ConsumerStatefulWidget {
  const DiagnosisTypesListScreen({super.key, this.baseColor});

  final Color? baseColor;

  @override
  ConsumerState<DiagnosisTypesListScreen> createState() =>
      _DiagnosisTypesListScreenState();
}

class _DiagnosisTypesListScreenState
    extends ConsumerState<DiagnosisTypesListScreen>
    with ControllerDisposer {
  late final TextEditingController searchController;
  final FocusNode searchFocusNode = FocusNode();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    searchController = createController();
    searchFocusNode.requestFocus();
  }

  @override
  void dispose() {
    disposeControllers();
    searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  List<DiagnosisType> _filterDiagnosisTypes(List<DiagnosisType> types) {
    if (_searchQuery.isEmpty) return types;

    return types.where((type) {
      final name = type.name.trim().toLowerCase().replaceAll(
        RegExp(r'\s+'),
        ' ',
      );
      final categoryName = (type.categoryName ?? '')
          .trim()
          .toLowerCase()
          .replaceAll(RegExp(r'\s+'), ' ');
      final price = type.price.toString();

      return name.contains(_searchQuery) ||
          categoryName.contains(_searchQuery) ||
          price.contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveColor = widget.baseColor ?? colorScheme.secondary;
    final diagnosisTypesAsync = ref.watch(diagnosisTypeProvider);

    return WindowScaffold(
      centerWidget: CenterSearchBar(
        controller: searchController,
        searchFocusNode: searchFocusNode,
        hintText: "Search Diagnosis Types...",
        width: 400,
        onSearch: _onSearchChanged,
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
        data: (types) {
          final filteredTypes = _filterDiagnosisTypes(types);
          return _buildDiagnosisTypeList(
            context,
            ref,
            filteredTypes,
            effectiveColor,
          );
        },
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
        crossAxisCount: getResponsiveCrossAxisCount(context),
        crossAxisSpacing: defaultPadding,
        mainAxisSpacing: defaultPadding,
        childAspectRatio: getResponsiveAspectRatio(
          context,
          baseSmall: 2.0,
          baseLarge: 2.4,
        ),
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
      child: AppInkWell(
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
                getInitials(diagnosis.name),
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
        crossAxisCount: getResponsiveCrossAxisCount(context),
        crossAxisSpacing: defaultPadding,
        mainAxisSpacing: defaultPadding,
        childAspectRatio: getResponsiveAspectRatio(
          context,
          baseSmall: 2.0,
          baseLarge: 2.4,
        ),
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
    return buildErrorState(
      context: context,
      error: error,
      theme: theme,
      onTap: () => ref.invalidate(diagnosisTypeProvider),
      errorHeading: 'Failed to load diagnosis types',
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
          MaterialPageRoute(
            builder: (context) {
              return DiagnosisTypeEditScreen();
            },
          ),
        );
      },
      title: 'No diagnosis type found',
      subtitle: 'Add a diagnosis type to get started',
      icon: FontAwesomeIcons.microscope,
      label: 'Add a diagnosis type',
    );
  }
}
