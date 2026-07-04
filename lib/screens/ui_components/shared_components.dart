import 'package:flutter/material.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/screens/ui_components/custom_error_state_widget.dart';

class CustomFormCardHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const CustomFormCardHeader({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
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
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(smallRadius),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(width: defaultWidth),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class CustomErrorState extends StatelessWidget {
  final Object error;
  final VoidCallback onTap;
  final String errorHeading;
  final String errorTitle;
  final String buttonLabel;
  final Widget icon;

  const CustomErrorState({
    super.key,
    required this.error,
    required this.onTap,
    this.errorHeading = 'Error Loading Data',
    this.errorTitle = 'An error occurred. Please try again.',
    this.buttonLabel = 'Retry',
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return buildErrorState(
      context: context,
      error: error,
      theme: theme,
      onTap: onTap,
      errorHeading: errorHeading,
      errorTitle: errorTitle,
      buttonLabel: buttonLabel,
      icon: icon,
    );
  }
}

class ShimmerListLoading extends StatelessWidget {
  final Color shimmerColor;
  const ShimmerListLoading({super.key, required this.shimmerColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (index) => Container(
          height: 100,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: shimmerColor,
            borderRadius: BorderRadius.circular(smallRadius),
          ),
        ),
      ),
    );
  }
}

class SummaryTextColumn extends StatelessWidget {
  final String title;
  final String subtitle;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final CrossAxisAlignment crossAxisAlignment;

  const SummaryTextColumn({
    super.key,
    required this.title,
    required this.subtitle,
    this.titleStyle,
    this.subtitleStyle,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: titleStyle ?? theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: isDark ? Colors.white : Colors.black87,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        const SizedBox(height: minimalPadding),
        Text(
          subtitle,
          style: subtitleStyle ?? theme.textTheme.bodyMedium?.copyWith(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            fontSize: 14,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    );
  }
}
