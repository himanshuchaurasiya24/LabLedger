class DoctorStats {
  final Doctor doctor;
  final int ultrasound;
  final int pathology;
  final int ecg;
  final int xray;
  final int franchiseLab;
  final int incentive;

  DoctorStats({
    required this.doctor,
    required this.ultrasound,
    required this.pathology,
    required this.ecg,
    required this.xray,
    required this.franchiseLab,
    required this.incentive,
  });
}

class TopReferrerModel {
  final List<DoctorStats> week;
  final List<DoctorStats> month;
  final List<DoctorStats> year;
  final List<DoctorStats> allTime;

  TopReferrerModel({
    required this.week,
    required this.month,
    required this.year,
    required this.allTime,
  });
}

class Doctor {
  Doctor({
    this.id, // 👈 make optional
    required this.firstName,
    required this.lastName,
    required this.hospitalName,
    required this.address,
    required this.phoneNumber,
    this.email, // nullable
    required this.ultrasoundPercentage,
    required this.pathologyPercentage,
    required this.ecgPercentage,
    required this.xrayPercentage,
    required this.franchiseLabPercentage,
    this.centerDetail, // 👈 make optional
  });

  final int? id;
  final String? firstName;
  final String? lastName;
  final String? hospitalName;
  final String? address;
  final String? phoneNumber;
  final String? email;
  final int? ultrasoundPercentage;
  final int? pathologyPercentage;
  final int? ecgPercentage;
  final int? xrayPercentage;
  final int? franchiseLabPercentage;
  final int? centerDetail; // backend auto-fills

  Doctor copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? hospitalName,
    String? address,
    String? phoneNumber,
    String? email,
    int? ultrasoundPercentage,
    int? pathologyPercentage,
    int? ecgPercentage,
    int? xrayPercentage,
    int? franchiseLabPercentage,
    int? centerDetail,
  }) {
    return Doctor(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      hospitalName: hospitalName ?? this.hospitalName,
      address: address ?? this.address,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      ultrasoundPercentage: ultrasoundPercentage ?? this.ultrasoundPercentage,
      pathologyPercentage: pathologyPercentage ?? this.pathologyPercentage,
      ecgPercentage: ecgPercentage ?? this.ecgPercentage,
      xrayPercentage: xrayPercentage ?? this.xrayPercentage,
      franchiseLabPercentage:
          franchiseLabPercentage ?? this.franchiseLabPercentage,
      centerDetail: centerDetail ?? this.centerDetail,
    );
  }

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json["id"],
      firstName: json["first_name"],
      lastName: json["last_name"],
      hospitalName: json["hospital_name"],
      address: json["address"],
      phoneNumber: json["phone_number"],
      email: json["email"],
      ultrasoundPercentage: json["ultrasound_percentage"],
      pathologyPercentage: json["pathology_percentage"],
      ecgPercentage: json["ecg_percentage"],
      xrayPercentage: json["xray_percentage"],
      franchiseLabPercentage: json["franchise_lab_percentage"],
      centerDetail: json["center_detail"],
    );
  }

  Map<String, dynamic> toJson() {
    final data = {
      "first_name": firstName,
      "last_name": lastName,
      "hospital_name": hospitalName,
      "address": address,
      "phone_number": phoneNumber,
      "email": email,
      "ultrasound_percentage": ultrasoundPercentage,
      "pathology_percentage": pathologyPercentage,
      "ecg_percentage": ecgPercentage,
      "xray_percentage": xrayPercentage,
      "franchise_lab_percentage": franchiseLabPercentage,
    };

    // Only include id if updating
    if (id != null) data["id"] = id;

    // Don't send center_detail, backend will set it
    return data;
  }

  @override
  String toString() {
    return "$id, $firstName, $lastName, $hospitalName, $address, $phoneNumber, $email, $ultrasoundPercentage, $pathologyPercentage, $ecgPercentage, $xrayPercentage, $franchiseLabPercentage, $centerDetail";
  }
}
