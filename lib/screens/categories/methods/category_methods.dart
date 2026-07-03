import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/models/diagnosis_category_model.dart';
import 'package:labledger/providers/category_provider.dart';
import 'package:labledger/screens/ui_components/custom_confirmation_dialog.dart';
import 'package:labledger/screens/ui_components/custom_error_dialog.dart';
import 'package:labledger/screens/ui_components/snackbar_utils.dart';

class CategoryMethods extends ChangeNotifier {
  final BuildContext context;
  final WidgetRef ref;

  CategoryMethods(this.context, this.ref);

  // ---------- Category List Screen State ----------
  String searchQuery = '';

  void onSearchChanged(String query) {
    searchQuery = query;
    notifyListeners();
  }

  List<DiagnosisCategory> filterCategories(List<DiagnosisCategory> categories) {
    if (searchQuery.isEmpty) return categories;

    return categories.where((category) {
      final name = category.name.trim().toLowerCase().replaceAll(
        RegExp(r'\s+'),
        ' ',
      );
      final description = (category.description ?? '')
          .trim()
          .toLowerCase()
          .replaceAll(RegExp(r'\s+'), ' ');

      return name.contains(searchQuery) || description.contains(searchQuery);
    }).toList();
  }

  // ---------- Category Edit Screen State ----------
  bool isFranchiseLab = false;
  bool isSaving = false;
  bool isDeleting = false;

  void setIsFranchiseLab(bool value) {
    isFranchiseLab = value;
    notifyListeners();
  }

  Future<void> handleSave({
    required bool isEditMode,
    required int categoryId,
    required String name,
    required String description,
  }) async {
    isSaving = true;
    notifyListeners();

    try {
      final category = DiagnosisCategory(
        id: isEditMode ? categoryId : 0,
        name: name,
        description: description.isEmpty ? null : description,
        isFranchiseLab: isFranchiseLab,
        isActive: true,
      );

      if (isEditMode) {
        await ref.read(updateCategoryProvider(category).future);
        if (context.mounted) {
          showSuccessSnackBar(context, 'Category updated successfully!');
        }
      } else {
        await ref.read(addCategoryProvider(category).future);
        if (context.mounted) {
          showSuccessSnackBar(context, 'Category created successfully!');
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

  Future<void> handleDelete({required DiagnosisCategory category}) async {
    final confirmed = await showDeleteConfirmationDialog(
      context: context,
      title: 'Confirm Deletion',
      message:
          'Are you sure you want to delete ${category.name}?\nThis action cannot be undone.',
    );

    if (!confirmed) return;

    isDeleting = true;
    notifyListeners();
    try {
      await ref.read(deleteCategoryProvider(category.id).future);
      if (context.mounted) {
        showSuccessSnackBar(context, 'Category deleted successfully!');
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

  void showErrorDialog(String title, String errorMessage) {
    showDialog(
      context: context,
      builder: (context) => ErrorDialog(title: title, errorMessage: errorMessage),
    );
  }
}
