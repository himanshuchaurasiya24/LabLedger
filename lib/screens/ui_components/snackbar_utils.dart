import 'package:flutter/material.dart';

/// Shows a custom floating snackbar with a prefix icon and background color.
/// Optional [clearSnackBars] will clear existing snackbars before showing.
void showCustomSnackBar({
  required BuildContext context,
  required String message,
  required IconData icon,
  required Color backgroundColor,
  bool clearSnackBars = true,
}) {
  if (!context.mounted) return;
  final messenger = ScaffoldMessenger.of(context);
  if (clearSnackBars) {
    messenger.clearSnackBars();
  }
  messenger.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 8),
          Flexible(child: Text(message)),
        ],
      ),
      backgroundColor: backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      duration: const Duration(seconds: 3),
    ),
  );
}

/// Shows a floating success snackbar with a check icon.
void showSuccessSnackBar(BuildContext context, String message, {bool clearSnackBars = true}) {
  showCustomSnackBar(
    context: context,
    message: message,
    icon: Icons.check_circle,
    backgroundColor: Theme.of(context).colorScheme.secondary,
    clearSnackBars: clearSnackBars,
  );
}

/// Shows a floating error snackbar with an error icon.
void showErrorSnackBar(BuildContext context, String message, {bool clearSnackBars = true}) {
  showCustomSnackBar(
    context: context,
    message: message,
    icon: Icons.error_outline,
    backgroundColor: Theme.of(context).colorScheme.error,
    clearSnackBars: clearSnackBars,
  );
}
