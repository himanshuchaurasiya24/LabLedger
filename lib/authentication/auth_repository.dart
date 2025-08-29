import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:labledger/authentication/auth_exceptions.dart';
import 'package:labledger/authentication/config.dart';

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
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('$globalBaseUrl/api/token/'),
            body: {"username": username, "password": password},
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final access = data["access"] as String?;
        final refresh = data["refresh"] as String?;

        if (access == null || refresh == null) {
          throw const ServerException("Invalid token response from server");
        }

        await _storage.write(key: "access_token", value: access);
        await _storage.write(key: "refresh_token", value: refresh);

        final normalizedData = _normalizeUserData(data);
        return normalizedData;
      } else if (response.statusCode == 401) {
        throw const InvalidCredentialsException();
      } else {
        throw ServerException("Unexpected error: ${response.body}");
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw const NetworkException();
    }
  }

  /// Verify current access token with backend
  Future<Map<String, dynamic>> verifyAuth() async {
    await debugStorage();

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
        final userData = jsonDecode(response.body);
        final normalizedData = _normalizeUserData(userData);
        _validateUserData(normalizedData);
        return normalizedData;
      } else if (response.statusCode == 401) {
        try {
          final data = await _retryWithRefresh();
          return data;
        } catch (refreshError) {
          rethrow;
        }
      } else {
        throw ServerException("Unexpected verify response: ${response.body}");
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw const NetworkException();
    }
  }

  /// Helper method to retry verification with refresh token
  Future<Map<String, dynamic>> _retryWithRefresh() async {
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
        final userData = jsonDecode(retryResponse.body);
        final normalizedData = _normalizeUserData(userData);
        _validateUserData(normalizedData);
        return normalizedData;
      } else if (retryResponse.statusCode == 401) {
        await logout();
        throw const TokenExpiredException();
      } else {
        throw ServerException(
          "Unexpected verify response after refresh: ${retryResponse.body}",
        );
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
        throw ServerException("Unexpected refresh response: ${response.body}");
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw const NetworkException();
    }
  }

  /// Convert snake_case API response to camelCase for HomeScreen
  Map<String, dynamic> _normalizeUserData(Map<String, dynamic> rawData) {
    final normalized = {
      'id': rawData['id'],
      'firstName': rawData['first_name'],
      'lastName': rawData['last_name'],
      'username': rawData['username'],
      'isAdmin': rawData['is_admin'],
      'centerDetail': rawData['center_detail'],
      if (rawData.containsKey('access')) 'access': rawData['access'],
      if (rawData.containsKey('refresh')) 'refresh': rawData['refresh'],
    };
    return normalized;
  }

  /// Validate that userData contains all required fields
  void _validateUserData(Map<String, dynamic> userData) {
    final requiredFields = [
      'id',
      'firstName',
      'lastName',
      'username',
      'isAdmin',
      'centerDetail',
    ];

    for (final field in requiredFields) {
      if (!userData.containsKey(field) || userData[field] == null) {
        throw ServerException("Missing required field: $field in user data");
      }
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

  /// Debug method to check all storage contents
  Future<void> debugStorage() async {
    try {
      await _storage.readAll();
    } catch (_) {}
  }
}
