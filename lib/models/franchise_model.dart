import 'dart:convert';

class Franchise {
  final int? id;
  final String franchiseName;
  final String address;
  final String phoneNumber;

  Franchise({
    this.id,
    required this.franchiseName,
    required this.address,
    required this.phoneNumber,
  });

  /// Factory to create Franchise from JSON
  factory Franchise.fromJson(Map<String, dynamic> json) {
    return Franchise(
      id: json['id'],
      franchiseName: json['franchise_name'] ?? '',
      address: json['address'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
    );
  }

  /// Convert Franchise object to JSON for update (includes id if available)
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'franchise_name': franchiseName,
      'address': address,
      'phone_number': phoneNumber,
    };
    if (id != null) data['id'] = id;
    return data;
  }

  /// Convert Franchise object to JSON for create (excludes id)
  Map<String, dynamic> toCreateJson() {
    return {
      'franchise_name': franchiseName,
      'address': address,
      'phone_number': phoneNumber,
    };
  }

  /// Encode list of Franchise objects to JSON string
  static String encode(List<Franchise> franchises) => json.encode(
        franchises.map<Map<String, dynamic>>((f) => f.toJson()).toList(),
      );

  /// Decode list of Franchise objects from JSON string
  static List<Franchise> decode(String franchises) =>
      (json.decode(franchises) as List<dynamic>)
          .map<Franchise>((item) => Franchise.fromJson(item))
          .toList();
}
