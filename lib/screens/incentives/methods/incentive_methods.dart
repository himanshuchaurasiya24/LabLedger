import 'dart:async';
import 'package:labledger/constants/constants.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:labledger/main.dart';
import 'package:labledger/models/incentive_model.dart';
import 'package:labledger/providers/incenitve_generator_provider.dart';
import 'package:labledger/screens/incentives/pdf_api.dart';
import 'package:labledger/screens/incentives/report_generation_dialog.dart';
import 'package:labledger/screens/ui_components/snackbar_utils.dart';
import 'package:universal_html/html.dart' as html;

class IncentiveMethods extends ChangeNotifier {
  final BuildContext context;
  final WidgetRef ref;

  IncentiveMethods(this.context, this.ref);

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  bool _isRefreshingReport = false;
  bool get isRefreshingReport => _isRefreshingReport;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void initializeData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(selectedDoctorIdsProvider);
      ref.invalidate(selectedFranchiseIdsProvider);
      ref.invalidate(selectedDiagnosisTypeIdsProvider);

      ref.read(selectedBillStatusesProvider.notifier).state = {'Fully Paid'};

      final now = DateTime.now();
      final firstDayOfMonth = DateTime(now.year, now.month, 1);
      ref.read(reportStartDateProvider.notifier).state = firstDayOfMonth;

      ref.read(reportEndDateProvider.notifier).state = now;
    });
  }

  Future<void> refreshReport() async {
    if (_isRefreshingReport) {
      return;
    }
    _isRefreshingReport = true;
    notifyListeners();
    try {
      final refreshedReport = await ref.refresh(
        incentiveReportProvider.future,
      );
      if (refreshedReport.isEmpty) {
        showSnackBar('Report refreshed', isError: false);
      }
    } catch (e) {
      showSnackBar('Refresh failed: $e', isError: true);
    } finally {
      _isRefreshingReport = false;
      notifyListeners();
    }
  }

  Future<void> showReportGenerationDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const ReportGenerationDialog();
      },
    );

    if (result != null && result['generate'] == true) {
      final selectedFields = result['selectedFields'] as Map<String, bool>;
      final pdfIndex = result['pdf_layout_index'] as int;
      _generatePDFReport(selectedFields, pdfIndex);
    }
  }

  void _showProgressDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Dialog(
          child: Padding(
            padding: EdgeInsets.all(largePadding),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: largePadding),
                Text("Generating Report..."),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _generatePDFReport(
    Map<String, bool> selectedFields,
    int pdfIndex,
  ) async {
    const minDuration = Duration(seconds: 1);
    final stopwatch = Stopwatch()..start();
    bool isDialogPopped = false;

    _showProgressDialog();
    final pdfFieldSelection = Map<String, bool>.from(selectedFields)
      ..remove('negativeIncentives')
      ..remove('zeroIncentives');

    void closeDialog() {
      if (!isDialogPopped) {
        if (Navigator.of(context, rootNavigator: true).canPop()) {
          Navigator.of(context, rootNavigator: true).pop();
        }
        isDialogPopped = true;
      }
    }

    try {
      final reportState = ref.read(incentiveReportProvider);

      switch (reportState) {
        case AsyncData(value: final report):
          if (report.isEmpty) {
            showSnackBar(
              'No data available for report generation',
              isError: true,
            );
            return;
          }

          final filteredReports = report.where((doctorReport) {
            final firstName = doctorReport.doctor.firstName ?? '';
            final lastName = doctorReport.doctor.lastName ?? '';
            final fullName = '$firstName $lastName'.toLowerCase();
            return fullName.contains(_searchQuery);
          }).toList();

          final pdfReports = _applyIncentiveFiltersForPdf(
            filteredReports,
            includeNegativeIncentives:
                selectedFields['negativeIncentives'] ?? false,
            includeZeroIncentives: selectedFields['zeroIncentives'] ?? false,
          );

          if (pdfReports.isEmpty) {
            showSnackBar('No filtered data to generate report', isError: true);
            return;
          }

          final pdfBytes = await createPDF(
            reports: pdfReports,
            selectedFields: pdfFieldSelection,
            ref: ref,
            pdfIndex: pdfIndex,
          );

          stopwatch.stop();
          final elapsed = stopwatch.elapsed;
          if (elapsed < minDuration) {
            await Future.delayed(minDuration - elapsed);
          }
          closeDialog();

          if (kIsWeb) {
            _downloadPdfWeb(pdfBytes);
          } else {
            final fileName =
                "LabLedger Incentive Report ${DateFormat("dd MMM yyyy hh-mm-ss").format(DateTime.now())}.pdf";

            final savePath = await FilePicker.saveFile(
              dialogTitle: 'Save report file',
              fileName: fileName,
              bytes: pdfBytes,
            );

            if (savePath == null || savePath.isEmpty) {
              showSnackBar('Save cancelled', isError: false);
              return;
            }

            showSnackBar('Report saved to $savePath', isError: false);
          }
        case AsyncLoading():
          showSnackBar('Please wait for data to load', isError: false);
        case AsyncError(:final error):
          showSnackBar('Error fetching report data: $error', isError: true);
        default:
          showSnackBar(
            'An unknown error occurred while fetching data.',
            isError: true,
          );
      }
    } catch (e) {
      showSnackBar('Failed to generate report: $e', isError: true);
    } finally {
      if (stopwatch.isRunning) {
        stopwatch.stop();
        final elapsed = stopwatch.elapsed;
        if (elapsed < minDuration) {
          await Future.delayed(minDuration - elapsed);
        }
      }
      closeDialog();
    }
  }

  void _downloadPdfWeb(Uint8List pdfBytes) {
    final blob = html.Blob([pdfBytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..style.display = 'none'
      ..download =
          '${"LabLedger Incentive Report ${DateFormat("dd_MM_YYYY_hh:mm:ss").format(DateTime.now())}".replaceAll(' ', '_')}.pdf';
    html.document.body!.children.add(anchor);
    anchor.click();
    html.document.body!.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }

  void showSnackBar(String message, {required bool isError}) {
    final currentContext = navigatorKey.currentContext ?? context;
    if (isError) {
      showErrorSnackBar(currentContext, message);
    } else {
      showSuccessSnackBar(currentContext, message);
    }
  }

  List<DoctorReport> _applyIncentiveFiltersForPdf(
    List<DoctorReport> reports, {
    required bool includeNegativeIncentives,
    required bool includeZeroIncentives,
  }) {
    bool includeDoctor(DoctorReport report) {
      if (!includeNegativeIncentives && report.totalIncentive < 0) {
        return false;
      }
      if (!includeZeroIncentives && report.totalIncentive == 0) {
        return false;
      }
      return true;
    }

    return reports.where(includeDoctor).toList();
  }
}
