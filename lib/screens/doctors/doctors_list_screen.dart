import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/models/doctors_model.dart';
import 'package:labledger/providers/doctor_provider.dart';
import 'package:labledger/screens/initials/window_scaffold.dart';
import 'package:labledger/screens/ui_components/tinted_container.dart';
import 'package:lucide_icons/lucide_icons.dart';

// Assuming ColorValues extension is defined elsewhere in your project
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

class DoctorsListScreen extends ConsumerWidget {
  const DoctorsListScreen({super.key, this.baseColor});

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
    final doctorsAsync = ref.watch(doctorsProvider);
    debugPrint(MediaQuery.of(context).size.width.toString());
    return WindowScaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: baseColor ?? Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(defaultRadius),
        ),
        onPressed: () async {
          // navigatorKey.currentState?.push(
          //   MaterialPageRoute(
          //     builder: (context) => AddBillScreen(
          //       themeColor: Theme.of(context).colorScheme.secondary,
          //     ),
          //   ),
          // );
        },
        label: const Text(
          "Add Doctor",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        icon: const Icon(LucideIcons.plus),
      ),
      child: doctorsAsync.when(
        data: (doctors) =>
            _buildDoctorsList(context, ref, doctors, effectiveColor),
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
      padding: EdgeInsets.all(defaultPadding),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: getCrossAxisCount(context),
        crossAxisSpacing: defaultPadding,
        mainAxisSpacing: defaultPadding,
        childAspectRatio: getChildAspectRatio(context),
      ),
      itemCount: doctors.length,
      itemBuilder: (context, index) {
        return _buildDoctorCard(context, doctors[index], effectiveColor);
      },
    );
  }

  Widget _buildDoctorCard(
    BuildContext context,
    Doctor doctor,
    Color effectiveColor,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // This is the identical color logic copied from UserListScreen
    final textColor = isDark ? Colors.white : effectiveColor;

    return TintedContainer(
      baseColor: effectiveColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(defaultRadius),
        onTap: () {
          // Navigate to doctor details
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: effectiveColor.withValues(alpha: 0.2),
              child: Text(
                _getInitials(doctor.firstName, doctor.lastName),
                style: theme.textTheme.titleMedium?.copyWith(
                  // Applied identical text color logic
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${doctor.firstName ?? ''} ${doctor.lastName ?? ''}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    // Applied identical text color logic
                    color: textColor,
                    fontSize: 22,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (doctor.hospitalName != null) ...[
                  Text(
                    doctor.hospitalName!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      // Applied identical text color logic
                      color: textColor,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (doctor.phoneNumber != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      // Icon color matches the text color logic
                      Icon(Icons.phone, size: 16, color: textColor),
                      const SizedBox(width: 4),
                      Text(
                        doctor.phoneNumber!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          // Applied identical text color logic
                          color: textColor,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
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
      padding: EdgeInsets.all(defaultPadding),
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
              'Failed to load doctors',
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
                ref.invalidate(doctorsProvider);
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
            Icon(Icons.person_add_outlined, size: 64, color: effectiveColor),
            SizedBox(height: defaultPadding),
            Text(
              'No doctors found',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first doctor to get started',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: defaultPadding),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to add doctor screen
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Doctor'),
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

  String _getInitials(String? firstName, String? lastName) {
    final first = firstName?.isNotEmpty == true
        ? firstName![0].toUpperCase()
        : '';
    final last = lastName?.isNotEmpty == true ? lastName![0].toUpperCase() : '';
    return '$first$last'.isEmpty ? '??' : '$first$last';
  }
}
