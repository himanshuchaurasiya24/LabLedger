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
// lib/models/doctors_model.dart

class Doctor {
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
  final List<DoctorCategoryPercentage>? categoryPercentages;

  Doctor({
    this.id,
    this.firstName,
    this.lastName,
    this.hospitalName,
    this.address,
    this.phoneNumber,
    this.email,
    this.ultrasoundPercentage,
    this.pathologyPercentage,
    this.ecgPercentage,
    this.xrayPercentage,
    this.franchiseLabPercentage,
    this.categoryPercentages,
  });

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
      categoryPercentages: json["category_percentages"] != null
          ? (json["category_percentages"] as List)
                .map((e) => DoctorCategoryPercentage.fromJson(e))
                .toList()
          : null,
      // The "center_detail" key from the JSON is now simply ignored.
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
      "category_percentages": categoryPercentages
          ?.map((e) => e.toJson())
          .toList(),
    };

    if (id != null) {
      data["id"] = id;
    }

    return data;
  }
}

// DoctorCategoryPercentage model
class DoctorCategoryPercentage {
  final int id;
  final int category;
  final String? categoryName;
  final int percentage; // Non-nullable, defaults to 0

  DoctorCategoryPercentage({
    required this.id,
    required this.category,
    this.categoryName,
    required this.percentage,
  });

  factory DoctorCategoryPercentage.fromJson(Map<String, dynamic> json) {
    return DoctorCategoryPercentage(
      id: json['id'] as int? ?? 0,
      category: json['category'] as int? ?? 0,
      categoryName: json['category_name'] as String?,
      percentage: json['percentage'] as int? ?? 0, // Default to 0 if null
    );
  }

  Map<String, dynamic> toJson() {
    return {'category': category, 'percentage': percentage};
  }
}
