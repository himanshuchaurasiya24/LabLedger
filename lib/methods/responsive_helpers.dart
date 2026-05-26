import 'package:flutter/material.dart';
import 'package:labledger/constants/constants.dart';

/// Returns the number of grid columns based on screen width.
int getResponsiveCrossAxisCount(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  if (width < initialWindowWidth && width > 1200) return 3;
  if (width < 1200) return 2;
  return 4;
}

/// Returns the child aspect ratio for grid cards based on screen width.
double getResponsiveAspectRatio(
  BuildContext context, {
  double baseSmall = 2.3,
  double baseLarge = 2.7,
}) {
  final width = MediaQuery.of(context).size.width;
  if (width < initialWindowWidth && width > 1200) return baseSmall;
  if (width < 1200 || width > initialWindowWidth) return baseLarge;
  return baseSmall;
}
