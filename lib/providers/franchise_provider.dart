// PROVIDERS & MODEL HANDLING - franchise_provider.dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/authentication/auth_http_client.dart';
import 'package:labledger/authentication/config.dart';
import 'package:labledger/models/franchise_model.dart';

/// ✅ Base API Endpoint
final String franchiseEndpoint =
    "${globalBaseUrl}diagnosis/franchise-names/franchise-name/";

/// ✅ Fetch all franchises
final franchiseProvider = FutureProvider.autoDispose<List<FranchiseName>>((ref) async {
  final response = await AuthHttpClient.get(ref, franchiseEndpoint);

  if (response.statusCode == 200) {
    final List data = jsonDecode(response.body);
    return data.map((e) => FranchiseName.fromJson(e)).toList().cast<FranchiseName>();
  } else {
    throw Exception("Failed to fetch franchises: ${response.body}");
  }
});

/// ✅ Fetch single franchise by ID
final singleFranchiseProvider =
    FutureProvider.autoDispose.family<FranchiseName, int>((ref, id) async {
  final response = await AuthHttpClient.get(
    ref,
    "$franchiseEndpoint$id/",
  );

  if (response.statusCode == 200) {
    return FranchiseName.fromJson(jsonDecode(response.body));
  } else {
    throw Exception("Failed to fetch franchise: ${response.body}");
  }
});

/// ✅ Create franchise
final createFranchiseProvider =
    FutureProvider.autoDispose.family<FranchiseName, FranchiseName>((ref, newFranchise) async {
  final response = await AuthHttpClient.post(
    ref,
    franchiseEndpoint,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(newFranchise.toCreateJson()), // exclude id, center_detail
  );

  if (response.statusCode == 201) {
    ref.invalidate(franchiseProvider);
    return FranchiseName.fromJson(jsonDecode(response.body));
  } else {
    throw Exception("Failed to create franchise: ${response.body}");
  }
});

/// ✅ Update franchise (using PUT instead of PATCH)
final updateFranchiseProvider =
    FutureProvider.autoDispose.family<Map<String, dynamic>, Map<String, dynamic>>((ref, input) async {
  final int id = input['id']; // Franchise ID
  final Map<String, dynamic> updatedData = input['data']; // Updated fields

  final response = await AuthHttpClient.put(
    ref,
    "$franchiseEndpoint$id/",
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(updatedData),
  );

  if (response.statusCode == 200) {
    ref.invalidate(franchiseProvider); // refresh franchise list
    return jsonDecode(response.body);
  } else {
    throw Exception("Failed to update Franchise: ${response.body}");
  }
});

/// ✅ Delete franchise
final deleteFranchiseProvider =
    FutureProvider.autoDispose.family<void, int>((ref, id) async {
  final response = await AuthHttpClient.delete(
    ref,
    "$franchiseEndpoint$id/",
  );

  if (response.statusCode == 204) {
    ref.invalidate(franchiseProvider);
  } else {
    throw Exception("Failed to delete franchise: ${response.body}");
  }
});

/// ✅ Fetch FranchiseName Models (with center_detail)
final franchiseNamesProvider =
    FutureProvider.autoDispose<List<FranchiseName>>((ref) async {
  final response = await AuthHttpClient.get(
    ref,
    franchiseEndpoint,
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((item) => FranchiseName.fromJson(item)).toList();
  } else {
    throw Exception('Failed to load franchise names: ${response.body}');
  }
});
