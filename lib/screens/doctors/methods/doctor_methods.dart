import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/models/doctors_model.dart';
import 'package:labledger/providers/doctor_provider.dart';
import 'package:labledger/screens/ui_components/custom_confirmation_dialog.dart';
import 'package:labledger/screens/ui_components/custom_error_dialog.dart';
import 'package:labledger/screens/ui_components/snackbar_utils.dart';

class DoctorMethods extends ChangeNotifier {
  final BuildContext context;
  final WidgetRef ref;

  DoctorMethods(this.context, this.ref);

  // ---------- Doctors List Screen State ----------
  String searchQuery = '';

  void onSearchChanged(String query) {
    searchQuery = query;
    notifyListeners();
  }

  List<Doctor> filterDoctors(List<Doctor> doctors) {
    if (searchQuery.isEmpty) return doctors;

    return doctors.where((doctor) {
      final firstName = (doctor.firstName ?? '')
          .trim()
          .toLowerCase()
          .replaceAll(RegExp(r'\s+'), ' ');
      final lastName = (doctor.lastName ?? '').trim().toLowerCase().replaceAll(
        RegExp(r'\s+'),
        ' ',
      );
      final fullName = '${doctor.firstName ?? ''} ${doctor.lastName ?? ''}'
          .trim()
          .toLowerCase()
          .replaceAll(RegExp(r'\s+'), ' ');
      final hospitalName = (doctor.hospitalName ?? '')
          .trim()
          .toLowerCase()
          .replaceAll(RegExp(r'\s+'), ' ');
      final phoneNumber = (doctor.phoneNumber ?? '')
          .trim()
          .toLowerCase()
          .replaceAll(RegExp(r'\s+'), ' ');

      return firstName.contains(searchQuery) ||
          lastName.contains(searchQuery) ||
          fullName.contains(searchQuery) ||
          hospitalName.contains(searchQuery) ||
          phoneNumber.contains(searchQuery);
    }).toList();
  }

  // ---------- Doctor Edit Screen State ----------
  bool isSaving = false;
  bool isDeleting = false;
  bool isDataInitialized = false;

  void setInitialized() {
    isDataInitialized = true;
    notifyListeners();
  }

  Future<void> handleSave({
    required bool isEditMode,
    required Doctor? originalDoctor,
    required String firstName,
    required String lastName,
    required String hospitalName,
    required String? email,
    required String phoneNumber,
    required String address,
    required List<DoctorCategoryPercentage>? categoryPercentages,
  }) async {
    isSaving = true;
    notifyListeners();

    try {
      if (isEditMode && originalDoctor != null) {
        final updatedDoctor = Doctor(
          id: originalDoctor.id,
          firstName: firstName,
          lastName: lastName,
          hospitalName: hospitalName,
          email: email,
          phoneNumber: phoneNumber,
          address: address,
          categoryPercentages: categoryPercentages,
        );

        await ref.read(updateDoctorProvider(updatedDoctor).future);

        if (context.mounted) {
          showSuccessSnackBar(context, 'Doctor updated successfully!');
        }
      } else {
        final newDoctor = Doctor(
          firstName: firstName,
          lastName: lastName,
          hospitalName: hospitalName,
          email: email,
          phoneNumber: phoneNumber,
          address: address,
          categoryPercentages: categoryPercentages,
        );

        await ref.read(createDoctorProvider(newDoctor).future);

        if (context.mounted) {
          showSuccessSnackBar(context, 'Doctor created successfully!');
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

  Future<void> handleDelete({required Doctor doctor}) async {
    final confirmed = await showDeleteConfirmationDialog(
      context: context,
      borderRadius: 12.0, // defaultRadius
      title: 'Confirm Deletion',
      message:
          'Are you sure you want to delete Dr. ${doctor.firstName} ${doctor.lastName}?\n\nAll bills and records related to this doctor will be permanently deleted. This action cannot be undone.',
    );

    if (confirmed == true) {
      isDeleting = true;
      notifyListeners();
      try {
        await ref.read(deleteDoctorProvider(doctor.id!).future);
        if (context.mounted) {
          showSuccessSnackBar(context, 'Doctor deleted successfully!');
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

  // ---------- Doctor Dashboard Screen Handlers ----------
  Future<void> confirmDeleteDoctor(Doctor doctor) async {
    final shouldDelete = await showDeleteConfirmationDialog(
      context: context,
      title: 'Delete Doctor',
      message:
          'All the records for Dr. ${doctor.firstName} ${doctor.lastName} will be deleted including bills.\nThis action cannot be undone.\nAre you sure?',
    );

    if (shouldDelete == true) {
      try {
        await ref.read(deleteDoctorProvider(doctor.id!).future);
        if (context.mounted) {
          showSuccessSnackBar(context, "Doctor deleted successfully");
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (context.mounted) {
          showErrorDialog('Error deleting doctor', e.toString());
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
