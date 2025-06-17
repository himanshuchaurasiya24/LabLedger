class Doctor {
  final int id;
  final CenterDetailOutput centerDetailOutput;
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

  Doctor({
    required this.id,
    required this.centerDetailOutput,
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
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'],
      centerDetailOutput: CenterDetailOutput.fromJson(json['center_detail_output']),
      firstName: json['first_name'],
      lastName: json['last_name'],
      hospitalName: json['hospital_name'],
      address: json['address'],
      phoneNumber: json['phone_number'],
      ultrasoundPercentage: json['ultrasound_percentage'],
      pathologyPercentage: json['pathology_percentage'],
      ecgPercentage: json['ecg_percentage'],
      xrayPercentage: json['xray_percentage'],
      franchiseLabPercentage: json['franchise_lab_percentage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "center_detail_output": centerDetailOutput.toJson(),
      "first_name": firstName,
      "last_name": lastName,
      "hospital_name": hospitalName,
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
    CenterDetailOutput? centerDetailOutput,
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
      id: id ?? this.id,
      centerDetailOutput: centerDetailOutput ?? this.centerDetailOutput,
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

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "center_name": centerName,
      "address": address,
    };
  }

  CenterDetailOutput copyWith({
    int? id,
    String? centerName,
    String? address,
  }) {
    return CenterDetailOutput(
      id: id ?? this.id,
      centerName: centerName ?? this.centerName,
      address: address ?? this.address,
    );
  }
}