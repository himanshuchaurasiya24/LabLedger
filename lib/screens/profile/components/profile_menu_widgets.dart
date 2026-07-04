import 'package:flutter/material.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/providers/message_provider.dart';
import 'package:labledger/screens/ui_components/app_inkwell.dart';

class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDark;
  final Widget? trailing;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isDark,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return AppInkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(smallRadius),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: mediumPadding, vertical: defaultPadding),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(smallPadding),
              decoration: BoxDecoration(
                color: (isDark ? Colors.grey.shade800 : Colors.grey.shade100),
                borderRadius: BorderRadius.circular(smallRadius),
              ),
              child: Icon(
                icon,
                size: 18,
                color: (isDark ? Colors.grey.shade300 : Colors.grey.shade700),
              ),
            ),
            const SizedBox(width: defaultPadding),
            Text(
              label,
              style: TextStyle(
                color: (isDark ? Colors.grey.shade300 : Colors.grey.shade700),
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
            const Spacer(),
            ?trailing,
          ],
        ),
      ),
    );
  }
}

class ProfileThemeOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final ThemeMode themeMode;
  final ThemeMode currentMode;
  final bool isDark;
  final Function(ThemeMode) onSelect;
  final Color baseColor;

  const ProfileThemeOption({
    super.key,
    required this.label,
    required this.icon,
    required this.themeMode,
    required this.currentMode,
    required this.isDark,
    required this.onSelect,
    required this.baseColor,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = currentMode == themeMode;

    return AppInkWell(
      onTap: () => onSelect(themeMode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: smallPadding),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? baseColor
                  : (isDark ? Colors.grey.shade500 : Colors.grey.shade600),
            ),
            const SizedBox(width: defaultPadding),
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
}

class ProfileMessageOption extends StatelessWidget {
  final MessagePlatform messagePlatform;
  final MessagePlatform currentPlatform;
  final bool isDark;
  final Function(MessagePlatform) onSelect;
  final Color baseColor;
  const ProfileMessageOption({
    super.key,
    required this.messagePlatform,
    required this.currentPlatform,
    required this.isDark,
    required this.onSelect,
    required this.baseColor,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = currentPlatform == messagePlatform;

    return AppInkWell(
      onTap: () => onSelect(messagePlatform),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: smallPadding),
        child: Row(
          children: [
            Icon(
              messagePlatform.icon,
              size: 16,
              color: isSelected
                  ? baseColor
                  : (isDark ? Colors.grey.shade500 : Colors.grey.shade600),
            ),
            const SizedBox(width: defaultPadding),
            Expanded(
              child: Text(
                messagePlatform.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? baseColor
                      : (isDark ? Colors.grey.shade400 : Colors.grey.shade700),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, size: 16, color: baseColor),
          ],
        ),
      ),
    );
  }
}
