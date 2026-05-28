import 'package:flutter/material.dart';
import 'package:labledger/screens/ui_components/tinted_container.dart';

class SetupLicensePage extends StatelessWidget {
  final bool isLoading;
  final String? licenseText;

  const SetupLicensePage({
    super.key,
    required this.isLoading,
    this.licenseText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "End User License Agreement",
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: TintedContainer(
                  baseColor: theme.colorScheme.secondary,
                  height: null,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : SingleChildScrollView(
                            child: Text(
                              licenseText ?? "",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                height: 1.6,
                              ),
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
