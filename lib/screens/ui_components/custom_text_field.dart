import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:labledger/constants/constants.dart'; // Import for InputFormatters

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool useSearchBarDesign;
  final TextInputType? keyboardType;
  final bool readOnly;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator; // For custom validation
  final FocusNode? focusNode;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final Color? tintColor;
  final List<TextInputFormatter>? inputFormatters;
  final TextAlign textAlign;

  // --- ADDED VALIDATION PROPERTIES ---
  final bool isRequired;
  final bool isNumeric;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.useSearchBarDesign = false,
    this.keyboardType,
    this.readOnly = false,
    this.obscureText = false,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.focusNode,
    this.prefixIcon,
    this.suffixIcon,
    this.onTap,
    this.tintColor,
    this.inputFormatters,
    this.textAlign = TextAlign.start,
    // --- ADDED TO CONSTRUCTOR (with defaults) ---
    this.isRequired = false,
    this.isNumeric = false,
  });

  @override
  Widget build(BuildContext context) {
    if (useSearchBarDesign) {
      return _buildSearchBarStyledField(context);
    }
    return _buildStandardStyledField(context);
  }

  Widget _buildSearchBarStyledField(BuildContext context) {
    // ... (This method is unchanged)
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
            color: Colors.black.withValues(alpha: isLightMode ? 0.08 : 0.3),
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

    // ... (Your dynamic tinting logic is unchanged)
    Color finalFillColor;
    Color finalBorderColor;
    if (tintColor != null) {
      final baseColor = tintColor!;
      finalFillColor = Color.alphaBlend(
        baseColor.withValues(alpha: isDarkMode ? 0.1 : 0.05),
        theme.colorScheme.surface,
      );
      finalBorderColor = baseColor.withValues(alpha: isDarkMode ? 0.4 : 0.3);
    } else {
      finalFillColor = isDarkMode
          ? const Color(0xFF2A2D3E)
          : const Color(0xFFF8F9FA);
      finalBorderColor = isDarkMode
          ? Colors.grey.shade700
          : Colors.grey.shade300;
    }
    final hintColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade500;

    // --- MASTER VALIDATOR FUNCTION ---
    String? masterValidator(String? value) {
      final trimmedValue = value?.trim() ?? '';

      // 1. Built-in 'isRequired' check
      if (isRequired && trimmedValue.isEmpty) {
        return '$label cannot be empty.';
      }

      // 2. Built-in 'isNumeric' check (only if not empty)
      if (isNumeric &&
          trimmedValue.isNotEmpty &&
          double.tryParse(trimmedValue) == null) {
        return '$label must be a valid number.';
      }

      // 3. Custom external validator (if provided)
      if (validator != null) {
        return validator!(value);
      }

      // All checks passed
      return null;
    }

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      readOnly: readOnly,
      obscureText: obscureText,
      onChanged: onChanged,
      validator: masterValidator, // <-- USE MASTER VALIDATOR
      onTap: onTap,
      onFieldSubmitted: onSubmitted,
      inputFormatters: _getEffectiveInputFormatters(), // USE THE NEW METHOD
      textAlign: textAlign,
      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: label,
        hintStyle: TextStyle(color: hintColor, fontWeight: FontWeight.w400),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        prefixIconColor: finalBorderColor,
        suffixIconColor: finalBorderColor,
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
              : BorderSide(color: finalBorderColor, width: 2.2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: theme.colorScheme.error, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: theme.colorScheme.error, width: 1.5),
        ),
        contentPadding: EdgeInsets.all(defaultPadding),
      ),
    );
  }

  List<TextInputFormatter> _getEffectiveInputFormatters() {
    final List<TextInputFormatter> formatters = [
      ...?inputFormatters, // Add user-supplied formatters first
    ];

    // Safety check: specific keyboard types usually don't need capitalization
    if (keyboardType == TextInputType.number ||
        keyboardType == TextInputType.phone ||
        keyboardType == TextInputType.datetime) {
      return formatters;
    }

    final lowerLabel = label.toLowerCase();

    // 1. Username / Email: Force lowercase + no spaces
    if (lowerLabel.contains('username') || lowerLabel.contains('email')) {
      formatters.add(
        FilteringTextInputFormatter.deny(RegExp(r'\s')),
      ); // No spaces
      formatters.add(LowerCaseTextFormatter());
      return formatters;
    }

    // 2. Password: Do nothing (preserve case)
    if (obscureText || lowerLabel.contains('password')) {
      return formatters;
    }

    // 3. Default: Title Case (Capitalize first letter of every word)
    // Only apply if it's NOT a numeric field (just to be safe)
    if (!isNumeric) {
      formatters.add(TitleCaseTextInputFormatter());
    }

    return formatters;
  }
}

class TitleCaseTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    // Capitalize first letter of each word
    // We use a regex to find the first letter of each word boundary
    String result = newValue.text.splitMapJoin(
      RegExp(r'\b[a-zA-Z]'),
      onMatch: (m) => m.group(0)!.toUpperCase(),
      onNonMatch: (n) => n,
    );

    return TextEditingValue(text: result, selection: newValue.selection);
  }
}

class LowerCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toLowerCase(),
      selection: newValue.selection,
    );
  }
}
