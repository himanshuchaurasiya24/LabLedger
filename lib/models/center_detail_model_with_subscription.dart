// models/center_detail_model.dart
import 'package:labledger/models/subscription_model.dart';

class CenterDetail {
  final int id;
  final String centerName;
  final String address;
  final String ownerName;
  final String ownerPhone;
  final Subscription subscription;

  const CenterDetail({
    required this.id,
    required this.centerName,
    required this.address,
    required this.ownerName,
    required this.ownerPhone,
    required this.subscription,
  });

  factory CenterDetail.fromJson(Map<String, dynamic> json) {
    return CenterDetail(
      id: json['id'] as int,
      centerName: json['center_name'] as String,
      address: json['address'] as String,
      ownerName: json['owner_name'] as String,
      ownerPhone: json['owner_phone'] as String,
      subscription: Subscription.fromJson(json['subscription'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'center_name': centerName,
      'address': address,
      'owner_name': ownerName,
      'owner_phone': ownerPhone,
      'subscription': subscription.toJson(),
    };
  }

  @override
  String toString() {
    return 'CenterDetail(id: $id, centerName: $centerName, address: $address, subscription: $subscription)';
  }
}