import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/authentication/auth_http_client.dart';
import 'package:labledger/authentication/config.dart';
import 'package:labledger/models/diagnosis_type_model.dart';

/// ✅ Base API Endpoint
final String diagnosisTypeEndpoint =
    "${globalBaseUrl}diagnosis/diagnosis-types/diagnosis-type/";

/// ✅ Fetch all Diagnosis Types
final diagnosisTypeProvider =
    FutureProvider.autoDispose<List<DiagnosisType>>((ref) async {
  final response = await AuthHttpClient.get(ref, diagnosisTypeEndpoint);

  if (response.statusCode == 200) {
    final List data = jsonDecode(response.body);
    return data.map((e) => DiagnosisType.fromJson(e)).toList();
  } else {
    throw Exception('Failed to load Diagnosis Types: ${response.body}');
  }
});

/// ✅ Add a Diagnosis Type
final addDiagnosisTypeProvider =
    FutureProvider.autoDispose.family<bool, DiagnosisType>(
  (ref, diagnosis) async {
    final response = await AuthHttpClient.post(
      ref,
      diagnosisTypeEndpoint,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(diagnosis.toJson()),
    );

    if (response.statusCode == 201) {
      ref.invalidate(diagnosisTypeProvider); // refresh list
      return true;
    } else {
      throw Exception('Failed to add Diagnosis Type: ${response.body}');
    }
  },
);

/// ✅ Update a Diagnosis Type
final updateDiagnosisTypeProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, Map<String, dynamic>>((ref, input) async {
  final int id = input['id'];
  final Map<String, dynamic> updatedData = input['data'];

  final response = await AuthHttpClient.put(
    ref,
    "$diagnosisTypeEndpoint$id/",
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(updatedData),
  );

  if (response.statusCode == 200) {
    ref.invalidate(diagnosisTypeProvider);
    return jsonDecode(response.body);
  } else {
    throw Exception("Failed to update Diagnosis Type: ${response.body}");
  }
});

/// ✅ Delete a Diagnosis Type
final deleteDiagnosisTypeProvider =
    FutureProvider.autoDispose.family<bool, int>((ref, id) async {
  final response = await AuthHttpClient.delete(
    ref,
    "$diagnosisTypeEndpoint$id/",
  );

  if (response.statusCode == 204) {
    ref.invalidate(diagnosisTypeProvider); // refresh list
    return true;
  } else {
    throw Exception('Failed to delete Diagnosis Type: ${response.body}');
  }
});
