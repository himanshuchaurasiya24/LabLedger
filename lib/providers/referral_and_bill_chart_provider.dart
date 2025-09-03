// providers/referral_providers.dart

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:labledger/authentication/config.dart';
import 'package:labledger/models/referral_and_bill_chart_model.dart';
import 'package:labledger/authentication/auth_http_client.dart';

String get billsEndpoint => "${globalBaseUrl}diagnosis/bills/bill/";
String get referralStatsEndpoint =>
    "${globalBaseUrl}diagnosis/referral-stats/referral-stat/";
String get chartStatsEndpoint =>
    "${globalBaseUrl}diagnosis/referral-stats/bill-chart-stat/";

final referralStatsProvider =
    FutureProvider.autoDispose<ReferralStatsResponse>((ref) async {
  final http.Response response =
      await AuthHttpClient.get(ref, referralStatsEndpoint);

  if (response.statusCode == 200) {
    final Map<String, dynamic> json = jsonDecode(response.body);
    return ReferralStatsResponse.fromJson(json);
  } else {
    throw Exception(
      "Failed to fetch referral stats: ${response.statusCode} ${response.body}",
    );
  }
});

final billChartStatsProvider =
    FutureProvider.autoDispose<ChartStatsResponse>((ref) async {
  final http.Response response =
      await AuthHttpClient.get(ref, chartStatsEndpoint);

  if (response.statusCode == 200) {
    final Map<String, dynamic> json = jsonDecode(response.body);
    return ChartStatsResponse.fromJson(json);
  } else {
    throw Exception(
      "Failed to fetch chart stats: ${response.statusCode} ${response.body}",
    );
  }
});

final selectedTimePeriodProvider = StateProvider<String>((ref) => 'This Month');