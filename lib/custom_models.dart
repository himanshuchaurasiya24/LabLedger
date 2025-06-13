class User {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String address;
  final bool isAdmin;
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
      centerDetail: centerDetail ?? this.centerDetail,
    );
  }
}

class CenterDetail {
  final int id;
  final String centerName;
  final String address;
  final String ownerName;
  final String ownerPhone;

  CenterDetail({
    required this.id,
    required this.centerName,
    required this.address,
    required this.ownerName,
    required this.ownerPhone,
  });

  factory CenterDetail.fromJson(Map<String, dynamic> json) {
    return CenterDetail(
      id: json['id'],
      centerName: json['center_name'],
      address: json['address'],
      ownerName: json['owner_name'],
      ownerPhone: json['owner_phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'center_name': centerName,
      'address': address,
      'owner_name': ownerName,
      'owner_phone': ownerPhone,
    };
  }

  CenterDetail copyWith({
    int? id,
    String? centerName,
    String? address,
    String? ownerName,
    String? ownerPhone,
  }) {
    return CenterDetail(
      id: id ?? this.id,
      centerName: centerName ?? this.centerName,
      address: address ?? this.address,
      ownerName: ownerName ?? this.ownerName,
      ownerPhone: ownerPhone ?? this.ownerPhone,
    );
  }
}