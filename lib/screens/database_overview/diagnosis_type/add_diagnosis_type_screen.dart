import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/main.dart';
import 'package:labledger/methods/custom_methods.dart';
import 'package:labledger/models/diagnosis_type_model.dart';
import 'package:labledger/providers/custom_providers.dart';
import 'package:labledger/providers/diagnosis_type_provider.dart';
import 'package:labledger/screens/home/home_screen_logic.dart';

class AddDiagnosisTypeScreen extends ConsumerWidget {
  AddDiagnosisTypeScreen({super.key, this.diagnosisType}) {
    // initialize controllers if editing
    if (diagnosisType != null) {
      nameController.text = diagnosisType!.name;
      priceController.text = diagnosisType!.price.toString();
      diagnosisTypeController.text = diagnosisType!.category;
    }
  }

  final DiagnosisType? diagnosisType;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController diagnosisTypeController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey();

  final List<String> diagnosisTypeCategories = [
    "Ultrasound",
    "Pathology",
    "ECG",
    "X-Ray",
    "Franchise Lab",
  ];

  // ADD NEW
  Future<void> addDiagnosisType(
    DiagnosisType newDiagnosisType,
    WidgetRef ref,
  ) async {
    try {
      final created = await ref.read(
        addDiagnosisTypeProvider(newDiagnosisType).future,
      );
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(
            navigatorKey.currentContext!,
          ).colorScheme.secondary,

          content: Text("Diagnosis Type created successfully"),
        ),
      );
      Navigator.pop(navigatorKey.currentContext!, created);
    } catch (e) {
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(
            navigatorKey.currentContext!,
          ).colorScheme.error,
          content: Text("Failed to create Diagnosis Type: $e"),
        ),
      );
    }
  }

  // UPDATE
  Future<void> updateDiagnosisTypeDetails(
    int? id,
    DiagnosisType updatedDiagnosisType,
    WidgetRef ref,
  ) async {
    if (id == null) return;
    try {
      final updated = await ref.read(
        updateDiagnosisTypeProvider({
          'id': id,
          'data': updatedDiagnosisType.toJson(),
        }).future,
      );
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(
            navigatorKey.currentContext!,
          ).colorScheme.secondary,
          content: Text("Diagnosis Type updated successfully"),
        ),
      );
      Navigator.pop(navigatorKey.currentContext!, updated);
    } catch (e) {
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(
            navigatorKey.currentContext!,
          ).colorScheme.error,

          content: Text("Failed to update Diagnosis Type: $e"),
        ),
      );
    }
  }

  // DELETE
  Future<void> deleteDiagnosisType(int id, WidgetRef ref) async {
    try {
      await ref.read(deleteDiagnosisTypeProvider(id).future);
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(
            navigatorKey.currentContext!,
          ).colorScheme.error,

          content: Text("Diagnosis Type deleted successfully"),
        ),
      );
      Navigator.pop(navigatorKey.currentContext!);
    } catch (e) {
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(
            navigatorKey.currentContext!,
          ).colorScheme.error,

          content: Text("Failed to delete Diagnosis Type: $e"),
        ),
      );
    }
  }

  void _submitForm(WidgetRef ref) {
    if (diagnosisTypeController.text.isEmpty) {
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(
            navigatorKey.currentContext!,
          ).colorScheme.error,

          content: Text("Please select a category"),
        ),
      );
      return;
    }

    DiagnosisType newDiagnosisType = DiagnosisType(
      name: nameController.text,
      category: diagnosisTypeController.text,
      price: int.parse(priceController.text),
    );

    if (diagnosisType == null) {
      addDiagnosisType(newDiagnosisType, ref);
    } else {
      updateDiagnosisTypeDetails(diagnosisType!.id, newDiagnosisType, ref);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: CustomCardContainer(
        xHeight: 0.5,
        xWidth: 0.5,
        child: Form(
          key: _formKey,
          child: IntrinsicHeight(
            child: Column(
              children: [
                pageHeader(context: context, centerWidget: null),

                customTextField(
                  label: "Name",
                  context: context,
                  controller: nameController,
                ),
                SizedBox(height: defaultHeight),

                // Category Dropdown (binded with controller)
                CustomDropDown<String>(
                  context: context,
                  dropDownList: diagnosisTypeCategories,
                  textController: diagnosisTypeController,
                  valueMapper: (e) => e,
                  idMapper: (e) => e,
                  textStyle: TextStyle(
                    fontSize: 20,
                    color: ThemeData.dark().scaffoldBackgroundColor,
                    fontFamily: "GoogleSans",
                  ),
                  hintText: "Select Category",
                ),
                SizedBox(height: defaultHeight),

                customTextField(
                  label: "Amount",
                  context: context,
                  controller: priceController,
                  keyboardType: TextInputType.number,
                ),

                const Spacer(),

                if (diagnosisType != null)
                  Column(
                    children: [
                      InkWell(
                        onTap: () {
                          if (_formKey.currentState!.validate()) {
                            deleteDiagnosisType(diagnosisType!.id!, ref);
                          }
                        },
                        child: Container(
                          height: 50,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.red[400],
                            borderRadius: BorderRadius.circular(defaultRadius),
                          ),
                          child: Center(
                            child: Text(
                              "Delete",
                              style: Theme.of(context).textTheme.headlineMedium!
                                  .copyWith(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),

                InkWell(
                  onTap: () {
                    if (_formKey.currentState!.validate()) {
                      _submitForm(ref);
                    }
                  },
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(defaultRadius),
                    ),
                    child: Center(
                      child: Text(
                        diagnosisType == null ? "Add" : "Update",
                        style: Theme.of(context).textTheme.headlineMedium!
                            .copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
