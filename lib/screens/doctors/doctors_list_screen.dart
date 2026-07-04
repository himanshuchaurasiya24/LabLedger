import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/main.dart';
import 'package:labledger/models/doctors_model.dart';
import 'package:labledger/providers/doctor_provider.dart';
import 'package:labledger/screens/doctors/doctor_dashboard_screen.dart';
import 'package:labledger/screens/doctors/doctor_edit_screen.dart';
import 'package:labledger/screens/ui_components/window_scaffold.dart';
import 'package:labledger/methods/custom_methods.dart';
import 'package:labledger/screens/ui_components/custom_empty_state_widget.dart';
import 'package:labledger/screens/ui_components/entity_summary_card.dart';
import 'package:labledger/screens/ui_components/tinted_container.dart';
import 'package:labledger/screens/doctors/methods/doctor_methods.dart';
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

class DoctorsListScreen extends ConsumerStatefulWidget {
  const DoctorsListScreen({super.key, this.baseColor});

  final Color? baseColor;

  @override
  ConsumerState<DoctorsListScreen> createState() => _DoctorsListScreenState();
}

class _DoctorsListScreenState extends ConsumerState<DoctorsListScreen>
    with ControllerDisposer {
  late final TextEditingController searchController;
  final FocusNode searchFocusNode = FocusNode();
  late final DoctorMethods _methods;

  @override
  void initState() {
    super.initState();
    _methods = DoctorMethods(context, ref);
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
    final doctorsAsync = ref.watch(doctorsProvider);
    return WindowScaffold(
      centerWidget: CenterSearchBar(
        controller: searchController,
        searchFocusNode: searchFocusNode,
        hintText: "Search Doctors...",
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
            MaterialPageRoute(
              builder: (context) => DoctorEditScreen(
                themeColor: Theme.of(context).colorScheme.secondary,
              ),
            ),
          );
        },
        label: const Text(
          "Add Doctor",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        icon: const Icon(LucideIcons.plus),
      ),
      child: doctorsAsync.when(
        data: (doctors) {
          final filteredDoctors = _methods.filterDoctors(doctors);
          return _buildDoctorsList(
            context,
            ref,
            filteredDoctors,
            effectiveColor,
          );
        },
        loading: () => _buildLoadingState(context, effectiveColor),
        error: (error, stack) =>
            _buildErrorState(context, ref, error, effectiveColor),
      ),
    );
  }

  Widget _buildDoctorsList(
    BuildContext context,
    WidgetRef ref,
    List<Doctor> doctors,
    Color effectiveColor,
  ) {
    if (doctors.isEmpty) {
      return _buildEmptyState(context, effectiveColor);
    }

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: getResponsiveCrossAxisCount(context),
        crossAxisSpacing: defaultPadding,
        mainAxisSpacing: defaultPadding,
        childAspectRatio: getResponsiveAspectRatio(context),
      ),
      itemCount: doctors.length,
      itemBuilder: (context, index) {
        return _buildDoctorCard(context, doctors[index], effectiveColor, () {
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (context) {
                return DoctorDashboardScreen(doctorId: doctors[index].id!);
              },
            ),
          );
        });
      },
    );
  }

  Widget _buildDoctorCard(
    BuildContext context,
    Doctor doctor,
    Color effectiveColor,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // This is the identical color logic copied from UserListScreen
    final textColor = isDark ? Colors.white : effectiveColor;

    return EntitySummaryCard(
      baseColor: effectiveColor,
      onTap: onTap,
      avatar: CircleAvatar(
        radius: 40,
        backgroundColor: effectiveColor.withValues(alpha: 0.2),
        child: Text(
          getInitials(doctor.firstName, doctor.lastName),
          style: theme.textTheme.titleMedium?.copyWith(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        '${doctor.firstName ?? ''} ${doctor.lastName ?? ''}',
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: textColor,
          fontSize: 22,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      details: [
        if (doctor.hospitalName != null)
          Text(
            doctor.hospitalName!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: textColor,
              fontSize: 16,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        if (doctor.phoneNumber != null) ...[
          const SizedBox(height: minimalPadding),
          Row(
            children: [
              Icon(Icons.phone, size: 16, color: textColor),
              const SizedBox(width: minimalPadding),
              Text(
                doctor.phoneNumber!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: textColor,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ],
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
    return CustomErrorState(error: error, onTap: () => ref.invalidate(doctorsProvider), errorHeading: 'Failed to load doctors', errorTitle: error.toString(), buttonLabel: 'Retry', icon: const Icon(Icons.refresh));
  }

  Widget _buildEmptyState(BuildContext context, Color effectiveColor) {
    return buildEmptyState(
      context: context,
      effectiveColor: effectiveColor,
      onAddPressed: () {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) {
              return DoctorEditScreen();
            },
          ),
        );
      },
      title: 'No doctors found',
      subtitle: 'Add a doctor to get started',
      icon: LucideIcons.stethoscope,
      label: 'Add a doctor',
    );
  }


}
