class ReportUploadData {
  final int billId;
  final String filePath;

  ReportUploadData({required this.billId, required this.filePath});
}

/// A helper class for the update provider.
class ReportUpdateData {
  final int reportId;
  final int billId; // Needed to invalidate the correct cache
  final String filePath;
  
  ReportUpdateData({required this.reportId, required this.billId, required this.filePath});
}
