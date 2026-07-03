import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/models/diagnosis_category_model.dart';
import 'package:labledger/screens/ui_components/custom_text_field.dart';
import 'package:labledger/screens/ui_components/tinted_container.dart';

class DoctorIncentivesFormCard extends StatelessWidget {
  const DoctorIncentivesFormCard({
    super.key,
    required this.color,
    required this.formKey,
    required this.categories,
    required this.categoryControllers,
  });

  final Color color;
  final GlobalKey<FormState> formKey;
  final List<DiagnosisCategory> categories;
  final Map<int, TextEditingController> categoryControllers;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TintedContainer(
      baseColor: color,
      radius: defaultRadius,
      height: 510,
      elevationLevel: 1,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(defaultPadding * 1.5),
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(defaultRadius),
                topRight: Radius.circular(defaultRadius),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(defaultPadding),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.percent, color: color, size: 20),
                ),
                SizedBox(width: defaultWidth / 2),
                Text(
                  'Incentives Rates (%)',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: defaultHeight),
          Expanded(
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(defaultPadding),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: isDark ? 0.1 : 0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: color.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: color, size: 20),
                          SizedBox(width: defaultWidth / 2),
                          Expanded(
                            child: Text(
                              'Leave fields empty or enter 0 if no Incentives applies for that service.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDark
                                    ? Colors.white70
                                    : theme.colorScheme.onSurface.withValues(
                                        alpha: 0.7,
                                      ),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: defaultHeight),
                    // Dynamic category incentive fields
                    ..._buildDynamicIncentiveFields(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDynamicIncentiveFields(BuildContext context) {
    if (categories.isEmpty) {
      return [
        Center(
          child: Padding(
            padding: EdgeInsets.all(defaultPadding * 2),
            child: const Text('Loading categories...'),
          ),
        ),
      ];
    }

    List<Widget> widgets = [];
    for (int i = 0; i < categories.length; i += 2) {
      final category1 = categories[i];
      final controller1 = categoryControllers[category1.id];

      if (i + 1 < categories.length) {
        final category2 = categories[i + 1];
        final controller2 = categoryControllers[category2.id];

        widgets.add(
          Row(
            children: [
              Expanded(
                child: _buildIncentiveField(
                  context,
                  '${category1.name} Incentives',
                  controller1!,
                  _getIconForCategory(category1.name),
                ),
              ),
              SizedBox(width: defaultWidth),
              Expanded(
                child: _buildIncentiveField(
                  context,
                  '${category2.name} Incentives',
                  controller2!,
                  _getIconForCategory(category2.name),
                ),
              ),
            ],
          ),
        );
      } else {
        widgets.add(
          _buildIncentiveField(
            context,
            '${category1.name} Incentives',
            controller1!,
            _getIconForCategory(category1.name),
          ),
        );
      }

      if (i + 2 < categories.length) {
        widgets.add(SizedBox(height: defaultHeight));
      }
    }

    return widgets;
  }

  IconData _getIconForCategory(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('ultrasound')) return Icons.monitor_heart_outlined;
    if (name.contains('pathology')) return Icons.biotech_outlined;
    if (name.contains('ecg')) return Icons.favorite_outline;
    if (name.contains('x-ray') || name.contains('xray')) {
      return Icons.camera_outlined;
    }
    if (name.contains('franchise')) return Icons.business_outlined;
    return Icons.medical_services_outlined;
  }

  Widget _buildIncentiveField(
    BuildContext context,
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(width: defaultWidth / 2),
            Icon(icon, color: color, size: 16),
            SizedBox(width: defaultWidth / 4),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        CustomTextField(
          label: '${label.split(' ')[0]} %',
          controller: controller,
          keyboardType: TextInputType.number,
          isNumeric: true,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          tintColor: color,
          validator: (value) {
            if (value != null && value.trim().isNotEmpty) {
              final parsed = int.tryParse(value.trim());
              if (parsed == null) {
                return 'Please enter a valid number';
              }
              if (parsed < 0 || parsed > 100) {
                return 'Percentage must be between 0 and 100';
              }
            }
            return null;
          },
        ),
      ],
    );
  }
}
