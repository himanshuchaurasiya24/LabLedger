// components/reusable_text_field.dart
import 'package:flutter/material.dart';

class ReusableTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final bool enabled;
  final int? maxLines;
  final String? errorText;
  final bool showTogglePasswordVisibility;

  const ReusableTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.maxLines = 1,
    this.errorText,
    this.showTogglePasswordVisibility = false,
  });

  @override
  State<ReusableTextField> createState() => _ReusableTextFieldState();
}

class _ReusableTextFieldState extends State<ReusableTextField> {
  bool _isObscured = true;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          obscureText: widget.showTogglePasswordVisibility
              ? _isObscured
              : widget.obscureText,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          enabled: widget.enabled,
          maxLines: widget.maxLines,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hintText,
            prefixIcon: widget.prefixIcon != null
                ? Icon(
                    widget.prefixIcon,
                    color: theme.colorScheme.primary,
                    size: 22,
                  )
                : null,
            suffixIcon: widget.showTogglePasswordVisibility
                ? IconButton(
                    icon: Icon(
                      _isObscured
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: theme.colorScheme.onSurfaceVariant,
                      size: 22,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscured = !_isObscured;
                      });
                    },
                  )
                : widget.suffixIcon != null
                ? Icon(
                    widget.suffixIcon,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 22,
                  )
                : null,
            errorText: widget.errorText,
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.7,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
            ),
            labelStyle: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
            hintStyle: TextStyle(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 20,
            ),
          ),
        ),
      ],
    );
  }
}

// components/reusable_button.dart
enum ButtonVariant { primary, secondary, outlined, text, elevated, tonal }

class ReusableButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final Color? backgroundColor;
  final Color? textColor;
  final double fontSize;
  final FontWeight fontWeight;

  const ReusableButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.backgroundColor,
    this.textColor,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w600,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (isLoading) {
      return _buildLoadingButton(context);
    }

    final buttonContent = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
        Text(
          text,
          style: TextStyle(fontSize: fontSize, fontWeight: fontWeight),
        ),
      ],
    );

    Widget button;

    switch (variant) {
      case ButtonVariant.primary:
        button = FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: backgroundColor ?? colorScheme.primary,
            foregroundColor: textColor ?? colorScheme.onPrimary,
            padding:
                padding ??
                const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 16),
            ),
            minimumSize: Size(width ?? 0, height ?? 52),
          ),
          child: buttonContent,
        );
        break;

      case ButtonVariant.secondary:
        button = FilledButton.tonal(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: backgroundColor ?? colorScheme.secondaryContainer,
            foregroundColor: textColor ?? colorScheme.onSecondaryContainer,
            padding:
                padding ??
                const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 16),
            ),
            minimumSize: Size(width ?? 0, height ?? 52),
          ),
          child: buttonContent,
        );
        break;

      case ButtonVariant.outlined:
        button = OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: textColor ?? colorScheme.primary,
            padding:
                padding ??
                const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 16),
            ),
            side: BorderSide(color: colorScheme.outline),
            minimumSize: Size(width ?? 0, height ?? 52),
          ),
          child: buttonContent,
        );
        break;

      case ButtonVariant.text:
        button = TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            foregroundColor: textColor ?? colorScheme.primary,
            padding:
                padding ??
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 12),
            ),
            minimumSize: Size(width ?? 0, height ?? 48),
          ),
          child: buttonContent,
        );
        break;

      case ButtonVariant.elevated:
        button = ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? colorScheme.surface,
            foregroundColor: textColor ?? colorScheme.primary,
            padding:
                padding ??
                const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 16),
            ),
            elevation: 4,
            shadowColor: colorScheme.shadow.withValues(alpha: 0.3),
            minimumSize: Size(width ?? 0, height ?? 52),
          ),
          child: buttonContent,
        );
        break;

      case ButtonVariant.tonal:
        button = FilledButton.tonal(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor:
                backgroundColor ?? colorScheme.surfaceContainerHighest,
            foregroundColor: textColor ?? colorScheme.onSurface,
            padding:
                padding ??
                const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 16),
            ),
            minimumSize: Size(width ?? 0, height ?? 52),
          ),
          child: buttonContent,
        );
        break;
    }

    return SizedBox(width: width, height: height, child: button);
  }

  Widget _buildLoadingButton(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: width,
      height: height ?? 52,
      decoration: BoxDecoration(
        color: (backgroundColor ?? colorScheme.primary).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(borderRadius ?? 16),
      ),
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: textColor ?? colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }
}
