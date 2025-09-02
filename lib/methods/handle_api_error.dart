// methods/error_handler.dart

import 'package:flutter/material.dart';
import 'package:labledger/authentication/auth_exceptions.dart';
import 'package:labledger/main.dart';
import 'package:labledger/screens/initials/login_screen.dart';

/// A global handler for critical API errors that require navigation.
void handleApiError(Object error) {
  String errorMessage;

  // MODIFIED: Added ServerException to the list of critical errors.
  switch (error.runtimeType) {
    case const (TokenExpiredException):
      errorMessage = "Your session has expired. Please log in again.";
      break;
    case const (SubscriptionInactiveException):
      errorMessage = "Your account is locked. Please contact support.";
      break;
    case const (SubscriptionExpiredException):
      errorMessage = "Your subscription has expired. Please renew.";
      break;
    case const (ServerException):
      // This will now catch errors like the "Invalid version format".
      errorMessage = "A server error occurred. Please try again later.";
      break;
    default:
      // For any other non-critical error, we do nothing.
      return;
  }

  // Now that ServerException is handled, this will be triggered correctly.
  navigatorKey.currentState?.pushAndRemoveUntil(
    MaterialPageRoute(
      builder: (context) => LoginScreen(initialErrorMessage: errorMessage),
    ),
    (Route<dynamic> route) => false,
  );
}