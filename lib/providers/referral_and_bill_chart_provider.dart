import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/authentication/config.dart';
import 'package:labledger/models/bill_stats_model.dart';
import 'package:labledger/models/referral_and_bill_chart_model.dart';
import 'package:labledger/authentication/auth_http_client.dart';

final String referralStatsEndpoint =
    "${globalBaseUrl}diagnosis/referral-stat/";
final String chartStatsEndpoint =
    "${globalBaseUrl}diagnosis/bill-chart-stat/";

final referralStatsProvider =
    FutureProvider.autoDispose<ReferralStatsResponse>((ref) async {
  final response = await AuthHttpClient.get(ref, referralStatsEndpoint);
  final Map<String, dynamic> json = jsonDecode(response.body);
  return ReferralStatsResponse.fromJson(json);
});

final billChartStatsProvider =
    FutureProvider.autoDispose<ChartStatsResponse>((ref) async {
  final response = await AuthHttpClient.get(ref, chartStatsEndpoint);
  final Map<String, dynamic> json = jsonDecode(response.body);
  return ChartStatsResponse.fromJson(json);
});

final selectedTimePeriodProvider = StateProvider.autoDispose<String>((ref) => 'This Month');

final doctorGrowthStatsProvider =
    FutureProvider.autoDispose.family<BillStats, int>((ref, doctorId) async {
  final String doctorGrowthStatsEndpoint =
      "${globalBaseUrl}diagnosis/doctors/$doctorId/growth-stats/";

  final response = await AuthHttpClient.get(ref, doctorGrowthStatsEndpoint);
  return BillStats.fromJson(jsonDecode(response.body));
});