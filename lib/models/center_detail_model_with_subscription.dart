import 'package:labledger/models/subscription_model.dart';

class CenterDetail {
  final int id;
  final String centerName;
  final String address;
  final String ownerName;
  final String ownerPhone;
  final bool isActive;
  final Subscription subscription;

  const CenterDetail({
    required this.id,
    required this.centerName,
    required this.address,
    required this.ownerName,
    required this.ownerPhone,
    required this.isActive,
    required this.subscription,
  });

  factory CenterDetail.fromJson(Map<String, dynamic> json) {
    final dynamic subscriptionRaw =
        json['subscription'] ?? json['subscription_plan'];

    return CenterDetail(
      id: json['id'] as int,
      centerName: (json['center_name'] as String?) ?? '',
      address: (json['address'] as String?) ?? '',
      ownerName: (json['owner_name'] as String?) ?? '',
      ownerPhone: (json['owner_phone'] as String?) ?? '',
      isActive: (json['is_active'] as bool?) ?? true,
      subscription: subscriptionRaw is Map<String, dynamic>
          ? Subscription.fromJson(subscriptionRaw)
          : const Subscription.fallback(),
    );
  }

  const CenterDetail.fallback()
    : id = 0,
      centerName = '',
      address = '',
      ownerName = '',
      ownerPhone = '',
      isActive = true,
      subscription = const Subscription.fallback();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'center_name': centerName,
      'address': address,
      'owner_name': ownerName,
      'owner_phone': ownerPhone,
      'is_active': isActive,
    };
  }

  @override
  String toString() {
    return 'CenterDetail(id: $id, centerName: $centerName, address: $address, isActive: $isActive, subscription: $subscription)';
  }
}
