import 'package:labledger/models/bill_model.dart';

class FranchiseName {
  final int? id;
  final String? franchiseName;
  final String? address;
  final String? phoneNumber;
  final CenterDetailForFranchise? centerDetail;

  FranchiseName({
    this.id,
    this.franchiseName,
    this.address,
    this.phoneNumber,
    this.centerDetail,
  });

  factory FranchiseName.fromJson(Map<String, dynamic> json) {
    return FranchiseName(
      id: json['id'],
      franchiseName: json['franchise_name'],
      address: json['address'],
      phoneNumber: json['phone_number'],
      centerDetail: json['center_detail'] != null
          ? CenterDetailForFranchise.fromJson(json['center_detail'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'franchise_name': franchiseName,
      'address': address,
      'phone_number': phoneNumber,
      'center_detail': centerDetail?.toJson(),
    };
  }

  /// Convert Franchise object to JSON for create (excludes id)
  Map<String, dynamic> toCreateJson() {
    return {
      'franchise_name': franchiseName,
      'address': address,
      'phone_number': phoneNumber,
      if (centerDetail != null) 'center_detail': centerDetail!.toJson(),
    };
  }
}
