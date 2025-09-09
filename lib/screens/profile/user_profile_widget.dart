import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/main.dart';
import 'package:labledger/models/auth_response_model.dart';
import 'package:labledger/providers/theme_providers.dart';
import 'package:labledger/screens/profile/user_edit_screen.dart';

class UserProfileWidget extends ConsumerStatefulWidget {
  final AuthResponse authResponse;
  final Color baseColor;
  final VoidCallback onLogout;
  final VoidCallback? onSettings; // Optional settings callback

  const UserProfileWidget({
    super.key,
    required this.authResponse,
    required this.baseColor,
    required this.onLogout,
    this.onSettings,
  });

  @override
  ConsumerState<UserProfileWidget> createState() => _UserProfileWidgetState();
}

class _UserProfileWidgetState extends ConsumerState<UserProfileWidget> {
  bool _isThemeExpanded = false;
  OverlayEntry? _overlayEntry;

  void _showCustomMenu(BuildContext context) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => _CustomDropdownMenu(
        offset: offset,
        size: size,
        onDismiss: _removeOverlay,
        authResponse: widget.authResponse,
        baseColor: widget.baseColor,
        onLogout: widget.onLogout,
        onSettings: widget.onSettings,
        isThemeExpanded: _isThemeExpanded,
        onThemeToggle: () {
          setState(() {
            _isThemeExpanded = !_isThemeExpanded;
          });
          _updateOverlay();
        },
        onThemeSelect: (themeMode) {
          ref.read(themeNotifierProvider.notifier).toggleTheme(themeMode);
          _removeOverlay();
        },
        onSettingsTap: () {
          _removeOverlay();
          if (widget.onSettings != null) {
            widget.onSettings!();
          } else {
            _showComingSoon(context, 'Settings');
          }
        },
        onLogoutTap: () {
          _removeOverlay();
          _showLogoutConfirmation(context);
        },
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _updateOverlay() {
    _removeOverlay();
    _showCustomMenu(context);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    // Extract data for clarity
    final String userName =
        "${widget.authResponse.firstName} ${widget.authResponse.lastName}";
    final String initials = _getInitials(userName);

    return GestureDetector(
      onTap: () => _showCustomMenu(context),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: widget.baseColor.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: CircleAvatar(
          radius: 22,
          backgroundColor: widget.baseColor,
          child: Text(
            initials,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to get user initials
  String _getInitials(String name) {
    List<String> names = name.trim().split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    } else if (names.length == 1 && names[0].isNotEmpty) {
      return names[0][0].toUpperCase();
    }
    return widget.authResponse.username[0].toUpperCase();
  }

  // Show logout confirmation dialog
  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
          title: Row(
            children: [
              Icon(Icons.logout_rounded, color: Colors.red.shade600, size: 24),
              const SizedBox(width: 12),
              Text(
                'Logout',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.grey.shade800,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: TextStyle(
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onLogout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Logout',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  // Show coming soon message
  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature screen coming soon!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: widget.baseColor,
      ),
    );
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }
}

class _CustomDropdownMenu extends ConsumerWidget {
  final Offset offset;
  final Size size;
  final VoidCallback onDismiss;
  final AuthResponse authResponse;
  final Color baseColor;
  final VoidCallback onLogout;
  final VoidCallback? onSettings;
  final bool isThemeExpanded;
  final VoidCallback onThemeToggle;
  final Function(ThemeMode) onThemeSelect;
  final VoidCallback onSettingsTap;
  final VoidCallback onLogoutTap;

  const _CustomDropdownMenu({
    required this.offset,
    required this.size,
    required this.onDismiss,
    required this.authResponse,
    required this.baseColor,
    required this.onLogout,
    this.onSettings,
    required this.isThemeExpanded,
    required this.onThemeToggle,
    required this.onThemeSelect,
    required this.onSettingsTap,
    required this.onLogoutTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentThemeMode = ref.watch(themeNotifierProvider);

    final String userName =
        "${authResponse.firstName} ${authResponse.lastName}";
    final String userRole = authResponse.isAdmin ? "Admin" : "User";
    final String initials = _getInitials(userName);

    return GestureDetector(
      onTap: onDismiss,
      child: Container(
        color: Colors.transparent,
        child: Stack(
          children: [
            Positioned(
              left: offset.dx - 230 + size.width,
              top: offset.dy + size.height + 8,
              child: Material(
                elevation: 8,
                shadowColor: Colors.black.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
                color: isDark ? Colors.grey.shade900 : Colors.white,
                child: Container(
                  width: 250,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? Colors.grey.shade700
                          : Colors.grey.shade300,
                      width: 0.5,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // User Info Header
                      GestureDetector(
                        onTap: () {
                          navigatorKey.currentState?.push(
                            MaterialPageRoute(
                              builder: (context) {
                                return UserEditScreen(currentUserId: authResponse.id);
                              },
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: baseColor,
                                    child: Text(
                                      initials,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          userName,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                            color: isDark
                                                ? Colors.white
                                                : Colors.grey.shade800,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: baseColor.withValues(
                                              alpha: 0.1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: baseColor.withValues(
                                                alpha: 0.3,
                                              ),
                                            ),
                                          ),
                                          child: Text(
                                            userRole,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: baseColor,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                authResponse.centerDetail.centerName,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),

                      Divider(
                        height: 20,
                        color: isDark
                            ? Colors.grey.shade700
                            : Colors.grey.shade300,
                      ),

                      // Settings Option
                      _buildMenuItem(
                        icon: Icons.settings_outlined,
                        label: 'Settings',
                        onTap: onSettingsTap,
                        isDark: isDark,
                      ),

                      // Theme Header (Clickable)
                      _buildMenuItem(
                        icon: Icons.palette_outlined,
                        label: 'Theme',
                        onTap: onThemeToggle,
                        isDark: isDark,
                        trailing: AnimatedRotation(
                          turns: isThemeExpanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            size: 20,
                            color: isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                          ),
                        ),
                      ),

                      // Theme Options (Conditionally shown with proper animation)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        height: isThemeExpanded
                            ? 144
                            : 0, // 3 options × 48px each
                        child: ClipRect(
                          child: isThemeExpanded
                              ? Column(
                                  children: [
                                    _buildThemeOption(
                                      'System',
                                      Icons.brightness_auto,
                                      ThemeMode.system,
                                      currentThemeMode,
                                      isDark,
                                      onThemeSelect,
                                    ),
                                    _buildThemeOption(
                                      'Light',
                                      Icons.light_mode,
                                      ThemeMode.light,
                                      currentThemeMode,
                                      isDark,
                                      onThemeSelect,
                                    ),
                                    _buildThemeOption(
                                      'Dark',
                                      Icons.dark_mode,
                                      ThemeMode.dark,
                                      currentThemeMode,
                                      isDark,
                                      onThemeSelect,
                                    ),
                                  ],
                                )
                              : const SizedBox.shrink(),
                        ),
                      ),

                      Divider(
                        height: 20,
                        color: isDark
                            ? Colors.grey.shade700
                            : Colors.grey.shade300,
                      ),

                      // Logout Option
                      _buildMenuItem(
                        icon: Icons.logout_rounded,
                        label: 'Logout',
                        onTap: onLogoutTap,
                        isDark: isDark,
                        isLogout: true,
                      ),

                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
    Widget? trailing,
    bool isLogout = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isLogout
                    ? Colors.red.shade50
                    : (isDark ? Colors.grey.shade800 : Colors.grey.shade100),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 18,
                color: isLogout
                    ? Colors.red.shade600
                    : (isDark ? Colors.grey.shade300 : Colors.grey.shade700),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: isLogout
                    ? Colors.red.shade600
                    : (isDark ? Colors.grey.shade300 : Colors.grey.shade700),
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
            const Spacer(),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    String label,
    IconData icon,
    ThemeMode themeMode,
    ThemeMode currentMode,
    bool isDark,
    Function(ThemeMode) onSelect,
  ) {
    final isSelected = currentMode == themeMode;

    return InkWell(
      onTap: () => onSelect(themeMode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? baseColor
                  : (isDark ? Colors.grey.shade500 : Colors.grey.shade600),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? baseColor
                    : (isDark ? Colors.grey.shade400 : Colors.grey.shade700),
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(Icons.check_circle, size: 16, color: baseColor),
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    List<String> names = name.trim().split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    } else if (names.length == 1 && names[0].isNotEmpty) {
      return names[0][0].toUpperCase();
    }
    return authResponse.username[0].toUpperCase();
  }
}
