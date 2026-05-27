import 'package:flutter/widgets.dart';

mixin ControllerDisposer {
  final List<TextEditingController> _registeredControllers = [];

  TextEditingController createController([String? initialText]) {
    final c = TextEditingController(text: initialText);
    _registeredControllers.add(c);
    return c;
  }

  void disposeControllers() {
    for (final c in _registeredControllers) {
      try {
        c.dispose();
      } catch (_) {
        // ignore
      }
    }
    _registeredControllers.clear();
  }
}
