import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:labledger/authentication/auth_http_client.dart';
import 'package:labledger/constants/urls.dart';
import 'package:labledger/screens/ui_components/app_inkwell.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/models/auth_response_model.dart';
import 'package:labledger/models/report_quota_model.dart';
import 'package:labledger/providers/message_provider.dart';
import 'package:labledger/providers/theme_providers.dart';
import 'package:labledger/providers/report_quota_provider.dart';
import 'package:labledger/screens/profile/audit_log_dialog.dart';
import 'package:labledger/screens/profile/user_edit_screen.dart';
import 'package:labledger/methods/string_utils.dart';
import 'package:labledger/screens/ui_components/custom_confirmation_dialog.dart';
import 'package:labledger/screens/ui_components/snackbar_utils.dart';
import 'package:labledger/screens/profile/components/profile_menu_widgets.dart';
import 'package:lucide_icons/lucide_icons.dart';

class UserProfileWidget extends ConsumerStatefulWidget {
  final AuthResponse authResponse;
  final Color baseColor;
  final VoidCallback onLogout;

  final VoidCallback? onSettings; // Optional settings callback
  final VoidCallback? onProfile; // Optional profile callback

  const UserProfileWidget({
    super.key,
    required this.authResponse,
    required this.baseColor,
    required this.onLogout,
    required this.onProfile,
    required this.onSettings,
  });

  @override
  ConsumerState<UserProfileWidget> createState() => _UserProfileWidgetState();
}

