import 'package:labledger/models/audit_log_model.dart';

class PaginatedAuditLogResponse {
  final List<AuditLogEntry> logs;
  final int count;
  final bool hasNext;

  const PaginatedAuditLogResponse({
    required this.logs,
    required this.count,
    required this.hasNext,
  });

  factory PaginatedAuditLogResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> jsonList = (json['results'] as List<dynamic>?) ?? [];

    return PaginatedAuditLogResponse(
      logs: jsonList
          .whereType<Map<String, dynamic>>()
          .map(AuditLogEntry.fromJson)
          .toList(),
      count: (json['count'] as int?) ?? 0,
      hasNext: json['next'] != null,
    );
  }
}
