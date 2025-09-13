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
    this.intensity = 0.1, // Controls tint intensity
    this.useGradient = true, // Enable gradient backgrounds
    this.elevationLevel = 1, // Shadow elevation (0-5)
  });

  final Color baseColor;
  final Widget child;
  final double? height;
  final double? width;
  final double? radius;
  final bool disablePadding;
  final double intensity;
  final bool useGradient;
  final int elevationLevel;

  // --- 🎨 Enhanced Color Logic ---
  Color _getBackgroundColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = Theme.of(context).colorScheme.surface;

    if (isDark) {
      // In dark mode, use a subtle tint with the surface color
      return Color.alphaBlend(
        baseColor.withValues(alpha: intensity * 0.3),
        surfaceColor,
      );
    } else {
      // In light mode, use a lighter tint
      return Color.alphaBlend(
        baseColor.withValues(alpha: intensity),
        surfaceColor,
      );
    }
  }

  Gradient? _getGradient(BuildContext context) {
    if (!useGradient) return null;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = _getBackgroundColor(context);

    if (isDark) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          backgroundColor,
          backgroundColor.withValues(alpha: 0.8),
          Color.alphaBlend(baseColor.withValues(alpha: 0.05), backgroundColor),
        ],
        stops: const [0.0, 0.6, 1.0],
      );
    } else {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          backgroundColor,
          Color.alphaBlend(
            baseColor.withValues(alpha: intensity * 0.5),
            backgroundColor,
          ),
          backgroundColor.withValues(alpha: 0.95),
        ],
        stops: const [0.0, 0.4, 1.0],
      );
    }
  }

  Color _getBorderColor(BuildContext context) {
    return baseColor.withValues(alpha: 0.4);
  }

  List<BoxShadow> _getShadows(BuildContext context) {
    if (elevationLevel == 0) return [];

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shadowColor = isDark ? Colors.black : Colors.grey;

    switch (elevationLevel) {
      case 1:
        return [
          BoxShadow(
            color: shadowColor.withValues(alpha: isDark ? 0.3 : 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ];
      case 2:
        return [
          BoxShadow(
            color: shadowColor.withValues(alpha: isDark ? 0.4 : 0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ];
      case 3:
        return [
          BoxShadow(
            color: shadowColor.withValues(alpha: isDark ? 0.5 : 0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ];
      case 4:
        return [
          BoxShadow(
            color: shadowColor.withValues(alpha: isDark ? 0.6 : 0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ];
      case 5:
        return [
          BoxShadow(
            color: shadowColor.withValues(alpha: isDark ? 0.7 : 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? tintedContainerHeight,
      width: width,
      padding: disablePadding ? null : EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: useGradient ? null : _getBackgroundColor(context),
        gradient: _getGradient(context),
        borderRadius: BorderRadius.circular(radius ?? defaultRadius),
        border: Border.all(color: _getBorderColor(context), width: 1.0),
        boxShadow: _getShadows(context),
      ),
      child: child,
    );
  }
}
