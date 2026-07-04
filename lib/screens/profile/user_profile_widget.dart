import 'dart:io';
import 'package:labledger/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:labledger/authentication/auth_http_client.dart';
import 'package:labledger/constants/urls.dart';
import 'package:labledger/screens/ui_components/app_inkwell.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/models/auth_response_model.dart';
import 'package:labledger/providers/message_provider.dart';
import 'package:labledger/providers/theme_providers.dart';
import 'package:labledger/screens/profile/audit_log_dialog.dart';
import 'package:labledger/methods/string_utils.dart';
import 'package:labledger/screens/ui_components/custom_confirmation_dialog.dart';
import 'package:labledger/screens/ui_components/snackbar_utils.dart';
import 'package:labledger/screens/profile/components/user_profile_dropdown_menu.dart';
import 'package:labledger/screens/profile/components/local_sms_gateway_config_dialog.dart';

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
      builder: (context) => CustomDropdownMenu(
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
                  return Row(
                    children: [
                      Expanded(
                        child: InkWell(
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
                            padding: const EdgeInsets.symmetric(vertical: smallPadding),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.download_rounded,
                                  size: 20,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: smallPadding),
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
                        ),
                      ),
                      const SizedBox(width: mediumPadding),
                      Expanded(
                        child: InkWell(
                          mouseCursor: SystemMouseCursors.click,
                          onTap: () {
                            Navigator.of(context).pop(true); // Close warning dialog and confirm selection
                            showDialog(
                              context: context,
                              builder: (_) => const LocalSmsGatewayConfigDialog(),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: smallPadding),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.settings_rounded,
                                  size: 20,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: smallPadding),
                                Expanded(
                                  child: Text(
                                    'Configure Local SMS Gateway',
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
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
      borderRadius: BorderRadius.circular(largeRadius),
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

