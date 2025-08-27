import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/models/bill_model.dart'; // make sure path is correct
import 'package:labledger/providers/custom_providers.dart';
import 'package:http/http.dart' as http;

String billsEndpoint = "${baseURL}diagnosis/bills/bill/";

/// ✅ Fetch all bills
final billsProvider = FutureProvider.autoDispose<List<Bill>>((ref) async {
  final token = await ref.read(tokenProvider.future);
  final response = await http.get(
    Uri.parse(billsEndpoint),
    headers: {"Authorization": "Bearer $token"},
  );
  if (response.statusCode == 200) {
    final List jsonList = jsonDecode(response.body);
    return jsonList.map((json) => Bill.fromJson(json)).toList();
  } else {
    throw Exception("Failed to fetch bills: ${response.body}");
  }
});



/// ✅ Search all bills
final searchBillsProvider = FutureProvider.autoDispose
    .family<List<Bill>, String>((ref, query) async {
      final token = await ref.read(tokenProvider.future);
      // Debounce using future delay
      final response = await http.get(
        Uri.parse('$billsEndpoint?search=$query'),
        headers: {"Authorization": "Bearer $token"},
      );
      if (response.statusCode == 200) {
        final List jsonList = jsonDecode(response.body);
        return jsonList.map((json) => Bill.fromJson(json)).toList();
      } else {
        throw Exception("Failed to fetch bills: ${response.body}");
      }
    });

/// ✅ Fetch a single bill by ID
final singleBillProvider = FutureProvider.autoDispose.family<Bill, int>((
  ref,
  id,
) async {
  final token = await ref.read(tokenProvider.future);
  final response = await http.get(
    Uri.parse("$billsEndpoint$id/?list_format=true"),
    headers: {"Authorization": "Bearer $token"},
  );
  if (response.statusCode == 200) {
    return Bill.fromJson(jsonDecode(response.body));
  } else {
    throw Exception("Failed to fetch bill: ${response.body}");
  }
});

/// ✅ Create a new bill
final createBillProvider = FutureProvider.autoDispose.family<Bill, Bill>((
  ref,
  newBill,
) async {
  final token = await ref.read(tokenProvider.future);
  final response = await http.post(
    Uri.parse(billsEndpoint),
    headers: {
      'Content-Type': 'application/json',
      "Authorization": "Bearer $token",
    },
    body: jsonEncode(newBill.toJson()),
  );
  if (response.statusCode == 201 || response.statusCode == 200) {
    ref.invalidate(billsProvider);
    ref.invalidate(searchBillsProvider);
    return Bill.fromJson(jsonDecode(response.body));
  } else {
    throw Exception("Failed to create a new bill: ${response.body}");
  }
});

/// ✅ Update an existing bill
final updateBillProvider = FutureProvider.autoDispose.family<Bill, Bill>((
  ref,
  updatedBill,
) async {
  final token = await ref.read(tokenProvider.future);
  final response = await http.put(
    Uri.parse("$billsEndpoint${updatedBill.id}/"),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    },
    body: jsonEncode(updatedBill.toJson()),
  );

  if (response.statusCode == 200) {
    ref.invalidate(billsProvider);
    ref.invalidate(searchBillsProvider);

    return Bill.fromJson(jsonDecode(response.body));
  } else {
    throw Exception("Failed to update bill: ${response.body}");
  }
});

/// ✅ Delete a bill
final deleteBillProvider = FutureProvider.autoDispose.family<void, int>((
  ref,
  id,
) async {
  final token = await ref.read(tokenProvider.future);
  final response = await http.delete(
    Uri.parse("$billsEndpoint$id/"),
    headers: {"Authorization": "Bearer $token"},
  );
  if (response.statusCode == 204) {
    ref.invalidate(billsProvider);
    ref.invalidate(searchBillsProvider);

  } else {
    throw Exception("Failed to delete bill: ${response.body}");
  }
});
