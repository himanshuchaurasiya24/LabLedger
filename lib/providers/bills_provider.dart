import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/authentication/config.dart';
import 'package:labledger/models/bill_model.dart';
import 'package:labledger/models/paginated_response.dart'; // Import new model
import 'package:labledger/providers/bill_status_provider.dart';
import 'package:labledger/providers/referral_and_bill_chart_provider.dart';
import '../authentication/auth_http_client.dart'; // Import the utility client

String billsEndpoint = "${globalBaseUrl}diagnosis/bills/bill/";

final currentPageProvider = StateProvider.autoDispose<int>((ref) => 1);

final currentSearchQueryProvider = StateProvider.autoDispose<String>(
  (ref) => '',
);
final latestBillsProvider = 
    FutureProvider.autoDispose<List<Bill>>((ref) async {

  // We explicitly ask for page 1 and set the page size to 10.
  // 'page_size' is a standard parameter for Django's pagination.
  final queryParams = {
    'page': '1',
    'page_size': '10', // Requesting only 10 items
  };

  // Replace 'billsEndpoint' with your actual endpoint variable
  final uri = Uri.parse(billsEndpoint).replace(queryParameters: queryParams);
  final response = await AuthHttpClient.get(ref, uri.toString());

  if (response.statusCode == 200) {
    // We parse the paginated response but only care about the 'results' list.
    final data = jsonDecode(response.body);
    final List<dynamic> jsonList = data['results'];
    
    return jsonList.map((item) => Bill.fromJson(item)).toList();
  } else {
    throw Exception("Failed to fetch latest bills: ${response.body}");
  }
});
final paginatedUnpaidPartialBillsProvider =
    FutureProvider.autoDispose<PaginatedBillsResponse>((ref) async {
      final page = ref.watch(currentPageProvider);
      final query = ref.watch(currentSearchQueryProvider);

      final queryParams = {
        'page': page.toString(),
        'unpaid_or_partial': 'true', // ✅ filter from backend
        'ordering': '-date_of_bill', // ✅ sort by recent bills first
        if (query.isNotEmpty) 'search': query,
      };

      final uri = Uri.parse(
        billsEndpoint,
      ).replace(queryParameters: queryParams);

      final response = await AuthHttpClient.get(ref, uri.toString());

      if (response.statusCode == 200) {
        return PaginatedBillsResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception(
          "Failed to fetch unpaid/partial bills: ${response.body}",
        );
      }
    });

final paginatedBillsProvider =
    FutureProvider.autoDispose<PaginatedBillsResponse>((ref) async {
      final page = ref.watch(currentPageProvider);
      final query = ref.watch(currentSearchQueryProvider);

      final queryParams = {
        'page': page.toString(),
        if (query.isNotEmpty) 'search': query,
      };

      final uri = Uri.parse(
        billsEndpoint,
      ).replace(queryParameters: queryParams);
      final response = await AuthHttpClient.get(ref, uri.toString());

      if (response.statusCode == 200) {
        return PaginatedBillsResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception("Failed to fetch bills: ${response.body}");
      }
    });

// --- ACTION PROVIDERS (Updated Invalidation Logic) ---

final singleBillProvider = FutureProvider.autoDispose.family<Bill, int>((
  ref,
  id,
) async {
  final response = await AuthHttpClient.get(
    ref,
    "$billsEndpoint$id/?list_format=true",
  );

  if (response.statusCode == 200) {
    return Bill.fromJson(jsonDecode(response.body));
  } else {
    throw Exception("Failed to fetch bill: ${response.body}");
  }
});
//
final billProvider = FutureProvider.autoDispose<List<Bill>>((ref) async {
  final response = await AuthHttpClient.get(ref, billsEndpoint);

  if (response.statusCode == 200) {
    final List data = jsonDecode(response.body);
    return data.map((e) => Bill.fromJson(e)).toList();
  } else {
    throw Exception("Failed to fetch bill: ${response.body}");
  }
});

/// ✅ Create a new bill (Updated invalidation)
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

  if (response.statusCode == 201 || response.statusCode == 200) {
    // Refresh stats AND our new main provider
    ref.invalidate(referralStatsProvider);
    ref.invalidate(billChartStatsProvider);
    ref.invalidate(paginatedUnpaidPartialBillsProvider);
    ref.invalidate(billGrowthStatsProvider);
    ref.invalidate(billProvider);
    ref.invalidate(paginatedBillsProvider);
    ref.invalidate(latestBillsProvider);


    return Bill.fromJson(jsonDecode(response.body));
  } else {
    throw Exception("Failed to create a new bill: ${response.body}");
  }
});

/// ✅ Update an existing bill (Updated invalidation)
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

  if (response.statusCode == 200) {
    // Refresh stats AND our new main provider
    ref.invalidate(referralStatsProvider);
    ref.invalidate(billChartStatsProvider);
    ref.invalidate(paginatedUnpaidPartialBillsProvider);
    ref.invalidate(billGrowthStatsProvider);
    ref.invalidate(paginatedBillsProvider);
    ref.invalidate(billProvider);
    ref.invalidate(singleBillProvider(updatedBill.id!));
    ref.invalidate(latestBillsProvider);


    return Bill.fromJson(jsonDecode(response.body));
  } else {
    throw Exception("Failed to update bill: ${response.body}");
  }
});

/// ✅ Delete a bill (Updated invalidation)
final deleteBillProvider = FutureProvider.autoDispose.family<void, int>((
  ref,
  id,
) async {
  final response = await AuthHttpClient.delete(ref, "$billsEndpoint$id/");

  if (response.statusCode == 204) {
    // Refresh stats AND our new main provider
    ref.invalidate(referralStatsProvider);
    ref.invalidate(billChartStatsProvider);
    ref.invalidate(paginatedUnpaidPartialBillsProvider);
    ref.invalidate(billGrowthStatsProvider);
    ref.invalidate(paginatedBillsProvider);
    ref.invalidate(billProvider);
    ref.invalidate(singleBillProvider(id));
    ref.invalidate(latestBillsProvider);

  } else {
    throw Exception("Failed to delete bill: ${response.body}");
  }
});
