import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for InputFormatters

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool useSearchBarDesign;
  final TextInputType? keyboardType;
  final bool readOnly;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted; // <-- ADDED for submission
  final FormFieldValidator<String>? validator;
  final FocusNode? focusNode;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final Color? tintColor;
  final List<TextInputFormatter>? inputFormatters; // <-- ADDED for input restriction
  final TextAlign textAlign; // <-- ADDED for centering

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.useSearchBarDesign = false,
    this.keyboardType,
    this.readOnly = false,
    this.obscureText = false,
    this.onChanged,
    this.onSubmitted, // <-- ADDED
    this.validator,
    this.focusNode,
    this.prefixIcon,
    this.suffixIcon,
    this.onTap,
    this.tintColor,
    this.inputFormatters, // <-- ADDED
    this.textAlign = TextAlign.start, // <-- ADDED
  });

  @override
  Widget build(BuildContext context) {
    if (useSearchBarDesign) {
      return _buildSearchBarStyledField(context);
    }
    return _buildStandardStyledField(context);
  }

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

  Widget _buildStandardStyledField(BuildContext context) {
    return _buildTextFieldCore(context, isTransparent: false);
  }

  Widget _buildTextFieldCore(
    BuildContext context, {
    required bool isTransparent,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // --- DYNAMIC TINTING LOGIC ---
    Color finalFillColor;
    Color finalBorderColor;

    if (tintColor != null) {
      // Use the tinted colors if a tintColor is provided
      final baseColor = tintColor!;
      finalFillColor = Color.alphaBlend(
        baseColor.withValues(alpha:  isDarkMode ? 0.1 : 0.05),
        theme.colorScheme.surface,
      );
      finalBorderColor = baseColor.withValues(alpha:  isDarkMode ? 0.4 : 0.3);
    } else {
      // Fallback to the original hardcoded colors
      finalFillColor = isDarkMode
          ? const Color(0xFF2A2D3E)
          : const Color(0xFFF8F9FA);
      finalBorderColor = isDarkMode
          ? Colors.grey.shade700
          : Colors.grey.shade300;
    }

    final hintColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade500;

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      readOnly: readOnly,
      obscureText: obscureText,
      onChanged: onChanged,
      validator: validator,
      onTap: onTap,
      onFieldSubmitted: onSubmitted,     // <-- ADDED
      inputFormatters: inputFormatters, // <-- ADDED
      textAlign: textAlign,           // <-- ADDED
      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: label,
        hintStyle: TextStyle(color: hintColor, fontWeight: FontWeight.w400), // <-- FIXED
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: isTransparent ? Colors.transparent : finalFillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: isTransparent
              ? BorderSide.none
              : BorderSide(color: finalBorderColor, width: 1.0),
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