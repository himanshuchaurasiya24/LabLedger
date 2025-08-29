// PROVIDERS & MODEL HANDLING - doctors_provider.dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/authentication/auth_http_client.dart';
import 'package:labledger/authentication/config.dart';
import 'package:labledger/models/doctors_model.dart';

/// ✅ Base API Endpoint
final String doctorsEndpoint = "${globalBaseUrl}diagnosis/doctors/doctor/";

/// ✅ Fetch all doctors
final doctorsProvider = FutureProvider.autoDispose<List<Doctor>>((ref) async {
  final response = await AuthHttpClient.get(ref, doctorsEndpoint);

  if (response.statusCode == 200) {
    final List data = jsonDecode(response.body);
    return data.map((e) => Doctor.fromJson(e)).toList().cast<Doctor>();
  } else {
    throw Exception("Failed to fetch doctors: ${response.body}");
  }
});

/// ✅ Fetch a single doctor by ID
final singleDoctorProvider =
    FutureProvider.autoDispose.family<Doctor, int>((ref, id) async {
  final response = await AuthHttpClient.get(
    ref,
    "$doctorsEndpoint$id/?list_format=true",
  );

  if (response.statusCode == 200) {
    final List data = jsonDecode(response.body);
    return Doctor.fromJson(data.first);
  } else {
    throw Exception("Failed to fetch doctor: ${response.body}");
  }
});

/// ✅ Create a new doctor
final createDoctorProvider =
    FutureProvider.autoDispose.family<Doctor, Doctor>((ref, newDoctor) async {
  final response = await AuthHttpClient.post(
    ref,
    doctorsEndpoint,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(newDoctor.toJson()),
  );

  if (response.statusCode == 201) {
    ref.invalidate(doctorsProvider);
    return Doctor.fromJson(jsonDecode(response.body));
  } else {
    throw Exception("Failed to create doctor: ${response.body}");
  }
});

/// ✅ Update an existing doctor
final updateDoctorProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, Map<String, dynamic>>((ref, input) async {
  final int id = input['id'];
  final Map<String, dynamic> updatedData = input['data'];

  final response = await AuthHttpClient.put(
    ref,
    "$doctorsEndpoint$id/",
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(updatedData),
  );

  if (response.statusCode == 200) {
    ref.invalidate(doctorsProvider);
    return jsonDecode(response.body);
  } else {
    throw Exception("Failed to update doctor: ${response.body}");
  }
});

/// ✅ Delete a doctor
final deleteDoctorProvider =
    FutureProvider.autoDispose.family<void, int>((ref, id) async {
  final response = await AuthHttpClient.delete(
    ref,
    "$doctorsEndpoint$id/",
  );

  if (response.statusCode == 204) {
    ref.invalidate(doctorsProvider);
  } else {
    throw Exception("Failed to delete doctor: ${response.body}");
  }
});
