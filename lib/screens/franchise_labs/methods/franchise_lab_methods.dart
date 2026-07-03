import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/models/franchise_model.dart';
import 'package:labledger/providers/franchise_lab_provider.dart';
import 'package:labledger/screens/ui_components/custom_confirmation_dialog.dart';
import 'package:labledger/screens/ui_components/custom_error_dialog.dart';
import 'package:labledger/screens/ui_components/snackbar_utils.dart';

class FranchiseLabMethods extends ChangeNotifier {
  final BuildContext context;
  final WidgetRef ref;

  FranchiseLabMethods(this.context, this.ref);

  // ---------- Franchise Labs List Screen State ----------
  String searchQuery = '';

  void onSearchChanged(String query) {
    searchQuery = query;
    notifyListeners();
  }

  List<FranchiseName> filterFranchises(List<FranchiseName> franchises) {
    if (searchQuery.isEmpty) return franchises;

    return franchises.where((franchise) {
      final franchiseName = (franchise.franchiseName ?? '')
          .trim()
          .toLowerCase()
          .replaceAll(RegExp(r'\s+'), ' ');
      final address = (franchise.address ?? '').trim().toLowerCase().replaceAll(
        RegExp(r'\s+'),
        ' ',
      );
      final phoneNumber = (franchise.phoneNumber ?? '')
          .trim()
          .toLowerCase()
          .replaceAll(RegExp(r'\s+'), ' ');

      return franchiseName.contains(searchQuery) ||
          address.contains(searchQuery) ||
          phoneNumber.contains(searchQuery);
    }).toList();
  }

  // ---------- Franchise Edit Screen State ----------
  bool isSaving = false;
  bool isDeleting = false;
  bool isDataInitialized = false;

  void setInitialized() {
    isDataInitialized = true;
    notifyListeners();
  }

  Future<void> handleSave({
    required bool isEditMode,
    required FranchiseName? originalFranchise,
    required String franchiseName,
    required String address,
    required String phoneNumber,
  }) async {
    isSaving = true;
    notifyListeners();

    try {
      if (isEditMode && originalFranchise != null) {
        await ref.read(
          updateFranchiseProvider(
            FranchiseName(
              id: originalFranchise.id,
              address: address,
              franchiseName: franchiseName,
              phoneNumber: phoneNumber,
            ),
          ).future,
        );
        if (context.mounted) {
          showSuccessSnackBar(context, 'Franchise Lab updated successfully!');
        }
      } else {
        final newFranchise = FranchiseName(
          franchiseName: franchiseName,
          address: address,
          phoneNumber: phoneNumber,
        );

        await ref.read(createFranchiseProvider(newFranchise).future);
        if (context.mounted) {
          showSuccessSnackBar(context, 'Franchise Lab created successfully!');
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

  Future<void> handleDelete({required FranchiseName franchise}) async {
    final confirmed = await showDeleteConfirmationDialog(
      context: context,
      title: 'Confirm Deletion',
      message:
          'Are you sure you want to delete ${franchise.franchiseName}?\n\nThis action cannot be undone.',
    );

    if (confirmed == true) {
      isDeleting = true;
      notifyListeners();
      try {
        await ref.read(deleteFranchiseProvider(franchise.id!).future);
        if (context.mounted) {
          showSuccessSnackBar(context, 'Franchise Lab deleted successfully!');
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
  }

  // ---------- Franchise Lab Bills List Screen Handlers ----------
  Future<void> confirmDeleteFranchise(FranchiseName franchise) async {
    final shouldDelete = await showDeleteConfirmationDialog(
      context: context,
      title: 'Delete Franchise',
      message:
          'All bills associated with "${franchise.franchiseName}" will be deleted.\nThis action cannot be undone.\nAre you sure?',
    );

    if (shouldDelete == true) {
      try {
        await ref.read(deleteFranchiseProvider(franchise.id!).future);
        if (context.mounted) {
          showSuccessSnackBar(context, "Franchise deleted successfully");
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (context.mounted) {
          showErrorDialog('Error deleting franchise', e.toString());
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
