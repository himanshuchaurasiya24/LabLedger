import 'package:flutter/material.dart';
import 'package:labledger/constants/constants.dart';

class CustomElevatedButton extends StatelessWidget {
  const CustomElevatedButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.outlined = false,
    required this.icon,
    this.width,
    this.height,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w600,
    this.iconSize = 20,
  });
  final VoidCallback? onPressed;
  final String label;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final bool outlined;
  final Widget icon;
  final double? width;
  final double? height;
  final double fontSize;
  final FontWeight fontWeight;
  final double iconSize;
  @override
  Widget build(BuildContext context) {
    final buttonWidth = width ?? 180;
    final buttonHeight = height ?? 60;
    final Color effectiveForeground = foregroundColor ?? Colors.white;

    final ButtonStyle buttonStyle =
        ElevatedButton.styleFrom(
          fixedSize: Size(buttonWidth, buttonHeight),
          backgroundColor: outlined
              ? effectiveForeground.withValues(alpha: 0.04)
              : backgroundColor,
          foregroundColor: effectiveForeground,
          elevation: outlined ? 0 : null,
          shadowColor: outlined ? Colors.transparent : null,
          surfaceTintColor: outlined ? Colors.transparent : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(defaultRadius),
            side: outlined
                ? BorderSide(color: borderColor ?? effectiveForeground)
                : BorderSide.none,
          ),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (!outlined) return null;
            if (states.contains(WidgetState.pressed)) {
              return effectiveForeground.withValues(alpha: 0.12);
            }
            if (states.contains(WidgetState.hovered) ||
                states.contains(WidgetState.focused)) {
              return effectiveForeground.withValues(alpha: 0.08);
            }
            return Colors.transparent;
          }),
        );

    return SizedBox(
      width: buttonWidth,
      height: buttonHeight,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: buttonStyle,
        icon: IconTheme(
          data: IconThemeData(size: iconSize, color: effectiveForeground),
          child: icon,
        ),
        label: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: effectiveForeground,
          ),
        ),
      ),
    );
  }
}
