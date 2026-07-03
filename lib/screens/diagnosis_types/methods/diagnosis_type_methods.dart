import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/models/diagnosis_type_model.dart';
import 'package:labledger/providers/diagnosis_type_provider.dart';
import 'package:labledger/screens/ui_components/custom_confirmation_dialog.dart';
import 'package:labledger/screens/ui_components/custom_error_dialog.dart';
import 'package:labledger/screens/ui_components/snackbar_utils.dart';

class DiagnosisTypeMethods extends ChangeNotifier {
  final BuildContext context;
  final WidgetRef ref;

  DiagnosisTypeMethods(this.context, this.ref);

  // ---------- Diagnosis Type List Screen State ----------
  String searchQuery = '';

  void onSearchChanged(String query) {
    searchQuery = query;
    notifyListeners();
  }

  List<DiagnosisType> filterDiagnosisTypes(List<DiagnosisType> types) {
    if (searchQuery.isEmpty) return types;

    return types.where((type) {
      final name = type.name.trim().toLowerCase().replaceAll(
        RegExp(r'\s+'),
        ' ',
      );
      final categoryName = (type.categoryName ?? '')
          .trim()
          .toLowerCase()
          .replaceAll(RegExp(r'\s+'), ' ');
      final price = type.price.toString();

      return name.contains(searchQuery) ||
          categoryName.contains(searchQuery) ||
          price.contains(searchQuery);
    }).toList();
  }

  // ---------- Diagnosis Type Edit Screen State ----------
  bool isSaving = false;
  bool isDeleting = false;
  bool isDataInitialized = false;

  void setInitialized() {
    isDataInitialized = true;
    notifyListeners();
  }

  Future<void> handleSave({
    required bool isEditMode,
    required DiagnosisType? originalDiagnosis,
    required String name,
    required int selectedCategoryId,
    required int price,
  }) async {
    isSaving = true;
    notifyListeners();

    try {
      if (isEditMode && originalDiagnosis != null) {
        final updatedDiagnosis = DiagnosisType(
          id: originalDiagnosis.id,
          name: name,
          category: selectedCategoryId,
          price: price,
        );
        await ref.read(updateDiagnosisTypeProvider(updatedDiagnosis).future);
        if (context.mounted) {
          showSuccessSnackBar(context, 'Diagnosis Type updated successfully!');
        }
      } else {
        final newDiagnosis = DiagnosisType(
          name: name,
          category: selectedCategoryId,
          price: price,
        );
        await ref.read(addDiagnosisTypeProvider(newDiagnosis).future);
        if (context.mounted) {
          showSuccessSnackBar(context, 'Diagnosis Type created successfully!');
        }
      }

      if (context.mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (context.mounted) {
        showErrorDialog(
          'Operation Failed',
          e.toString().replaceAll("Exception: ", ""),
        );
      }
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<void> handleDelete({required DiagnosisType diagnosis}) async {
    final confirmed = await showDeleteConfirmationDialog(
      context: context,
      title: 'Confirm Deletion',
      message: 'Are you sure you want to delete "${diagnosis.name}"?',
      showWarningIcon: false,
    );

    if (!confirmed) return;

    isDeleting = true;
    notifyListeners();

    try {
      await ref.read(deleteDiagnosisTypeProvider(diagnosis.id!).future);
      if (context.mounted) {
        showSuccessSnackBar(context, 'Diagnosis Type deleted successfully!');
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (context.mounted) {
        showErrorDialog(
          'Delete Failed',
          e.toString().replaceAll("Exception: ", ""),
        );
      }
    } finally {
      isDeleting = false;
      notifyListeners();
    }
  }

  // ---------- Diagnosis Type Bills List Screen Handlers ----------
  Future<void> confirmDeleteDiagnosisType(DiagnosisType diagnosisType) async {
    final shouldDelete = await showDeleteConfirmationDialog(
      context: context,
      title: 'Delete Diagnosis Type',
      message:
          'All bills associated with "${diagnosisType.name}" will also be deleted.\nThis action cannot be undone.\nAre you sure?',
    );

    if (shouldDelete == true) {
      try {
        await ref.read(deleteDiagnosisTypeProvider(diagnosisType.id!).future);
        if (context.mounted) {
          showSuccessSnackBar(context, 'Diagnosis Type deleted successfully');
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (context.mounted) {
          showErrorDialog(
              'Error deleting diagnosis type', e.toString());
        }
      }
    }
  }

  void showErrorDialog(String title, String errorMessage) {
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (context) =>
          ErrorDialog(title: title, errorMessage: errorMessage),
    );
  }
}
