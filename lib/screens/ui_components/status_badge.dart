import 'package:flutter/material.dart';
import 'package:labledger/constants/constants.dart';

/// A small colored badge used to display status labels.
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.text,
    required this.color,
    this.icon,
  });

  final String text;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: smallPadding, vertical: minimalPadding),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(defaultRadius),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: minimalIconSize, color: color),
            const SizedBox(width: tinyPadding),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: smallFontSize,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
