import 'package:flutter/material.dart';
import 'package:labledger/constants/constants.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircleAvatar(
                    radius: 80,
                    backgroundImage: AssetImage('assets/images/app_icon.png'),
                    backgroundColor: Colors.transparent,
                  ),
                  const SizedBox(height: 40),
                  Text(
                    "Welcome to LabLedger!",
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: largePadding),
                  Text(
                    "Let's get you set up to manage your lab operations efficiently.",
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
