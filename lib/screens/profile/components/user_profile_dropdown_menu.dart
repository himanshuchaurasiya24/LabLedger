import 'package:flutter/material.dart';
import 'package:labledger/screens/ui_components/app_inkwell.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/models/auth_response_model.dart';
import 'package:labledger/models/report_quota_model.dart';
import 'package:labledger/providers/message_provider.dart';
import 'package:labledger/providers/theme_providers.dart';
import 'package:labledger/providers/report_quota_provider.dart';
import 'package:labledger/screens/profile/user_edit_screen.dart';
import 'package:labledger/methods/string_utils.dart';
import 'package:labledger/screens/profile/components/profile_menu_widgets.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class CustomDropdownMenu extends ConsumerWidget {
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

  const CustomDropdownMenu({
    super.key,
    required this.offset,
    required this.size,
    required this.onDismiss,
    required this.authResponse,
    required this.baseColor,
    required this.onLogout,
    this.onSettings,
    required this.isThemeExpanded,
    required this.isMessageExpanded,
    required this.onThemeToggle,
    required this.onMessageToggle,
    required this.onThemeSelect,
    required this.onMessageSelect,
    required this.onAboutAppTap,
    required this.onViewAuditLogsTap,
    required this.onProfileTap,
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
                  borderRadius: BorderRadius.circular(mediumRadius),
                  color: isDark ? Colors.grey.shade900 : Colors.white,
                  child: Container(
                    width: 250,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(mediumRadius),
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
                                                  BorderRadius.circular(defaultRadius),
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
                            icon: LucideIcons.circle_user,
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
                            icon: LucideIcons.message_square,
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
                                          currentPlatform: currentMessagePlatform,
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
                          icon: LucideIcons.info,
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

                        const SizedBox(height: smallPadding),
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
        const SizedBox(height: smallPadding),
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
        borderRadius: BorderRadius.circular(defaultRadius),
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
          const SizedBox(height: smallPadding),
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
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(defaultRadius),
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
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(defaultRadius),
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
