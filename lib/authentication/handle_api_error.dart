// methods/error_handler.dart

import 'package:flutter/material.dart';
import 'package:labledger/authentication/auth_exceptions.dart';
import 'package:labledger/main.dart';
import 'package:labledger/screens/initials/login_screen.dart';

/// A global handler for critical API errors that require navigation.
void handleApiError(Object error) {
  String errorMessage;

  // --- AMENDED LOGIC ---
  switch (error.runtimeType) {
    case const (TokenExpiredException):
      errorMessage = "Your session has expired. Please log in again.";
      break;
    case const (AccountLockedException): // <-- ADDED THIS CASE
      errorMessage = "Your account is locked. Please contact support.";
      break;
    case const (SubscriptionInactiveException): // <-- MESSAGE UPDATED FOR CLARITY
      errorMessage = "Your subscription is inactive. Please contact support.";
      break;
    case const (SubscriptionExpiredException):
      errorMessage = "Your subscription has expired. Please renew.";
      break;
    case const (ServerException):
      errorMessage = "A server error occurred. Please try again later.";
      break;
    default:
      // For any other non-critical error, we do nothing.
      return;
  }

  navigatorKey.currentState?.pushAndRemoveUntil(
    MaterialPageRoute(
      builder: (context) => LoginScreen(initialErrorMessage: errorMessage),
    ),
    (Route<dynamic> route) => false,
  );
}