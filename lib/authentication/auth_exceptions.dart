class AuthException implements Exception {
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
  const ServerException(super.msg);
}
