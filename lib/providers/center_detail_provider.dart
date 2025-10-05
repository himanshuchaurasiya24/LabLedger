import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/authentication/auth_http_client.dart';
import 'package:labledger/authentication/config.dart';
import 'package:labledger/models/center_detail_model_with_subscription.dart';
import 'package:labledger/providers/user_provider.dart';

final String centerDetailsEndpoint =
    "${globalBaseUrl}center-details/center-detail/";

final centerDetailsProvider =
    FutureProvider.autoDispose<List<CenterDetail>>((ref) async {
  final response = await AuthHttpClient.get(ref, centerDetailsEndpoint);
  final List data = jsonDecode(response.body);
  return data.map((json) => CenterDetail.fromJson(json)).toList();
});

final singleCenterDetailProvider =
    FutureProvider.autoDispose.family<CenterDetail, int>((ref, id) async {
  final response = await AuthHttpClient.get(ref, "$centerDetailsEndpoint$id/");
  return CenterDetail.fromJson(jsonDecode(response.body));
});

final updateCenterDetailProvider =
    FutureProvider.autoDispose.family<CenterDetail, CenterDetail>((ref, updatedDetail) async {
  final response = await AuthHttpClient.put(
    ref,
    "$centerDetailsEndpoint${updatedDetail.id}/",
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(updatedDetail.toJson()),
  );
  _invalidateCenterDetailsCache(ref);
  return CenterDetail.fromJson(jsonDecode(response.body));
});

final deleteCenterDetailProvider =
    FutureProvider.autoDispose.family<void, int>((ref, id) async {
  await AuthHttpClient.delete(ref, "$centerDetailsEndpoint$id/");
  _invalidateCenterDetailsCache(ref);
});



void _invalidateCenterDetailsCache(Ref ref) {
  ref.invalidate(centerDetailsProvider);
  ref.invalidate(singleCenterDetailProvider);
  ref.invalidate(usersDetailsProvider);
}