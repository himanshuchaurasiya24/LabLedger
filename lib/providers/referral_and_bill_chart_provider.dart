// providers/referral_providers.dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:labledger/authentication/config.dart';
import 'package:labledger/models/bill_model.dart';
import 'package:labledger/models/referral_and_bill_chart_model.dart';

import '../authentication/auth_http_client.dart'; // contains globalBaseUrl & AuthHttpClient

// Build endpoints dynamically from globalBaseUrl
String get billsEndpoint => "${globalBaseUrl}diagnosis/bills/bill/";
String get referralStatsEndpoint => "${globalBaseUrl}diagnosis/referral-stats/referral-stat/";
String get chartStatsEndpoint => "${globalBaseUrl}diagnosis/referral-stats/bill-chart-stat/";

// ---------------- Providers ---------------- //

// Fetch all bills
final billsProvider = FutureProvider.autoDispose<List<Bill>>((ref) async {
  final http.Response response = await AuthHttpClient.get(ref, billsEndpoint);

  if (response.statusCode == 200) {
    final List<dynamic> jsonList = jsonDecode(response.body);
    return jsonList.map((json) => Bill.fromJson(json)).toList();
  } else {
    throw Exception(
      "Failed to fetch bills: ${response.statusCode} ${response.body}",
    );
  }
});

// Fetch referral stats
final referralStatsProvider =
    FutureProvider.autoDispose<ReferralStatsResponse>((ref) async {
  final http.Response response = await AuthHttpClient.get(ref, referralStatsEndpoint);

  if (response.statusCode == 200) {
    final Map<String, dynamic> json = jsonDecode(response.body);
    return ReferralStatsResponse.fromJson(json);
  } else {
    throw Exception(
      "Failed to fetch referral stats: ${response.statusCode} ${response.body}",
    );
  }
});

// Fetch chart stats
final chartStatsProvider =
    FutureProvider.autoDispose<ChartStatsResponse>((ref) async {
  final http.Response response = await AuthHttpClient.get(ref, chartStatsEndpoint);

  if (response.statusCode == 200) {
    final Map<String, dynamic> json = jsonDecode(response.body);
    return ChartStatsResponse.fromJson(json);
  } else {
    throw Exception(
      "Failed to fetch chart stats: ${response.statusCode} ${response.body}",
    );
  }
});

// State provider for selected time period
final selectedTimePeriodProvider = StateProvider<String>((ref) => 'This Month');
