import 'package:flutter/material.dart';
import 'package:labledger/constants/constants.dart';

class CustomOutlinedButton extends StatelessWidget {
  const CustomOutlinedButton({
    super.key,
    required this.onPressed,
    required this.label,
    required this.icon,
  });
  final VoidCallback? onPressed;
  final String label;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed:onPressed,
      style: OutlinedButton.styleFrom(
        fixedSize: const Size(180, 60),
        foregroundColor: Theme.of(context).colorScheme.error,
        side: BorderSide(color: Theme.of(context).colorScheme.error),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(defaultRadius),
        ),
      ),
      icon:icon,
      label: Text(label),
    );
  }
}
