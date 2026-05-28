class PatientReport {
  final int id;
  final String reportFile;
  final int billId;

  PatientReport({
    required this.id,
    required this.reportFile,
    required this.billId,
  });

  factory PatientReport.fromJson(Map<String, dynamic> json) {
    return PatientReport(
      id: json['id'],
      reportFile: json['report_file'],
      billId: json['bill_output']?['id'] ?? 0,
    );
  }
}
