class Bill {
  final int? id;
  final String? billNumber;
  final DateTime dateOfTest;
  final String patientName;
  final String? patientPhoneNumber;
  final int patientAge;
  final String patientSex;
  final DateTime dateOfBill;
  final String billStatus;
  final int totalAmount;
  final int paidAmount;
  final int discByCenter;
  final int discByDoctor;
  final int incentiveAmount;
  final String? reportUrl; // ✅ Field added

  // Storing IDs for write operations (POST/PUT)
  final List<int> diagnosisTypes;
  final int referredByDoctor;
  final int? franchiseName;

  // Storing full objects for read operations (GET)
  final List<Map<String, dynamic>>? diagnosisTypesOutput;
  final Map<String, dynamic>? referredByDoctorOutput;
  final Map<String, dynamic>? franchiseNameOutput;
  final Map<String, dynamic>? testDoneBy;
  final Map<String, dynamic>? centerDetail;
  final List<String>? matchReason;

  Bill({
    this.id,
    this.billNumber,
    required this.dateOfTest,
    required this.patientName,
    required this.patientPhoneNumber,
    required this.patientAge,
    required this.patientSex,
    required this.dateOfBill,
    required this.billStatus,
    required this.totalAmount,
    required this.paidAmount,
    required this.discByCenter,
    required this.discByDoctor,
    required this.incentiveAmount,
    required this.diagnosisTypes,
    required this.referredByDoctor,
    this.franchiseName,
    this.diagnosisTypesOutput,
    this.referredByDoctorOutput,
    this.franchiseNameOutput,
    this.testDoneBy,
    this.centerDetail,
    this.matchReason,
    this.reportUrl, // ✅ Added to constructor
  });

  /// Factory Constructor to Parse JSON
  factory Bill.fromJson(Map<String, dynamic> json) {
    return Bill(
      id: json['id'],
      billNumber: json['bill_number'],
      dateOfTest: DateTime.parse(json['date_of_test']),
      patientName: json['patient_name'],
      patientPhoneNumber: json['patient_phone_number']?.toString(),
      patientAge: json['patient_age'],
      patientSex: json['patient_sex'],
      dateOfBill: DateTime.parse(json['date_of_bill']),
      billStatus: json['bill_status'],
      totalAmount: json['total_amount'],
      paidAmount: json['paid_amount'],
      discByCenter: json['disc_by_center'],
      discByDoctor: json['disc_by_doctor'],
      incentiveAmount: json['incentive_amount'],
      reportUrl: json['report_url'], // ✅ Added parsing for the new field
      diagnosisTypes: json['diagnosis_types_output'] != null
          ? (json['diagnosis_types_output'] as List)
                .map((dt) => dt['diagnosis_type'] as int)
                .toList()
          : [],
      referredByDoctor: json['referred_by_doctor_output']?['id'] ?? 0,
      franchiseName: json['franchise_name_output']?['id'],
      diagnosisTypesOutput: json['diagnosis_types_output'] != null
          ? (json['diagnosis_types_output'] as List)
                .map(
                  (dt) =>
                      Map<String, dynamic>.from(dt['diagnosis_type_detail']),
                )
                .toList()
          : null,
      referredByDoctorOutput: json['referred_by_doctor_output'],
      franchiseNameOutput: json['franchise_name_output'],
      testDoneBy: json['test_done_by'],
      centerDetail: json['center_detail'],
      matchReason: (json['match_reason'] as List?)?.cast<String>(),
    );
  }

  /// Convert Object to JSON Map (for POST/PUT)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'patient_name': patientName,
      'patient_phone_number': patientPhoneNumber,
      'patient_age': patientAge,
      'patient_sex': patientSex,
      'paid_amount': paidAmount,
      'disc_by_center': discByCenter,
      'disc_by_doctor': discByDoctor,
      'bill_status': billStatus,
      'date_of_test': dateOfTest.toIso8601String(),
      'date_of_bill': dateOfBill.toIso8601String(),
      'diagnosis_types': diagnosisTypes,
      'referred_by_doctor': referredByDoctor,
      'franchise_name': franchiseName,
    };
  }
}
