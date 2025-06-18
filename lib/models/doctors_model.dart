
import 'package:labledger/models/center_detail_model.dart';

class Doctor {
  final int id;
  final String firstName;
  final String lastName;
  final String hospitalName;
  final String address;
  final String phoneNumber;
  final int ultrasoundPercentage;
  final int pathologyPercentage;
  final int ecgPercentage;
  final int xrayPercentage;
  final int franchiseLabPercentage;
  final CenterDetailOutput centerDetail;

  Doctor({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.hospitalName,
    required this.address,
    required this.phoneNumber,
    required this.ultrasoundPercentage,
    required this.pathologyPercentage,
    required this.ecgPercentage,
    required this.xrayPercentage,
    required this.franchiseLabPercentage,
    required this.centerDetail,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      hospitalName: json['hospital_name'] ?? '',
      address: json['address'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      ultrasoundPercentage: json['ultrasound_percentage'] ?? 0,
      pathologyPercentage: json['pathology_percentage'] ?? 0,
      ecgPercentage: json['ecg_percentage'] ?? 0,
      xrayPercentage: json['xray_percentage'] ?? 0,
      franchiseLabPercentage: json['franchise_lab_percentage'] ?? 0,
      centerDetail: CenterDetailOutput.fromJson(json['center_detail_output']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'hospital_name': hospitalName,
      'address': address,
      'phone_number': phoneNumber,
      'ultrasound_percentage': ultrasoundPercentage,
      'pathology_percentage': pathologyPercentage,
      'ecg_percentage': ecgPercentage,
      'xray_percentage': xrayPercentage,
      'franchise_lab_percentage': franchiseLabPercentage,
      'center_detail': centerDetail.id, // ✅ Only ID needed for POST/PATCH
    };
  }

  Doctor copyWith({
  String? firstName,
  String? lastName,
  String? hospitalName,
  String? address,
  String? phoneNumber,
  int? ultrasoundPercentage,
  int? pathologyPercentage,
  int? ecgPercentage,
  int? xrayPercentage,
  int? franchiseLabPercentage,
}) {
  return Doctor(
    id: id,
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    hospitalName: hospitalName ?? this.hospitalName,
    address: address ?? this.address,
    phoneNumber: phoneNumber ?? this.phoneNumber,
    ultrasoundPercentage: ultrasoundPercentage ?? this.ultrasoundPercentage,
    pathologyPercentage: pathologyPercentage ?? this.pathologyPercentage,
    ecgPercentage: ecgPercentage ?? this.ecgPercentage,
    xrayPercentage: xrayPercentage ?? this.xrayPercentage,
    franchiseLabPercentage: franchiseLabPercentage ?? this.franchiseLabPercentage,
    centerDetail: centerDetail, // unchanged
  );
}

}