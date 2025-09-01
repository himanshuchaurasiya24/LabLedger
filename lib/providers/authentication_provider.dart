// providers/auth_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/authentication/auth_repository.dart';
import 'package:labledger/authentication/auth_exceptions.dart';
import 'package:labledger/models/auth_response_model.dart';

// Login credentials model for provider input
class LoginCredentials {
  final String username;
  final String password;

  const LoginCredentials({
    required this.username,
    required this.password,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoginCredentials &&
          runtimeType == other.runtimeType &&
          username == other.username &&
          password == other.password;

  @override
  int get hashCode => username.hashCode ^ password.hashCode;
}

// Login Provider
final loginProvider = FutureProvider.family.autoDispose<AuthResponse, LoginCredentials>(
  (ref, credentials) async {
    final authRepo = AuthRepository.instance;
    
    // Use the repository's login method which handles token storage and validation
    final authResponse = await authRepo.login(credentials.username, credentials.password);
    
    return authResponse;
  },
);

// Verify Auth Provider
final verifyAuthProvider = FutureProvider.autoDispose<AuthResponse>((ref) async {
  final authRepo = AuthRepository.instance;
  
  // Use the repository's verifyAuth method which handles token refresh and validation
  final authResponse = await authRepo.verifyAuth();
  
  return authResponse;
});

// Current user provider - gets current authenticated user
final currentUserProvider = FutureProvider.autoDispose<AuthResponse>((ref) async {
  final authRepo = AuthRepository.instance;
  
  try {
    // Try to verify auth first
    return await ref.read(verifyAuthProvider.future);
  } catch (e) {
    // If verification fails, clear tokens and throw exception
    await authRepo.logout();
    rethrow;
  }
});

// Logout provider
final logoutProvider = FutureProvider.autoDispose<bool>((ref) async {
  final authRepo = AuthRepository.instance;
  await authRepo.logout();
  return true;
});



// Token refresh provider (if needed separately)
final refreshTokenProvider = FutureProvider.autoDispose<String>((ref) async {
  final authRepo = AuthRepository.instance;
  final refreshToken = await authRepo.getRefreshToken();
  
  if (refreshToken == null) {
    throw const TokenExpiredException();
  }
  
  final newAccessToken = await authRepo.refreshToken(refreshToken);
  if (newAccessToken == null) {
    throw const TokenExpiredException();
  }
  
  return newAccessToken;
});

// Check subscription status provider
final subscriptionStatusProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final authResponse = await ref.read(currentUserProvider.future);
  final subscription = authResponse.centerDetail.subscription;
  
  return {
    'isActive': subscription.isActive,
    'daysLeft': subscription.daysLeft,
    'planType': subscription.planType,
    'expiryDate': subscription.expiryDate,
    'isExpiringSoon': subscription.daysLeft <= 7 && subscription.daysLeft > 0,
  };
});