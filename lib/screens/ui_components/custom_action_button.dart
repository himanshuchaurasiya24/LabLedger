import 'package:flutter/material.dart';
import 'package:labledger/constants/constants.dart';

class CustomActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isPrimary;
  final Color? color;

  const CustomActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isPrimary = true,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Use the provided color or fallback to the theme's primary color
    final baseColor = color ?? theme.colorScheme.primary;

    return isPrimary
        ? _buildPrimaryButton(context, theme, baseColor, isDark)
        : _buildSecondaryButton(context, theme, isDark);
  }

  /// Builds the main action button (e.g., "Add Bill", "Update")
  Widget _buildPrimaryButton(
    BuildContext context,
    ThemeData theme,
    Color baseColor,
    bool isDark,
  ) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(defaultPadding),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.secondary,
          borderRadius: BorderRadius.circular(defaultPadding),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the secondary action button (e.g., "Cancel")
  Widget _buildSecondaryButton(
    BuildContext context,
    ThemeData theme,
    bool isDark,
  ) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          child: Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
