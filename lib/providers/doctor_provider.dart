import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/models/doctors_model.dart';
import 'package:labledger/providers/custom_providers.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DoctorNotifier extends StateNotifier<AsyncValue<List<Doctor>>> {
  final Ref ref;

  DoctorNotifier(this.ref) : super(const AsyncValue.loading()) {
    fetchDoctors();
  }
  final String doctorsUrl = "${baseURL}diagnosis/doctors/doctor/";
  Future<void> fetchSingleDoctor({required int id}) async {
    try {
      final token = await ref.read(tokenProvider.future);
      final response = await http.get(
        Uri.parse("$doctorsUrl$id/?list_format=true"),
        headers: {"Authorization": "Bearer $token"},
      );
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        final users = data
            .map((e) => Doctor.fromJson(e))
            .toList()
            .cast<Doctor>();
        state = AsyncValue.data(users);
      } else {
        throw Exception(
          "Failed to fetch single doctor: ${response.statusCode.toString()}",
        );
      }
    } catch (e, st) {
      debugPrint('Error fetching doctors: ${e.toString()}');
      state = AsyncValue.error(e.toString(), st);
    }
  }

  Future<void> fetchDoctors() async {
    try {
      final token = await ref.read(tokenProvider.future);
      final response = await http.get(
        Uri.parse(doctorsUrl),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        final doctors = data
            .map((e) => Doctor.fromJson(e))
            .toList()
            .cast<Doctor>();
        state = AsyncValue.data(doctors);
      } else {
        throw Exception('Failed to fetch doctors: ${response.body}');
      }
    } catch (e, st) {
      debugPrint(st.toString());
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createDoctor(Doctor newDoctor) async {
    try {
      final token = await ref.read(tokenProvider.future);
      final url = Uri.parse("${baseURL}diagnosis/doctors/doctor/");
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },

        body: jsonEncode(newDoctor.toJson()),
      );

      if (response.statusCode == 201) {
        final created = Doctor.fromJson(jsonDecode(response.body));
        state = AsyncValue.data([...state.value ?? [], created]);
      } else {
        throw Exception('Failed to create doctor: ${response.body}');
      }
    } catch (e, stack) {
      debugPrint(e.toString());
      debugPrint(stack.toString());
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateDoctor(
    int doctorId,
    Map<String, dynamic> updatedData,
  ) async {
    try {
      final token = await ref.read(tokenProvider.future);
      final response = await http.patch(
        Uri.parse('$doctorsUrl$doctorId/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(updatedData),
      );

      if (response.statusCode == 200) {
        await fetchDoctors(); // refresh list
      } else {
        throw Exception('Failed to update doctor: ${response.body}');
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteDoctor(int doctorId) async {
    try {
      final token = await ref.read(tokenProvider.future);
      final response = await http.delete(
        Uri.parse('$doctorsUrl$doctorId/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 204) {
        // Remove doctor locally from state
        final currentDoctors = state.value ?? [];
        final updatedDoctors = currentDoctors
            .where((doc) => doc.id != doctorId)
            .toList();
        state = AsyncValue.data(updatedDoctors);
      } else {
        throw Exception('Failed to delete doctor: ${response.body}');
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final doctorNotifierProvider =
    StateNotifierProvider.autoDispose<DoctorNotifier, AsyncValue<List<Doctor>>>(
      (ref) => DoctorNotifier(ref),
    );
