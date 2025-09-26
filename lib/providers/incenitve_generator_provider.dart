
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:labledger/authentication/config.dart';
import 'package:labledger/models/incentive_model.dart';

import '../authentication/auth_http_client.dart';

/// Base API Endpoint
final String incentiveReportEndpoint =
    "${globalBaseUrl}diagnosis/incentives/";

// Holds the set of selected doctor IDs
final selectedDoctorIdsProvider = StateProvider<Set<int>>((ref) => {});

// Holds the set of selected franchise IDs
final selectedFranchiseIdsProvider = StateProvider<Set<int>>((ref) => {});

// Holds the set of selected diagnosis type IDs
final selectedDiagnosisTypeIdsProvider = StateProvider<Set<int>>((ref) => {});

// Holds the set of selected bill statuses, defaulting to 'Fully Paid'
final selectedBillStatusesProvider =
    StateProvider<Set<String>>((ref) => {'Fully Paid'});

// Holds the selected start date, defaulting to the 1st of the current month
final reportStartDateProvider =
    StateProvider<DateTime>((ref) => DateTime.now().copyWith(day: 1));

// Holds the selected end date, defaulting to today
final reportEndDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

/// The main provider that watches all filters and fetches the incentive report.
final incentiveReportProvider =
    FutureProvider.autoDispose<List<DoctorReport>>((ref) async {
  // 1. Watch all the individual filter providers.
  final doctorIds = ref.watch(selectedDoctorIdsProvider);
  final franchiseIds = ref.watch(selectedFranchiseIdsProvider);
  final diagnosisTypeIds = ref.watch(selectedDiagnosisTypeIdsProvider);
  final billStatuses = ref.watch(selectedBillStatusesProvider);
  final startDate = ref.watch(reportStartDateProvider);
  final endDate = ref.watch(reportEndDateProvider);

  // 2. Build the query parameters map based on the filter states.
  final Map<String, List<String>> filters = {
    // Convert sets of integers to lists of strings
    'doctor_id': doctorIds.map((id) => id.toString()).toList(),
    'franchise_id': franchiseIds.map((id) => id.toString()).toList(),
    'diagnosis_type_id':
        diagnosisTypeIds.map((id) => id.toString()).toList(),
    // Convert set of strings to a list of strings
    'bill_status': billStatuses.toList(),
    // Format dates into YYYY-MM-DD strings
    'start_date': [DateFormat('yyyy-MM-dd').format(startDate)],
    'end_date': [DateFormat('yyyy-MM-dd').format(endDate)],
  };

  // 3. Construct the final URI.
  final uri = Uri.parse(incentiveReportEndpoint).replace(
    queryParameters: filters,
  );

  // 4. Make the API call and parse the response.
  final response = await AuthHttpClient.get(ref, uri.toString());
  final List<dynamic> jsonList = jsonDecode(response.body);

  return jsonList.map((json) => DoctorReport.fromJson(json)).toList();
});