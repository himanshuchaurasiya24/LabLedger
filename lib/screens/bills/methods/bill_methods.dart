import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:labledger/main.dart';
import 'package:labledger/models/bill_model.dart';
import 'package:labledger/models/diagnosis_type_model.dart';
import 'package:labledger/models/doctors_model.dart';
import 'package:labledger/models/franchise_model.dart';
import 'package:labledger/providers/bills_provider.dart';
import 'package:labledger/providers/patient_report_provider.dart';
import 'package:labledger/screens/bills/add_update_bill_screen.dart';
import 'package:labledger/screens/bills/message/bill_message_service.dart';
import 'package:labledger/screens/ui_components/custom_confirmation_dialog.dart';
import 'package:labledger/screens/ui_components/custom_error_dialog.dart';
import 'package:labledger/screens/ui_components/snackbar_utils.dart';

class BillMethods extends ChangeNotifier {
  final WidgetRef ref;
  final BuildContext context;
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  BillMethods(this.ref, this.context);

  // ---------- Bills Screen State ----------
  String selectedView = 'grid';
  Timer? debounce;

  Future<void> loadSavedView() async {
    final savedView = await storage.read(key: 'bill_view');
    if (savedView != null) {
      selectedView = savedView;
      notifyListeners();
    }
  }

  Future<void> saveView(String view) async {
    selectedView = view;
    notifyListeners();
    await storage.write(key: 'bill_view', value: view);
  }

