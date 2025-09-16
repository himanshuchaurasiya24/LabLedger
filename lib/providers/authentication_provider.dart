// providers/auth_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/authentication/auth_repository.dart';
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

// Using a Dart 3 record with a typedef for a more concise data structure.
// typedef LoginCredentials = ({String username, String password});

//----------------------------------------------------------------------

/// Provides the currently authenticated user's data.
///
/// This is the **single source of truth** for the user's authentication state.
/// The UI should watch this provider to determine if a user is logged in.
/// It automatically handles token verification and refreshing via `AuthRepository`.
final currentUserProvider = FutureProvider.autoDispose<AuthResponse>((ref) {
  return AuthRepository.instance.verifyAuth();
});

/// A provider that performs the login action.
final loginProvider =
    FutureProvider.family.autoDispose<AuthResponse, LoginCredentials>(
        (ref, credentials) {
  // After a successful login, invalidate currentUserProvider to trigger a re-fetch
  // of the user state, ensuring the app reflects the new logged-in status.
  ref.invalidate(currentUserProvider);
  return AuthRepository.instance
      .login(credentials.username, credentials.password);
});

/// A provider that performs the logout action.
final logoutProvider = FutureProvider.autoDispose<void>((ref) async {
  await AuthRepository.instance.logout();
  // After logging out, invalidate currentUserProvider so it re-evaluates
  // and enters an error state, allowing the UI to navigate to the login screen.
  ref.invalidate(currentUserProvider);
});

/// A provider that derives the subscription status from the current user data.
/// This is an efficient way to get specific, computed state from another provider.
final subscriptionStatusProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  // This will watch currentUserProvider and re-evaluate if it changes.
  final authResponse = await ref.watch(currentUserProvider.future);
  final subscription = authResponse.centerDetail.subscription;

  return {
    'isActive': subscription.isActive,
    'daysLeft': subscription.daysLeft,
    'planType': subscription.planType,
    'expiryDate': subscription.expiryDate,
    'isExpiringSoon': subscription.daysLeft <= 7 && subscription.daysLeft > 0,
  };
});