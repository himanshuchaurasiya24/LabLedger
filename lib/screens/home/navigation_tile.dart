import 'package:flutter/material.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/screens/ui_components/app_inkwell.dart';
import 'package:labledger/screens/ui_components/tinted_container.dart';

class NavigationTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  final double height;

  const NavigationTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return AppInkWell(
      borderRadius: BorderRadius.circular(defaultRadius),
      onTap: onTap,
      child: TintedContainer(
        height: height,
        baseColor: color,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(
              icon,
              color: color,
              size: 50,
            ),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_outlined,
              color: color,
              size: 30,
            ),
          ],
        ),
      ),
    );
  }
}
