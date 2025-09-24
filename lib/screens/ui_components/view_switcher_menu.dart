import 'package:flutter/material.dart';
import 'package:labledger/constants/constants.dart'; // Or your own constants
import 'package:lucide_icons/lucide_icons.dart';

class ViewSwitcherMenu extends StatefulWidget {
  // Positional arguments
  final Color? baseColor;
  final RelativeRect position;

  // Named arguments
  final String initialView;
  final ValueChanged<String> onViewChanged;

  const ViewSwitcherMenu(
  // Positional
  {
    // Named
    super.key,
    required this.initialView,
    required this.onViewChanged,
   this.baseColor,
    required this.position,
  });

  @override
  State<ViewSwitcherMenu> createState() => _ViewSwitcherMenuState();
}

class _ViewSwitcherMenuState extends State<ViewSwitcherMenu> {
  late String _currentView;

  @override
  void initState() {
    super.initState();
    // Initialize the internal state with the value from the parent
    _currentView = widget.initialView;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = widget.baseColor ?? theme.colorScheme.secondary;
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(defaultRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(defaultRadius),
        onTap: () {
          showViewMenu(color);
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            // Use the internal state variable to display the correct icon
            _currentView == "grid" ? LucideIcons.layoutGrid : LucideIcons.list,
            color: theme.colorScheme.onSurface,
            size: 24,
          ),
        ),
      ),
    );
  }

  void showViewMenu(Color color) async {
    final theme = Theme.of(context);
    Color getBackgroundColor() {
      final isDark = theme.brightness == Brightness.dark;
      final surfaceColor = theme.colorScheme.surface;
      final opacity = isDark ? 0.25 : 0.15;
      return Color.alphaBlend(
        color.withValues(alpha: opacity), // Use the passed baseColor
        surfaceColor,
      );
    }

    final selected = await showMenu<String>(
      context: context,
      position: widget.position, // Use the passed position
      color: getBackgroundColor(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(defaultRadius),
        side: BorderSide(color: color, width: 0.8),
      ),
      items: [
        const PopupMenuItem(value: 'list', child: Text("List View")),
        const PopupMenuItem(value: 'grid', child: Text("Grid View")),
      ],
    );

    if (selected != null && selected != _currentView) {
      // 1. Call this widget's own setState to update the icon
      setState(() {
        _currentView = selected;
      });
      // 2. Notify the parent screen of the change so it can save it
      widget.onViewChanged(selected);
    }
  }
}
