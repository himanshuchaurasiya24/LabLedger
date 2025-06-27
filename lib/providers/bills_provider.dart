import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/providers/custom_providers.dart';
import "package:http/http.dart" as http;

// final billsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((
//   ref,
// ) async {
//   final token = await ref.read(tokenProvider.future);
//   final response = await http.get(
//     Uri.parse("${baseURL}diagnosis/bills/bill/"),
//     headers: {"Authorization": "Bearer $token"},
//   );
//   if (response.statusCode == 200) {
//     final List<Map<String, dynamic>> data = jsonDecode(response.body);
//     return data;
//   } else {
//     throw Exception("Failed to fetch bills: ${response.body}");
//   }
// });
final billsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final token = await ref.read(tokenProvider.future);
  final response = await http.get(
    Uri.parse("${baseURL}diagnosis/bills/bill/"),
    headers: {"Authorization": "Bearer $token"},
  );
  if (response.statusCode == 200) {
    final List data = jsonDecode(response.body);
    return data.cast<Map<String, dynamic>>();
  } else {
    throw Exception("Failed to fetch bills: ${response.body}");
  }
});

final singleBillProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, int>((ref, id) async {
      final token = await ref.read(tokenProvider.future);
      final response = await http.get(
        Uri.parse("${baseURL}diagnosis/bills/bill/$id/?list_format=true"),
        headers: {"Authorization": "Bearer $token"},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception("Failed to fetch bill: ${response.body}");
      }
    });
final createBillProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, Map<String, dynamic>>((ref, newBill) async {
      final token = await ref.read(tokenProvider.future);
      final response = await http.post(
        Uri.parse("${baseURL}diagnosis/bills/bill/"),
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer $token",
        },
        body: newBill,
      );
      if (response.statusCode == 201) {
        ref.invalidate(billsProvider);
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to create a new bill: ${response.body}");
      }
    });

final updateBillProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, Map<String, dynamic>>((ref, input) async {
      final token = await ref.read(tokenProvider.future);
      final int id = input['id'];
      final Map<String, dynamic> updatedData = input['data'];
      final response = await http.patch(
        Uri.parse("${baseURL}diagnosis/bills/bill/$id/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: updatedData,
      );
      if (response.statusCode == 200) {
        ref.invalidate(billsProvider);
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to update this bill: ${response.body}");
      }
    });

final deleteBillProvider = FutureProvider.autoDispose.family<void, int>((
  ref,
  id,
) async {
  final token = await ref.read(tokenProvider.future);
  final response = await http.delete(
    Uri.parse("${baseURL}diagnosis/bills/bill/$id/"),
    headers: {"Authorization": "Bearer $token"},
  );
  if (response.statusCode == 204) {
    ref.invalidate(billsProvider);
  } else {
    throw Exception("Failed to delete bills: ${response.body}");
  }
});
