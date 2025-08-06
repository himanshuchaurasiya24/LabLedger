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

class FranchiseName {
  final int id;
  final String franchiseName;
  final String address;
  final String phoneNumber;
  final CenterDetailForFranchise centerDetail;

  FranchiseName({
    required this.id,
    required this.franchiseName,
    required this.address,
    required this.phoneNumber,
    required this.centerDetail,
  });

  factory FranchiseName.fromJson(Map<String, dynamic> json) {
    return FranchiseName(
      id: json['id'],
      franchiseName: json['franchise_name'],
      address: json['address'],
      phoneNumber: json['phone_number'],
      centerDetail: CenterDetailForFranchise.fromJson(json['center_detail']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'franchise_name': franchiseName,
      'address': address,
      'phone_number': phoneNumber,
      'center_detail': centerDetail.toJson(),
    };
  }
}


class Bill {
  final int? id;  // <-- Nullable ID
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

  // Optional Nested Outputs (for GET responses)
  final Map<String, dynamic>? diagnosisTypeOutput;
  final Map<String, dynamic>? referredByDoctorOutput;
  final Map<String, dynamic>? testDoneBy;
  final Map<String, dynamic>? centerDetailOutput;
  final String? billNumber;

  Bill({
    this.id,
    required this.diagnosisType,
    required this.referredByDoctor,
    required this.centerDetail,
    required this.dateOfTest,
    required this.patientName,
    required this.patientAge,
    required this.patientSex,
    required this.franchiseName,
    required this.dateOfBill,
    required this.billStatus,
    required this.totalAmount,
    required this.paidAmount,
    required this.discByCenter,
    required this.discByDoctor,
    required this.incentiveAmount,
    this.diagnosisTypeOutput,
    this.referredByDoctorOutput,
    this.testDoneBy,
    this.centerDetailOutput,
    this.billNumber,
  });

  /// Factory Constructor to Parse JSON Safely
  factory Bill.fromJson(Map<String, dynamic> json) {
    return Bill(
      id: json['id'],
      diagnosisType:
          json['diagnosis_type'] ?? json['diagnosis_type_output']?['id'] ?? 0,
      referredByDoctor:
          json['referred_by_doctor'] ?? json['referred_by_doctor_output']?['id'] ?? 0,
      centerDetail: json['center_detail'] is int
          ? json['center_detail']
          : json['center_detail']?['id'] ?? 0,
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
      diagnosisTypeOutput: json['diagnosis_type_output'],
      referredByDoctorOutput: json['referred_by_doctor_output'],
      testDoneBy: json['test_done_by'],
      centerDetailOutput: json['center_detail'] is Map
          ? json['center_detail']
          : null,
      billNumber: json['bill_number'],
    );
  }

  /// Convert Object to JSON Map (Skip ID if null)
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

  /// API Operations (Optional Static Methods)

  // static Future<List<Bill>> fetchAll(String token) async {
  //   final response = await http.get(
  //     Uri.parse('$baseURL/bills/'),
  //     headers: {'Authorization': 'Bearer $token'},
  //   );
  //   if (response.statusCode == 200) {
  //     List jsonList = json.decode(response.body);
  //     return jsonList.map((json) => Bill.fromJson(json)).toList();
  //   } else {
  //     throw Exception('Failed to fetch bills');
  //   }
  // }

  // static Future<Bill> fetchById(int id, String token) async {
  //   final response = await http.get(
  //     Uri.parse('$baseURL/bills/$id/'),
  //     headers: {'Authorization': 'Bearer $token'},
  //   );
  //   if (response.statusCode == 200) {
  //     return Bill.fromJson(json.decode(response.body));
  //   } else {
  //     throw Exception('Bill not found');
  //   }
  // }

  // static Future<Bill> create(Bill bill, String token) async {
  //   final response = await http.post(
  //     Uri.parse('$baseURL/bills/'),
  //     headers: {
  //       'Authorization': 'Bearer $token',
  //       'Content-Type': 'application/json',
  //     },
  //     body: json.encode(bill.toJson()),
  //   );
  //   if (response.statusCode == 201 || response.statusCode == 200) {
  //     return Bill.fromJson(json.decode(response.body));
  //   } else {
  //     throw Exception('Failed to create bill');
  //   }
  // }

  // static Future<Bill> update(Bill bill, String token) async {
  //   if (bill.id == null) {
  //     throw Exception('Cannot update Bill without ID');
  //   }
  //   final response = await http.put(
  //     Uri.parse('$baseURL/bills/${bill.id}/'),
  //     headers: {
  //       'Authorization': 'Bearer $token',
  //       'Content-Type': 'application/json',
  //     },
  //     body: json.encode(bill.toJson()),
  //   );
  //   if (response.statusCode == 200) {
  //     return Bill.fromJson(json.decode(response.body));
  //   } else {
  //     throw Exception('Failed to update bill');
  //   }
  // }

  // static Future<void> delete(int id, String token) async {
  //   final response = await http.delete(
  //     Uri.parse('$baseURL/bills/$id/'),
  //     headers: {'Authorization': 'Bearer $token'},
  //   );
  //   if (response.statusCode != 204) {
  //     throw Exception('Failed to delete bill');
  //   }
  // }
}

