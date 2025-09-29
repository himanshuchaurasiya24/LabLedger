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

final currentUserProvider = FutureProvider.autoDispose<AuthResponse>((ref) {
  return AuthRepository.instance.verifyAuth();
});

final loginProvider =
    FutureProvider.family.autoDispose<AuthResponse, LoginCredentials>(
        (ref, credentials) {
  ref.invalidate(currentUserProvider);
  return AuthRepository.instance
      .login(credentials.username, credentials.password);
});

final logoutProvider = FutureProvider.autoDispose<void>((ref) async {
  await AuthRepository.instance.logout();
  ref.invalidate(currentUserProvider);
});
final subscriptionStatusProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
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