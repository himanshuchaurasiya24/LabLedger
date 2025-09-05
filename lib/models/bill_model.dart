class CenterDetailForFranchise {
  final int id;
  final String centerName;
  final String address;

  CenterDetailForFranchise({
    required this.id,
    required this.centerName,
    required this.address,
  });

  factory CenterDetailForFranchise.fromJson(Map<String, dynamic> json) {
    return CenterDetailForFranchise(
      id: json['id'],
      centerName: json['center_name'],
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'center_name': centerName,
      'address': address,
    };
  }
}

class Bill {
  final int? id; // Nullable for new bills
  final int diagnosisType;
  final int referredByDoctor;
  final int centerDetail;
  final DateTime dateOfTest;
  final String patientName;
  final int patientAge;
  final String patientSex;
  final String? franchiseName;
  final DateTime dateOfBill;
  final String billStatus;
  final int totalAmount;
  final int paidAmount;
  final int discByCenter;
  final int discByDoctor;
  final int incentiveAmount;
  final String? billNumber;

  // Optional Nested Outputs (for GET responses)
  final Map<String, dynamic>? diagnosisTypeOutput;
  final Map<String, dynamic>? referredByDoctorOutput;
  final Map<String, dynamic>? testDoneBy;
  final Map<String, dynamic>? centerDetailOutput;
  final List<String>? matchReason;

  Bill({
    this.id,
    required this.diagnosisType,
    required this.referredByDoctor,
    required this.centerDetail,
    required this.dateOfTest,
    required this.patientName,
    required this.patientAge,
    required this.patientSex,
    this.franchiseName,
    required this.dateOfBill,
    required this.billStatus,
    required this.totalAmount,
    required this.paidAmount,
    required this.discByCenter,
    required this.discByDoctor,
    required this.incentiveAmount,
    this.billNumber,
    this.diagnosisTypeOutput,
    this.referredByDoctorOutput,
    this.testDoneBy,
    this.centerDetailOutput,
    this.matchReason,
  });

  /// Factory Constructor to Parse JSON
  factory Bill.fromJson(Map<String, dynamic> json) {
    return Bill(
      id: json['id'],
      diagnosisType: json['diagnosis_type'] ??
          json['diagnosis_type_output']?['id'] ??
          0,
      referredByDoctor: json['referred_by_doctor'] ??
          json['referred_by_doctor_output']?['id'] ??
          0,
      centerDetail: json['center_detail'] is int
          ? json['center_detail']
          : json['center_detail']?['id'] ??
              0, // Handles both int and object
      dateOfTest: json['date_of_test'] != null
          ? DateTime.parse(json['date_of_test'])
          : DateTime.now(),
      patientName: json['patient_name'] ?? '',
      patientAge: json['patient_age'] ?? 0,
      patientSex: json['patient_sex'] ?? '',
      franchiseName: json['franchise_name'],
      dateOfBill: json['date_of_bill'] != null
          ? DateTime.parse(json['date_of_bill'])
          : DateTime.now(),
      billStatus: json['bill_status'] ?? '',
      totalAmount: json['total_amount'] ?? 0,
      paidAmount: json['paid_amount'] ?? 0,
      discByCenter: json['disc_by_center'] ?? 0,
      discByDoctor: json['disc_by_doctor'] ?? 0,
      incentiveAmount: json['incentive_amount'] ?? 0,
      billNumber: json['bill_number'],
      diagnosisTypeOutput: json['diagnosis_type_output'],
      referredByDoctorOutput: json['referred_by_doctor_output'],
      testDoneBy: json['test_done_by'],
      centerDetailOutput: json['center_detail'] is Map
          ? json['center_detail']
          : null,
      matchReason: (json['match_reason'] as List?)?.cast<String>(),
    );
  }

  /// Convert Object to JSON Map (for POST/PUT)
  Map<String, dynamic> toJson() {
    final data = {
      "diagnosis_type": diagnosisType,
      "referred_by_doctor": referredByDoctor,
      "center_detail": centerDetail,
      "date_of_test": dateOfTest.toIso8601String(),
      "patient_name": patientName,
      "patient_age": patientAge,
      "patient_sex": patientSex,
      "franchise_name": franchiseName,
      "date_of_bill": dateOfBill.toIso8601String(),
      "bill_status": billStatus,
      "total_amount": totalAmount,
      "paid_amount": paidAmount,
      "disc_by_center": discByCenter,
      "disc_by_doctor": discByDoctor,
      "incentive_amount": incentiveAmount,
    };

    if (id != null) {
      data["id"] = id;
    }

    return data;
  }
}
