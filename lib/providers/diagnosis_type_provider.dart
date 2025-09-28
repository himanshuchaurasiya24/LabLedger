import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/authentication/auth_http_client.dart';
import 'package:labledger/authentication/config.dart';
import 'package:labledger/models/diagnosis_type_model.dart';

/// Base API Endpoint
final String diagnosisTypeEndpoint =
    "${globalBaseUrl}diagnosis/diagnosis-type/";

/// Fetches all Diagnosis Types.
final diagnosisTypeProvider =
    FutureProvider.autoDispose<List<DiagnosisType>>((ref) async {
  final response = await AuthHttpClient.get(ref, diagnosisTypeEndpoint);
  final List data = jsonDecode(response.body);
  return data.map((e) => DiagnosisType.fromJson(e)).toList();
});

final diagnosisTypeDetailProvider =
    FutureProvider.autoDispose.family<DiagnosisType, int>((ref, id) async {
  final response = await AuthHttpClient.get(
    ref,
    "$diagnosisTypeEndpoint$id/",
  );
  return DiagnosisType.fromJson(jsonDecode(response.body));
});

/// Adds a new Diagnosis Type and returns the created object.
final addDiagnosisTypeProvider =
    FutureProvider.autoDispose.family<DiagnosisType, DiagnosisType>((ref, diagnosis) async {
  final response = await AuthHttpClient.post(
    ref,
    diagnosisTypeEndpoint,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(diagnosis.toJson()),
  );
  // On success, invalidate the list.
  ref.invalidate(diagnosisTypeProvider);
  // Return the newly created DiagnosisType object from the server's response.
  return DiagnosisType.fromJson(jsonDecode(response.body));
});

/// Updates an existing Diagnosis Type using the model object directly.
final updateDiagnosisTypeProvider =
    FutureProvider.autoDispose.family<DiagnosisType, DiagnosisType>((ref, updatedDiagnosis) async {
  final int id = updatedDiagnosis.id!;

  final response = await AuthHttpClient.put(
    ref,
    "$diagnosisTypeEndpoint$id/",
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(updatedDiagnosis.toJson()),
  );
  
  // Invalidate providers that depend on this specific instance
  ref.invalidate(diagnosisTypeProvider);
  ref.invalidate(diagnosisTypeDetailProvider(id));
  return DiagnosisType.fromJson(jsonDecode(response.body));
});

/// Deletes a Diagnosis Type.
final deleteDiagnosisTypeProvider =
    FutureProvider.autoDispose.family<void, int>((ref, id) async {
  await AuthHttpClient.delete(
    ref,
    "$diagnosisTypeEndpoint$id/",
  );
  // On success, invalidate relevant providers.
  ref.invalidate(diagnosisTypeProvider);
  ref.invalidate(diagnosisTypeDetailProvider(id));
});