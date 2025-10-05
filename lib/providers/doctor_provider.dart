import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/authentication/auth_http_client.dart';
import 'package:labledger/authentication/config.dart';
import 'package:labledger/models/doctors_model.dart';

final String doctorsEndpoint = "${globalBaseUrl}diagnosis/doctor/";

final doctorsProvider = FutureProvider.autoDispose<List<Doctor>>((ref) async {
  final response = await AuthHttpClient.get(ref, doctorsEndpoint);
  final List data = jsonDecode(response.body);
  return data.map((e) => Doctor.fromJson(e)).toList();
});

final singleDoctorProvider = FutureProvider.autoDispose.family<Doctor, int>((
  ref,
  id,
) async {
  final response = await AuthHttpClient.get(ref, "$doctorsEndpoint$id/");
  return Doctor.fromJson(jsonDecode(response.body));
});

final createDoctorProvider = FutureProvider.autoDispose.family<Doctor, Doctor>((
  ref,
  newDoctor,
) async {
  final response = await AuthHttpClient.post(
    ref,
    doctorsEndpoint,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(newDoctor.toJson()),
  );
  ref.invalidate(doctorsProvider);
  return Doctor.fromJson(jsonDecode(response.body));
});

final updateDoctorProvider = FutureProvider.autoDispose.family<Doctor, Doctor>((
  ref,
  doctor,
) async {
  final int id = doctor.id!;

  final response = await AuthHttpClient.put(
    ref,
    "$doctorsEndpoint$id/",
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(doctor.toJson()),
  );
  ref.invalidate(doctorsProvider);
  ref.invalidate(singleDoctorProvider(id));
  return Doctor.fromJson(jsonDecode(response.body));
});

final deleteDoctorProvider = FutureProvider.autoDispose.family<void, int>((
  ref,
  id,
) async {
  await AuthHttpClient.delete(ref, "$doctorsEndpoint$id/");
  ref.invalidate(doctorsProvider);
  ref.invalidate(singleDoctorProvider(id));
});
