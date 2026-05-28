import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/authentication/config.dart';
import 'package:labledger/constants/urls.dart';
import 'package:labledger/models/patient_report_model.dart';
import 'package:labledger/models/report_upload_data_model.dart';
import 'package:labledger/providers/bills_provider.dart';
import 'package:labledger/providers/report_quota_provider.dart';

import '../authentication/auth_http_client.dart';

final String patientReportsEndpoint =
    '$globalBaseUrl${AppUrls.diagnosisPatientReport}';
String patientReportDetailEndpoint(int reportId) =>
    '$globalBaseUrl${AppUrls.diagnosisPatientReportDetail(reportId)}';
String patientReportDownloadEndpoint(int reportId) =>
    '$globalBaseUrl${AppUrls.diagnosisPatientReportDownload(reportId)}';

final getReportForBillProvider = FutureProvider.autoDispose
    .family<PatientReport?, int>((ref, billId) async {
      final response = await AuthHttpClient.get(
        ref,
        '$patientReportsEndpoint?bill=$billId',
      );
      final data = jsonDecode(response.body) as List;
      if (data.isNotEmpty) {
        return PatientReport.fromJson(data.first);
      }
      return null;
    });

final createPatientReportProvider = FutureProvider.autoDispose
    .family<PatientReport, ReportUploadData>((ref, uploadData) async {
      try {
        final response = await AuthHttpClient.postMultipart(
          ref,
          patientReportsEndpoint,
          fields: {'bill': uploadData.billId.toString()},
          fileField: 'report_file',
          filePath: uploadData.filePath,
        );

        if (response.statusCode == 201 || response.statusCode == 200) {
          _invalidateReportCache(ref, uploadData.billId);
          final jsonData = jsonDecode(response.body);
          return PatientReport.fromJson(jsonData);
        } else {
          throw Exception('Failed to upload report: ${response.body}');
        }
      } catch (e) {
        rethrow;
      }
    });

final deletePatientReportProvider = FutureProvider.autoDispose
    .family<void, ({int reportId, int billId})>((ref, ids) async {
      await AuthHttpClient.delete(
        ref,
        patientReportDetailEndpoint(ids.reportId),
      );
      _invalidateReportCache(ref, ids.billId);
    });

final downloadPatientReportProvider = FutureProvider.autoDispose
    .family<({Uint8List bytes, String fileName}), int>((ref, reportId) async {
      final response = await AuthHttpClient.get(
        ref,
        patientReportDownloadEndpoint(reportId),
        throwOnError: false,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to download report: ${response.body}');
      }

      final disposition = response.headers['content-disposition'] ?? '';
      final fileNameMatch = RegExp(
        r'filename="?([^";]+)"?',
      ).firstMatch(disposition);
      final fileName = fileNameMatch?.group(1) ?? 'patient_report_$reportId';

      return (bytes: response.bodyBytes, fileName: fileName);
    });

final updatePatientReportProvider = FutureProvider.autoDispose
    .family<PatientReport, ReportUpdateData>((ref, updateData) async {
      final response = await AuthHttpClient.putMultipart(
        ref,
        patientReportDetailEndpoint(updateData.reportId),
        fields: {'bill': updateData.billId.toString()},
        fileField: 'report_file',
        filePath: updateData.filePath,
      );

      _invalidateReportCache(ref, updateData.billId);
      return PatientReport.fromJson(jsonDecode(response.body));
    });

void _invalidateReportCache(Ref ref, int billId) {
  ref.invalidate(getReportForBillProvider(billId));
  ref.invalidate(paginatedBillsProvider);
  ref.invalidate(singleBillProvider(billId));
  ref.invalidate(pendingReportBillProvider);
  ref.invalidate(reportQuotaSummaryProvider);
}
