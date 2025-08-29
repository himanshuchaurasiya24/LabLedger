import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/providers/token_provider.dart';
import 'package:labledger/authentication/auth_repository.dart';
import 'package:labledger/authentication/auth_exceptions.dart';
import 'package:http/http.dart' as http;

class AuthHttpClient {
  /// Makes an authenticated HTTP request with automatic token refresh
  static Future<http.Response> request(
    Ref ref, {
    required String method,
    required String url,
    Map<String, String>? headers,
    String? body,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    
    // Get the current token
    String? token;
    try {
      token = await ref.read(tokenProvider.future);
    } catch (e) {
      throw Exception("Authentication required");
    }
    
    // Prepare headers
    final requestHeaders = {
      ...?headers,
      "Authorization": "Bearer $token",
    };
    
    // Make the initial request
    http.Response response = await _makeHttpRequest(
      method: method,
      url: url,
      headers: requestHeaders,
      body: body,
      timeout: timeout,
    );
    
    
    // If token is expired (401), try to refresh and retry
    if (response.statusCode == 401) {
      try {
        // Refresh the token using auth repository
        final authRepo = AuthRepository.instance;
        await authRepo.verifyAuth(); // This will refresh the token if needed
        
        // Get the new token
        final newToken = await ref.read(tokenProvider.future);
        
        // Update headers with new token
        final refreshedHeaders = {
          ...?headers,
          "Authorization": "Bearer $newToken",
        };
        
        // Retry the original request with new token
        response = await _makeHttpRequest(
          method: method,
          url: url,
          headers: refreshedHeaders,
          body: body,
          timeout: timeout,
        );
        
        
      } on TokenExpiredException {
        throw Exception("Session expired. Please login again.");
      } on NetworkException {
        throw Exception("Network error during authentication. Please try again.");
      } catch (e) {
        throw Exception("Authentication failed: Please try again.");
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
      throw Exception("Network error: Please check your connection and try again.");
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