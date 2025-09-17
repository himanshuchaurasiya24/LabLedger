import 'package:flutter/material.dart';
import 'package:labledger/screens/initials/window_scaffold.dart';

class IncentiveGenerationScreen extends StatelessWidget {
  const IncentiveGenerationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WindowScaffold(
      child: Column(
        children: [
          Text(
            "Incentive Generation Page",
            style: Theme.of(context).textTheme.headlineLarge,
          ),
        ],
      ),
    );
  }
}
