// PROVIDERS & MODEL HANDLING - doctors_provider.dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:labledger/models/doctors_model.dart';
import 'package:labledger/providers/custom_providers.dart';

final doctorsProvider = FutureProvider.autoDispose<List<Doctor>>((ref) async {
  final token = await ref.read(tokenProvider.future);
  final response = await http.get(
    Uri.parse("${baseURL}diagnosis/doctors/doctor/"),
    headers: {"Authorization": "Bearer $token"},
  );

  if (response.statusCode == 200) {
    final List data = jsonDecode(response.body);
    return data.map((e) => Doctor.fromJson(e)).toList().cast<Doctor>();
  } else {
    throw Exception("Failed to fetch doctors: ${response.body}");
  }
});

final singleDoctorProvider = FutureProvider.autoDispose.family<Doctor, int>((
  ref,
  id,
) async {
  final token = await ref.read(tokenProvider.future);
  final response = await http.get(
    Uri.parse("${baseURL}diagnosis/doctors/doctor/$id/?list_format=true"),
    headers: {"Authorization": "Bearer $token"},
  );

  if (response.statusCode == 200) {
    final List data = jsonDecode(response.body);
    return Doctor.fromJson(data.first);
  } else {
    throw Exception("Failed to fetch doctor: ${response.body}");
  }
});

final createDoctorProvider = FutureProvider.autoDispose.family<Doctor, Doctor>((
  ref,
  newDoctor,
) async {
  final token = await ref.read(tokenProvider.future);
  final response = await http.post(
    Uri.parse("${baseURL}diagnosis/doctors/doctor/"),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode(newDoctor.toJson()),
  );

  if (response.statusCode == 201) {
    ref.invalidate(doctorsProvider);
    return Doctor.fromJson(jsonDecode(response.body));
  } else {
    throw Exception("Failed to create doctor: ${response.body}");
  }
});

final updateDoctorProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, Map<String, dynamic>>((ref, input) async {
      final token = await ref.read(tokenProvider.future);
      final int id = input['id'];
      final Map<String, dynamic> updatedData = input['data'];

      final response = await http.patch(
        Uri.parse("${baseURL}diagnosis/doctors/doctor/$id/"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(updatedData),
      );

      if (response.statusCode == 200) {
        ref.invalidate(doctorsProvider);
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to update doctor: ${response.body}");
      }
    });

final deleteDoctorProvider = FutureProvider.autoDispose.family<void, int>((
  ref,
  id,
) async {
  final token = await ref.read(tokenProvider.future);
  final response = await http.delete(
    Uri.parse("${baseURL}diagnosis/doctors/doctor/$id/"),
    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode == 204) {
    ref.invalidate(doctorsProvider);
  } else {
    throw Exception("Failed to delete doctor: ${response.body}");
  }
});
