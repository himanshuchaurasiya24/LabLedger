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

    if (response.statusCode == 401) {
      try {
        final authRepo = AuthRepository.instance;
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
      } on AuthException {
        rethrow;
      } catch (e) {
        throw const NetworkException();
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    } else {
      throw _generateExceptionFromResponse(response);
    }
  }

  static Exception _generateExceptionFromResponse(http.Response response) {
    try {
      final dynamic errorData = jsonDecode(response.body);

      if (errorData is Map<String, dynamic>) {
        if (errorData.containsKey('detail')) {
          final String detail =
              errorData['detail'] ?? 'An unknown server error occurred.';
          if (response.statusCode == 403) return AccountLockedException(detail);
          return ApiException(detail);
        } else {
          final String formattedMessage = _formatValidationErrors(errorData);
          return ValidationException(formattedMessage);
        }
      }
      return ApiException(errorData.toString());
    } catch (_) {
      return ServerException(
        'The server returned an unexpected response. Status: ${response.statusCode}',
      );
    }
  }

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

  /// ⭐️ NEW: Handles multipart (file upload) POST requests.
  static Future<http.Response> postMultipart(
    Ref ref,
    String url, {
    required Map<String, String> fields,
    required String filePath,
    required String fileField,
    Duration timeout = const Duration(
      seconds: 30,
    ), // Longer timeout for uploads
  }) async {
    return _requestMultipart(
      ref,
      method: 'POST',
      url: url,
      fields: fields,
      filePath: filePath,
      fileField: fileField,
      timeout: timeout,
    );
  }

  /// ⭐️ NEW: Handles multipart (file upload) PUT requests.
  static Future<http.Response> putMultipart(
    Ref ref,
    String url, {
    required Map<String, String> fields,
    required String filePath,
    required String fileField,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    return _requestMultipart(
      ref,
      method: 'PUT',
      url: url,
      fields: fields,
      filePath: filePath,
      fileField: fileField,
      timeout: timeout,
    );
  }

  /// ⭐️ NEW HELPER: Private method to handle the core logic for multipart requests.
  static Future<http.Response> _requestMultipart(
    Ref ref, {
    required String method,
    required String url,
    required Map<String, String> fields,
    required String filePath,
    required String fileField,
    required Duration timeout,
  }) async {
    String? token;
    try {
      token = await ref.read(tokenProvider.future);
    } catch (e) {
      throw const TokenExpiredException();
    }

    // Helper function to create, populate, and send the multipart request.
    // This is needed to avoid duplicating code for the token-refresh retry logic.
    Future<http.Response> sendRequest(String currentToken) async {
      try {
        final request = http.MultipartRequest(method, Uri.parse(url));
        request.headers['Authorization'] = 'Bearer $currentToken';
        request.fields.addAll(fields);
        request.files.add(
          await http.MultipartFile.fromPath(fileField, filePath),
        );

        final streamedResponse = await request.send().timeout(timeout);
        // Convert the streamed response into a regular http.Response
        return await http.Response.fromStream(streamedResponse);
      } catch (e) {
        throw const NetworkException();
      }
    }

    // Make the initial request attempt
    http.Response response = await sendRequest(token!);

    // --- Token Refresh Handling (Identical to your existing 'request' method) ---
    if (response.statusCode == 401) {
      try {
        final authRepo = AuthRepository.instance;
        await authRepo.verifyAuth();

        final newToken = await ref.read(tokenProvider.future);
        // Retry the request with the new token
        response = await sendRequest(newToken!);
      } on AuthException {
        rethrow;
      } catch (e) {
        throw const NetworkException();
      }
    }

    // --- Centralized Success/Error Check ---
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    } else {
      // Reuse your existing powerful exception generator
      throw _generateExceptionFromResponse(response);
    }
  }

  static String _formatValidationErrors(Map<String, dynamic> errors) {
    String errorMessage = '';
    errors.forEach((key, value) {
      final String fieldError = (value is List)
          ? value.join(', ')
          : value.toString();

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
