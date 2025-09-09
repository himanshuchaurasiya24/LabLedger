import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/authentication/auth_http_client.dart';
import 'package:labledger/authentication/config.dart';
import 'package:labledger/models/center_detail_model_with_subscription.dart';
import 'package:labledger/providers/user_provider.dart'; // ✅ Make sure path is correct

/// ✅ Base API Endpoint
final String centerDetailsEndpoint =
    "${globalBaseUrl}center-details/center-details/center-detail/";

/// ✅ Fetch all center details
final centerDetailsProvider = FutureProvider.autoDispose<List<CenterDetail>>((
  ref,
) async {
  final response = await AuthHttpClient.get(ref, centerDetailsEndpoint);

  if (response.statusCode == 200) {
    final List data = jsonDecode(response.body);
    return data.map((json) => CenterDetail.fromJson(json)).toList();
  } else {
    throw Exception("Failed to fetch center details: ${response.body}");
  }
});

/// ✅ Fetch a single center detail by ID
final singleCenterDetailProvider = FutureProvider.autoDispose
    .family<CenterDetail, int>((ref, id) async {
      final response = await AuthHttpClient.get(
        ref,
        "$centerDetailsEndpoint$id/",
      );

      if (response.statusCode == 200) {
        return CenterDetail.fromJson(jsonDecode(response.body));
      } else {
        throw Exception("Failed to fetch center detail: ${response.body}");
      }
    });

/// ✅ Update an existing center detail
final updateCenterDetailProvider = FutureProvider.autoDispose
    .family<CenterDetail, CenterDetail>((ref, updatedDetail) async {
      final response = await AuthHttpClient.put(
        ref,
        "$centerDetailsEndpoint${updatedDetail.id}/",
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(updatedDetail.toJson()),
      );

      if (response.statusCode == 200) {
        ref.invalidate(centerDetailsProvider);
        ref.invalidate(singleCenterDetailProvider);
        ref.invalidate(usersDetailsProvider);

        return CenterDetail.fromJson(jsonDecode(response.body));
      } else {
        throw Exception("Failed to update center detail: ${response.body}");
      }
    });

/// ✅ Delete a center detail
final deleteCenterDetailProvider = FutureProvider.autoDispose.family<void, int>(
  (ref, id) async {
    final response = await AuthHttpClient.delete(
      ref,
      "$centerDetailsEndpoint$id/",
    );

    if (response.statusCode == 204) {
      ref.invalidate(centerDetailsProvider);
      ref.invalidate(singleCenterDetailProvider);
      ref.invalidate(usersDetailsProvider);
    } else {
      throw Exception("Failed to delete center detail: ${response.body}");
    }
  },
);
