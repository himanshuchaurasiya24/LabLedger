import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/authentication/auth_http_client.dart';
import 'package:labledger/authentication/config.dart';
import 'package:labledger/models/bill_model.dart';
import 'package:labledger/models/bill_stats_model.dart';
import 'package:labledger/models/paginated_response.dart';
import 'package:labledger/providers/referral_and_bill_chart_provider.dart';

// --- Base Endpoint ---
final String billsEndpoint = "${globalBaseUrl}diagnosis/bill/";
final String billGrowthStatsEndpoint =
    "${globalBaseUrl}diagnosis/bills/growth-stats/";

final currentPageProvider = StateProvider.autoDispose<int>((ref) => 1);
final currentSearchQueryProvider = StateProvider.autoDispose<String>(
  (ref) => '',
);


final billGrowthStatsProvider = FutureProvider.autoDispose((ref) async {
  final response = await AuthHttpClient.get(ref, billGrowthStatsEndpoint);
  return BillStats.fromJson(jsonDecode(response.body));
});

final latestBillsProvider = FutureProvider.autoDispose<List<Bill>>((ref) async {
  final uri = Uri.parse(
    billsEndpoint,
  ).replace(queryParameters: {'page': '1', 'page_size': '10'});
  final response = await AuthHttpClient.get(ref, uri.toString());
  final data = jsonDecode(response.body);
  final List<dynamic> jsonList = data['results'];
  return jsonList.map((item) => Bill.fromJson(item)).toList();
});

final paginatedUnpaidPartialBillsProvider =
    FutureProvider.autoDispose<PaginatedBillsResponse>((ref) async {
      final uri = Uri.parse(billsEndpoint).replace(
        queryParameters: {
          'unpaid_or_partial': 'true',
          'ordering': '-date_of_bill',
        },
      );
      final response = await AuthHttpClient.get(ref, uri.toString());
      return PaginatedBillsResponse.fromJson(jsonDecode(response.body));
    });

final paginatedBillsProvider =
    FutureProvider.autoDispose<PaginatedBillsResponse>((ref) async {
      final page = ref.watch(currentPageProvider);
      final query = ref.watch(currentSearchQueryProvider);

      final uri = Uri.parse(billsEndpoint).replace(
        queryParameters: {
          'page': page.toString(),
          if (query.isNotEmpty) 'search': query,
        },
      );
      final response = await AuthHttpClient.get(ref, uri.toString());
      return PaginatedBillsResponse.fromJson(jsonDecode(response.body));
    });


final paginatedDoctorBillProvider = FutureProvider.autoDispose
    .family<PaginatedBillsResponse, int>((ref, id) async {
      final page = ref.watch(currentPageProvider);
      final query = ref.watch(currentSearchQueryProvider);
      final uri = Uri.parse(billsEndpoint).replace(
        queryParameters: {
          "page": page.toString(),
          if (query.isNotEmpty) 'search': query,
          "referred_by_doctor": id.toString(),
        },
      );
      final response = await AuthHttpClient.get(ref, uri.toString());
      return PaginatedBillsResponse.fromJson(jsonDecode(response.body));
    });

final paginatedDiagnosisTypeBillProvider = FutureProvider.autoDispose
    .family<PaginatedBillsResponse, int>((ref, id) async {
      final page = ref.watch(currentPageProvider);
      final query = ref.watch(currentSearchQueryProvider);
      final uri = Uri.parse(billsEndpoint).replace(
        queryParameters: {
          "page": page.toString(),
          if (query.isNotEmpty) 'search': query,
          "diagnosis_type": id.toString(),
        },
      );
      final response = await AuthHttpClient.get(ref, uri.toString());
      return PaginatedBillsResponse.fromJson(jsonDecode(response.body));
    });
final paginatedFranchiseBillProvider = FutureProvider.autoDispose
    .family<PaginatedBillsResponse, int>((ref, id) async {
      final page = ref.watch(currentPageProvider);
      final query = ref.watch(currentSearchQueryProvider);
      final uri = Uri.parse(billsEndpoint).replace(
        queryParameters: {
          "page": page.toString(),
          if (query.isNotEmpty) "search": query,
          "franchise_name_id": id.toString(),
        },
      );
      final response = await AuthHttpClient.get(ref, uri.toString());
      return PaginatedBillsResponse.fromJson(jsonDecode(response.body));
    });

final singleBillProvider = FutureProvider.autoDispose.family<Bill, int>((
  ref,
  id,
) async {
  final response = await AuthHttpClient.get(
    ref,
    "$billsEndpoint$id/?list_format=true",
  );
  return Bill.fromJson(jsonDecode(response.body));
});


final createBillProvider = FutureProvider.autoDispose.family<Bill, Bill>((
  ref,
  newBill,
) async {
  final response = await AuthHttpClient.post(
    ref,
    billsEndpoint,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(newBill.toJson()),
  );
  _invalidateBillCache(ref);
  return Bill.fromJson(jsonDecode(response.body));
});

final updateBillProvider = FutureProvider.autoDispose.family<Bill, Bill>((
  ref,
  updatedBill,
) async {
  final response = await AuthHttpClient.put(
    ref,
    "$billsEndpoint${updatedBill.id}/",
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(updatedBill.toJson()),
  );
  _invalidateBillCache(ref);
  ref.invalidate(singleBillProvider(updatedBill.id!));
  return Bill.fromJson(jsonDecode(response.body));
});

final deleteBillProvider = FutureProvider.autoDispose.family<void, int>((
  ref,
  id,
) async {
  await AuthHttpClient.delete(ref, "$billsEndpoint$id/");
  _invalidateBillCache(ref);
  ref.invalidate(singleBillProvider(id));
});


void _invalidateBillCache(Ref ref) {
  ref.invalidate(referralStatsProvider);
  ref.invalidate(billChartStatsProvider);
  ref.invalidate(doctorGrowthStatsProvider);
  ref.invalidate(billGrowthStatsProvider);
  ref.invalidate(latestBillsProvider);
  ref.invalidate(paginatedUnpaidPartialBillsProvider);
  ref.invalidate(paginatedBillsProvider);
}
