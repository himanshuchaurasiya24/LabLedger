import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/authentication/config.dart';
import 'package:labledger/models/patient_report_model.dart';
import 'package:labledger/models/report_upload_data_model.dart';
import 'package:labledger/providers/bills_provider.dart';

import '../authentication/auth_http_client.dart';
final String patientReportsEndpoint = '$globalBaseUrl/diagnosis/patient-report/';
String patientReportDetailEndpoint(int reportId) => '$globalBaseUrl/diagnosis/patient-report/$reportId/';

void _invalidateReportCache(Ref ref, int billId) {
  ref.invalidate(getReportForBillProvider(billId));
  ref.invalidate(paginatedBillsProvider);
  ref.invalidate(singleBillProvider(billId));
}

// --- Providers (Simplified) ---

final getReportForBillProvider =
    FutureProvider.autoDispose.family<PatientReport?, int>((ref, billId) async {
  final response = await AuthHttpClient.get(ref, '$patientReportsEndpoint?bill=$billId');
  final data = jsonDecode(response.body) as List;
  if (data.isNotEmpty) {
    return PatientReport.fromJson(data.first);
  }
  return null;
});

final createPatientReportProvider = FutureProvider.autoDispose.family<PatientReport, ReportUploadData>((
  ref,
  uploadData,
) async {
  final response = await AuthHttpClient.postMultipart(
    ref,
    patientReportsEndpoint,
    fields: { 'bill': uploadData.billId.toString() },
    fileField: 'report_file',
    filePath: uploadData.filePath,
  );

  _invalidateReportCache(ref, uploadData.billId);
  return PatientReport.fromJson(jsonDecode(response.body));
});

final deletePatientReportProvider =
    FutureProvider.autoDispose.family<void, ({int reportId, int billId})>((
  ref,
  ids,
) async {
  await AuthHttpClient.delete(ref, patientReportDetailEndpoint(ids.reportId));
  _invalidateReportCache(ref, ids.billId);
});

final updatePatientReportProvider =
    FutureProvider.autoDispose.family<PatientReport, ReportUpdateData>((
  ref,
  updateData,
) async {
  final response = await AuthHttpClient.putMultipart(
    ref,
    patientReportDetailEndpoint(updateData.reportId),
    fields: { 'bill': updateData.billId.toString() },
    fileField: 'report_file',
    filePath: updateData.filePath,
  );

  _invalidateReportCache(ref, updateData.billId);
  return PatientReport.fromJson(jsonDecode(response.body));
});