  void onSearchChanged(String query) {
    debounce?.cancel();
    debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(currentSearchQueryProvider.notifier).state = query;
      ref.read(currentPageProvider.notifier).state = 1;
    });
  }

  void navigateToBill(Bill bill, Color themeColor) {
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) =>
            AddUpdateBillScreen(billId: bill.id, themeColor: themeColor),
      ),
    );
  }

  void disposeDebounce() {
    debounce?.cancel();
  }

  // ---------- Add/Update Bill Screen State ----------
  bool isSendingMessage = false;
  bool isDownloadingReport = false;
  bool isDataInitialized = false;
  bool isSubmitting = false;

  String selectedTestDateISO = DateTime.now().toIso8601String();
  String selectedBillDateISO = DateTime.now().toIso8601String();

  List<DiagnosisType> selectedDiagnosisTypes = [];
  FranchiseName? selectedFranchise;
  Doctor? selectedDoctor;

  Future<void> sendBillMessage(Bill bill) async {
    if (bill.id == null) return;
    isSendingMessage = true;
    notifyListeners();

    try {
      await BillMessageService().send(
        context: context,
        ref: ref,
        bill: bill,
        showErrorDialog: showErrorDialog,
        showSuccessMessage: (message) => showSuccessSnackBar(context, message),
      );
    } catch (e) {
      showErrorDialog('Message Failed', 'Could not send the message: $e');
    } finally {
      isSendingMessage = false;
      notifyListeners();
    }
  }

  Future<void> downloadReport(int reportId) async {
    if (reportId <= 0) return;
    isDownloadingReport = true;
    notifyListeners();

    try {
      final downloadPayload = await ref.read(
        downloadPatientReportProvider(reportId).future,
      );
      final savePath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save report file',
        fileName: downloadPayload.fileName,
      );

      if (savePath == null || savePath.isEmpty) {
        return;
      }

      final file = File(savePath);
      await file.writeAsBytes(downloadPayload.bytes);
      if (!context.mounted) return;
      showSuccessSnackBar(context, 'Report saved to $savePath');
    } catch (e) {
      showErrorDialog('Download Failed', 'Could not download the report: $e');
    } finally {
      isDownloadingReport = false;
      notifyListeners();
    }
  }

  Future<void> deleteBill(Bill bill) async {
    final shouldDelete = await showDeleteConfirmationDialog(
      context: context,
      title: 'Delete Bill',
      message:
          'Are you sure you want to delete this bill? This action cannot be undone.',
    );
    if (shouldDelete) {
      try {
        await ref.read(deleteBillProvider(bill.id!).future);
        if (!context.mounted) return;
        showSuccessSnackBar(context, "Bill deleted successfully");
        if (context.mounted) Navigator.of(context).pop();
      } catch (e) {
        showErrorDialog('Delete Failed', e.toString());
      }
    }
  }

  Future<void> saveBill({
    required GlobalKey<FormState> formKey,
    required bool isEditMode,
    required Bill? originalBill,
    required int? billId,
    required TextEditingController patientNameController,
    required TextEditingController patientAgeController,
    required TextEditingController patientSexController,
    required TextEditingController billStatusController,
    required TextEditingController paidAmountController,
    required TextEditingController discByCenterController,
    required TextEditingController discByDoctorController,
    required TextEditingController patientPhoneNumberController,
    required TextEditingController refByDoctorController,
    required TextEditingController franchiseNameController,
  }) async {
    if (billStatusController.text == "Unpaid") {
      paidAmountController.text = "0";
      discByCenterController.text = "0";
      discByDoctorController.text = "0";
    }
    if (discByCenterController.text.isEmpty) discByCenterController.text = "0";
    if (discByDoctorController.text.isEmpty) discByDoctorController.text = "0";

    if (!formKey.currentState!.validate()) {
      showErrorDialog(
        "Form Not Valid",
        "Please correct the errors before saving.",
      );
      return;
    }

    setSubmitting(true);

    final billToSave = Bill(
      id: billId,
      patientName: patientNameController.text,
      patientAge: int.parse(patientAgeController.text),
      patientSex: patientSexController.text,
      dateOfTest: DateTime.parse(selectedTestDateISO),
      dateOfBill: DateTime.parse(selectedBillDateISO),
      billStatus: billStatusController.text,
      paidAmount: int.parse(paidAmountController.text),
      discByCenter: int.parse(discByCenterController.text),
      discByDoctor: int.parse(discByDoctorController.text),
      patientPhoneNumber: patientPhoneNumberController.text,
      diagnosisTypes: selectedDiagnosisTypes
          .map((dt) => dt.id)
          .whereType<int>()
          .toList(),
      referredByDoctor: int.parse(refByDoctorController.text),
      franchiseName: franchiseNameController.text.isNotEmpty
          ? int.parse(franchiseNameController.text)
          : null,
      diagnosisTypesOutput: originalBill?.diagnosisTypesOutput,
      referredByDoctorOutput: originalBill?.referredByDoctorOutput,
      franchiseNameOutput: originalBill?.franchiseNameOutput,
      testDoneBy: originalBill?.testDoneBy,
      centerDetail: originalBill?.centerDetail,
      billNumber: null,
      totalAmount: 0,
      incentiveAmount: 0,
    );

    try {
      if (isEditMode) {
        final updatedBill = await ref.read(
          updateBillProvider(billToSave).future,
        );
        if (!context.mounted) return;
        showSuccessSnackBar(
          context,
          'Bill updated successfully: #${updatedBill.billNumber}',
        );
        Navigator.pop(context, updatedBill);
      } else {
        final newBill = await ref.read(createBillProvider(billToSave).future);
        if (!context.mounted) return;
        showSuccessSnackBar(
          context,
          'Bill created successfully: #${newBill.billNumber}',
        );
        Navigator.pop(context, newBill);
      }
    } catch (e) {
      if (!context.mounted) return;
      showErrorDialog('Failed to Save Bill', e.toString());
    } finally {
      setSubmitting(false);
    }
  }

  void setSubmitting(bool value) {
    isSubmitting = value;
    notifyListeners();
  }

  void initializeData() {
    if (isDataInitialized) return;
    isDataInitialized = true;
    notifyListeners();
  }

  void showErrorDialog(String title, String errorMessage) {
    showDialog(
      context: context,
      builder: (context) =>
          ErrorDialog(title: title, errorMessage: errorMessage),
    );
  }
}
