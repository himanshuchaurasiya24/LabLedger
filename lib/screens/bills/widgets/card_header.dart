import 'package:flutter/material.dart';
import 'package:labledger/screens/ui_components/shared_components.dart';

class CardHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const CardHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CustomFormCardHeader(
      title: title,
      icon: icon,
      color: color,
    );
  }
}
