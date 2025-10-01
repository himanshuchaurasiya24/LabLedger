class PatientReport {
  final int id;
  final String reportUrl;
  final int billId;

  PatientReport({
    required this.id,
    required this.reportUrl,
    required this.billId,
  });

  factory PatientReport.fromJson(Map<String, dynamic> json) {
    return PatientReport(
      id: json['id'],
      reportUrl: json['report_file'],
      billId: json['bill_output']?['id'] ?? 0,
    );
  }
}
