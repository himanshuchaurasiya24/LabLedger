import 'package:flutter/material.dart';
import 'package:labledger/authentication/auth_exceptions.dart';
import 'package:labledger/main.dart';
import 'package:labledger/screens/initials/login_screen.dart';

void handleApiError(Object error) {
  if (error is! AuthException) {
    return;
  }

  if (error is InvalidCredentialsException) {
    return;
  }

  final String errorMessage = error.message;

  try {
    final navigator = navigatorKey.currentState;
    if (navigator != null && navigator.overlay != null) {
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => LoginScreen(initialErrorMessage: errorMessage),
        ),
        (Route<dynamic> route) => false,
      );
    }
  } catch (e) {
    debugPrint("ERROR in handleApiError navigation: $e");
  }
}
