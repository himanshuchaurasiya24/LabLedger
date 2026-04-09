import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/authentication/auth_http_client.dart';
import 'package:labledger/authentication/config.dart';
import 'package:labledger/models/paginated_audit_log_response.dart';

final String auditLogsEndpoint = '${globalBaseUrl}diagnosis/audit-logs/';
final auditLogsCurrentPageProvider = StateProvider.autoDispose<int>((ref) => 1);

final auditLogsProvider = FutureProvider.autoDispose<PaginatedAuditLogResponse>(
  (ref) async {
    final page = ref.watch(auditLogsCurrentPageProvider);
    final uri = Uri.parse(
      auditLogsEndpoint,
    ).replace(queryParameters: {'page': page.toString()});

    final response = await AuthHttpClient.get(ref, uri.toString());
    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Unexpected audit log response format.');
    }

    return PaginatedAuditLogResponse.fromJson(decoded);
  },
);
