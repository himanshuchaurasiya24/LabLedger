import 'package:flutter/material.dart';
import 'package:labledger/constants/constants.dart';

class CustomOutlinedButton extends StatelessWidget {
  const CustomOutlinedButton({
    super.key,
    required this.onPressed,
    required this.label,
    required this.icon,
    this.width,
    this.height,
    this.fontSize = 16,
  });
  final VoidCallback? onPressed;
  final String label;
  final Widget icon;
  final double? width;
  final double? height;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final buttonWidth = width ?? 180;
    final buttonHeight = height ?? 60;

    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        fixedSize: Size(buttonWidth, buttonHeight),
        foregroundColor: Theme.of(context).colorScheme.error,
        side: BorderSide(color: Theme.of(context).colorScheme.error),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(defaultRadius),
        ),
      ),
      icon: icon,
      label: Text(label, style: TextStyle(fontSize: fontSize)),
    );
  }
}
