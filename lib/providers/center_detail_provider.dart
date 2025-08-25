import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:labledger/providers/custom_providers.dart';
import 'package:labledger/models/center_detail_model.dart'; // make sure path is correct

/// ✅ API Endpoint (separate for easy change)
String centerDetailsEndpoint =
    "${baseURL}center-details/center-details/center-detail/";

/// ✅ Fetch all center details
final centerDetailsProvider = FutureProvider.autoDispose<List<CenterDetail>>((
  ref,
) async {
  final token = await ref.read(tokenProvider.future);
  final response = await http.get(
    Uri.parse(centerDetailsEndpoint),
    headers: {"Authorization": "Bearer $token"},
  );
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
      final token = await ref.read(tokenProvider.future);
      final response = await http.get(
        Uri.parse("$centerDetailsEndpoint$id/"),
        headers: {"Authorization": "Bearer $token"},
      );
      if (response.statusCode == 200) {
        return CenterDetail.fromJson(jsonDecode(response.body));
      } else {
        throw Exception("Failed to fetch center detail: ${response.body}");
      }
    });

/// ✅ Create a new center detail
final createCenterDetailProvider = FutureProvider.autoDispose
    .family<CenterDetail, CenterDetail>((ref, newDetail) async {
      final token = await ref.read(tokenProvider.future);
      final response = await http.post(
        Uri.parse(centerDetailsEndpoint),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(newDetail.toJson()),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        ref.invalidate(centerDetailsProvider);
        ref.invalidate(userDetailsProvider);
        ref.invalidate(usersDetailsProvider);
        return CenterDetail.fromJson(jsonDecode(response.body));
      } else {
        throw Exception("Failed to create center detail: ${response.body}");
      }
    });

/// ✅ Update an existing center detail
final updateCenterDetailProvider = FutureProvider.autoDispose
    .family<CenterDetail, CenterDetail>((ref, updatedDetail) async {
      final token = await ref.read(tokenProvider.future);
      final response = await http.put(
        Uri.parse("$centerDetailsEndpoint${updatedDetail.id}/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(updatedDetail.toJson()),
      );
      if (response.statusCode == 200) {
        ref.invalidate(centerDetailsProvider);
        ref.invalidate(userDetailsProvider);
        ref.invalidate(usersDetailsProvider);
        return CenterDetail.fromJson(jsonDecode(response.body));
      } else {
        throw Exception("Failed to update center detail: ${response.body}");
      }
    });

/// ✅ Delete a center detail
final deleteCenterDetailProvider = FutureProvider.autoDispose.family<void, int>(
  (ref, id) async {
    final token = await ref.read(tokenProvider.future);
    final response = await http.delete(
      Uri.parse("$centerDetailsEndpoint$id/"),
      headers: {"Authorization": "Bearer $token"},
    );
    if (response.statusCode == 204) {
      ref.invalidate(centerDetailsProvider);
      ref.invalidate(userDetailsProvider);
      ref.invalidate(usersDetailsProvider);
    } else {
      throw Exception("Failed to delete center detail: ${response.body}");
    }
  },
);
