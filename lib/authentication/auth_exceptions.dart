abstract class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => "AuthException: $message";
}

class InvalidCredentialsException extends AuthException {
  const InvalidCredentialsException() : super("Invalid username or password");
}

class TokenExpiredException extends AuthException {
  const TokenExpiredException() : super("Refresh token expired, please login again");
}

class NetworkException extends AuthException {
  const NetworkException() : super("Network error, please try again");
}

class ServerException extends AuthException {
  const ServerException(super.message);
}

class AccountLockedException extends AuthException {
  const AccountLockedException() : super("Your account has been locked. Please contact administrator.");
}

class SubscriptionExpiredException extends AuthException {
  final int daysLeft;
  const SubscriptionExpiredException(this.daysLeft) 
    : super("Your subscription has expired. Please renew to continue using the service.");
}

class SubscriptionInactiveException extends AuthException {
  const SubscriptionInactiveException() 
    : super("Your subscription is inactive. Please contact administrator to activate your account.");
}

class ValidationException extends AuthException {
  const ValidationException(super.message);
}