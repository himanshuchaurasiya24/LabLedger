import 'package:flutter/material.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/screens/ui_components/custom_elevated_button.dart';
import 'package:labledger/screens/ui_components/custom_outlined_button.dart';
import 'package:labledger/screens/ui_components/status_badge.dart';
import 'package:labledger/screens/ui_components/tinted_container.dart';

class EditScreenHeaderCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String initials;
  final Color color;
  final bool isEditMode;
  final bool isAdmin;
  final bool isSaving;
  final bool isDeleting;
  final VoidCallback? onSave;
  final VoidCallback? onDelete;
  final String saveLabel;
  final String deleteLabel;

  const EditScreenHeaderCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.initials,
    required this.color,
    required this.isEditMode,
    required this.isAdmin,
    required this.isSaving,
    required this.isDeleting,
    this.onSave,
    this.onDelete,
    required this.saveLabel,
    this.deleteLabel = 'Delete',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
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
                const SizedBox(height: minimalPadding),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? Colors.white70
                        : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: defaultHeight / 2),
                Row(
                  children: [
                    if (isAdmin && isEditMode) ...[
                      const StatusBadge(
                        text: 'Admin Edit Mode',
                        color: Colors.purple,
                      ),
                      SizedBox(width: defaultWidth / 2),
                    ],
                    StatusBadge(
                      text: isEditMode ? 'Edit Mode' : 'Create Mode',
                      color: isEditMode
                          ? theme.colorScheme.primary
                          : theme.colorScheme.secondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (!isEditMode || isAdmin)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomElevatedButton(
                  onPressed: isSaving ? null : onSave,
                  label: isSaving ? 'Saving...' : saveLabel,
                  backgroundColor: color,
                  icon: isSaving
                      ? SizedBox(
                          height: defaultHeight,
                          width: defaultWidth,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Icon(isEditMode ? Icons.update : Icons.save),
                ),
                if (isEditMode && isAdmin) ...[
                  SizedBox(height: defaultHeight / 2),
                  CustomOutlinedButton(
                    onPressed: isDeleting ? null : onDelete,
                    label: isDeleting ? 'Deleting...' : deleteLabel,
                    icon: isDeleting
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.colorScheme.error,
                            ),
                          )
                        : const Icon(Icons.delete_outline),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }
}
