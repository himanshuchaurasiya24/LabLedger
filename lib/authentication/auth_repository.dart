import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:labledger/authentication/auth_exceptions.dart';
import 'package:labledger/authentication/config.dart';
import 'package:labledger/models/auth_response_model.dart';

class AuthRepository {
  // Singleton pattern
  static AuthRepository? _instance;
  static AuthRepository get instance {
    _instance ??= AuthRepository._internal();
    return _instance!;
  }

  AuthRepository._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Login with username/password
  Future<AuthResponse> login(String username, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('$globalBaseUrl/api/token/'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({"username": username, "password": password}),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(jsonDecode(response.body));

        // Validate subscription
        _validateSubscription(authResponse);

        // Store tokens
        if (authResponse.access != null && authResponse.refresh != null) {
          await _storage.write(key: "access_token", value: authResponse.access!);
          await _storage.write(key: "refresh_token", value: authResponse.refresh!);
        }

        return authResponse;
      } else if (response.statusCode == 401) {
        throw const InvalidCredentialsException();
      } else {
        throw ServerException("Login failed: ${response.body}");
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw const NetworkException();
    }
  }

  /// Verify current access token with backend
  Future<AuthResponse> verifyAuth() async {
    try {
      final accessToken = await getAccessToken();

      if (accessToken == null) {
        throw const TokenExpiredException();
      }

      final response = await http
          .get(
            Uri.parse('$globalBaseUrl/verify-auth/'),
            headers: {"Authorization": "Bearer $accessToken"},
          )
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(jsonDecode(response.body));
        _validateSubscription(authResponse);
        return authResponse;
      } else if (response.statusCode == 401) {
        try {
          return await _retryWithRefresh();
        } catch (refreshError) {
          rethrow;
        }
      } else {
        throw ServerException("Verify auth failed: ${response.body}");
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw const NetworkException();
    }
  }

  /// Helper method to retry verification with refresh token
  Future<AuthResponse> _retryWithRefresh() async {
    try {
      final refresh = await getRefreshToken();

      if (refresh == null) {
        throw const TokenExpiredException();
      }

      final newAccess = await refreshToken(refresh);

      if (newAccess == null) {
        throw const TokenExpiredException();
      }

      final retryResponse = await http
          .get(
            Uri.parse('$globalBaseUrl/verify-auth/'),
            headers: {"Authorization": "Bearer $newAccess"},
          )
          .timeout(const Duration(seconds: 5));

      if (retryResponse.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(jsonDecode(retryResponse.body));
        _validateSubscription(authResponse);
        return authResponse;
      } else if (retryResponse.statusCode == 401) {
        await logout();
        throw const TokenExpiredException();
      } else {
        throw ServerException("Verify auth retry failed: ${retryResponse.body}");
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw const NetworkException();
    }
  }

  /// Refresh access token
  Future<String?> refreshToken(String refreshToken) async {
    try {
      final response = await http
          .post(
            Uri.parse('$globalBaseUrl/api/token/refresh/'),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"refresh": refreshToken}),
          )
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newAccess = data["access"] as String?;
        if (newAccess != null) {
          await _storage.write(key: "access_token", value: newAccess);
          return newAccess;
        }
        return null;
      } else if (response.statusCode == 401) {
        await logout();
        throw const TokenExpiredException();
      } else {
        throw ServerException("Token refresh failed: ${response.body}");
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw const NetworkException();
    }
  }

  /// Validate subscription status
  void _validateSubscription(AuthResponse authResponse) {
    final subscription = authResponse.centerDetail.subscription;
    
    // Check if subscription is active
    if (!subscription.isActive) {
      throw const SubscriptionInactiveException();
    }
    
    // Check if subscription has expired
    if (subscription.daysLeft <= 0) {
      throw SubscriptionExpiredException(subscription.daysLeft);
    }
  }

  /// Logout
  Future<void> logout() async {
    await _storage.delete(key: "access_token");
    await _storage.delete(key: "refresh_token");
  }

  /// Token getters
  Future<String?> getAccessToken() async {
    return await _storage.read(key: "access_token");
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: "refresh_token");
  }

  /// Store tokens (public method)
  Future<void> storeTokens({required String accessToken, required String refreshToken}) async {
    await _storage.write(key: "access_token", value: accessToken);
    await _storage.write(key: "refresh_token", value: refreshToken);
  }

  /// Debug method to check all storage contents
  Future<void> debugStorage() async {
    try {
      await _storage.readAll();
    } catch (_) {}
  }
  Future<String> fetchMinimumAppVersion() async {
    try {
      final response = await http
          .get(Uri.parse('$globalBaseUrl/api/app-info/'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final version = data['minimum_required_version'];
        if (version != null && version is String && version.isNotEmpty) {
          return version;
        } else {
          // If the key is missing or null in the response, it's a server-side error.
          throw const ServerException("Invalid version format from server.");
        }
      } else {
        // If the server returns any error code (like 500), it's a failure.
        throw ServerException(
            "Could not connect to server to verify app version.");
      }
    } catch (e) {
      // Re-throw any known exceptions or wrap others in a NetworkException.
      if (e is AuthException) rethrow;
      throw const NetworkException();
    }
  }
}