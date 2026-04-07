import 'package:flutter/material.dart';

class AppInkWell extends StatelessWidget {
  const AppInkWell({
    super.key,
    required this.child,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.onSecondaryTap,
    this.onTapDown,
    this.onTapCancel,
    this.onHover,
    this.onHighlightChanged,
    this.borderRadius,
    this.customBorder,
    this.splashColor,
    this.highlightColor,
    this.hoverColor,
    this.focusColor,
    this.radius,
    this.enableFeedback = true,
    this.excludeFromSemantics = false,
    this.canRequestFocus = true,
    this.mouseCursor,
  });

  final Widget child;
  final GestureTapCallback? onTap;
  final GestureTapCallback? onDoubleTap;
  final GestureLongPressCallback? onLongPress;
  final GestureTapCallback? onSecondaryTap;
  final GestureTapDownCallback? onTapDown;
  final GestureTapCancelCallback? onTapCancel;
  final ValueChanged<bool>? onHover;
  final ValueChanged<bool>? onHighlightChanged;
  final BorderRadius? borderRadius;
  final ShapeBorder? customBorder;
  final Color? splashColor;
  final Color? highlightColor;
  final Color? hoverColor;
  final Color? focusColor;
  final double? radius;
  final bool enableFeedback;
  final bool excludeFromSemantics;
  final bool canRequestFocus;
  final MouseCursor? mouseCursor;

  @override
  Widget build(BuildContext context) {
    final hasAction =
        onTap != null ||
        onDoubleTap != null ||
        onLongPress != null ||
        onSecondaryTap != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onDoubleTap: onDoubleTap,
        onLongPress: onLongPress,
        onSecondaryTap: onSecondaryTap,
        onTapDown: onTapDown,
        onTapCancel: onTapCancel,
        onHover: onHover,
        onHighlightChanged: onHighlightChanged,
        borderRadius: borderRadius,
        customBorder: customBorder,
        splashColor: splashColor,
        highlightColor: highlightColor,
        hoverColor: hoverColor,
        focusColor: focusColor,
        radius: radius,
        enableFeedback: enableFeedback,
        excludeFromSemantics: excludeFromSemantics,
        canRequestFocus: canRequestFocus,
        mouseCursor:
            mouseCursor ??
            (hasAction ? SystemMouseCursors.click : SystemMouseCursors.basic),
        child: child,
      ),
    );
  }
}
