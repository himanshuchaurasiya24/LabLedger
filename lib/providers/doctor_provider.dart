import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/authentication/auth_http_client.dart';
import 'package:labledger/authentication/config.dart';
import 'package:labledger/models/doctors_model.dart';

/// Base API Endpoint
final String doctorsEndpoint = "${globalBaseUrl}diagnosis/doctor/";

/// Fetches all doctors.
final doctorsProvider = FutureProvider.autoDispose<List<Doctor>>((ref) async {
  // AuthHttpClient now handles all errors. If we get a response, it's successful.
  final response = await AuthHttpClient.get(ref, doctorsEndpoint);
  final List data = jsonDecode(response.body);
  return data.map((e) => Doctor.fromJson(e)).toList();
});

/// Fetches a single doctor by their ID.
final singleDoctorProvider =
    FutureProvider.autoDispose.family<Doctor, int>((ref, id) async {
  final response = await AuthHttpClient.get(ref, "$doctorsEndpoint$id/");
  return Doctor.fromJson(jsonDecode(response.body));
});

/// Creates a new doctor.
final createDoctorProvider =
    FutureProvider.autoDispose.family<Doctor, Doctor>((ref, newDoctor) async {
  final response = await AuthHttpClient.post(
    ref,
    doctorsEndpoint,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(newDoctor.toJson()),
  );
  // On success, invalidate the list so it re-fetches with the new doctor.
  ref.invalidate(doctorsProvider);
  return Doctor.fromJson(jsonDecode(response.body));
});

/// Updates an existing doctor.
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
  // On success, invalidate the list to reflect the changes.
  ref.invalidate(doctorsProvider);
  return jsonDecode(response.body);
});

/// Deletes a doctor by their ID.
final deleteDoctorProvider =
    FutureProvider.autoDispose.family<void, int>((ref, id) async {
  await AuthHttpClient.delete(
    ref,
    "$doctorsEndpoint$id/",
  );
  // On success, invalidate the list to remove the deleted doctor.
  ref.invalidate(doctorsProvider);
});