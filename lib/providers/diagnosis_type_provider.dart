import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/authentication/auth_http_client.dart';
import 'package:labledger/authentication/config.dart';
import 'package:labledger/models/diagnosis_type_model.dart';
import 'package:labledger/providers/bills_provider.dart';
import 'package:labledger/providers/referral_and_bill_chart_provider.dart';

final String diagnosisTypeEndpoint =
    "${globalBaseUrl}diagnosis/diagnosis-type/";

final diagnosisTypeProvider = FutureProvider.autoDispose<List<DiagnosisType>>((
  ref,
) async {
  final response = await AuthHttpClient.get(ref, diagnosisTypeEndpoint);
  final List data = jsonDecode(response.body);
  return data.map((e) => DiagnosisType.fromJson(e)).toList();
});

final diagnosisTypeDetailProvider = FutureProvider.autoDispose
    .family<DiagnosisType, int>((ref, id) async {
      final response = await AuthHttpClient.get(
        ref,
        "$diagnosisTypeEndpoint$id/",
      );
      return DiagnosisType.fromJson(jsonDecode(response.body));
    });

final addDiagnosisTypeProvider = FutureProvider.autoDispose
    .family<DiagnosisType, DiagnosisType>((ref, diagnosis) async {
      final response = await AuthHttpClient.post(
        ref,
        diagnosisTypeEndpoint,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(diagnosis.toJson()),
      );
      _invalidateDiagnosisTypeCache(ref :ref);
      return DiagnosisType.fromJson(jsonDecode(response.body));
    });

final updateDiagnosisTypeProvider = FutureProvider.autoDispose
    .family<DiagnosisType, DiagnosisType>((ref, updatedDiagnosis) async {
      final int id = updatedDiagnosis.id!;

      final response = await AuthHttpClient.put(
        ref,
        "$diagnosisTypeEndpoint$id/",
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(updatedDiagnosis.toJson()),
      );

      _invalidateDiagnosisTypeCache(ref :ref,id: id);
      return DiagnosisType.fromJson(jsonDecode(response.body));
    });

final deleteDiagnosisTypeProvider = FutureProvider.autoDispose
    .family<void, int>((ref, id) async {
      await AuthHttpClient.delete(ref, "$diagnosisTypeEndpoint$id/");
      _invalidateDiagnosisTypeCache(ref :ref,id: id);
    });

void _invalidateDiagnosisTypeCache({required Ref ref, int? id}) {
  ref.invalidate(diagnosisTypeProvider);
  if (id != null) {
    ref.invalidate(diagnosisTypeDetailProvider(id));
  }
  ref.invalidate(referralStatsProvider);
  ref.invalidate(billChartStatsProvider);
  ref.invalidate(paginatedUnpaidPartialBillsProvider);
  ref.invalidate(latestBillsProvider);
  ref.invalidate(pendingReportBillProvider);
}
