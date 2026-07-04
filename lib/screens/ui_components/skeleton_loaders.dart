import 'package:flutter/material.dart';
import 'package:labledger/constants/constants.dart';

Widget buildEntitySkeletonLoader(BuildContext context, Color shimmerColor) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      CircleAvatar(radius: 40, backgroundColor: shimmerColor),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 22,
            width: 180,
            decoration: BoxDecoration(
              color: shimmerColor,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 16,
            width: 150,
            decoration: BoxDecoration(
              color: shimmerColor,
              borderRadius: BorderRadius.circular(7),
            ),
          ),
        ],
      ),
    ],
  );
}

Widget buildCategorySkeletonLoader(BuildContext context, Color shimmerColor) {
  return Padding(
    padding: EdgeInsets.all(defaultPadding),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            CircleAvatar(radius: 28, backgroundColor: shimmerColor),
            SizedBox(width: defaultWidth),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 20,
                  width: 120,
                  decoration: BoxDecoration(
                    color: shimmerColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 14,
                  width: 180,
                  decoration: BoxDecoration(
                    color: shimmerColor,
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}
