// authentication/auth_http_client.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/providers/token_provider.dart';
import 'package:labledger/authentication/auth_repository.dart';
import 'package:labledger/authentication/auth_exceptions.dart';
import 'package:http/http.dart' as http;

class AuthHttpClient {
  /// Makes an authenticated HTTP request with automatic token refresh and subscription validation.
  static Future<http.Response> request(
    Ref ref, {
    required String method,
    required String url,
    Map<String, String>? headers,
    String? body,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    String? token;
    try {
      token = await ref.read(tokenProvider.future);
    } catch (e) {
      // If no token is available at all, this is a critical auth failure.
      throw const TokenExpiredException();
    }

    final requestHeaders = {
      'Content-Type': 'application/json', // Set default content type
      ...?headers,
      "Authorization": "Bearer $token",
    };

    http.Response response = await _makeHttpRequest(
      method: method,
      url: url,
      headers: requestHeaders,
      body: body,
      timeout: timeout,
    );

    // --- AMENDED LOGIC ---
    // Handle both 401 (Unauthorized) and 403 (Forbidden).
    // The 403 code from your backend indicates an inactive subscription.
    if (response.statusCode == 401 || response.statusCode == 403) {
      try {
        final authRepo = AuthRepository.instance;
        // This single call handles both token refresh AND subscription validation.
        // It will throw SubscriptionInactiveException if the account is locked.
        await authRepo.verifyAuth();

        // If verifyAuth succeeds, a new token should be available.
        final newToken = await ref.read(tokenProvider.future);
        final refreshedHeaders = {
          ...requestHeaders, // Carry over original headers
          "Authorization": "Bearer $newToken",
        };

        // Retry the original request with the new token
        response = await _makeHttpRequest(
          method: method,
          url: url,
          headers: refreshedHeaders,
          body: body,
          timeout: timeout,
        );

        // If the retry also fails, the session is truly invalid.
        if (response.statusCode == 401 || response.statusCode == 403) {
          throw const TokenExpiredException();
        }

      } on AuthException {
        // If verifyAuth throws ANY specific auth exception (TokenExpired, SubscriptionInactive, etc.),
        // catch it and re-throw it so the UI layer's listener can handle it.
        rethrow;
      } catch (e) {
        // Catch any other unexpected errors during the refresh process.
        throw const NetworkException();
      }
    }

    return response;
  }

  /// Helper method to make actual HTTP requests
  static Future<http.Response> _makeHttpRequest({
    required String method,
    required String url,
    required Map<String, String> headers,
    String? body,
    required Duration timeout,
  }) async {
    try {
      switch (method.toUpperCase()) {
        case 'GET':
          return await http.get(Uri.parse(url), headers: headers).timeout(timeout);
        case 'POST':
          return await http.post(Uri.parse(url), headers: headers, body: body).timeout(timeout);
        case 'PUT':
          return await http.put(Uri.parse(url), headers: headers, body: body).timeout(timeout);
        case 'DELETE':
          return await http.delete(Uri.parse(url), headers: headers).timeout(timeout);
        case 'PATCH':
          return await http.patch(Uri.parse(url), headers: headers, body: body).timeout(timeout);
        default:
          throw Exception("Unsupported HTTP method: $method");
      }
    } catch (e) {
      // AMENDED: Throw a specific, catchable exception for all network-related issues.
      throw const NetworkException();
    }
  }

  /// Convenience methods for common HTTP verbs
  static Future<http.Response> get(
    Ref ref,
    String url, {
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 10),
  }) =>
      request(ref, method: 'GET', url: url, headers: headers, timeout: timeout);

  static Future<http.Response> post(
    Ref ref,
    String url, {
    Map<String, String>? headers,
    String? body,
    Duration timeout = const Duration(seconds: 10),
  }) =>
      request(ref, method: 'POST', url: url, headers: headers, body: body, timeout: timeout);

  static Future<http.Response> put(
    Ref ref,
    String url, {
    Map<String, String>? headers,
    String? body,
    Duration timeout = const Duration(seconds: 10),
  }) =>
      request(ref, method: 'PUT', url: url, headers: headers, body: body, timeout: timeout);

  static Future<http.Response> delete(
    Ref ref,
    String url, {
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 10),
  }) =>
      request(ref, method: 'DELETE', url: url, headers: headers, timeout: timeout);
}