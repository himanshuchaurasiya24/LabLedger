import 'package:flutter/material.dart';

class CustomFilterChips extends StatefulWidget {
  const CustomFilterChips({
    required this.label,
    required this.selectedPeriod,
    required this.onTap,
    this.primaryColor,
    super.key,
  });
  final String label;
  final Color? primaryColor;
  final String selectedPeriod;
  final VoidCallback onTap;
  @override
  State<CustomFilterChips> createState() => _CustomFilterChipsState();
}

class _CustomFilterChipsState extends State<CustomFilterChips> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = widget.selectedPeriod == widget.label;
    final primary =
        widget.primaryColor ?? Theme.of(context).colorScheme.secondary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(25),

        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: isDark
                ? (isSelected ? Colors.white : primary.withAlpha(204))
                : (isSelected ? primary.withAlpha(204) : Colors.transparent),
            border: Border.all(
              color: isDark ? Colors.transparent : primary.withAlpha(204),
            ),
          ),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              color: isDark
                  ? (isSelected ? Colors.black : Colors.white)
                  : (isSelected ? Colors.white : Colors.black),
              fontWeight: FontWeight.w600,
              fontSize: 14,
              letterSpacing: 0.5,
            ),
            child: Text(widget.label),
          ),
        ),
      ),
    );
  }
}
