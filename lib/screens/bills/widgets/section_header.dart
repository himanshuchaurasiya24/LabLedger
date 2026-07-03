import 'package:flutter/material.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/screens/ui_components/view_switcher_menu.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String initialView;
  final ValueChanged<String> onViewChanged;

  const SectionHeader({
    super.key,
    required this.title,
    required this.initialView,
    required this.onViewChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: defaultPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          ViewSwitcherMenu(
            initialView: initialView,
            onViewChanged: onViewChanged,
            position: RelativeRect.fromLTRB(200, 434, defaultPadding, 100),
          ),
        ],
      ),
    );
  }
}
