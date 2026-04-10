import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/authentication/auth_http_client.dart';
import 'package:labledger/authentication/config.dart';
import 'package:labledger/constants/urls.dart';
import 'package:labledger/models/report_quota_model.dart';

final String reportQuotaSummaryEndpoint =
    '$globalBaseUrl${AppUrls.diagnosisReportQuotaSummary}';

final reportQuotaSummaryProvider =
    FutureProvider.autoDispose<ReportQuotaSummary>((ref) async {
      final response = await AuthHttpClient.get(
        ref,
        reportQuotaSummaryEndpoint,
      );
      return ReportQuotaSummary.fromJson(jsonDecode(response.body));
    });
