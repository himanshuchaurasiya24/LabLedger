// authentication/auth_exceptions.dart

abstract class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => "AuthException: $message";
}

class InvalidCredentialsException extends AuthException {
  const InvalidCredentialsException([String? message]) 
    : super(message ?? "Invalid username or password");
}

class TokenExpiredException extends AuthException {
  const TokenExpiredException() : super("Your session has expired. Please log in again");
}

class NetworkException extends AuthException {
  const NetworkException() : super("Network error, please try again");
}

class ServerException extends AuthException {
  const ServerException(super.message);
}

class AccountLockedException extends AuthException {
  const AccountLockedException([String? message]) 
    : super(message ?? "Your account is locked. Please contact administrator.");
}

class SubscriptionExpiredException extends AuthException {
  final int daysLeft;
  const SubscriptionExpiredException(this.daysLeft) 
    : super("Your subscription has expired. Please renew to continue using the service.");
}

class SubscriptionInactiveException extends AuthException {
  const SubscriptionInactiveException() 
    : super("Your subscription is inactive. Please contact administrator.");
}

class ValidationException extends AuthException {
  const ValidationException(super.message);
}