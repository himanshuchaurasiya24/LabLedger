import 'package:flutter/material.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/methods/custom_methods.dart';

class IncentiveScreen extends StatelessWidget {
  const IncentiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.tertiaryFixed,
      body: Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal: defaultPadding),
        child: Column(
          children: [pageHeader(context: context, centerWidget: null)],
        ),
      ),
    );
  }
}
