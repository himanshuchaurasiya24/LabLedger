
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
class CenterDetailOutput {
  final int id;
  final String centerName;
  final String address;

  CenterDetailOutput({
    required this.id,
    required this.centerName,
    required this.address,
  });

  factory CenterDetailOutput.fromJson(Map<String, dynamic> json) {
    return CenterDetailOutput(
      id: json['id'],
      centerName: json['center_name'],
      address: json['address'],
    );
  }
}
