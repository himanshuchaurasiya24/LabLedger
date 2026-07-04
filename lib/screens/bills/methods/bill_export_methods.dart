import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/main.dart';
import 'package:labledger/models/bill_model.dart';
import 'package:labledger/providers/bills_provider.dart';
import 'package:labledger/screens/bills/export/bill_export_csv.dart';
import 'package:labledger/screens/bills/export/bill_export_dialog.dart';
import 'package:labledger/screens/bills/export/bill_export_pdf.dart';
import 'package:labledger/screens/bills/pdf/bill_receipt_pdf.dart';
import 'package:labledger/screens/ui_components/snackbar_utils.dart';
import 'package:universal_html/html.dart' as html;

class BillExportMethods extends ChangeNotifier {
  final BuildContext context;
  final WidgetRef ref;

  BillExportMethods(this.context, this.ref);

  // ── Export Dialog Flow ──

  Future<void> showExportDialog() async {
    _showSnackBar('Fetching bills for export...', isError: false);
    List<Bill> bills;
    try {
      bills = await ref.read(allFilteredBillsProvider.future);
    } catch (e) {
      if (!context.mounted) return;
      _showSnackBar('Failed to fetch bills: $e', isError: true);
      return;
    }

    if (!context.mounted) return;

    if (bills.isEmpty) {
      _showSnackBar('No bills available to export', isError: true);
      return;
    }

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const BillExportDialog();
      },
    );

    if (result != null && result['export'] == true) {
      final selectedFields = result['selectedFields'] as Map<String, bool>;
      final format = result['format'] as String;

      if (format == 'pdf') {
        await _exportPDF(bills, selectedFields);
      } else {
        await _exportCSV(bills, selectedFields);
      }
    }
  }

  // ── PDF Export ──

  Future<void> _exportPDF(
    List<Bill> bills,
    Map<String, bool> selectedFields,
  ) async {
    const minDuration = Duration(seconds: 1);
    final stopwatch = Stopwatch()..start();
    bool isDialogPopped = false;

    _showProgressDialog('Generating PDF...');

    void closeDialog() {
      if (!isDialogPopped) {
        if (Navigator.of(context, rootNavigator: true).canPop()) {
          Navigator.of(context, rootNavigator: true).pop();
        }
        isDialogPopped = true;
      }
    }

    try {
      final pdfBytes = await createBillsExportPDF(
        bills: bills,
        selectedFields: selectedFields,
        ref: ref,
      );

      stopwatch.stop();
      final elapsed = stopwatch.elapsed;
      if (elapsed < minDuration) {
        await Future.delayed(minDuration - elapsed);
      }
      closeDialog();

      await _saveFile(
        pdfBytes,
        'LabLedger Bills Export ${DateFormat("dd MMM yyyy hh-mm-ss").format(DateTime.now())}.pdf',
        'application/pdf',
      );
    } catch (e) {
      closeDialog();
      _showSnackBar('Failed to generate PDF: $e', isError: true);
    }
  }

  // ── CSV Export ──

  Future<void> _exportCSV(
    List<Bill> bills,
    Map<String, bool> selectedFields,
  ) async {
    const minDuration = Duration(seconds: 1);
    final stopwatch = Stopwatch()..start();
    bool isDialogPopped = false;

    _showProgressDialog('Generating spreadsheet...');

    void closeDialog() {
      if (!isDialogPopped) {
        if (Navigator.of(context, rootNavigator: true).canPop()) {
          Navigator.of(context, rootNavigator: true).pop();
        }
        isDialogPopped = true;
      }
    }

    try {
      final csvBytes = createBillsExportCSV(
        bills: bills,
        selectedFields: selectedFields,
      );

      stopwatch.stop();
      final elapsed = stopwatch.elapsed;
      if (elapsed < minDuration) {
        await Future.delayed(minDuration - elapsed);
      }
      closeDialog();

      await _saveFile(
        csvBytes,
        'LabLedger Bills Export ${DateFormat("dd MMM yyyy hh-mm-ss").format(DateTime.now())}.csv',
        'text/csv',
      );
    } catch (e) {
      closeDialog();
      _showSnackBar('Failed to generate spreadsheet: $e', isError: true);
    }
  }

  // ── Single Bill Receipt ──

  Future<void> generateBillReceipt(Bill bill) async {
    const minDuration = Duration(seconds: 1);
    final stopwatch = Stopwatch()..start();
    bool isDialogPopped = false;

    _showProgressDialog('Generating receipt...');

    void closeDialog() {
      if (!isDialogPopped) {
        if (Navigator.of(context, rootNavigator: true).canPop()) {
          Navigator.of(context, rootNavigator: true).pop();
        }
        isDialogPopped = true;
      }
    }

    try {
      final pdfBytes = await createBillReceiptPDF(
        bill: bill,
        ref: ref,
      );

      stopwatch.stop();
      final elapsed = stopwatch.elapsed;
      if (elapsed < minDuration) {
        await Future.delayed(minDuration - elapsed);
      }
      closeDialog();

      final sanitizedName = bill.patientName.replaceAll(RegExp(r'[^\w\s]'), '');
      await _saveFile(
        pdfBytes,
        'Receipt ${bill.billNumber ?? ''} $sanitizedName.pdf',
        'application/pdf',
      );
    } catch (e) {
      closeDialog();
      _showSnackBar('Failed to generate receipt: $e', isError: true);
    }
  }

  // ── Shared Helpers ──

  Future<void> _saveFile(
    Uint8List bytes,
    String fileName,
    String mimeType,
  ) async {
    if (kIsWeb) {
      _downloadWeb(bytes, fileName, mimeType);
    } else {
      final savePath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save export file',
        fileName: fileName,
      );

      if (savePath == null || savePath.isEmpty) {
        _showSnackBar('Save cancelled', isError: false);
        return;
      }

      final file = File(savePath);
      await file.writeAsBytes(bytes);
      _showSnackBar('Saved to $savePath', isError: false);
    }
  }

  void _downloadWeb(Uint8List bytes, String fileName, String mimeType) {
    final blob = html.Blob([bytes], mimeType);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..style.display = 'none'
      ..download = fileName.replaceAll(' ', '_');
    html.document.body!.children.add(anchor);
    anchor.click();
    html.document.body!.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }

  void _showProgressDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: EdgeInsets.all(largePadding),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: largePadding),
                Text(message),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSnackBar(String message, {required bool isError}) {
    final currentContext = navigatorKey.currentContext ?? context;
    if (isError) {
      showErrorSnackBar(currentContext, message);
    } else {
      showSuccessSnackBar(currentContext, message);
    }
  }
}
