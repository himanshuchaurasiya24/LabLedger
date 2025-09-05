import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/main.dart';
import 'package:labledger/methods/custom_methods.dart';
import 'package:labledger/models/franchise_model.dart';
import 'package:labledger/providers/franchise_provider.dart';
import 'package:labledger/screens/home/home_screen_logic.dart';

class AddFranchiseNameScreen extends ConsumerWidget {
  AddFranchiseNameScreen({super.key, this.franchiseName}) {
    // initialize controllers if editing
    if (franchiseName != null) {
      nameController.text = franchiseName!.franchiseName!;
      addressController.text = franchiseName!.address!;
      phoneController.text = franchiseName!.phoneNumber!;
    }
  }

  final FranchiseName? franchiseName;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey();

  // ADD NEW
  Future<void> addFranchiseName(FranchiseName newFranchiseName, WidgetRef ref) async {
    try {
      final created = await ref.read(
        createFranchiseProvider(newFranchiseName).future,
      );
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        const SnackBar(content: Text("FranchiseName created successfully")),
      );
      Navigator.pop(navigatorKey.currentContext!, created);
    } catch (e) {
      ScaffoldMessenger.of(
        navigatorKey.currentContext!,
      ).showSnackBar(SnackBar(content: Text("Failed to create FranchiseName: $e")));
    }
  }

  // UPDATE
  Future<void> updateFranchiseNameDetails(
    int? id,
    FranchiseName updatedFranchiseName,
    WidgetRef ref,
  ) async {
    if (id == null) return;
    try {
      final updated = await ref.read(
        updateFranchiseProvider({
          'id': id,
          'data': updatedFranchiseName.toJson(),
        }).future,
      );
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        const SnackBar(content: Text("FranchiseName updated successfully")),
      );
      Navigator.pop(navigatorKey.currentContext!, updated);
    } catch (e) {
      ScaffoldMessenger.of(
        navigatorKey.currentContext!,
      ).showSnackBar(SnackBar(content: Text("Failed to update FranchiseName: $e")));
    }
  }

  // DELETE
  Future<void> deleteFranchiseName(int id, WidgetRef ref) async {
    try {
      await ref.read(deleteFranchiseProvider(id).future);
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        const SnackBar(content: Text("FranchiseName deleted successfully")),
      );
      Navigator.pop(navigatorKey.currentContext!);
    } catch (e) {
      ScaffoldMessenger.of(
        navigatorKey.currentContext!,
      ).showSnackBar(SnackBar(content: Text("Failed to delete FranchiseName: $e")));
    }
  }

  void _submitForm(WidgetRef ref) {
    FranchiseName newFranchiseName = FranchiseName(
      id: 0,
      franchiseName: nameController.text,
      address: addressController.text,
      phoneNumber: phoneController.text,
      
    );

    if (franchiseName == null) {
      addFranchiseName(newFranchiseName, ref);
    } else {
      updateFranchiseNameDetails(franchiseName!.id, newFranchiseName, ref);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: CustomCardContainer(
        xHeight: 0.6,
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

                customTextField(
                  label: "Address",
                  context: context,
                  controller: addressController,
                ),
                SizedBox(height: defaultHeight),

                customTextField(
                  label: "Phone Number",
                  context: context,
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                ),
                const Spacer(),

                if (franchiseName != null)
                  Column(
                    children: [
                      InkWell(
                        onTap: () {
                          if (_formKey.currentState!.validate()) {
                            deleteFranchiseName(franchiseName!.id!, ref);
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
                        franchiseName == null ? "Add" : "Update",
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
