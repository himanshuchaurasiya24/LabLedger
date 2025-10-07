import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/authentication/auth_http_client.dart';
import 'package:labledger/authentication/config.dart';
import 'package:labledger/models/franchise_model.dart';
import 'package:labledger/providers/bills_provider.dart';
import 'package:labledger/providers/referral_and_bill_chart_provider.dart';

final String franchiseEndpoint = "${globalBaseUrl}diagnosis/franchise-name/";
final franchiseProvider = FutureProvider.autoDispose<List<FranchiseName>>((
  ref,
) async {
  final response = await AuthHttpClient.get(ref, franchiseEndpoint);
  final List data = jsonDecode(response.body);
  return data.map((e) => FranchiseName.fromJson(e)).toList();
});

final singleFranchiseProvider = FutureProvider.autoDispose
    .family<FranchiseName, int>((ref, id) async {
      final response = await AuthHttpClient.get(ref, "$franchiseEndpoint$id/");
      return FranchiseName.fromJson(jsonDecode(response.body));
    });

final createFranchiseProvider = FutureProvider.autoDispose
    .family<FranchiseName, FranchiseName>((ref, newFranchise) async {
      final response = await AuthHttpClient.post(
        ref,
        franchiseEndpoint,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(newFranchise.toCreateJson()),
      );

      _invalidateFranchiseCache(ref: ref);
      return FranchiseName.fromJson(jsonDecode(response.body));
    });

final updateFranchiseProvider = FutureProvider.autoDispose
    .family<FranchiseName, FranchiseName>((ref, franchiseName) async {
      final int id = franchiseName.id!;

      final response = await AuthHttpClient.put(
        ref,
        "$franchiseEndpoint$id/",
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(franchiseName.toJson()),
      );
      _invalidateFranchiseCache(ref: ref, id: id);

      return FranchiseName.fromJson(jsonDecode(response.body));
    });

final deleteFranchiseProvider = FutureProvider.autoDispose.family<void, int>((
  ref,
  id,
) async {
  await AuthHttpClient.delete(ref, "$franchiseEndpoint$id/");
  _invalidateFranchiseCache(ref: ref, id: id);
});

void _invalidateFranchiseCache({required Ref ref, int? id}) {
  ref.invalidate(franchiseProvider);
  if (id != null) {
    ref.invalidate(singleFranchiseProvider(id));
  }
  ref.invalidate(referralStatsProvider);
  ref.invalidate(billChartStatsProvider);
  ref.invalidate(paginatedUnpaidPartialBillsProvider);
  ref.invalidate(latestBillsProvider);
  ref.invalidate(pendingReportBillProvider);
}
