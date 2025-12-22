import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:labledger/authentication/config.dart';
import 'package:labledger/models/incentive_model.dart';

import '../authentication/auth_http_client.dart';

final String incentiveReportEndpoint = "${globalBaseUrl}diagnosis/incentives/";

final selectedDoctorIdsProvider = StateProvider<Set<int>>((ref) => {});

final selectedFranchiseIdsProvider = StateProvider<Set<int>>((ref) => {});

final selectedDiagnosisTypeIdsProvider = StateProvider<Set<int>>((ref) => {});

final selectedBillStatusesProvider = StateProvider<Set<String>>(
  (ref) => {'Fully Paid'},
);

final reportStartDateProvider = StateProvider<DateTime>(
  (ref) => DateTime.now().copyWith(day: 1),
);
final reportEndDateProvider = StateProvider<DateTime>((ref) => DateTime.now());
final incentiveReportProvider = FutureProvider.autoDispose<List<DoctorReport>>((
  ref,
) async {
  final doctorIds = ref.watch(selectedDoctorIdsProvider);
  final franchiseIds = ref.watch(selectedFranchiseIdsProvider);
  final diagnosisTypeIds = ref.watch(selectedDiagnosisTypeIdsProvider);
  final billStatuses = ref.watch(selectedBillStatusesProvider);
  final startDate = ref.watch(reportStartDateProvider);
  final endDate = ref.watch(reportEndDateProvider);

  final Map<String, List<String>> filters = {
    'doctor_id': doctorIds.map((id) => id.toString()).toList(),
    'franchise_id': franchiseIds.map((id) => id.toString()).toList(),
    'diagnosis_type_id': diagnosisTypeIds.map((id) => id.toString()).toList(),
    'bill_status': billStatuses.toList(),
    'start_date': [DateFormat('yyyy-MM-dd').format(startDate)],
    'end_date': [DateFormat('yyyy-MM-dd').format(endDate)],
  };

  final uri = Uri.parse(
    incentiveReportEndpoint,
  ).replace(queryParameters: filters);

  final response = await AuthHttpClient.get(ref, uri.toString());

  final List data = jsonDecode(response.body);

  return data.map((json) => DoctorReport.fromJson(json)).toList();
});
