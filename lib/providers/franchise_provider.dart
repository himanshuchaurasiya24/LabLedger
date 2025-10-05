import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/authentication/auth_http_client.dart';
import 'package:labledger/authentication/config.dart';
import 'package:labledger/models/franchise_model.dart';

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

      ref.invalidate(franchiseProvider);
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

      ref.invalidate(franchiseProvider);
      ref.invalidate(singleFranchiseProvider(id));

      return FranchiseName.fromJson(jsonDecode(response.body));
    });

final deleteFranchiseProvider = FutureProvider.autoDispose.family<void, int>((
  ref,
  id,
) async {
  await AuthHttpClient.delete(ref, "$franchiseEndpoint$id/");
  ref.invalidate(singleFranchiseProvider(id));
  ref.invalidate(franchiseProvider);
});

final franchiseNamesProvider = FutureProvider.autoDispose<List<FranchiseName>>((
  ref,
) async {
  final response = await AuthHttpClient.get(ref, franchiseEndpoint);
  final List<dynamic> data = jsonDecode(response.body);
  return data.map((item) => FranchiseName.fromJson(item)).toList();
});
