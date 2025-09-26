import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/authentication/auth_http_client.dart';
import 'package:labledger/authentication/config.dart';
import 'package:labledger/models/franchise_model.dart';

/// ✅ Base API Endpoint
final String franchiseEndpoint =
    "${globalBaseUrl}diagnosis/franchise-name/";

/// ✅ Fetch all franchises
final franchiseProvider =
    FutureProvider.autoDispose<List<FranchiseName>>((ref) async {
  // AuthHttpClient now handles all errors. If we get a response, it's successful.
  final response = await AuthHttpClient.get(ref, franchiseEndpoint);
  final List data = jsonDecode(response.body);
  return data.map((e) => FranchiseName.fromJson(e)).toList();
});

/// ✅ Fetch single franchise by ID
final singleFranchiseProvider =
    FutureProvider.autoDispose.family<FranchiseName, int>((ref, id) async {
  final response = await AuthHttpClient.get(
    ref,
    "$franchiseEndpoint$id/",
  );
  // No need to check status code.
  return FranchiseName.fromJson(jsonDecode(response.body));
});

/// ✅ Create franchise
final createFranchiseProvider =
    FutureProvider.autoDispose.family<FranchiseName, FranchiseName>((ref, newFranchise) async {
  final response = await AuthHttpClient.post(
    ref,
    franchiseEndpoint,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(newFranchise.toCreateJson()),
  );

  // If the request succeeds (e.g., status 201), we proceed. Otherwise, AuthHttpClient would have thrown an exception.
  ref.invalidate(franchiseProvider);
  return FranchiseName.fromJson(jsonDecode(response.body));
});

/// ✅ Update franchise (using PUT instead of PATCH)
final updateFranchiseProvider =
    FutureProvider.autoDispose.family<Map<String, dynamic>, Map<String, dynamic>>((ref, input) async {
  final int id = input['id'];
  final Map<String, dynamic> updatedData = input['data'];

  final response = await AuthHttpClient.put(
    ref,
    "$franchiseEndpoint$id/",
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(updatedData),
  );

  ref.invalidate(franchiseProvider);
  return jsonDecode(response.body);
});

/// ✅ Delete franchise
final deleteFranchiseProvider =
    FutureProvider.autoDispose.family<void, int>((ref, id) async {
  // We just need to make the call. Success (204) or failure is handled by the client.
  await AuthHttpClient.delete(
    ref,
    "$franchiseEndpoint$id/",
  );
  // On success, invalidate the list.
  ref.invalidate(franchiseProvider);
});

/// ⚠️ NOTE: This provider is redundant as it's identical to `franchiseProvider`.
/// It's recommended to remove this and use `franchiseProvider` everywhere.
final franchiseNamesProvider =
    FutureProvider.autoDispose<List<FranchiseName>>((ref) async {
  final response = await AuthHttpClient.get(
    ref,
    franchiseEndpoint,
  );
  final List<dynamic> data = jsonDecode(response.body);
  return data.map((item) => FranchiseName.fromJson(item)).toList();
});