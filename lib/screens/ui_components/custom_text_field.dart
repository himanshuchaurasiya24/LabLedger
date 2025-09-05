import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool useSearchBarDesign; // <-- New property to switch styles
  final TextInputType? keyboardType;
  final bool readOnly;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final FocusNode? focusNode;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onTap;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.useSearchBarDesign = false, // Defaults to the standard style
    this.keyboardType,
    this.readOnly = false,
    this.obscureText = false,
    this.onChanged,
    this.validator,
    this.focusNode,
    this.prefixIcon,
    this.suffixIcon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // If using the search bar design, wrap the field in a decorated container
    if (useSearchBarDesign) {
      return _buildSearchBarStyledField(context);
    }
    // Otherwise, return the standard styled field
    return _buildStandardStyledField(context);
  }

  /// Builds the field with the modern search bar container style.
  Widget _buildSearchBarStyledField(BuildContext context) {
    final theme = Theme.of(context);
    final isLightMode = theme.brightness == Brightness.light;

    return Container(
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            isLightMode ? Colors.white : const Color(0xFF2A2A2A),
            isLightMode ? const Color(0xFFF8F9FA) : const Color(0xFF1E1E1E),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:  isLightMode ? 0.08 : 0.3),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
        border: Border.all(
          color: isLightMode ? Colors.grey.shade200 : Colors.grey.shade800,
          width: 1.0,
        ),
      ),
      child: _buildTextFieldCore(context, isTransparent: true),
    );
  }

  /// Builds the field with the standard, general-purpose form style.
  Widget _buildStandardStyledField(BuildContext context) {
    return _buildTextFieldCore(context, isTransparent: false);
  }

  /// The core TextFormField used by both styles.
  Widget _buildTextFieldCore(
    BuildContext context, {
    required bool isTransparent,
  }) {
    final theme = Theme.of(context);
    final isLightMode = theme.brightness == Brightness.light;

    // Define colors
    final fillColor = isLightMode
        ? const Color(0xFFF8F9FA)
        : const Color(0xFF2A2D3E);
    final borderColor = isLightMode
        ? Colors.grey.shade300
        : Colors.grey.shade700;
    final hintColor = isLightMode ? Colors.grey.shade500 : Colors.grey.shade400;

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      readOnly: readOnly,
      obscureText: obscureText,
      onChanged: onChanged,
      validator: validator,
      onTap: onTap,
      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: label,
        hintStyle: TextStyle(color: hintColor, fontWeight: FontWeight.w400),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: isTransparent ? Colors.transparent : fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: isTransparent
              ? BorderSide.none
              : BorderSide(color: borderColor, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: isTransparent
              ? BorderSide.none
              : BorderSide(color: theme.colorScheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: theme.colorScheme.error, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: theme.colorScheme.error, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }
}
