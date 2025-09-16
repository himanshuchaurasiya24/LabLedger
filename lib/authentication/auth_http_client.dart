import 'dart:convert'; // Required for jsonDecode
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:labledger/authentication/auth_exceptions.dart';
import 'package:labledger/providers/token_provider.dart';
import 'package:labledger/authentication/auth_repository.dart';

class AuthHttpClient {
  static Future<http.Response> request(
    Ref ref, {
    required String method,
    required String url,
    Map<String, String>? headers,
    String? body,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    // ... (No changes to the token retrieval logic)
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

    // --- ⭐️ AMENDED LOGIC: 401 (Token Refresh) Handling ---
    if (response.statusCode == 401) {
      try {
        final authRepo = AuthRepository.instance;
        await authRepo.verifyAuth();

        final newToken = await ref.read(tokenProvider.future);
        final refreshedHeaders = {
          ...requestHeaders,
          "Authorization": "Bearer $newToken",
        };

        // Retry the request with the new token
        response = await _makeHttpRequest(
          method: method,
          url: url,
          headers: refreshedHeaders,
          body: body,
          timeout: timeout,
        );
      } on AuthException {
        rethrow;
      } catch (e) {
        throw const NetworkException();
      }
    }

    // --- ⭐️ NEW: Centralized Success/Error Check ---
    // After attempting the request (and a potential retry), check the final status.
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // If the request was successful, return the response.
      return response;
    } else {
      // If it failed for any other reason, parse the body and throw a clean exception.
      throw _generateExceptionFromResponse(response);
    }
  }
  /// ⭐️ ENHANCED HELPER: Parses both simple and complex error responses.
  static Exception _generateExceptionFromResponse(http.Response response) {
    try {
      final dynamic errorData = jsonDecode(response.body);

      if (errorData is Map<String, dynamic>) {
        // Case 1: Simple error message (e.g., {"detail": "Not found."})
        if (errorData.containsKey('detail')) {
          final String detail = errorData['detail'] ?? 'An unknown server error occurred.';
          if (response.statusCode == 403) return AccountLockedException(detail);
          return ApiException(detail);
        }
        // Case 2: Complex validation error map (e.g., {"password": ["Too short."]})
        else {
          final String formattedMessage = _formatValidationErrors(errorData);
          return ValidationException(formattedMessage);
        }
      }
      // Fallback for non-map or primitive JSON bodies (e.g., "An error occurred")
      return ApiException(errorData.toString());
    } catch (_) {
      // Fallback for non-JSON responses
      return ServerException(
          'The server returned an unexpected response. Status: ${response.statusCode}');
    }
  }

  // --- (No changes to _makeHttpRequest or convenience methods like get, post, etc.) ---

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
          return await http
              .get(Uri.parse(url), headers: headers)
              .timeout(timeout);
        case 'POST':
          return await http
              .post(Uri.parse(url), headers: headers, body: body)
              .timeout(timeout);
        case 'PUT':
          return await http
              .put(Uri.parse(url), headers: headers, body: body)
              .timeout(timeout);
        case 'DELETE':
          return await http
              .delete(Uri.parse(url), headers: headers)
              .timeout(timeout);
        case 'PATCH':
          return await http
              .patch(Uri.parse(url), headers: headers, body: body)
              .timeout(timeout);
        default:
          throw Exception("Unsupported HTTP method: $method");
      }
    } catch (e) {
      throw const NetworkException();
    }
  }

  /// Convenience methods
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
  }) => request(
    ref,
    method: 'POST',
    url: url,
    headers: headers,
    body: body,
    timeout: timeout,
  );

  static Future<http.Response> put(
    Ref ref,
    String url, {
    Map<String, String>? headers,
    String? body,
    Duration timeout = const Duration(seconds: 10),
  }) => request(
    ref,
    method: 'PUT',
    url: url,
    headers: headers,
    body: body,
    timeout: timeout,
  );

  static Future<http.Response> delete(
    Ref ref,
    String url, {
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 10),
  }) => request(
    ref,
    method: 'DELETE',
    url: url,
    headers: headers,
    timeout: timeout,
  );

  /// ⭐️ NEW HELPER: Formats complex validation errors from a map into a single string.
  static String _formatValidationErrors(Map<String, dynamic> errors) {
    String errorMessage = '';
    errors.forEach((key, value) {
      // Join list of errors into a single line
      final String fieldError = (value is List)
          ? value.join(', ')
          : value.toString();

      // Make common field names more user-friendly
      String friendlyFieldName = key
          .replaceAll('_', ' ')
          .split(' ')
          .map((w) => w[0].toUpperCase() + w.substring(1))
          .join(' ');
      if (key == 'non_field_errors') friendlyFieldName = '';

      errorMessage += friendlyFieldName.isEmpty
          ? '$fieldError\n'
          : '$friendlyFieldName: $fieldError\n';
    });
    return errorMessage.trim();
  }
}
