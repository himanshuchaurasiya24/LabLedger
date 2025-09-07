import 'package:flutter/material.dart';
import 'package:labledger/constants/constants.dart';

class TintedContainer extends StatelessWidget {
  const TintedContainer({
    super.key,
    required this.baseColor,
    required this.child,
    this.height,
    this.width,
    this.radius,
    this.disablePadding = false,
  });
  final Color baseColor;
  final Widget child;
  final double? height;
  final double? width;
  final double? radius;
  final bool disablePadding;
  // --- 🎨 Color Logic ---
  Color backgroundColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? baseColor.withValues(alpha: 0.8)
        : baseColor.withValues(alpha: 0.1);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 302,
      width: width,
      padding: disablePadding ? null : EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: backgroundColor(context),
        borderRadius: BorderRadius.circular(radius??defaultRadius),
        border: Border.all(color: baseColor.withValues(alpha: 0.3)),
      ),
      child: child,
    );
  }
}
