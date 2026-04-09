class AuditLogEntry {
  final int id;
  final String action;
  final String modelName;
  final String? objectId;
  final String details;
  final DateTime? timestamp;
  final String? ipAddress;
  final String username;
  final String userFullName;

  const AuditLogEntry({
    required this.id,
    required this.action,
    required this.modelName,
    required this.objectId,
    required this.details,
    required this.timestamp,
    required this.ipAddress,
    required this.username,
    required this.userFullName,
  });

  factory AuditLogEntry.fromJson(Map<String, dynamic> json) {
    final dynamic timestampRaw = json['timestamp'];

    return AuditLogEntry(
      id: (json['id'] as int?) ?? 0,
      action: (json['action'] as String?) ?? 'UNKNOWN',
      modelName: (json['model_name'] as String?) ?? 'Unknown',
      objectId: json['object_id']?.toString(),
      details: (json['details'] as String?) ?? '',
      timestamp: timestampRaw is String && timestampRaw.isNotEmpty
          ? DateTime.tryParse(timestampRaw)?.toLocal()
          : null,
      ipAddress: json['ip_address'] as String?,
      username: (json['username'] as String?) ?? 'Unknown',
      userFullName: (json['user_full_name'] as String?) ?? 'Unknown user',
    );
  }
}
