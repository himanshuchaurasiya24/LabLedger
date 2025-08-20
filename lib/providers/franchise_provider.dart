// PROVIDERS & MODEL HANDLING - franchise_provider.dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:labledger/models/franchise_model.dart';
import 'package:labledger/providers/custom_providers.dart';

/// Fetch all franchises
final franchiseProvider = FutureProvider.autoDispose<List<Franchise>>((ref) async {
  final token = await ref.read(tokenProvider.future);
  final response = await http.get(
    Uri.parse("${baseURL}diagnosis/franchise-names/franchise-name/"),
    headers: {"Authorization": "Bearer $token"},
  );

  if (response.statusCode == 200) {
    final List data = jsonDecode(response.body);
    return data.map((e) => Franchise.fromJson(e)).toList().cast<Franchise>();
  } else {
    throw Exception("Failed to fetch franchises: ${response.body}");
  }
});

/// Fetch single franchise
final singleFranchiseProvider =
    FutureProvider.autoDispose.family<Franchise, int>((ref, id) async {
  final token = await ref.read(tokenProvider.future);
  final response = await http.get(
    Uri.parse("${baseURL}diagnosis/franchise-names/franchise-name/$id/"),
    headers: {"Authorization": "Bearer $token"},
  );

  if (response.statusCode == 200) {
    return Franchise.fromJson(jsonDecode(response.body));
  } else {
    throw Exception("Failed to fetch franchise: ${response.body}");
  }
});

/// Create franchise
final createFranchiseProvider =
    FutureProvider.autoDispose.family<Franchise, Franchise>((ref, newFranchise) async {
  final token = await ref.read(tokenProvider.future);
  final response = await http.post(
    Uri.parse("${baseURL}diagnosis/franchise-names/franchise-name/"),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode(newFranchise.toCreateJson()), // exclude id, center_detail
  );

  if (response.statusCode == 201) {
    ref.invalidate(franchiseProvider);
    return Franchise.fromJson(jsonDecode(response.body));
  } else {
    throw Exception("Failed to create franchise: ${response.body}");
  }
});

/// Update franchise
final updateFranchiseProvider =
    FutureProvider.autoDispose.family<Map<String, dynamic>, Map<String, dynamic>>((ref, input) async {
  final token = await ref.read(tokenProvider.future);
  final int id = input['id']; // Franchise ID
  final Map<String, dynamic> updatedData = input['data']; // Updated fields

  final response = await http.patch(
    Uri.parse("${baseURL}diagnosis/franchise-names/franchise-name/$id/"), // Adjust endpoint if needed
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode(updatedData),
  );

  if (response.statusCode == 200) {
    ref.invalidate(franchiseProvider); // refresh the franchise list provider
    return jsonDecode(response.body);
  } else {
    throw Exception("Failed to update Franchise: ${response.body}");
  }
});


/// Delete franchise
final deleteFranchiseProvider =
    FutureProvider.autoDispose.family<void, int>((ref, id) async {
  final token = await ref.read(tokenProvider.future);
  final response = await http.delete(
    Uri.parse("${baseURL}diagnosis/franchise-names/franchise-name/$id/"),
    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode == 204) {
    ref.invalidate(franchiseProvider);
  } else {
    throw Exception("Failed to delete franchise: ${response.body}");
  }
});
