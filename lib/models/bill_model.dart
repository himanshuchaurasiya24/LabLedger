// class CenterDetailForFranchise {
//   final int id;
//   final String centerName;
//   final String address;

//   CenterDetailForFranchise({
//     required this.id,
//     required this.centerName,
//     required this.address,
//   });

//   factory CenterDetailForFranchise.fromJson(Map<String, dynamic> json) {
//     return CenterDetailForFranchise(
//       id: json['id'],
//       centerName: json['center_name'],
//       address: json['address'],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'center_name': centerName,
//       'address': address,
//     };
//   }
// }
class Bill {
  final int? id; // Nullable for creating new bills
  final String? billNumber;
  final DateTime dateOfTest;
  final String patientName;
  final int patientAge;
  final String patientSex;
  final DateTime dateOfBill;
  final String billStatus;
  final int totalAmount;
  final int paidAmount;
  final int discByCenter;
  final int discByDoctor;
  final int incentiveAmount;
  
  // Storing IDs for write operations (POST/PUT)
  final int diagnosisType;
  final int referredByDoctor;
  final int? franchiseName; // Nullable

  // Storing full objects for read operations (GET)
  final Map<String, dynamic>? diagnosisTypeOutput;
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
    required this.patientAge,
    required this.patientSex,
    required this.dateOfBill,
    required this.billStatus,
    required this.totalAmount,
    required this.paidAmount,
    required this.discByCenter,
    required this.discByDoctor,
    required this.incentiveAmount,
    required this.diagnosisType,
    required this.referredByDoctor,
    this.franchiseName,
    this.diagnosisTypeOutput,
    this.referredByDoctorOutput,
    this.franchiseNameOutput,
    this.testDoneBy,
    this.centerDetail,
    this.matchReason,
  });

  /// Factory Constructor to Parse JSON
  factory Bill.fromJson(Map<String, dynamic> json) {
  return Bill(
    id: json['id'],
    billNumber: json['bill_number'],
    dateOfTest: DateTime.parse(json['date_of_test']),
    patientName: json['patient_name'],
    patientAge: json['patient_age'],
    patientSex: json['patient_sex'],
    dateOfBill: DateTime.parse(json['date_of_bill']),
    billStatus: json['bill_status'],
    totalAmount: json['total_amount'],
    paidAmount: json['paid_amount'],
    discByCenter: json['disc_by_center'],
    discByDoctor: json['disc_by_doctor'],
    incentiveAmount: json['incentive_amount'],
    
    // ✅ This safe parsing prevents the crash
    diagnosisType: json['diagnosis_type_output']?['id'] ?? 0,
    referredByDoctor: json['referred_by_doctor_output']?['id'] ?? 0,
    franchiseName: json['franchise_name_output']?['id'],
    
    // Store the full nested objects
    diagnosisTypeOutput: json['diagnosis_type_output'],
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
      // id is only included for updates, not creations
      if (id != null) 'id': id,
      
      'patient_name': patientName,
      'patient_age': patientAge,
      'patient_sex': patientSex,
      'paid_amount': paidAmount,
      'disc_by_center': discByCenter,
      'disc_by_doctor': discByDoctor,
      'bill_status': billStatus,
      'date_of_test': dateOfTest.toIso8601String(),
      'date_of_bill': dateOfBill.toIso8601String(),
      
      // Send only the integer IDs for foreign key relationships
      'diagnosis_type': diagnosisType,
      'referred_by_doctor': referredByDoctor,
      'franchise_name': franchiseName,
    };
  }
}