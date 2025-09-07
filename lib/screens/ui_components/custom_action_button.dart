import 'package:flutter/material.dart';
import 'package:labledger/constants/constants.dart';

class CustomActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final Color? color;

  const CustomActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final baseColor = color ?? theme.colorScheme.primary;
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(defaultPadding),
      child: Container(
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding:  EdgeInsets.symmetric(horizontal: defaultPadding*2, vertical: defaultPadding),
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
