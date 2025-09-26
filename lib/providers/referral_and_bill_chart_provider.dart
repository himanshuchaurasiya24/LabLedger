import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/authentication/config.dart';
import 'package:labledger/models/bill_stats_model.dart';
import 'package:labledger/models/referral_and_bill_chart_model.dart';
import 'package:labledger/authentication/auth_http_client.dart';

// --- Endpoints ---
final String referralStatsEndpoint =
    "${globalBaseUrl}diagnosis/referral-stat/";
final String chartStatsEndpoint =
    "${globalBaseUrl}diagnosis/bill-chart-stat/";

/// Fetches referral statistics for the dashboard.
final referralStatsProvider =
    FutureProvider.autoDispose<ReferralStatsResponse>((ref) async {
  // AuthHttpClient now handles all errors. If we get a response, it's successful.
  final response = await AuthHttpClient.get(ref, referralStatsEndpoint);
  final Map<String, dynamic> json = jsonDecode(response.body);
  return ReferralStatsResponse.fromJson(json);
});

/// Fetches chart statistics for the dashboard.
final billChartStatsProvider =
    FutureProvider.autoDispose<ChartStatsResponse>((ref) async {
  // No need to check status codes; AuthHttpClient manages failures.
  final response = await AuthHttpClient.get(ref, chartStatsEndpoint);
  final Map<String, dynamic> json = jsonDecode(response.body);
  return ChartStatsResponse.fromJson(json);
});

/// Holds the currently selected time period for filtering stats (e.g., "This Month").
final selectedTimePeriodProvider = StateProvider.autoDispose<String>((ref) => 'This Month');

/// Fetches bill growth statistics for a specific doctor.
final doctorGrowthStatsProvider =
    FutureProvider.autoDispose.family<BillStats, int>((ref, doctorId) async {
  // Construct the new endpoint URL
  final String doctorGrowthStatsEndpoint =
      "${globalBaseUrl}diagnosis/doctors/$doctorId/growth-stats/";

  final response = await AuthHttpClient.get(ref, doctorGrowthStatsEndpoint);
  return BillStats.fromJson(jsonDecode(response.body));
});