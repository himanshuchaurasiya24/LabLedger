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
        _validateSubscription(authResponse);

        if (authResponse.access != null && authResponse.refresh != null) {
          await _storage.write(key: "access_token", value: authResponse.access!);
          await _storage.write(key: "refresh_token", value: authResponse.refresh!);
        }

        return authResponse;
      } else {
        // AMENDED: Centralized error parsing
        final errorBody = jsonDecode(response.body);
        final errorMessage = errorBody['detail'] as String?;

        if (response.statusCode == 401) {
          throw InvalidCredentialsException(errorMessage);
        } else if (response.statusCode == 403) {
          throw AccountLockedException(errorMessage);
        } else {
          throw ServerException(errorMessage ?? "Login failed: An unknown error occurred.");
        }
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw const NetworkException();
    }
  }

  Future<AuthResponse> verifyAuth() async {
    try {
      final accessToken = await getAccessToken();
      if (accessToken == null) throw const TokenExpiredException();

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
        return await _retryWithRefresh();
      } else if (response.statusCode == 403) {
        await logout();
        final errorBody = jsonDecode(response.body);
        final errorMessage = errorBody['detail'] as String?;
        throw AccountLockedException(errorMessage);
      } else {
        throw ServerException("Verify auth failed: ${response.body}");
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw const NetworkException();
    }
  }

  Future<AuthResponse> _retryWithRefresh() async {
    try {
      final refresh = await getRefreshToken();
      if (refresh == null) throw const TokenExpiredException();

      final newAccess = await refreshToken(refresh);
      if (newAccess == null) throw const TokenExpiredException();

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
      } else {
        await logout();
        if (retryResponse.statusCode == 403) {
            final errorBody = jsonDecode(retryResponse.body);
            final errorMessage = errorBody['detail'] as String?;
            throw AccountLockedException(errorMessage);
        }
        // Any other failure after a refresh is a definitive session expiry.
        throw const TokenExpiredException();
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw const NetworkException();
    }
  }

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
      } else {
        await logout();
        throw const TokenExpiredException();
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw const NetworkException();
    }
  }

  void _validateSubscription(AuthResponse authResponse) {
    final subscription = authResponse.centerDetail.subscription;
    if (!subscription.isActive) throw const SubscriptionInactiveException();
    if (subscription.daysLeft <= 0) throw SubscriptionExpiredException(subscription.daysLeft);
  }

  Future<void> logout() async {
    await _storage.delete(key: "access_token");
    await _storage.delete(key: "refresh_token");
  }

  Future<String?> getAccessToken() async => await _storage.read(key: "access_token");
  Future<String?> getRefreshToken() async => await _storage.read(key: "refresh_token");

  Future<void> storeTokens({required String accessToken, required String refreshToken}) async {
    await _storage.write(key: "access_token", value: accessToken);
    await _storage.write(key: "refresh_token", value: refreshToken);
  }

  Future<void> debugStorage() async {
    try { await _storage.readAll(); } catch (_) {}
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
          throw const ServerException("Invalid version format from server.");
        }
      } else {
        throw ServerException("Could not connect to server to verify app version.");
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw const NetworkException();
    }
  }
}