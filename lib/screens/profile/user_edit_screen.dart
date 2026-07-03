import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/models/user_model.dart';
import 'package:labledger/providers/authentication_provider.dart';
import 'package:labledger/providers/user_provider.dart';
import 'package:labledger/screens/ui_components/window_scaffold.dart';
import 'package:labledger/screens/ui_components/tinted_container.dart';
import 'package:labledger/screens/profile/methods/profile_methods.dart';
import 'package:labledger/screens/profile/components/user_form_components.dart';

class UserAddEditScreen extends ConsumerStatefulWidget {
  const UserAddEditScreen({super.key, this.targetUserId, this.baseColor});

  final int? targetUserId;
  final Color? baseColor;

  @override
  ConsumerState<UserAddEditScreen> createState() => _UserAddEditScreenState();
}

class _UserAddEditScreenState extends ConsumerState<UserAddEditScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ProfileMethods _methods;

  bool get _isEditMode => widget.targetUserId != null;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _methods = ProfileMethods(context, ref);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _methods.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get the admin status of the user currently logged into the app
    final currentUserIsAdmin =
        ref.watch(currentUserProvider).value?.isAdmin ?? false;

    final effectiveBaseColor =
        widget.baseColor ?? Theme.of(context).colorScheme.secondary;

    final content = _isEditMode
        ? ref
              .watch(singleUserDetailsProvider(widget.targetUserId!))
              .when(
                data: (user) {
                  _methods.initializeData(user);
                  return AnimatedBuilder(
                    animation: _methods,
                    builder: (context, _) => _buildContent(
                      effectiveBaseColor,
                      currentUserIsAdmin,
                      user: user,
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, st) =>
                    _buildErrorWidget('Failed to load user: $err'),
              )
        : AnimatedBuilder(
            animation: _methods,
            builder: (context, _) => _buildContent(effectiveBaseColor, currentUserIsAdmin),
          );

    return WindowScaffold(child: content);
  }

  Widget _buildContent(Color color, bool currentUserIsAdmin, {User? user}) {
    return Column(
      children: [
        // After
        _buildUserHeaderCard(color, currentUserIsAdmin, user),
        SizedBox(height: defaultHeight),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 900) {
                return _buildLargeScreenLayout(
                  color,
                  currentUserIsAdmin,
                  user: user,
                );
              } else {
                return Column(
                  children: [
                    _buildTabBar(color),
                    SizedBox(height: defaultHeight),
                    Expanded(
                      child: _buildTabContent(
                        color,
                        currentUserIsAdmin,
                        user: user,
                      ),
                    ),
                    SizedBox(height: defaultHeight),
                  ],
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUserHeaderCard(
    Color color,
    bool currentUserIsAdmin,
    User? user,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final title = _isEditMode
        ? '${user?.firstName ?? ''} ${user?.lastName ?? ''}'
        : 'New User Profile';
    final subtitle = _isEditMode
        ? user?.email ?? ''
        : 'Enter user details below';
    final initials = _isEditMode
        ? '${user?.firstName.isNotEmpty == true ? user!.firstName[0] : 'U'}${user?.lastName.isNotEmpty == true ? user!.lastName[0] : 'U'}'
        : 'NU';

    final lightThemeColor = Color.lerp(
      color,
      isDark ? Colors.black : Colors.white,
      isDark ? 0.3 : 0.2,
    )!;

    return TintedContainer(
      baseColor: color,
      height: 160,
      radius: defaultRadius,
      intensity: isDark ? 0.15 : 0.08,
      useGradient: true,
      elevationLevel: 2,
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [color, lightThemeColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: defaultWidth / 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? Colors.white70
                        : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                SizedBox(height: defaultHeight / 2),
                _buildStatusBadge(
                  _isEditMode ? 'Edit Mode' : 'Create Mode',
                  _isEditMode
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.secondary,
                ),
              ],
            ),
          ),
          // ✅ CORRECTED LOGIC: The Column is now always visible.
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _methods.isSaving ? null : () async {
                  bool success = await _methods.handleSave(user, _isEditMode, currentUserIsAdmin, widget.targetUserId);
                  if (!success && mounted) {
                    final detailsValid = _methods.detailsFormKey.currentState?.validate() ?? false;
                    if (!detailsValid) {
                      _tabController.animateTo(0);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size(180, 60),
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(defaultRadius),
                  ),
                ),
                icon: _methods.isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(_isEditMode ? Icons.update : Icons.save),
                label: Text(
                  _methods.isSaving
                      ? 'Saving...'
                      : (_isEditMode ? 'Update User' : 'Create User'),
                ),
              ),
              // ✅ The delete button's visibility is the only part that is conditional.
              if (_isEditMode && currentUserIsAdmin) ...[
                SizedBox(height: defaultHeight / 2),
                OutlinedButton.icon(
                  onPressed: _methods.isDeleting ? null : () => _methods.handleDelete(user!),
                  style: OutlinedButton.styleFrom(
                    fixedSize: const Size(180, 60),
                    foregroundColor: theme.colorScheme.error,
                    side: BorderSide(color: theme.colorScheme.error),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(defaultRadius),
                    ),
                  ),
                  icon: _methods.isDeleting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.delete_outline),
                  label: const Text('Delete'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(Color color) {
    return TabBar(
      controller: _tabController,
      indicator: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      indicatorSize: TabBarIndicatorSize.tab,
      labelColor: Colors.white,
      dividerColor: Colors.transparent,
      tabs: const [
        Tab(
          height: 44,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_outline, size: 18),
              SizedBox(width: 8),
              Text('Personal Details'),
            ],
          ),
        ),
        Tab(
          height: 44,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.security, size: 18),
              SizedBox(width: 8),
              Text('Security'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabContent(Color color, bool currentUserIsAdmin, {User? user}) {
    return TabBarView(
      controller: _tabController,
      children: [
        UserPersonalDetailsCard(methods: _methods, color: color),
        UserSecurityCard(
          methods: _methods,
          color: color,
          currentUserIsAdmin: currentUserIsAdmin,
          isEditMode: _isEditMode,
          user: user,
        ),
      ],
    );
  }

  Widget _buildLargeScreenLayout(
    Color color,
    bool currentUserIsAdmin, {
    User? user,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: UserPersonalDetailsCard(methods: _methods, color: color)),
        SizedBox(width: defaultWidth),
        Expanded(child: UserSecurityCard(
          methods: _methods,
          color: color,
          currentUserIsAdmin: currentUserIsAdmin,
          isEditMode: _isEditMode,
          user: user,
        )),
      ],
    );
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }


  Widget _buildErrorWidget(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            SizedBox(height: defaultHeight),
            Text('Error Loading User', style: TextStyle(fontSize: 20)),
            SizedBox(height: defaultHeight / 2),
            Text(message, textAlign: TextAlign.center),
            SizedBox(height: defaultHeight),
            ElevatedButton.icon(
              onPressed: () {
                if (widget.targetUserId != null) {
                  ref.invalidate(
                    singleUserDetailsProvider(widget.targetUserId!),
                  );
                }
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
