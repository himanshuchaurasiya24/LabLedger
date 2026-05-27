import 'package:flutter/material.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/screens/ui_components/app_inkwell.dart';
import 'package:labledger/screens/ui_components/tinted_container.dart';

class EntitySummaryCard extends StatelessWidget {
  const EntitySummaryCard({
    super.key,
    required this.baseColor,
    required this.avatar,
    required this.title,
    required this.details,
    required this.onTap,
    this.trailing,
  });

  final Color baseColor;
  final Widget avatar;
  final Widget title;
  final List<Widget> details;
  final Widget? trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TintedContainer(
      baseColor: baseColor,
      child: AppInkWell(
        borderRadius: BorderRadius.circular(defaultRadius),
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            avatar,
            SizedBox(width: defaultWidth),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: title),
                      if (trailing != null) ...[
                        const SizedBox(width: 12),
                        trailing!,
                      ],
                    ],
                  ),
                  ...details,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
