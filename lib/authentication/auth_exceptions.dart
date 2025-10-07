
abstract class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}
abstract class AuthException extends AppException {
  const AuthException(super.message);
}

class TokenExpiredException extends AuthException {
  const TokenExpiredException() : super("Your session has expired. Please log in again.");
}

class AccountLockedException extends AuthException {
  const AccountLockedException(super.message);
}

class SubscriptionExpiredException extends AuthException {
  final int daysLeft;
  const SubscriptionExpiredException(this.daysLeft)
      : super("Your subscription has expired. Please renew to continue.");
}

class SubscriptionInactiveException extends AuthException {
  const SubscriptionInactiveException()
      : super("Your subscription is inactive. Please contact administrator.");
}

class ServerException extends AuthException {
  const ServerException(super.message);
}

class NetworkException extends AuthException {
  const NetworkException() : super("A network error occurred. Please check your connection and try again.");
}

class ApiException extends AppException {
  const ApiException(super.message);
}

class InvalidCredentialsException extends ApiException {
  const InvalidCredentialsException([String? message])
      : super(message ?? "Invalid username or password.");
}

class ValidationException extends ApiException {
  const ValidationException(super.message);
}