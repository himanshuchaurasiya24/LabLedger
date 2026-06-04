import 'package:flutter/material.dart';

/// Provides a subtle background with circular ambient shapes using
/// the app's primary and secondary colors at very low opacity.
class AmbientBackground extends StatelessWidget {
  final Widget child;

  const AmbientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    return Stack(
      children: [
        // Clean base background color
        Container(
          color: isDark ? const Color(0xFF0F0F10) : const Color(0xFFF9FAFB),
          width: double.infinity,
          height: double.infinity,
        ),

        // Soft ambient shapes using the app's own primary color
        Positioned(
          top: -80,
          right: -60,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primary.withValues(alpha: isDark ? 0.08 : 0.06),
            ),
          ),
        ),
        Positioned(
          bottom: -100,
          left: -80,
          child: Container(
            width: 350,
            height: 350,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primary.withValues(alpha: isDark ? 0.06 : 0.04),
            ),
          ),
        ),
        Positioned(
          top: 200,
          left: 150,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.secondary.withValues(
                alpha: isDark ? 0.05 : 0.03,
              ),
            ),
          ),
        ),

        // Content (Scaffolds)
        Positioned.fill(child: child),
      ],
    );
  }
}
