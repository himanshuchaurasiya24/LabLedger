import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/models/bill_stats_model.dart';
import 'package:labledger/providers/custom_providers.dart';
import "package:http/http.dart" as http;

final billStatsProvider = FutureProvider.autoDispose((ref) async {
  final token = await ref.read(tokenProvider.future);
  final response = await http.get(
    Uri.parse("${baseURL}diagnosis/bills/growth-stats/"),
    headers: {"Authorization": "Bearer $token"},
  );
  if (response.statusCode == 200) {
    return BillStats.fromJson(jsonDecode(response.body));
  } else {
    throw Exception("Failed to get bill stats: ${response.body}");
  }
});
