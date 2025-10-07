class Doctor {
  final int? id;
  final String? firstName;
  final String? lastName;
  final String? hospitalName;
  final int? ultrasoundPercentage;
  final int? pathologyPercentage;
  final int? ecgPercentage;
  final int? xrayPercentage;
  final int? franchiseLabPercentage;

  Doctor({
    this.id,
    this.firstName,
    this.lastName,
    this.hospitalName,
    this.ultrasoundPercentage,
    this.pathologyPercentage,
    this.ecgPercentage,
    this.xrayPercentage,
    this.franchiseLabPercentage,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json["id"] as int?,
      firstName: json["first_name"] as String?,
      lastName: json["last_name"] as String?,
      hospitalName: json["hospital_name"] as String?,
      ultrasoundPercentage: json["ultrasound_percentage"] as int?,
      pathologyPercentage: json["pathology_percentage"] as int?,
      ecgPercentage: json["ecg_percentage"] as int?,
      xrayPercentage: json["xray_percentage"] as int?,
      franchiseLabPercentage: json["franchise_lab_percentage"] as int?,
    );
  }
}

class DoctorReport {
  final Doctor doctor;
  final int totalIncentive;

  // 🌟 RENAMED: This list now uses the IncentiveBill model.
  final List<IncentiveBill> bills;

  DoctorReport({
    required this.doctor,
    required this.totalIncentive,
    required this.bills,
  });

  factory DoctorReport.fromJson(Map<String, dynamic> json) {
    final billsListFromJson = json['bills'] as List? ?? [];
    final List<IncentiveBill> parsedBills = billsListFromJson
        .map(
          (billJson) =>
              IncentiveBill.fromJson(billJson as Map<String, dynamic>),
        )
        .toList();

    return DoctorReport(
      doctor: Doctor.fromJson(json['doctor'] as Map<String, dynamic>),
      totalIncentive: json['total_incentive'] as int? ?? 0,
      bills: parsedBills,
    );
  }
}

/// Helper model for the nested Diagnosis Type object.
class DiagnosisType {
  final String name;
  final String category;
  final int price;

  DiagnosisType({
    required this.name,
    required this.category,
    required this.price,
  });

  factory DiagnosisType.fromJson(Map<String, dynamic> json) {
    return DiagnosisType(
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      price: json['price'] as int? ?? 0,
    );
  }
}

/// 🌟 RENAMED: Helper model for the nested Franchise object.
class FranchiseName {
  final String franchiseName;

  FranchiseName({required this.franchiseName});

  factory FranchiseName.fromJson(Map<String, dynamic> json) {
    return FranchiseName(
      franchiseName: json['franchise_name'] as String? ?? '',
    );
  }
}

/// 🌟 RENAMED: The main Bill model, updated for the new optimized JSON structure.
class IncentiveBill {
  final int id;
  final String billNumber;
  final String patientName;
  final int patientAge;
  final String patientSex;
  final int? patientPhoneNumber;
  final DiagnosisType diagnosisType;
  final FranchiseName? franchiseName; // 🌟 RENAMED: Using FranchiseName
  final DateTime dateOfBill;
  final String billStatus;
  final int totalAmount;
  final int paidAmount;
  final int discByDoctor;
  final int discByCenter;
  final int incentiveAmount;

  IncentiveBill({
    required this.id,
    required this.billNumber,
    required this.patientName,
    required this.patientAge,
    required this.patientSex,
    this.patientPhoneNumber,
    required this.diagnosisType,
    this.franchiseName,
    required this.dateOfBill,
    required this.billStatus,
    required this.totalAmount,
    required this.paidAmount,
    required this.discByDoctor,
    required this.discByCenter,
    required this.incentiveAmount,
  });

  factory IncentiveBill.fromJson(Map<String, dynamic> json) {
    final franchiseJson = json['franchise_name'] as Map<String, dynamic>?;

    return IncentiveBill(
      id: json['id'] as int? ?? 0,
      billNumber: json['bill_number'] as String? ?? '',
      patientName: json['patient_name'] as String? ?? '',
      patientAge: json['patient_age'] as int? ?? 0,
      patientSex: json['patient_sex'] as String? ?? '',
      patientPhoneNumber: json['patient_phone_number'] as int?,
      diagnosisType: DiagnosisType.fromJson(
        json['diagnosis_type'] as Map<String, dynamic>,
      ),
      // 🌟 RENAMED: Parsing now uses FranchiseName.fromJson.
      franchiseName: franchiseJson != null
          ? FranchiseName.fromJson(franchiseJson)
          : null,
      dateOfBill: DateTime.parse(json['date_of_bill'] as String),
      billStatus: json['bill_status'] as String? ?? 'Unpaid',
      totalAmount: json['total_amount'] as int? ?? 0,
      paidAmount: json['paid_amount'] as int? ?? 0,
      discByDoctor: json['disc_by_doctor'] as int? ?? 0,
      discByCenter: json['disc_by_center'] as int? ?? 0,
      incentiveAmount: json['incentive_amount'] as int? ?? 0,
    );
  }
}
