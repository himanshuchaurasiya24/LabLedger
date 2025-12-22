import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/authentication/auth_http_client.dart';
import 'package:labledger/authentication/config.dart';
import 'package:labledger/models/diagnosis_category_model.dart';
import 'package:labledger/providers/bills_provider.dart';
import 'package:labledger/providers/diagnosis_type_provider.dart';
import 'package:labledger/providers/referral_and_bill_chart_provider.dart';

final String categoryEndpoint = "${globalBaseUrl}diagnosis/categories/";

// Provider for categories list
final categoriesProvider = FutureProvider.autoDispose<List<DiagnosisCategory>>((
  ref,
) async {
  final response = await AuthHttpClient.get(ref, categoryEndpoint);
  final List data = jsonDecode(response.body);
  return data.map((e) => DiagnosisCategory.fromJson(e)).toList();
});

// Provider for category detail
final categoryDetailProvider = FutureProvider.autoDispose
    .family<DiagnosisCategory, int>((ref, id) async {
      final response = await AuthHttpClient.get(ref, "$categoryEndpoint$id/");
      return DiagnosisCategory.fromJson(jsonDecode(response.body));
    });

// Provider for creating a category
final addCategoryProvider = FutureProvider.autoDispose
    .family<DiagnosisCategory, DiagnosisCategory>((ref, category) async {
      final response = await AuthHttpClient.post(
        ref,
        categoryEndpoint,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(category.toJson()),
      );
      _invalidateCategoryCache(ref: ref);
      return DiagnosisCategory.fromJson(jsonDecode(response.body));
    });

// Provider for updating a category
final updateCategoryProvider = FutureProvider.autoDispose
    .family<DiagnosisCategory, DiagnosisCategory>((ref, updatedCategory) async {
      final int id = updatedCategory.id;

      final response = await AuthHttpClient.put(
        ref,
        "$categoryEndpoint$id/",
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(updatedCategory.toJson()),
      );

      _invalidateCategoryCache(ref: ref, id: id);
      return DiagnosisCategory.fromJson(jsonDecode(response.body));
    });

// Provider for deleting a category
final deleteCategoryProvider = FutureProvider.autoDispose.family<void, int>((
  ref,
  id,
) async {
  await AuthHttpClient.delete(ref, "$categoryEndpoint$id/");
  _invalidateCategoryCache(ref: ref, id: id);
});

// Cache invalidation helper
void _invalidateCategoryCache({required Ref ref, int? id}) {
  ref.invalidate(categoriesProvider);
  if (id != null) {
    ref.invalidate(categoryDetailProvider(id));
  }
  // Invalidate diagnosis types since they depend on categories
  ref.invalidate(diagnosisTypeProvider);
  // Invalidate stats and bills providers
  ref.invalidate(referralStatsProvider);
  ref.invalidate(billChartStatsProvider);
  ref.invalidate(paginatedUnpaidPartialBillsProvider);
  ref.invalidate(latestBillsProvider);
  ref.invalidate(pendingReportBillProvider);
}
