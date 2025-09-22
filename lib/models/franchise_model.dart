
class FranchiseName {
  final int? id;
  final String? franchiseName;
  final String? address;
  final String? phoneNumber;

  FranchiseName({
    this.id,
    this.franchiseName,
    this.address,
    this.phoneNumber,
  });

  factory FranchiseName.fromJson(Map<String, dynamic> json) {
    return FranchiseName(
      id: json['id'],
      franchiseName: json['franchise_name'],
      address: json['address'],
      phoneNumber: json['phone_number'],
     
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'franchise_name': franchiseName,
      'address': address,
      'phone_number': phoneNumber,
    };
  }

  /// Convert Franchise object to JSON for create (excludes id)
  Map<String, dynamic> toCreateJson() {
    return {
      'franchise_name': franchiseName,
      'address': address,
      'phone_number': phoneNumber,
    };
  }
}
