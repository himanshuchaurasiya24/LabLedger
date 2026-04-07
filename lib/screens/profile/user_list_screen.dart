import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/main.dart';
import 'package:labledger/models/user_model.dart'; // Assuming your user model is here
import 'package:labledger/methods/custom_methods.dart';
import 'package:labledger/providers/user_provider.dart';
import 'package:labledger/screens/initials/window_scaffold.dart';
import 'package:labledger/screens/profile/user_edit_screen.dart';
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

class UserListScreen extends ConsumerStatefulWidget {
  const UserListScreen({super.key, required this.adminId});

  final int adminId;

  @override
  ConsumerState<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends ConsumerState<UserListScreen> {
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    searchFocusNode.requestFocus();
  }

  @override
  void dispose() {
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  List<User> _filterUsers(List<User> users) {
    if (_searchQuery.isEmpty) return users;

    return users.where((user) {
      final username = user.username.trim().toLowerCase().replaceAll(
        RegExp(r'\s+'),
        ' ',
      );
      final fullName = '${user.firstName} ${user.lastName}'
          .trim()
          .toLowerCase()
          .replaceAll(RegExp(r'\s+'), ' ');
      final firstName = user.firstName.trim().toLowerCase().replaceAll(
        RegExp(r'\s+'),
        ' ',
      );
      final lastName = user.lastName.trim().toLowerCase().replaceAll(
        RegExp(r'\s+'),
        ' ',
      );
      final email = user.email.trim().toLowerCase().replaceAll(
        RegExp(r'\s+'),
        ' ',
      );
      final phoneNumber = user.phoneNumber.trim().toLowerCase().replaceAll(
        RegExp(r'\s+'),
        ' ',
      );
      final address = user.address.trim().toLowerCase().replaceAll(
        RegExp(r'\s+'),
        ' ',
      );

      return username.contains(_searchQuery) ||
          fullName.contains(_searchQuery) ||
          firstName.contains(_searchQuery) ||
          lastName.contains(_searchQuery) ||
          email.contains(_searchQuery) ||
          phoneNumber.contains(_searchQuery) ||
          address.contains(_searchQuery);
    }).toList();
  }

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
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(usersDetailsProvider);
    return WindowScaffold(
      centerWidget: CenterSearchBar(
        controller: searchController,
        searchFocusNode: searchFocusNode,
        hintText: 'Search Users...',
        width: 400,
        onSearch: _onSearchChanged,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(defaultRadius),
        ),
        onPressed: () async {
          navigatorKey.currentState?.push(
            MaterialPageRoute(builder: (context) => UserAddEditScreen()),
          );
        },
        label: const Text(
          "Add User",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        icon: const Icon(LucideIcons.plus),
      ),
      child: usersAsync.when(
        data: (users) {
          final filteredUsers = _filterUsers(users);
          return _buildUsersList(context, ref, filteredUsers);
        },
        loading: () => _buildLoadingState(context),
        error: (error, stack) => _buildErrorState(context, ref, error),
      ),
    );
  }

  Widget _buildUsersList(
    BuildContext context,
    WidgetRef ref,
    List<User> users,
  ) {
    if (users.isEmpty) {
      return _buildEmptyState(context);
    }

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: getCrossAxisCount(context),
        crossAxisSpacing: defaultPadding,
        mainAxisSpacing: defaultPadding,
        childAspectRatio: getChildAspectRatio(context),
      ),
      itemCount: users.length,
      itemBuilder: (context, index) {
        return _buildUserCard(context, users[index]);
      },
    );
  }

  Widget _buildUserCard(BuildContext context, User user) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Card color turns red if the user is locked
    final cardColor = user.isLocked
        ? Colors.red.shade700
        : theme.colorScheme.secondary;

    // Identical text color logic from Doctors screen
    final textColor = isDark ? Colors.white : cardColor;

    return TintedContainer(
      baseColor: cardColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(defaultRadius),
        onTap: () {
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (context) {
                return UserAddEditScreen(targetUserId: user.id);
              },
            ),
          );
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: cardColor.withValues(alpha: 0.2),
              child: Text(
                _getInitials(user.firstName, user.lastName),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        user.username,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          fontSize: 22,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: cardColor.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(
                            defaultRadius * 2,
                          ),
                        ),
                        child: Text(
                          "${user.isAdmin ? "Admin" : "User"}${user.isLocked ? " (Locked)" : ""}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "${user.firstName} ${user.lastName}",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: textColor,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    user.phoneNumber,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: textColor,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    user.address,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: textColor,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final theme = Theme.of(context);
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
          baseColor: theme.colorScheme.secondary,
          intensity: 0.05,
          child: _buildSkeletonLoader(context),
        );
      },
    );
  }

  Widget _buildSkeletonLoader(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final shimmerColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(radius: 40, backgroundColor: shimmerColor),
        SizedBox(width: defaultPadding),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 22,
                width: 120,
                decoration: BoxDecoration(
                  color: shimmerColor,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 16,
                width: 180,
                decoration: BoxDecoration(
                  color: shimmerColor,
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object error) {
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
              'Failed to load users',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: defaultHeight),
            ElevatedButton.icon(
              onPressed: () => ref.invalidate(usersDetailsProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.secondary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = theme.colorScheme.secondary;

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
              'No users found',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: defaultHeight),
            ElevatedButton.icon(
              onPressed: () {
                /* Navigate to add user screen */
              },
              icon: const Icon(Icons.add),
              label: const Text('Add User'),
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
