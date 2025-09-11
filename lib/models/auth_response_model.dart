// models/auth_response_model.dart
import 'package:labledger/models/center_detail_model_with_subscription.dart';

class AuthResponse {
  final String? refresh;
  final String? access;
  final bool? success; // For verify-auth response
  final bool isAdmin;
  final bool isLocked; // <-- ADDED
  final String username;
  final String firstName;
  final String lastName;
  final int id;
  final CenterDetail centerDetail;

  const AuthResponse({
    this.refresh,
    this.access,
    this.success,
    required this.isAdmin,
    required this.isLocked, // <-- ADDED
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.id,
    required this.centerDetail,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      refresh: json['refresh'] as String?,
      access: json['access'] as String?,
      success: json['success'] as bool?,
      isAdmin: json['is_admin'] as bool,
      isLocked: json['is_locked'] as bool, // <-- ADDED
      username: json['username'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      id: json['id'] as int,
      centerDetail: CenterDetail.fromJson(json['center_detail'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (refresh != null) 'refresh': refresh,
      if (access != null) 'access': access,
      if (success != null) 'success': success,
      'is_admin': isAdmin,
      'is_locked': isLocked, // <-- ADDED
      'username': username,
      'first_name': firstName,
      'last_name': lastName,
      'id': id,
      'center_detail': centerDetail.toJson(),
    };
  }

  @override
  String toString() {
    return 'AuthResponse(username: $username, isAdmin: $isAdmin, isLocked: $isLocked, centerDetail: $centerDetail)';
  }
}