
import 'package:labledger/models/bill_model.dart';

class PaginatedBillsResponse {
  final List<Bill> bills;
  final int count;
  final bool hasNext;

  PaginatedBillsResponse({
    required this.bills,
    required this.count,
    required this.hasNext,
  });

  factory PaginatedBillsResponse.fromJson(Map<String, dynamic> json) {
    final List jsonList = json['results'] as List;
    final List<Bill> billList = jsonList.map((i) => Bill.fromJson(i as Map<String, dynamic>)).toList();
    
    return PaginatedBillsResponse(
      bills: billList,
      count: json['count'] ?? 0,
      // The API sends a URL string for 'next', or null if it's the last page.
      hasNext: json['next'] != null,
    );
  }
}