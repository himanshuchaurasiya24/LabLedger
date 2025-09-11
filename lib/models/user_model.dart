// models/user_model.dart
import 'package:labledger/models/center_detail_model_with_subscription.dart';

class User {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String address;
  final bool isAdmin;
  final bool isLocked; // <-- ADDED
  final CenterDetail centerDetail;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.address,
    required this.isAdmin,
    required this.isLocked, // <-- ADDED
    required this.centerDetail,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      phoneNumber: json['phone_number'],
      address: json['address'],
      isAdmin: json['is_admin'],
      isLocked: json['is_locked'], // <-- ADDED
      centerDetail: CenterDetail.fromJson(json['center_detail']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber,
      'address': address,
      'is_admin': isAdmin,
      'is_locked': isLocked, // <-- ADDED
      'center_detail': centerDetail.toJson(),
    };
  }

  User copyWith({
    int? id,
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? address,
    bool? isAdmin,
    bool? isLocked, // <-- ADDED
    CenterDetail? centerDetail,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      isAdmin: isAdmin ?? this.isAdmin,
      isLocked: isLocked ?? this.isLocked, // <-- ADDED
      centerDetail: centerDetail ?? this.centerDetail,
    );
  }
}