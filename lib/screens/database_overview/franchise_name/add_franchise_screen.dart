import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/main.dart';
import 'package:labledger/methods/custom_methods.dart';
import 'package:labledger/models/franchise_model.dart';
import 'package:labledger/providers/franchise_provider.dart';
import 'package:labledger/screens/home/home_screen_logic.dart';

class AddFranchiseScreen extends ConsumerWidget {
  AddFranchiseScreen({super.key, this.franchise}) {
    // initialize controllers if editing
    if (franchise != null) {
      nameController.text = franchise!.franchiseName;
      addressController.text = franchise!.address;
      phoneController.text = franchise!.phoneNumber;
    }
  }

  final Franchise? franchise;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey();

  // ADD NEW
  Future<void> addFranchise(Franchise newFranchise, WidgetRef ref) async {
    try {
      final created = await ref.read(
        createFranchiseProvider(newFranchise).future,
      );
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        const SnackBar(content: Text("Franchise created successfully")),
      );
      Navigator.pop(navigatorKey.currentContext!, created);
    } catch (e) {
      ScaffoldMessenger.of(
        navigatorKey.currentContext!,
      ).showSnackBar(SnackBar(content: Text("Failed to create Franchise: $e")));
    }
  }

  // UPDATE
  Future<void> updateFranchiseDetails(
    int? id,
    Franchise updatedFranchise,
    WidgetRef ref,
  ) async {
    if (id == null) return;
    try {
      final updated = await ref.read(
        updateFranchiseProvider({
          'id': id,
          'data': updatedFranchise.toJson(),
        }).future,
      );
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        const SnackBar(content: Text("Franchise updated successfully")),
      );
      Navigator.pop(navigatorKey.currentContext!, updated);
    } catch (e) {
      ScaffoldMessenger.of(
        navigatorKey.currentContext!,
      ).showSnackBar(SnackBar(content: Text("Failed to update Franchise: $e")));
    }
  }

  // DELETE
  Future<void> deleteFranchise(int id, WidgetRef ref) async {
    try {
      await ref.read(deleteFranchiseProvider(id).future);
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        const SnackBar(content: Text("Franchise deleted successfully")),
      );
      Navigator.pop(navigatorKey.currentContext!);
    } catch (e) {
      ScaffoldMessenger.of(
        navigatorKey.currentContext!,
      ).showSnackBar(SnackBar(content: Text("Failed to delete Franchise: $e")));
    }
  }

  void _submitForm(WidgetRef ref) {
    Franchise newFranchise = Franchise(
      franchiseName: nameController.text,
      address: addressController.text,
      phoneNumber: phoneController.text,
    );

    if (franchise == null) {
      addFranchise(newFranchise, ref);
    } else {
      updateFranchiseDetails(franchise!.id, newFranchise, ref);
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

                if (franchise != null)
                  Column(
                    children: [
                      InkWell(
                        onTap: () {
                          if (_formKey.currentState!.validate()) {
                            deleteFranchise(franchise!.id!, ref);
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
                        franchise == null ? "Add" : "Update",
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
