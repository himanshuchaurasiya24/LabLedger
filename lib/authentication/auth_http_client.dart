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
      throw const TokenExpiredException();
    }

    final requestHeaders = {
      'Content-Type': 'application/json',
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
    if (response.statusCode == 403) {
      // A 403 from the backend is a definitive "locked" or "forbidden" state.
      // Do not attempt to refresh the token, just throw the specific exception.
      throw const AccountLockedException();
    }
    
    if (response.statusCode == 401) {
      // A 401 indicates an expired token, so we attempt a refresh and retry.
      try {
        final authRepo = AuthRepository.instance;
        // This call handles refresh and re-validates the user,
        // throwing the correct exception if anything fails.
        await authRepo.verifyAuth();

        final newToken = await ref.read(tokenProvider.future);
        final refreshedHeaders = {
          ...requestHeaders,
          "Authorization": "Bearer $newToken",
        };

        response = await _makeHttpRequest(
          method: method,
          url: url,
          headers: refreshedHeaders,
          body: body,
          timeout: timeout,
        );

        if (response.statusCode == 401 || response.statusCode == 403) {
          throw const TokenExpiredException();
        }

      } on AuthException {
        // If verifyAuth throws ANY specific auth exception, re-throw it
        // so the UI layer's listener can handle it.
        rethrow;
      } catch (e) {
        throw const NetworkException();
      }
    }

    return response;
  }

  // --- NO CHANGES BELOW THIS LINE ---

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
        case 'GET': return await http.get(Uri.parse(url), headers: headers).timeout(timeout);
        case 'POST': return await http.post(Uri.parse(url), headers: headers, body: body).timeout(timeout);
        case 'PUT': return await http.put(Uri.parse(url), headers: headers, body: body).timeout(timeout);
        case 'DELETE': return await http.delete(Uri.parse(url), headers: headers).timeout(timeout);
        case 'PATCH': return await http.patch(Uri.parse(url), headers: headers, body: body).timeout(timeout);
        default: throw Exception("Unsupported HTTP method: $method");
      }
    } catch (e) {
      throw const NetworkException();
    }
  }

  /// Convenience methods
  static Future<http.Response> get(Ref ref, String url, {Map<String, String>? headers, Duration timeout = const Duration(seconds: 10)}) =>
      request(ref, method: 'GET', url: url, headers: headers, timeout: timeout);

  static Future<http.Response> post(Ref ref, String url, {Map<String, String>? headers, String? body, Duration timeout = const Duration(seconds: 10)}) =>
      request(ref, method: 'POST', url: url, headers: headers, body: body, timeout: timeout);

  static Future<http.Response> put(Ref ref, String url, {Map<String, String>? headers, String? body, Duration timeout = const Duration(seconds: 10)}) =>
      request(ref, method: 'PUT', url: url, headers: headers, body: body, timeout: timeout);

  static Future<http.Response> delete(Ref ref, String url, {Map<String, String>? headers, Duration timeout = const Duration(seconds: 10)}) =>
      request(ref, method: 'DELETE', url: url, headers: headers, timeout: timeout);
}