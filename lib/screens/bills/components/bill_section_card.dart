import 'package:flutter/material.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/screens/ui_components/tinted_container.dart';

class BillSectionCard extends StatelessWidget {
  const BillSectionCard({
    super.key,
    required this.baseColor,
    required this.title,
    required this.icon,
    required this.child,
    this.height,
    this.elevationLevel = 1,
    this.bottomPadding = const EdgeInsets.only(bottom: 16),
  });

  final Color baseColor;
  final String title;
  final IconData icon;
  final Widget child;
  final double? height;
  final int elevationLevel;
  final EdgeInsetsGeometry bottomPadding;

  @override
  Widget build(BuildContext context) {
    return TintedContainer(
      baseColor: baseColor,
      height: height,
      radius: defaultRadius,
      elevationLevel: elevationLevel,
      child: SingleChildScrollView(
        padding: bottomPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: baseColor, size: 24),
                SizedBox(width: defaultWidth / 2),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: baseColor,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            SizedBox(height: defaultHeight),
            child,
          ],
        ),
      ),
    );
  }
}
