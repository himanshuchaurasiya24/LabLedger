class DoctorReport {
  final int doctorId;
  final String firstName;
  final String lastName;
  final int totalIncentive;
  final List<BillDetail> bills;

  DoctorReport({
    required this.doctorId,
    required this.firstName,
    required this.lastName,
    required this.totalIncentive,
    required this.bills,
  });

  factory DoctorReport.fromJson(Map<String, dynamic> json) {
    var billsListFromJson = json['bills'] as List? ?? [];
    List<BillDetail> parsedBills = billsListFromJson
        .map((billJson) => BillDetail.fromJson(billJson))
        .toList();

    return DoctorReport(
      doctorId: json['doctor_id'] ?? 0,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      totalIncentive: json['total_incentive'] ?? 0,
      bills: parsedBills,
    );
  }
}

// Model for the nested bill objects
class BillDetail {
  final String billNumber;
  final String patientName;
  final int patientAge;
  final String patientSex;
  final String? patientPhoneNumber;
  final String diagnosisType;
  final String? franchiseName;
  final int totalAmount;
  final int incentiveAmount;
  final int discByDoctor;
  final int discByCenter;
  final DateTime dateOfBill;
  final int paidAmount;       // ✅ Added field
  final String billStatus;     // ✅ Added field

  BillDetail({
    required this.billNumber,
    required this.patientName,
    required this.patientAge,
    required this.patientSex,
    this.patientPhoneNumber,
    required this.diagnosisType,
    this.franchiseName,
    required this.totalAmount,
    required this.incentiveAmount,
    required this.discByDoctor,
    required this.discByCenter,
    required this.dateOfBill,
    required this.paidAmount,   // ✅ Added to constructor
    required this.billStatus,   // ✅ Added to constructor
  });

  factory BillDetail.fromJson(Map<String, dynamic> json) {
    return BillDetail(
      billNumber: json['bill_number'] ?? '',
      patientName: json['patient_name'] ?? '',
      patientAge: json['patient_age'] ?? 0,
      patientSex: json['patient_sex'] ?? '',
      patientPhoneNumber: json['patient_phone_number'],
      diagnosisType: json['diagnosis_type'] ?? '',
      franchiseName: json['franchise_name'],
      totalAmount: json['total_amount'] ?? 0,
      incentiveAmount: json['incentive_amount'] ?? 0,
      discByDoctor: json['disc_by_doctor'] ?? 0,
      discByCenter: json['disc_by_center'] ?? 0,
      dateOfBill: DateTime.parse(json['date_of_bill']),
      paidAmount: json['paid_amount'] ?? 0,     // ✅ Parse new field
      billStatus: json['bill_status'] ?? '',     // ✅ Parse new field
    );
  }
}