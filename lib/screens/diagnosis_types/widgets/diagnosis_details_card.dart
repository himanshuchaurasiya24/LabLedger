import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/models/diagnosis_type_model.dart';
import 'package:labledger/models/doctors_model.dart';
import 'package:labledger/models/franchise_model.dart';
import 'package:labledger/screens/bills/widgets/error_field.dart';
import 'package:labledger/screens/bills/widgets/loading_field.dart';
import 'package:labledger/screens/ui_components/card_header.dart';
import 'package:labledger/screens/ui_components/searchable_dropdown_field.dart';
import 'package:labledger/screens/ui_components/tinted_container.dart';

class DiagnosisDetailsCard extends StatelessWidget {
  final Color defaultColor;
  final double? height;
  final AsyncValue<List<DiagnosisType>> diagnosisTypesAsync;
  final AsyncValue<List<FranchiseName>> franchiseNamesAsync;
  final AsyncValue<List<Doctor>> doctorsAsync;
  final List<DiagnosisType> selectedDiagnosisTypes;
  final bool isEditMode;
  final bool isDataInitialized;
  final TextEditingController diagnosisTypeDisplayController;
  final TextEditingController diagnosisTypeSearchController;
  final TextEditingController franchiseNameDisplayController;
  final TextEditingController refByDoctorDisplayController;
  final Function(DiagnosisType) onDiagnosisTypeRemoved;
  final Function(DiagnosisType) onDiagnosisTypeSelected;
  final Function(FranchiseName) onFranchiseSelected;
  final Function(Doctor) onDoctorSelected;
  final Function(List<DiagnosisType>, List<FranchiseName>, List<Doctor>)
      onUpdateDisplayControllers;

  const DiagnosisDetailsCard({
    super.key,
    required this.defaultColor,
    this.height,
    required this.diagnosisTypesAsync,
    required this.franchiseNamesAsync,
    required this.doctorsAsync,
    required this.selectedDiagnosisTypes,
    required this.isEditMode,
    required this.isDataInitialized,
    required this.diagnosisTypeDisplayController,
    required this.diagnosisTypeSearchController,
    required this.franchiseNameDisplayController,
    required this.refByDoctorDisplayController,
    required this.onDiagnosisTypeRemoved,
    required this.onDiagnosisTypeSelected,
    required this.onFranchiseSelected,
    required this.onDoctorSelected,
    required this.onUpdateDisplayControllers,
  });

  @override
  Widget build(BuildContext context) {
    return TintedContainer(
      baseColor: defaultColor,
      height: height ?? 318,
      radius: defaultRadius,
      elevationLevel: 1,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          children: [
            CardHeader(
              icon: Icons.medical_services_outlined,
              title: 'Diagnosis Details',
              color: defaultColor,
            ),
            SizedBox(height: defaultHeight),
            diagnosisTypesAsync.when(
              data: (types) {
                if (doctorsAsync.hasValue &&
                    franchiseNamesAsync.hasValue &&
                    isEditMode &&
                    isDataInitialized &&
                    diagnosisTypeDisplayController.text.isEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    onUpdateDisplayControllers(
                      types,
                      franchiseNamesAsync.value!,
                      doctorsAsync.value!,
                    );
                  });
                }
                return Column(
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: selectedDiagnosisTypes.map((dt) {
                        return Chip(
                          label: Text(
                            '${dt.categoryName ?? "Unknown"} ${dt.name} (₹${dt.price})',
                            style: const TextStyle(fontSize: 12),
                          ),
                          backgroundColor: defaultColor.withValues(alpha: 0.1),
                          deleteIconColor: defaultColor,
                          onDeleted: () => onDiagnosisTypeRemoved(dt),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: defaultHeight / 2),
                    SearchableDropdownField<DiagnosisType>(
                      label: 'Add Diagnosis Type',
                      controller: diagnosisTypeSearchController,
                      items: types,
                      color: defaultColor,
                      valueMapper: (item) =>
                          '${item.categoryName ?? "Unknown"} ${item.name}, ₹${item.price}',
                      onSelected: onDiagnosisTypeSelected,
                      validator: (v) => selectedDiagnosisTypes.isEmpty
                          ? 'At least one diagnosis type is required'
                          : null,
                    ),
                  ],
                );
              },
              loading: () => const LoadingField(),
              error: (e, s) =>
                  const ErrorField(message: 'Error loading diagnosis types'),
            ),
            SizedBox(height: defaultHeight),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              child: selectedDiagnosisTypes.any(
                (dt) => dt.categoryName?.toLowerCase() == 'franchise lab',
              )
                  ? Padding(
                      padding: EdgeInsets.only(bottom: defaultPadding),
                      child: franchiseNamesAsync.when(
                        data: (franchises) =>
                            SearchableDropdownField<FranchiseName>(
                          label: 'Franchise Name',
                          controller: franchiseNameDisplayController,
                          items: franchises,
                          color: defaultColor,
                          valueMapper: (item) =>
                              "${item.franchiseName}, ${item.address}",
                          onSelected: onFranchiseSelected,
                          validator: (v) =>
                              v!.isEmpty ? 'Franchise is required' : null,
                        ),
                        loading: () => const LoadingField(),
                        error: (e, s) =>
                            const ErrorField(message: 'Error loading franchises'),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            doctorsAsync.when(
              data: (doctors) => SearchableDropdownField<Doctor>(
                label: 'Referred By Doctor',
                controller: refByDoctorDisplayController,
                items: doctors,
                color: defaultColor,
                valueMapper: (item) =>
                    '${item.firstName} ${item.lastName ?? ''}, ${item.address ?? ""}',
                onSelected: onDoctorSelected,
                validator: (v) =>
                    v!.isEmpty ? 'Referring doctor is required' : null,
              ),
              loading: () => const LoadingField(),
              error: (e, s) => const ErrorField(message: 'Error loading doctors'),
            ),
          ],
        ),
      ),
    );
  }
}
