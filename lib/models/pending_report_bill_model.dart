import 'package:labledger/models/diagnosis_type_model.dart';

class PendingReportBillModel {
  final int id;
  final String patientName;
  final int patientAge;
  final String patientSex;
  final DiagnosisType diagnosisType;
  final DateTime dateOfBill;
  final int referredByDoctor;

  PendingReportBillModel({
    required this.id,
    required this.patientName,
    required this.patientAge,
    required this.patientSex,
    required this.diagnosisType,
    required this.dateOfBill,
    required this.referredByDoctor,
  });

  factory PendingReportBillModel.fromJson(Map<String, dynamic> json) =>
      PendingReportBillModel(
        id: json["id"],
        patientName: json["patient_name"],
        patientAge: json["patient_age"],
        patientSex: json["patient_sex"],
        diagnosisType: DiagnosisType.fromJson(json["diagnosis_type"]),
        dateOfBill: DateTime.parse(json["date_of_bill"]),
        referredByDoctor: json["referred_by_doctor"],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "patient_name": patientName,
    "patient_age": patientAge,
    "patient_sex": patientSex,
    "diagnosis_type": diagnosisType.toJson(),
    "date_of_bill": dateOfBill.toIso8601String(),
    "referred_by_doctor": referredByDoctor,
  };
}
