// providers/referral_providers.dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:labledger/models/bill_model.dart';
import 'package:labledger/models/referral_and_bill_chart_model.dart';
import 'package:labledger/providers/custom_providers.dart';

// Constants for API endpoints
 String billsEndpoint = "${baseURL}diagnosis/bills/bill/";
 String referralStatsEndpoint = "${baseURL}diagnosis/referral-stats/referral-stat/";
 String chartStatsEndpoint = "${baseURL}diagnosis/referral-stats/bill-chart-stat/";



// Fetch all bills
final billsProvider = FutureProvider.autoDispose<List<Bill>>((ref) async {
 final token = await ref.read(tokenProvider.future);  final response = await http.get(
    Uri.parse(billsEndpoint),
    headers: {"Authorization": "Bearer $token"},
  );
  if (response.statusCode == 200) {
    final List jsonList = jsonDecode(response.body);
    return jsonList.map((json) => Bill.fromJson(json)).toList();
  } else {
    throw Exception("Failed to fetch bills: ${response.body}");
  }
});

// Fetch referral stats
final referralStatsProvider = FutureProvider.autoDispose<ReferralStatsResponse>((ref) async {
 final token = await ref.read(tokenProvider.future);  final response = await http.get(
    Uri.parse(referralStatsEndpoint),
    headers: {"Authorization": "Bearer $token"},
  );
  if (response.statusCode == 200) {
    final Map<String, dynamic> json = jsonDecode(response.body);
    return ReferralStatsResponse.fromJson(json);
  } else {
    throw Exception("Failed to fetch referral stats: ${response.body}");
  }
});

// Fetch chart stats
final chartStatsProvider = FutureProvider.autoDispose<ChartStatsResponse>((ref) async {
 final token = await ref.read(tokenProvider.future);  final response = await http.get(
    Uri.parse(chartStatsEndpoint),
    headers: {"Authorization": "Bearer $token"},
  );
  if (response.statusCode == 200) {
    final Map<String, dynamic> json = jsonDecode(response.body);
    return ChartStatsResponse.fromJson(json);
  } else {
    throw Exception("Failed to fetch chart stats: ${response.body}");
  }
});

// State provider for selected time period
final selectedTimePeriodProvider = StateProvider<String>((ref) => 'This Month');