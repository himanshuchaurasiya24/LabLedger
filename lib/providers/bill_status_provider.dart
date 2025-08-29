import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/authentication/auth_http_client.dart';
import 'package:labledger/authentication/config.dart';
import 'package:labledger/models/bill_stats_model.dart';

String billStatsEndpoint = "${globalBaseUrl}diagnosis/bills/growth-stats/";
final billStatsProvider = FutureProvider.autoDispose((ref) async {
  final response = await AuthHttpClient.get(ref, billStatsEndpoint);

  if (response.statusCode == 200) {
    return BillStats.fromJson(jsonDecode(response.body));
  } else {
    throw Exception("Failed to get bill stats: ${response.body}");
  }
});
