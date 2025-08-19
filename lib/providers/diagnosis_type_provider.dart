import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/models/diagnosis_type_model.dart';
import 'package:http/http.dart' as http;
import 'package:labledger/providers/custom_providers.dart';

/// Fetch all diagnosis types
final diagnosisTypeProvider =
    FutureProvider.autoDispose<List<DiagnosisType>>((ref) async {
  final token = await ref.read(tokenProvider.future);
  final response = await http.get(
    Uri.parse('${baseURL}diagnosis/diagnosis-types/diagnosis-type/'),
    headers: {"Authorization": "Bearer $token"},
  );

  if (response.statusCode == 200) {
    final List data = jsonDecode(response.body);
    return data.map((e) => DiagnosisType.fromJson(e)).toList();
  } else {
    throw Exception('Failed to load Diagnosis Types');
  }
});

/// Add Diagnosis Type
final addDiagnosisTypeProvider =
    FutureProvider.family.autoDispose<bool, DiagnosisType>((ref, diagnosis) async {
  final token = await ref.read(tokenProvider.future);
  final response = await http.post(
    Uri.parse('${baseURL}diagnosis/diagnosis-types/diagnosis-type/'),
    headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    },
    body: jsonEncode(diagnosis.toJson()),
  );

  if (response.statusCode == 201) {
    ref.invalidate(diagnosisTypeProvider); // refresh list
    return true;
  } else {
    throw Exception('Failed to add Diagnosis Type: ${response.body}');
  }
});
final updateDiagnosisTypeProvider =
    FutureProvider.autoDispose.family<Map<String, dynamic>, Map<String, dynamic>>((ref, input) async {
  final token = await ref.read(tokenProvider.future);
  final int id = input['id'];
  final Map<String, dynamic> updatedData = input['data'];

  final response = await http.patch(
    Uri.parse("${baseURL}diagnosis/diagnosis-types/diagnosis-type/$id/"),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode(updatedData),
  );

  if (response.statusCode == 200) {
    ref.invalidate(diagnosisTypeProvider); // refresh the list
    return jsonDecode(response.body);
  } else {
    throw Exception("Failed to update Diagnosis Type: ${response.body}");
  }
});


/// Delete Diagnosis Type
final deleteDiagnosisTypeProvider =
    FutureProvider.family.autoDispose<bool, int>((ref, id) async {
  final token = await ref.read(tokenProvider.future);
  final response = await http.delete(
    Uri.parse('${baseURL}diagnosis/diagnosis-types/diagnosis-type/$id/'),
    headers: {"Authorization": "Bearer $token"},
  );

  if (response.statusCode == 204) {
    ref.invalidate(diagnosisTypeProvider); // refresh list
    return true;
  } else {
    throw Exception('Failed to delete Diagnosis Type: ${response.body}');
  }
});
