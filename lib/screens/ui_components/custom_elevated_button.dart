import 'package:flutter/material.dart';
import 'package:labledger/constants/constants.dart';

class CustomElevatedButton extends StatelessWidget {
  const CustomElevatedButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.backgroundColor,
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

    return SizedBox(
      width: buttonWidth,
      height: buttonHeight,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          fixedSize: Size(buttonWidth, buttonHeight),
          backgroundColor: backgroundColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(defaultRadius),
          ),
        ),
        icon: IconTheme(
          data: IconThemeData(size: iconSize, color: Colors.white),
          child: icon,
        ),
        label: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: fontSize, fontWeight: fontWeight),
        ),
      ),
    );
  }
}
