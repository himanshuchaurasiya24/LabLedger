import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/authentication/auth_http_client.dart';
import 'package:labledger/authentication/config.dart';
import 'package:labledger/models/diagnosis_type_model.dart';

/// Base API Endpoint
final String diagnosisTypeEndpoint =
    "${globalBaseUrl}diagnosis/diagnosis-types/diagnosis-type/";

/// Fetches all Diagnosis Types.
final diagnosisTypeProvider =
    FutureProvider.autoDispose<List<DiagnosisType>>((ref) async {
  // AuthHttpClient handles all errors. If we get a response, it's successful.
  final response = await AuthHttpClient.get(ref, diagnosisTypeEndpoint);
  final List data = jsonDecode(response.body);
  return data.map((e) => DiagnosisType.fromJson(e)).toList();
});

/// Adds a new Diagnosis Type.
final addDiagnosisTypeProvider =
    FutureProvider.autoDispose.family<bool, DiagnosisType>((ref, diagnosis) async {
  await AuthHttpClient.post(
    ref,
    diagnosisTypeEndpoint,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(diagnosis.toJson()),
  );
  // On success, invalidate the list and return true.
  ref.invalidate(diagnosisTypeProvider);
  return true;
});

/// Updates an existing Diagnosis Type.
final updateDiagnosisTypeProvider =
    FutureProvider.autoDispose.family<Map<String, dynamic>, Map<String, dynamic>>((ref, input) async {
  final int id = input['id'];
  final Map<String, dynamic> updatedData = input['data'];

  final response = await AuthHttpClient.put(
    ref,
    "$diagnosisTypeEndpoint$id/",
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(updatedData),
  );
  // On success, invalidate the list and return the updated data.
  ref.invalidate(diagnosisTypeProvider);
  return jsonDecode(response.body);
});

/// Deletes a Diagnosis Type.
final deleteDiagnosisTypeProvider =
    FutureProvider.autoDispose.family<bool, int>((ref, id) async {
  await AuthHttpClient.delete(
    ref,
    "$diagnosisTypeEndpoint$id/",
  );
  // On success, invalidate the list and return true.
  ref.invalidate(diagnosisTypeProvider);
  return true;
});