import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:labledger/authentication/auth_http_client.dart';
import 'package:labledger/authentication/auth_repository.dart';
import 'package:labledger/authentication/config.dart';
import 'package:labledger/models/sample_report_model.dart';

final String sampleReportsEndpoint = "${globalBaseUrl}diagnosis/sample-test-report/";

final allSampleReportsProvider =
    FutureProvider.autoDispose<List<SampleReportModel>>((ref) async {
  final response = await AuthHttpClient.get(ref, sampleReportsEndpoint);
  final List<dynamic> jsonList = jsonDecode(response.body);
  return jsonList.map((item) => SampleReportModel.fromJson(item)).toList();
});

final singleSampleReportProvider =
    FutureProvider.autoDispose.family<SampleReportModel, int>(
  (ref, id) async {
    final response = await AuthHttpClient.get(ref, "$sampleReportsEndpoint$id/");
    return SampleReportModel.fromJson(jsonDecode(response.body));
  },
);
final createSampleReportProvider =
    FutureProvider.autoDispose.family<SampleReportModel, SampleReportModel>(
  (ref, newReport) async {
    final token = await AuthRepository.instance.getAccessToken();
    if (token == null) throw Exception("Authentication token not found.");

    final uri = Uri.parse(sampleReportsEndpoint);
    final request = http.MultipartRequest("POST", uri)
      ..fields.addAll(newReport.toPostMap())
      ..headers['Authorization'] = 'Bearer $token';

    if (newReport.sampleReportFileLocal != null) {
      request.files.add(await http.MultipartFile.fromPath(
        "sample_report_file",
        newReport.sampleReportFileLocal!.path,
      ));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      _invalidateSampleReportCache(ref);
      return SampleReportModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to create sample report: ${response.body}");
    }
  },
);

final updateSampleReportProvider =
    FutureProvider.autoDispose.family<SampleReportModel, SampleReportModel>(
  (ref, updatedReport) async {
    final token = await AuthRepository.instance.getAccessToken();
    if (token == null) throw Exception("Authentication token not found.");
    if (updatedReport.id == null) throw Exception("Report ID is required for update.");

    final uri = Uri.parse("$sampleReportsEndpoint${updatedReport.id}/");
    // Use PATCH for partial updates
    final request = http.MultipartRequest("PATCH", uri)
      ..fields.addAll(updatedReport.toPostMap())
      ..headers['Authorization'] = 'Bearer $token';

    if (updatedReport.sampleReportFileLocal != null) {
      request.files.add(await http.MultipartFile.fromPath(
        "sample_report_file",
        updatedReport.sampleReportFileLocal!.path,
      ));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      _invalidateSampleReportCache(ref);
      ref.invalidate(singleSampleReportProvider(updatedReport.id!));
      return SampleReportModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to update sample report: ${response.body}");
    }
  },
);

final deleteSampleReportProvider = FutureProvider.autoDispose.family<void, int>(
  (ref, id) async {
    await AuthHttpClient.delete(ref, "$sampleReportsEndpoint$id/");
    _invalidateSampleReportCache(ref);
    // Also invalidate the specific item provider in case it's being watched
    ref.invalidate(singleSampleReportProvider(id));
  },
);
void _invalidateSampleReportCache(Ref ref) {
  ref.invalidate(allSampleReportsProvider);
}
