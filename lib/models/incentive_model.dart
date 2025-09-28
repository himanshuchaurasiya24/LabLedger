import 'package:labledger/models/bill_model.dart';

class DoctorReport {
  final int doctorId;
  final String firstName;
  final String lastName;
  final int totalIncentive;
  final List<Bill> bills;

  DoctorReport({
    required this.doctorId,
    required this.firstName,
    required this.lastName,
    required this.totalIncentive,
    required this.bills,
  });

  factory DoctorReport.fromJson(Map<String, dynamic> json) {
    var billsListFromJson = json['bills'] as List? ?? [];
    List<Bill> parsedBills = billsListFromJson
        .map((billJson) => Bill.fromJson(billJson))
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

