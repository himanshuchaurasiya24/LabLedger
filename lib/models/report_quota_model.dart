class ReportQuotaBucket {
  final String label;
  final int usedBytes;
  final double usedMb;
  final int quotaMb;
  final int quotaBytes;
  final int remainingBytes;
  final double remainingMb;
  final double usagePercent;

  const ReportQuotaBucket({
    required this.label,
    required this.usedBytes,
    required this.usedMb,
    required this.quotaMb,
    required this.quotaBytes,
    required this.remainingBytes,
    required this.remainingMb,
    required this.usagePercent,
  });

  factory ReportQuotaBucket.fromJson(Map<String, dynamic> json) {
    return ReportQuotaBucket(
      label: (json['label'] as String?) ?? '',
      usedBytes: (json['used_bytes'] as int?) ?? 0,
      usedMb: (json['used_mb'] as num?)?.toDouble() ?? 0,
      quotaMb: (json['quota_mb'] as int?) ?? 0,
      quotaBytes: (json['quota_bytes'] as int?) ?? 0,
      remainingBytes: (json['remaining_bytes'] as int?) ?? 0,
      remainingMb: (json['remaining_mb'] as num?)?.toDouble() ?? 0,
      usagePercent: (json['usage_percent'] as num?)?.toDouble() ?? 0,
    );
  }

  double get normalizedUsage => (usagePercent / 100).clamp(0, 1);
}

class ReportQuotaSummary {
  final int planId;
  final String planName;
  final int planIndex;
  final bool isCustom;
  final ReportQuotaBucket serverReport;
  final ReportQuotaBucket patientReport;

  const ReportQuotaSummary({
    required this.planId,
    required this.planName,
    required this.planIndex,
    required this.isCustom,
    required this.serverReport,
    required this.patientReport,
  });

  factory ReportQuotaSummary.fromJson(Map<String, dynamic> json) {
    final planRaw = json['plan'] as Map<String, dynamic>? ?? const {};
    return ReportQuotaSummary(
      planId: (planRaw['id'] as int?) ?? 0,
      planName: (planRaw['name'] as String?) ?? '',
      planIndex: (planRaw['plan_index'] as int?) ?? 0,
      isCustom: (planRaw['is_custom'] as bool?) ?? false,
      serverReport: ReportQuotaBucket.fromJson(
        (json['server_report'] as Map<String, dynamic>?) ?? const {},
      ),
      patientReport: ReportQuotaBucket.fromJson(
        (json['patient_report'] as Map<String, dynamic>?) ?? const {},
      ),
    );
  }
}
