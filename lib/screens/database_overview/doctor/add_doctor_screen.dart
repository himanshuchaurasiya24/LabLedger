import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/main.dart';
import 'package:labledger/methods/custom_methods.dart';
import 'package:labledger/models/doctors_model.dart';
import 'package:labledger/providers/doctor_provider.dart';
import 'package:labledger/screens/home/home_screen_logic.dart';

class AddDoctorScreen extends ConsumerWidget {
  AddDoctorScreen({super.key, this.doctor});
  final Doctor? doctor;
  void updateDoctor() {
    if (doctor != null) {
      firstNameController.text = doctor!.firstName!;
      lastNameController.text = doctor!.lastName!;
      phoneNumberController.text = doctor!.phoneNumber!;
      addressController.text = doctor!.address!;
      usgController.text = doctor!.ultrasoundPercentage.toString();
      pathController.text = doctor!.pathologyPercentage.toString();
      xrayController.text = doctor!.xrayPercentage.toString();
      ecgController.text = doctor!.ecgPercentage.toString();
      franchiseLabController.text = doctor!.franchiseLabPercentage.toString();
      hospitalNameController.text = doctor!.hospitalName!;
      emailController.text = doctor!.email!;
    } else {
      // Logic to add a new doctor
    }
  }

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController usgController = TextEditingController();
  final TextEditingController pathController = TextEditingController();
  final TextEditingController xrayController = TextEditingController();
  final TextEditingController ecgController = TextEditingController();
  final TextEditingController franchiseLabController = TextEditingController();
  final TextEditingController hospitalNameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey();

  // ADD NEW DOCTOR
  Future<void> addDoctor(
    Doctor newDoctor,
    WidgetRef ref,
    BuildContext context,
  ) async {
    try {
      final createdDoctor = await ref.read(
        createDoctorProvider(newDoctor).future,
      );
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        const SnackBar(content: Text("Doctor created successfully")),
      );
      Navigator.pop(
        navigatorKey.currentContext!,
        createdDoctor,
      ); // 👈 return created doctor if needed
    } catch (e) {
      ScaffoldMessenger.of(
        navigatorKey.currentContext!,
      ).showSnackBar(SnackBar(content: Text("Failed to create doctor: $e")));
    }
  }

  // UPDATE EXISTING DOCTOR
  Future<void> updateDoctorDetails(
    int? id,
    Doctor updatedDoctor,
    WidgetRef ref,
    BuildContext context,
  ) async {
    if (id == null) return;
    try {
      final updated = await ref.read(
        updateDoctorProvider({
          'id': id,
          'data': updatedDoctor.toJson(), // 👈 send data
        }).future,
      );

      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        const SnackBar(content: Text("Doctor updated successfully")),
      );
      Navigator.pop(
        navigatorKey.currentContext!,
        updated,
      ); // 👈 return updated doctor if needed
    } catch (e) {
      ScaffoldMessenger.of(
        navigatorKey.currentContext!,
      ).showSnackBar(SnackBar(content: Text("Failed to update doctor: $e")));
    }
  }

  // DELETE DOCTOR
  Future<void> deleteDoctor(int id, WidgetRef ref, BuildContext context) async {
    try {
      await ref.read(deleteDoctorProvider(id).future);
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        const SnackBar(content: Text("Doctor deleted successfully")),
      );
      Navigator.pop(navigatorKey.currentContext!); // 👈 go back after deletion
    } catch (e) {
      ScaffoldMessenger.of(
        navigatorKey.currentContext!,
      ).showSnackBar(SnackBar(content: Text("Failed to delete doctor: $e")));
    }
  }

  void _submitForm(WidgetRef ref) {
    Doctor newDoctor = Doctor(
      firstName: firstNameController.text,
      lastName: lastNameController.text,
      phoneNumber: phoneNumberController.text,
      email: emailController.text,
      address: addressController.text,
      ultrasoundPercentage: int.parse(usgController.text),
      pathologyPercentage: int.parse(pathController.text),
      xrayPercentage: int.parse(xrayController.text),
      ecgPercentage: int.parse(ecgController.text),
      franchiseLabPercentage: int.parse(franchiseLabController.text),
      hospitalName: hospitalNameController.text,
    );

    if (doctor == null) {
      addDoctor(newDoctor, ref, navigatorKey.currentContext!);
    } else {
      updateDoctorDetails(
        doctor!.id,
        newDoctor,
        ref,
        navigatorKey.currentContext!,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    updateDoctor();
    return Scaffold(
      body: CustomCardContainer(
        xHeight: 0.5,
        xWidth: 0.5,
        child: Padding(
          padding: EdgeInsets.only(
            left: defaultPadding / 2,
            right: defaultPadding / 2,
            bottom: defaultPadding / 2,
          ),
          child: Form(
            key: _formKey,
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  pageHeader(context: context, centerWidget: null),

                  Row(
                    children: [
                      Expanded(
                        child: customTextField(
                          label: "First Name",
                          context: context,
                          controller: firstNameController,
                        ),
                      ),
                      SizedBox(width: defaultWidth),
                      Expanded(
                        child: customTextField(
                          label: "Last Name",
                          context: context,
                          controller: lastNameController,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: defaultHeight),

                  Row(
                    children: [
                      Expanded(
                        child: customTextField(
                          label: "Email",
                          context: context,
                          controller: emailController,
                        ),
                      ),
                      SizedBox(width: defaultWidth),

                      Expanded(
                        child: customTextField(
                          label: "Phone Number",
                          context: context,
                          controller: phoneNumberController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: defaultHeight),

                  Row(
                    children: [
                      Expanded(
                        child: customTextField(
                          label: "Address",
                          context: context,
                          controller: addressController,
                        ),
                      ),
                      SizedBox(width: defaultWidth),

                      Expanded(
                        child: customTextField(
                          label: "Hospital Name",
                          context: context,
                          controller: hospitalNameController,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: defaultHeight),
                  Row(
                    children: [
                      Expanded(
                        child: customTextField(
                          label: "USG %",
                          context: context,
                          controller: usgController,
                        ),
                      ),
                      SizedBox(width: defaultWidth),

                      Expanded(
                        child: customTextField(
                          label: "Pathology %",
                          context: context,
                          controller: pathController,
                        ),
                      ),
                      SizedBox(width: defaultWidth),

                      Expanded(
                        child: customTextField(
                          label: "ECG %",
                          context: context,
                          controller: ecgController,
                        ),
                      ),
                      SizedBox(width: defaultWidth),

                      Expanded(
                        child: customTextField(
                          label: "XRay %",
                          context: context,
                          controller: xrayController,
                        ),
                      ),
                      SizedBox(width: defaultWidth),

                      Expanded(
                        child: customTextField(
                          label: "Franchise Lab %",
                          context: context,
                          controller: franchiseLabController,
                        ),
                      ),
                    ],
                  ),

                  Spacer(),
                  doctor == null
                      ? const SizedBox()
                      : Column(
                          children: [
                            InkWell(
                              onTap: () {
                                if (_formKey.currentState!.validate()) {
                                  deleteDoctor(doctor!.id!, ref, context);
                                }
                              },
                              child: Container(
                                height: 50,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.red[400],
                                  borderRadius: BorderRadius.circular(
                                    defaultRadius,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    "Delete Doctor",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium!
                                        .copyWith(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
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
                          doctor == null ? "Add Doctor" : "Update",
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
      ),
    );
  }
}
