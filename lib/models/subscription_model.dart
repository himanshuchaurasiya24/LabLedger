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

  const Subscription.fallback()
    : id = 0,
      center = 0,
      centerName = '',
      planType = 'UNKNOWN',
      purchaseDate = '',
      expiryDate = 'N/A',
      isActive = false,
      daysLeft = 0;

  factory Subscription.fromJson(Map<String, dynamic> json) {
    final bool isLegacySubscription = json.containsKey('plan_type');

    final dynamic idRaw = json['id'];
    final dynamic centerRaw = json['center'];
    final dynamic daysLeftRaw = json['days_left'];
    final dynamic durationRaw = json['duration_days'];

    return Subscription(
      id: idRaw is int ? idRaw : 0,
      center: centerRaw is int ? centerRaw : 0,
      centerName: (json['center_name'] as String?) ?? '',
      planType: isLegacySubscription
          ? ((json['plan_type'] as String?) ?? 'FREE')
          : ((json['name'] as String?) ?? 'FREE'),
        purchaseDate: (json['purchase_date'] as String?) ??
          (json['plan_activated_on'] as String?) ??
          '',
      expiryDate: (json['expiry_date'] as String?) ?? 'N/A',
      isActive: (json['is_active'] as bool?) ?? true,
      daysLeft: daysLeftRaw is int
          ? daysLeftRaw
          : (durationRaw is int ? durationRaw : 0),
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
