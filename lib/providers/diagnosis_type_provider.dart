import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/models/diagnosis_type_model.dart';
import "package:http/http.dart" as http;
import 'package:labledger/providers/custom_providers.dart';

final diagnosisTypeProvider = FutureProvider.autoDispose<List<DiagnosisType>>((
  ref,
) async {
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
