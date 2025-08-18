import 'package:flutter/material.dart';
import 'package:labledger/methods/custom_methods.dart';
import 'package:labledger/models/doctors_model.dart';
import 'package:labledger/providers/custom_providers.dart';
import 'package:labledger/screens/home/home_screen_logic.dart';

class AddDoctorScreen extends StatelessWidget {
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
  @override
  Widget build(BuildContext context) {
    updateDoctor();
    return Scaffold(
      body: Center(
        child: Container(
          height: MediaQuery.of(context).size.height * 0.5,
          width: MediaQuery.of(context).size.width * 0.5,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.tertiaryFixed,
            borderRadius: BorderRadius.circular(defaultPadding / 2),
          ),
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
                        SizedBox(width: defaultPadding / 2),
                        Expanded(
                          child: customTextField(
                            label: "Last Name",
                            context: context,
                            controller: lastNameController,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: defaultPadding / 2),

                    Row(
                      children: [
                        Expanded(
                          child: customTextField(
                            label: "Email",
                            context: context,
                            controller: emailController,
                          ),
                        ),
                        SizedBox(width: defaultPadding / 2),

                        Expanded(
                          child: customTextField(
                            label: "username",
                            context: context,
                            controller: phoneNumberController,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: defaultPadding / 2),

                    Row(
                      children: [
                        Expanded(
                          child: customTextField(
                            label: "Address",
                            context: context,
                            controller: addressController,
                          ),
                        ),
                        SizedBox(width: defaultPadding / 2),

                        Expanded(
                          child: customTextField(
                            label: "Hospital Name",
                            context: context,
                            controller: hospitalNameController,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: defaultPadding / 2),

                    Row(
                      children: [
                        Expanded(
                          child: customTextField(
                            label: "USG %",
                            context: context,
                            controller: usgController,
                          ),
                        ),
                        SizedBox(width: defaultPadding / 2),

                        Expanded(
                          child: customTextField(
                            label: "Pathology %",
                            context: context,
                            controller: pathController,
                          ),
                        ),
                        SizedBox(width: defaultPadding / 2),

                        Expanded(
                          child: customTextField(
                            label: "ECG %",
                            context: context,
                            controller: ecgController,
                          ),
                        ),
                        SizedBox(width: defaultPadding / 2),

                        Expanded(
                          child: customTextField(
                            label: "XRay %",
                            context: context,
                            controller: xrayController,
                          ),
                        ),
                        SizedBox(width: defaultPadding / 2),

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
                    InkWell(
                      onTap: () {
                        if (_formKey.currentState!.validate()) {
                          // _submitForm();
                        }
                      },
                      child: Container(
                        height: 50,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(
                            defaultPadding / 2,
                          ),
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
      ),
    );
  }
}
