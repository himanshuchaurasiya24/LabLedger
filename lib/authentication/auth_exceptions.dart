/// --- Base Application Exception ---
/// A unified abstract class for all custom exceptions in the app.
/// This ensures a consistent structure and a clean `toString()` method for UI display.
abstract class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

// --- Critical Auth Exceptions (For Global Error Handler) ---
/// An abstract class that extends [AppException].
/// Its purpose is to act as a "marker" for critical errors that your
/// `handleApiError` function will catch to navigate the user to the login screen.
abstract class AuthException extends AppException {
  const AuthException(super.message);
}

/// Thrown when the user's session token is invalid or expired.
class TokenExpiredException extends AuthException {
  const TokenExpiredException() : super("Your session has expired. Please log in again.");
}

/// Thrown when an admin has locked the user's account.
class AccountLockedException extends AuthException {
  const AccountLockedException(super.message);
}

/// Thrown when the user's subscription has run out.
class SubscriptionExpiredException extends AuthException {
  final int daysLeft;
  const SubscriptionExpiredException(this.daysLeft)
      : super("Your subscription has expired. Please renew to continue.");
}

/// Thrown when the user's subscription is marked as inactive by an admin.
class SubscriptionInactiveException extends AuthException {
  const SubscriptionInactiveException()
      : super("Your subscription is inactive. Please contact administrator.");
}

/// Thrown for unexpected 5xx server errors.
class ServerException extends AuthException {
  const ServerException(super.message);
}

/// Thrown for connectivity issues.
class NetworkException extends AuthException {
  const NetworkException() : super("A network error occurred. Please check your connection and try again.");
}


// --- Non-Critical API Exceptions (For Local UI Handling) ---
/// A class for API errors that should be handled locally (e.g., in a dialog)
/// and NOT trigger a global navigation to the login screen.
class ApiException extends AppException {
  const ApiException(super.message);
}

/// Thrown for incorrect login details. Handled on the login screen itself.
class InvalidCredentialsException extends ApiException {
  const InvalidCredentialsException([String? message])
      : super(message ?? "Invalid username or password.");
}

/// Thrown for general validation errors (e.g., "Name already exists").
class ValidationException extends ApiException {
  const ValidationException(super.message);
}