class _UserProfileWidgetState extends ConsumerState<UserProfileWidget> {
  bool _isThemeExpanded = false;
  bool _isMessageExpanded = false;
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
        isMessageExpanded: _isMessageExpanded,
        onThemeToggle: () {
          setState(() {
            _isThemeExpanded = !_isThemeExpanded;
            if (_isThemeExpanded) {
              _isMessageExpanded = false;
            }
          });
          _updateOverlay();
        },
        onMessageToggle: () {
          setState(() {
            _isMessageExpanded = !_isMessageExpanded;
            if (_isMessageExpanded) {
              _isThemeExpanded = false;
            }
          });
          _updateOverlay();
        },
        onThemeSelect: (themeMode) {
          ref.read(themeNotifierProvider.notifier).toggleTheme(themeMode);
          _removeOverlay();
        },
        onMessageSelect: (messagePlatform) async {
          _removeOverlay();
          if (messagePlatform == MessagePlatform.localSmsGateway) {
            bool isDownloading = false;
            final confirmed = await showCustomConfirmationDialog(
              context: context,
              title: 'SMS Gateway Warning',
              message:
                  'Using SMS from a personal SIM card for commercial purposes is often prohibited under local telecom laws and your SIM card can be permanently blocked. Please verify your current government telecom regulations before proceeding.\n\nTo further reduce automated blocking, the app will randomly select from 20 different message formats when using this gateway.',
              isDeleteOption: false,
              showWarningIcon: true,
              cancelLabel: 'Cancel',
              confirmLabel: 'Okay',
              contentBottomWidget: StatefulBuilder(
                builder: (context, setStateDialog) {
                  return InkWell(
                    mouseCursor: SystemMouseCursors.click,
                    onTap: isDownloading
                        ? null
                        : () async {
                            setStateDialog(() => isDownloading = true);
                            try {
                              final url =
                                  '${AppUrls.localBaseUrl}${AppUrls.localSmsGatewayApk}';
                              final response = await AuthHttpClient.request(
                                ref,
                                method: 'GET',
                                url: url,
                              );

                              if (response.statusCode == 200) {
                                final savePath = await FilePicker.platform
                                    .saveFile(
                                      dialogTitle: 'Save SMS Gateway APK',
                                      fileName: 'local_sms_gateway.apk',
                                    );

                                if (savePath != null && savePath.isNotEmpty) {
                                  final file = File(savePath);
                                  await file.writeAsBytes(response.bodyBytes);
                                  if (context.mounted) {
                                    showSuccessSnackBar(
                                      context,
                                      'APK downloaded successfully to $savePath',
                                    );
                                  }
                                }
                              } else {
                                if (context.mounted) {
                                  showErrorSnackBar(
                                    context,
                                    'File is not available on server.',
                                  );
                                }
                              }
                            } catch (e) {
                              if (context.mounted) {
                                showErrorSnackBar(
                                  context,
                                  'Failed to download APK: $e',
                                );
                              }
                            } finally {
                              setStateDialog(() => isDownloading = false);
                            }
                          },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.download_rounded,
                            size: 20,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              isDownloading
                                  ? 'Downloading...'
                                  : 'Download SMS Gateway App',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                // decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
            if (confirmed != true) {
              return;
            }
          }
          ref
              .read(messageNotifierProvider.notifier)
              .selectMessagePlatform(messagePlatform);
        },
        onViewAuditLogsTap: () {
          _removeOverlay();
          showDialog(context: context, builder: (_) => const AuditLogDialog());
        },
        onAboutAppTap: () {
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
        onProfileTap: () {
          _removeOverlay();
          widget.onProfile!();
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
    final String initials = getInitials(
      widget.authResponse.firstName,
      widget.authResponse.lastName,
    );

    return AppInkWell(
      borderRadius: BorderRadius.circular(20),
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

  // Show logout confirmation dialog
  void _showLogoutConfirmation(BuildContext context) async {
    final logoutResult = await showCustomConfirmationDialog(
      context: context,
      title: 'Logout',
      message: 'Are you sure you want to logout?',
      isDeleteOption: false,
      cancelLabel: 'Cancel',
      confirmLabel: 'Logout',
      showWarningIcon: false,
    );
    if (logoutResult == true) {
      widget.onLogout();
    }
  }

  // Show coming soon message
  void _showComingSoon(BuildContext context, String feature) {
    showCustomSnackBar(
      context: context,
      message: '$feature screen coming soon!',
      icon: Icons.info_outline,
      backgroundColor: widget.baseColor,
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
  final bool isMessageExpanded;
  final VoidCallback onThemeToggle;
  final VoidCallback onMessageToggle;
  final Function(ThemeMode) onThemeSelect;
  final Function(MessagePlatform) onMessageSelect;
  final VoidCallback onAboutAppTap;
  final VoidCallback onViewAuditLogsTap;
  final VoidCallback onProfileTap;
  final VoidCallback onLogoutTap;

  const _CustomDropdownMenu({
    required this.offset,
    required this.size,
    required this.onDismiss,
    required this.authResponse,
    required this.baseColor,
    required this.onLogout,
    this.onSettings,
    required this.onProfileTap,
    required this.isThemeExpanded,
    required this.isMessageExpanded,
    required this.onThemeToggle,
    required this.onMessageToggle,
    required this.onThemeSelect,
    required this.onMessageSelect,
    required this.onViewAuditLogsTap,
    required this.onAboutAppTap,
    required this.onLogoutTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentThemeMode = ref.watch(themeNotifierProvider);
    final currentMessagePlatform = ref.watch(messageNotifierProvider);
    final quotaAsync = ref.watch(reportQuotaSummaryProvider);

    final String userName =
        "${authResponse.firstName} ${authResponse.lastName}";
    final String userRole = authResponse.isAdmin ? "Admin" : "User";
    final String initials = getInitials(
      authResponse.firstName,
      authResponse.lastName,
    );

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onDismiss,
      child: MouseRegion(
        cursor: SystemMouseCursors.basic,
        child: Container(
          color: Colors.transparent,
          child: Stack(
            children: [
              Positioned(
                left: offset.dx - 250 + size.width,
                top: offset.dy + size.height + 10,
                child: Material(
                  elevation: 100,
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
                      children: [
                        Container(
                          padding: EdgeInsets.all(defaultPadding),
                          child: AppInkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) {
                                    return UserAddEditScreen(
                                      targetUserId: authResponse.id,
                                    );
                                  },
                                ),
                              );
                              onDismiss();
                            },
                            child: Column(
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
                                    SizedBox(width: defaultWidth / 2),
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
                                              borderRadius:
                                                  BorderRadius.circular(12),
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
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            defaultPadding,
                            0,
                            defaultPadding,
                            defaultPadding,
                          ),
                          child: quotaAsync.when(
                            loading: () => _QuotaLoadingView(isDark: isDark),
                            error: (error, _) => _QuotaErrorView(
                              message: error.toString(),
                              isDark: isDark,
                            ),
                            data: (summary) => _QuotaSummaryView(
                              summary: summary,
                              baseColor: baseColor,
                              isDark: isDark,
                            ),
                          ),
                        ),

                        Divider(
                          height: 20,
                          color: isDark
                              ? Colors.grey.shade700
                              : Colors.grey.shade300,
                        ),
                        if (authResponse.isAdmin)
                          ProfileMenuItem(
                            icon: LucideIcons.user2,
                            label: 'Profile',
                            onTap: onProfileTap,
                            isDark: isDark,
                          ),

                        if (authResponse.isAdmin)
                          ProfileMenuItem(
                            icon: LucideIcons.history,
                            label: 'View Audit Logs',
                            onTap: onViewAuditLogsTap,
                            isDark: isDark,
                          ),
                        if (authResponse.isAdmin)
                          ProfileMenuItem(
                            icon: LucideIcons.messageSquare,
                            label: 'Message Gateway',
                            onTap: onMessageToggle,
                            isDark: isDark,
                            trailing: AnimatedRotation(
                              turns: isMessageExpanded ? 0.5 : 0,
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

                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          height: isMessageExpanded
                              ? (availableMessagePlatforms().length * 48.0)
                              : 0,
                          child: ClipRect(
                            child: isMessageExpanded
                                ? Column(
                                    children: [
                                      for (final platform
                                          in availableMessagePlatforms())
                                        ProfileMessageOption(
                                          messagePlatform: platform,
                                          currentPlatform:
                                              currentMessagePlatform,
                                          isDark: isDark,
                                          onSelect: onMessageSelect,
                                          baseColor: baseColor,
                                        ),
                                    ],
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ),

                        ProfileMenuItem(
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

                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          height: isThemeExpanded ? 144 : 0,
                          child: ClipRect(
                            child: isThemeExpanded
                                ? Column(
                                    children: [
                                      ProfileThemeOption(
                                        label: 'System',
                                        icon: Icons.brightness_auto,
                                        themeMode: ThemeMode.system,
                                        currentMode: currentThemeMode,
                                        isDark: isDark,
                                        onSelect: onThemeSelect,
                                        baseColor: baseColor,
                                      ),
                                      ProfileThemeOption(
                                        label: 'Light',
                                        icon: Icons.light_mode,
                                        themeMode: ThemeMode.light,
                                        currentMode: currentThemeMode,
                                        isDark: isDark,
                                        onSelect: onThemeSelect,
                                        baseColor: baseColor,
                                      ),
                                      ProfileThemeOption(
                                        label: 'Dark',
                                        icon: Icons.dark_mode,
                                        themeMode: ThemeMode.dark,
                                        currentMode: currentThemeMode,
                                        isDark: isDark,
                                        onSelect: onThemeSelect,
                                        baseColor: baseColor,
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

                        ProfileMenuItem(
                          icon: FontAwesomeIcons.circleInfo,
                          label: 'About this app',
                          onTap: onAboutAppTap,
                          isDark: isDark,
                        ),

                        ProfileMenuItem(
                          icon: Icons.logout_rounded,
                          label: 'Logout',
                          onTap: onLogoutTap,
                          isDark: isDark,
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
      ),
    );
  }
}

class _QuotaSummaryView extends StatelessWidget {
  final ReportQuotaSummary summary;
  final Color baseColor;
  final bool isDark;

  const _QuotaSummaryView({
    required this.summary,
    required this.baseColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _QuotaBar(
          label: 'Server reports',
          bucket: summary.serverReport,
          accent: scheme.primary,
          isDark: isDark,
        ),
        const SizedBox(height: 8),
        _QuotaBar(
          label: 'Patient reports',
          bucket: summary.patientReport,
          accent: baseColor,
          isDark: isDark,
        ),
      ],
    );
  }
}

class _QuotaBar extends StatelessWidget {
  final String label;
  final ReportQuotaBucket bucket;
  final Color accent;
  final bool isDark;

  const _QuotaBar({
    required this.label,
    required this.bucket,
    required this.accent,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progressColor = bucket.quotaMb <= 0
        ? theme.colorScheme.error
        : accent;
    final progressValue = bucket.quotaMb <= 0
        ? (bucket.usedBytes > 0 ? 1.0 : 0.0)
        : bucket.normalizedUsage;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: progressColor.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                bucket.quotaMb <= 0
                    ? '${bucket.usedMb.toStringAsFixed(2)} MB'
                    : '${bucket.usedMb.toStringAsFixed(2)} / ${bucket.quotaMb} MB',
                style: theme.textTheme.labelSmall,
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 6,
              value: progressValue.clamp(0, 1),
              backgroundColor: progressColor.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            bucket.quotaMb <= 0
                ? 'No quota available on this plan'
                : '${bucket.remainingMb.toStringAsFixed(2)} MB remaining',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuotaLoadingView extends StatelessWidget {
  final bool isDark;

  const _QuotaLoadingView({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const SizedBox(
        height: 42,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
    );
  }
}

class _QuotaErrorView extends StatelessWidget {
  final String message;
  final bool isDark;

  const _QuotaErrorView({required this.message, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.error,
        ),
      ),
    );
  }
}
