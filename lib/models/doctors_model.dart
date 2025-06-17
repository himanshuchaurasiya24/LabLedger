class Doctor {
  final int id;
  final String firstName;
  final String lastName;
  final String address;
  final String phoneNumber;
  final int ultrasoundPercentage;
  final int pathologyPercentage;
  final int ecgPercentage;
  final int xrayPercentage;
  final int franchiseLabPercentage;
  final String centerName;

  Doctor({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.address,
    required this.phoneNumber,
    required this.ultrasoundPercentage,
    required this.pathologyPercentage,
    required this.ecgPercentage,
    required this.xrayPercentage,
    required this.franchiseLabPercentage,
    required this.centerName,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      address: json['address'],
      phoneNumber: json['phone_number'],
      ultrasoundPercentage: json['ultrasound_percentage'],
      pathologyPercentage: json['pathology_percentage'],
      ecgPercentage: json['ecg_percentage'],
      xrayPercentage: json['xray_percentage'],
      franchiseLabPercentage: json['franchise_lab_percentage'],
      centerName: json['center_detail_output']['center_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "first_name": firstName,
      "last_name": lastName,
      "address": address,
      "phone_number": phoneNumber,
      "ultrasound_percentage": ultrasoundPercentage,
      "pathology_percentage": pathologyPercentage,
      "ecg_percentage": ecgPercentage,
      "xray_percentage": xrayPercentage,
      "franchise_lab_percentage": franchiseLabPercentage,
    };
  }

  Doctor copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? address,
    String? phoneNumber,
    int? ultrasoundPercentage,
    int? pathologyPercentage,
    int? ecgPercentage,
    int? xrayPercentage,
    int? franchiseLabPercentage,
    String? centerName,
  }) {
    return Doctor(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      address: address ?? this.address,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      ultrasoundPercentage: ultrasoundPercentage ?? this.ultrasoundPercentage,
      pathologyPercentage: pathologyPercentage ?? this.pathologyPercentage,
      ecgPercentage: ecgPercentage ?? this.ecgPercentage,
      xrayPercentage: xrayPercentage ?? this.xrayPercentage,
      franchiseLabPercentage: franchiseLabPercentage ?? this.franchiseLabPercentage,
      centerName: centerName ?? this.centerName,
    );
  }
}
