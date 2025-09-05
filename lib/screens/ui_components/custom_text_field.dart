// lib/methods/custom_methods.dart OR lib/widgets/custom_text_field.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool readOnly;
  final bool required;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.focusNode,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.readOnly = false,
    this.required = false,
    this.onTap,
    this.validator,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.black87,
                fontSize: 14,
              ),
            ),
            if (required)
              const Text(
                ' *',
                style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          readOnly: readOnly,
          onTap: onTap,
          validator: validator,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            prefixIcon: prefixIcon != null
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: prefixIcon,
                  )
                : null,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF8F9FA),
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF0072B5),
                width: 2.0,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.red.shade400,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.red.shade400,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}