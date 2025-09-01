
// models/subscription_model.dart
class Subscription {
  final int id;
  final int center;
  final String centerName;
  final String planType;
  final String purchaseDate;
  final String expiryDate;
  final bool isActive;
  final int daysLeft;

  const Subscription({
    required this.id,
    required this.center,
    required this.centerName,
    required this.planType,
    required this.purchaseDate,
    required this.expiryDate,
    required this.isActive,
    required this.daysLeft,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] as int,
      center: json['center'] as int,
      centerName: json['center_name'] as String,
      planType: json['plan_type'] as String,
      purchaseDate: json['purchase_date'] as String,
      expiryDate: json['expiry_date'] as String,
      isActive: json['is_active'] as bool,
      daysLeft: json['days_left'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'center': center,
      'center_name': centerName,
      'plan_type': planType,
      'purchase_date': purchaseDate,
      'expiry_date': expiryDate,
      'is_active': isActive,
      'days_left': daysLeft,
    };
  }

  @override
  String toString() {
    return 'Subscription(id: $id, centerName: $centerName, planType: $planType, isActive: $isActive, daysLeft: $daysLeft)';
  }
}
