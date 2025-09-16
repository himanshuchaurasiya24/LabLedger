import 'dart:async';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:labledger/authentication/auth_exceptions.dart';
import 'package:labledger/authentication/config.dart';
import 'package:labledger/models/auth_response_model.dart';

class AuthRepository {
  // --- Constants for Endpoints and Timeouts ---
  static const _tokenEndpoint = '/api/token/';
  static const _refreshEndpoint = '/api/token/refresh/';
  static const _verifyEndpoint = '/verify-auth/';
  static const _appInfoEndpoint = '/api/app-info/';
  static const _defaultTimeout = Duration(seconds: 10);

  // --- Singleton Pattern (No Changes) ---
  static AuthRepository? _instance;
  static AuthRepository get instance {
    _instance ??= AuthRepository._internal();
    return _instance!;
  }
  AuthRepository._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // --- Public API Methods ---

  /// Attempts to log in the user and stores tokens upon success.
  Future<AuthResponse> login(String username, String password) async {
    final response = await _post(
      _tokenEndpoint,
      {"username": username, "password": password},
    );

    if (response.statusCode == 200) {
      final authResponse = AuthResponse.fromJson(jsonDecode(response.body));
      _validateSubscription(authResponse);
      await _storeTokensFromResponse(authResponse);
      return authResponse;
    } else {
      final detail = _parseErrorDetail(response.body);
      switch (response.statusCode) {
        case 401:
          throw InvalidCredentialsException(detail);
        case 403:
          throw AccountLockedException(detail!);
        default:
          throw ServerException(detail ?? "Login failed: An unknown error occurred.");
      }
    }
  }

  /// Verifies the current user's authentication status and subscription.
  /// Attempts to refresh the token automatically if it has expired.
  Future<AuthResponse> verifyAuth() async {
    try {
      final accessToken = await getAccessToken();
      if (accessToken == null) throw const TokenExpiredException();
      return await _performVerification(accessToken);
    } on TokenExpiredException {
      // If the initial token is expired, try refreshing it.
      return await _retryWithRefresh();
    }
  }

  /// Refreshes the access token using the stored refresh token.
  Future<String?> refreshToken(String refreshToken) async {
    final response = await _post(
      _refreshEndpoint,
      {"refresh": refreshToken},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final newAccess = data["access"] as String?;
      if (newAccess != null) {
        await _storage.write(key: "access_token", value: newAccess);
        return newAccess;
      }
    }
    // If refresh fails for any reason, the session is invalid.
    await logout();
    throw const TokenExpiredException();
  }
  
  /// Logs the user out by deleting their stored tokens.
  Future<void> logout() async {
    await _storage.delete(key: "access_token");
    await _storage.delete(key: "refresh_token");
  }

  /// Fetches the minimum required application version from the server.
  Future<String> fetchMinimumAppVersion() async {
    final response = await _get(_appInfoEndpoint);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final version = data['minimum_required_version'];
      if (version is String && version.isNotEmpty) {
        return version;
      }
    }
    // If response is not 200 or version format is invalid
    throw const ServerException("Could not verify app version from server.");
  }


  // --- Private Helper Methods ---

  /// Centralized method to perform the actual auth verification call.
  Future<AuthResponse> _performVerification(String token) async {
    final response = await _get(_verifyEndpoint, token: token);

    if (response.statusCode == 200) {
      final authResponse = AuthResponse.fromJson(jsonDecode(response.body));
      _validateSubscription(authResponse);
      return authResponse;
    } else if (response.statusCode == 401) {
      // A 401 here specifically means the token is expired.
      throw const TokenExpiredException();
    } else {
      await logout();
      final detail = _parseErrorDetail(response.body);
      if (response.statusCode == 403) {
        throw AccountLockedException(detail!);
      }
      throw ServerException(detail ?? "Authentication failed.");
    }
  }

  /// Handles the complete token refresh and verification retry flow.
  Future<AuthResponse> _retryWithRefresh() async {
    final refreshTokenValue = await getRefreshToken();
    if (refreshTokenValue == null) throw const TokenExpiredException();

    final newAccessToken = await refreshToken(refreshTokenValue);
    if (newAccessToken == null) throw const TokenExpiredException();

    // Retry the verification with the new token.
    return await _performVerification(newAccessToken);
  }

  /// Validates the subscription status from an [AuthResponse].
  void _validateSubscription(AuthResponse authResponse) {
    final subscription = authResponse.centerDetail.subscription;
    if (!subscription.isActive) throw const SubscriptionInactiveException();
    if (subscription.daysLeft <= 0) throw SubscriptionExpiredException(subscription.daysLeft);
  }

  /// Safely parses the 'detail' message from a JSON error body.
  String? _parseErrorDetail(String responseBody) {
    try {
      return jsonDecode(responseBody)['detail'] as String?;
    } catch (_) {
      return null; // Return null if body is not valid JSON or doesn't contain 'detail'
    }
  }

  // --- Centralized HTTP Request Helpers ---

  Future<http.Response> _get(String endpoint, {String? token}) async {
    try {
      final headers = {'Content-Type': 'application/json'};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      return await http
          .get(Uri.parse('$globalBaseUrl$endpoint'), headers: headers)
          .timeout(_defaultTimeout);
    } catch (e) {
      // Rethrow specific auth exceptions, otherwise wrap in NetworkException
      if (e is AuthException) rethrow;
      throw const NetworkException();
    }
  }

  Future<http.Response> _post(String endpoint, Map<String, dynamic> body) async {
    try {
      return await http
          .post(
            Uri.parse('$globalBaseUrl$endpoint'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(_defaultTimeout);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw const NetworkException();
    }
  }


  // --- Secure Storage Accessors ---

  Future<void> _storeTokensFromResponse(AuthResponse response) async {
    if (response.access != null && response.refresh != null) {
      await _storage.write(key: "access_token", value: response.access!);
      await _storage.write(key: "refresh_token", value: response.refresh!);
    }
  }

  Future<String?> getAccessToken() => _storage.read(key: "access_token");
  Future<String?> getRefreshToken() => _storage.read(key: "refresh_token");
}