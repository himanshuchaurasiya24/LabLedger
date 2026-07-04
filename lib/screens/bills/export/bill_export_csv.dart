import 'dart:convert';
import 'dart:typed_data';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:labledger/models/bill_model.dart';

/// Generates a CSV spreadsheet from a list of bills with selected fields.
/// Returns UTF-8 encoded bytes ready for file saving.
Uint8List createBillsExportCSV({
  required List<Bill> bills,
  required Map<String, bool> selectedFields,
}) {
  final headers = <String>[];
  final fieldKeys = <String>[];

  // Build headers based on selected fields
  final fieldConfig = {
    'dateOfBill': 'Date of Bill',
    'billNumber': 'Bill Number',
    'patientName': 'Patient Name',
    'ageAndSex': 'Age/Sex',
    'patientPhone': 'Phone',
    'diagnosisType': 'Diagnosis',
    'franchiseName': 'Franchise',
    'referredByDoctor': 'Referred By Doctor',
    'billStatus': 'Status',
    'totalAmount': 'Total Amount',
    'paidAmount': 'Paid Amount',
    'discByCenter': 'Center Discount',
    'discByDoctor': 'Doctor Discount',
    'incentiveAmount': 'Incentive Amount',
    'testDoneBy': 'Test Done By',
  };

  for (final entry in fieldConfig.entries) {
    if (selectedFields[entry.key] ?? false) {
      headers.add(entry.value);
      fieldKeys.add(entry.key);
    }
  }

  // Build data rows
  final rows = <List<String>>[];
  rows.add(headers);

  for (final bill in bills) {
    final row = <String>[];
    for (final key in fieldKeys) {
      row.add(_getCellValue(bill, key));
    }
    rows.add(row);
  }

  // Add summary row
  if (bills.isNotEmpty) {
    final summaryRow = List<String>.filled(fieldKeys.length, '');
    final firstCol = fieldKeys.indexOf('dateOfBill');
    final nameCol = fieldKeys.indexOf('patientName');
    final summaryCol = firstCol >= 0 ? firstCol : (nameCol >= 0 ? nameCol : 0);
    summaryRow[summaryCol] = 'TOTAL (${bills.length} bills)';

    final totalIdx = fieldKeys.indexOf('totalAmount');
    if (totalIdx >= 0) {
      summaryRow[totalIdx] =
          bills.fold<int>(0, (sum, b) => sum + b.totalAmount).toString();
    }
    final paidIdx = fieldKeys.indexOf('paidAmount');
    if (paidIdx >= 0) {
      summaryRow[paidIdx] =
          bills.fold<int>(0, (sum, b) => sum + b.paidAmount).toString();
    }
    final centerDiscIdx = fieldKeys.indexOf('discByCenter');
    if (centerDiscIdx >= 0) {
      summaryRow[centerDiscIdx] =
          bills.fold<int>(0, (sum, b) => sum + b.discByCenter).toString();
    }
    final doctorDiscIdx = fieldKeys.indexOf('discByDoctor');
    if (doctorDiscIdx >= 0) {
      summaryRow[doctorDiscIdx] =
          bills.fold<int>(0, (sum, b) => sum + b.discByDoctor).toString();
    }
    final incentiveIdx = fieldKeys.indexOf('incentiveAmount');
    if (incentiveIdx >= 0) {
      summaryRow[incentiveIdx] =
          bills.fold<int>(0, (sum, b) => sum + b.incentiveAmount).toString();
    }

    rows.add(summaryRow);
  }

  // Convert to CSV string then to bytes (csv v8 uses CsvEncoder)
  const encoder = CsvEncoder(addBom: true);
  final csvString = encoder.convert(rows);

  return Uint8List.fromList(utf8.encode(csvString));
}

String _getCellValue(Bill bill, String key) {
  switch (key) {
    case 'dateOfBill':
      return DateFormat('dd-MM-yyyy').format(bill.dateOfBill);
    case 'billNumber':
      return bill.billNumber ?? 'N/A';
    case 'patientName':
      return bill.patientName;
    case 'ageAndSex':
      return '${bill.patientAge}y / ${bill.patientSex}';
    case 'patientPhone':
      return bill.patientPhoneNumber ?? 'N/A';
    case 'diagnosisType':
      return _formatDiagnosis(bill);
    case 'franchiseName':
      return bill.franchiseNameOutput?['franchise_name']?.toString() ?? 'N/A';
    case 'referredByDoctor':
      return _formatDoctor(bill);
    case 'billStatus':
      return bill.billStatus;
    case 'totalAmount':
      return bill.totalAmount.toString();
    case 'paidAmount':
      return bill.paidAmount.toString();
    case 'discByCenter':
      return bill.discByCenter.toString();
    case 'discByDoctor':
      return bill.discByDoctor.toString();
    case 'incentiveAmount':
      return bill.incentiveAmount.toString();
    case 'testDoneBy':
      return _formatTestDoneBy(bill);
    default:
      return '';
  }
}

String _formatDiagnosis(Bill bill) {
  if (bill.diagnosisTypesOutput != null &&
      bill.diagnosisTypesOutput!.isNotEmpty) {
    return bill.diagnosisTypesOutput!
        .map((dt) =>
            "${dt['name'] ?? 'Unknown'} (${dt['category_name'] ?? 'Unknown'})")
        .join(', ');
  }
  return 'N/A';
}

String _formatDoctor(Bill bill) {
  final doc = bill.referredByDoctorOutput;
  if (doc == null) return 'N/A';
  final first = doc['first_name'] ?? '';
  final last = doc['last_name'] ?? '';
  if (first.isEmpty && last.isEmpty) return 'N/A';
  return 'Dr. $first $last'.trim();
}

String _formatTestDoneBy(Bill bill) {
  final tdb = bill.testDoneBy;
  if (tdb == null) return 'N/A';
  final first = tdb['first_name'] ?? '';
  final last = tdb['last_name'] ?? '';
  if (first.isEmpty && last.isEmpty) return 'N/A';
  return '$first $last'.trim();
}
