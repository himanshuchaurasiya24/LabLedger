import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/authentication/config.dart';
import 'package:labledger/models/bill_model.dart';

import '../authentication/auth_http_client.dart'; // Import the utility client

String billsEndpoint = "${globalBaseUrl}diagnosis/bills/bill/";

/// ✅ Fetch all bills
final billsProvider = FutureProvider.autoDispose<List<Bill>>((ref) async {
  
  final response = await AuthHttpClient.get(ref, billsEndpoint);
  
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
  
  final response = await AuthHttpClient.get(
    ref, 
    '$billsEndpoint?search=$query',
  );
  
  if (response.statusCode == 200) {
    final List jsonList = jsonDecode(response.body);
    return jsonList.map((json) => Bill.fromJson(json)).toList();
  } else {
    throw Exception("Failed to search bills: ${response.body}");
  }
});

/// ✅ Fetch a single bill by ID
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

/// ✅ Create a new bill
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
    
    // Invalidate related providers to refresh data
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
  
  final response = await AuthHttpClient.put(
    ref,
    "$billsEndpoint${updatedBill.id}/",
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(updatedBill.toJson()),
  );

  if (response.statusCode == 200) {
    
    // Invalidate related providers to refresh data
    ref.invalidate(billsProvider);
    ref.invalidate(searchBillsProvider);
    ref.invalidate(singleBillProvider(updatedBill.id!)); // Invalidate specific bill too
    
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
  
  final response = await AuthHttpClient.delete(
    ref,
    "$billsEndpoint$id/",
  );
  
  if (response.statusCode == 204) {
    
    // Invalidate related providers to refresh data
    ref.invalidate(billsProvider);
    ref.invalidate(searchBillsProvider);
    ref.invalidate(singleBillProvider(id)); // Invalidate the deleted bill provider

  } else {
    throw Exception("Failed to delete bill: ${response.body}");
  }
});