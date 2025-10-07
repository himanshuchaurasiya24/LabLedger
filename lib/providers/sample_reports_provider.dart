import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/authentication/config.dart';
import 'package:labledger/models/sample_report_model.dart';
import 'package:labledger/authentication/auth_http_client.dart';

final String sampleReportsEndpoint =
    "${globalBaseUrl}diagnosis/sample-test-report/";

String singleSampleReportEndpoint(int id) =>
    "$sampleReportsEndpoint$id/";

// Invalidate related caches when any sample report changes
void _invalidateSampleReportCache(Ref ref) {
  ref.invalidate(allSampleReportsProvider);
}

// Fetch all sample reports
final allSampleReportsProvider =
    FutureProvider.autoDispose<List<SampleReportModel>>((ref) async {
  final response = await AuthHttpClient.get(ref, sampleReportsEndpoint);
  final List<dynamic> jsonList = jsonDecode(response.body);
  return jsonList.map((item) => SampleReportModel.fromJson(item)).toList();
});

// Fetch single sample report
final singleSampleReportProvider =
    FutureProvider.autoDispose.family<SampleReportModel, int>((ref, id) async {
  final response = await AuthHttpClient.get(
    ref,
    singleSampleReportEndpoint(id),
  );
  return SampleReportModel.fromJson(jsonDecode(response.body));
});

// Create new sample report (multipart)
final createSampleReportProvider =
    FutureProvider.autoDispose.family<SampleReportModel, SampleReportModel>(
        (ref, newReport) async {
  final fields = newReport.toPostMap();

  final filePath = newReport.sampleReportFileLocal?.path;
  if (filePath == null) {
    throw Exception("No file selected for upload.");
  }

  final response = await AuthHttpClient.postMultipart(
    ref,
    sampleReportsEndpoint,
    fields: fields,
    fileField: "sample_report_file",
    filePath: filePath,
  );

  if (response.statusCode == 201 || response.statusCode == 200) {
    _invalidateSampleReportCache(ref);
    return SampleReportModel.fromJson(jsonDecode(response.body));
  } else {
    throw Exception("Failed to create sample report: ${response.body}");
  }
});

// Update sample report (multipart)
final updateSampleReportProvider =
    FutureProvider.autoDispose.family<SampleReportModel, SampleReportModel>(
        (ref, updatedReport) async {
  if (updatedReport.id == null) {
    throw Exception("Report ID is required for update.");
  }

  final fields = updatedReport.toPostMap();
  final filePath = updatedReport.sampleReportFileLocal?.path;

  final response = await AuthHttpClient.putMultipart(
    ref,
    singleSampleReportEndpoint(updatedReport.id!),
    fields: fields,
    fileField: "sample_report_file",
    filePath: filePath ?? '', // Safe fallback
  );

  if (response.statusCode == 200) {
    _invalidateSampleReportCache(ref);
    ref.invalidate(singleSampleReportProvider(updatedReport.id!));
    return SampleReportModel.fromJson(jsonDecode(response.body));
  } else {
    throw Exception("Failed to update sample report: ${response.body}");
  }
});

final deleteSampleReportProvider =
    FutureProvider.autoDispose.family<void, int>((ref, id) async {
  await AuthHttpClient.delete(ref, singleSampleReportEndpoint(id));
  _invalidateSampleReportCache(ref);
  ref.invalidate(singleSampleReportProvider(id));
});
