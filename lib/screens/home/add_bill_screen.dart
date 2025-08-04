import 'package:flutter/material.dart';
import 'package:labledger/methods/custom_methods.dart';
import 'package:labledger/providers/custom_providers.dart';
import 'package:labledger/screens/home/home_screen_logic.dart';

class AddBillScreen extends StatefulWidget {
  const AddBillScreen({super.key});

  @override
  State<AddBillScreen> createState() => _AddBillScreenState();
}

class _AddBillScreenState extends State<AddBillScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController patientNameController = TextEditingController();
  TextEditingController patientAgeController = TextEditingController();
  TextEditingController patientSexController = TextEditingController();
  TextEditingController paidAmountController = TextEditingController();
  TextEditingController discByCenterController = TextEditingController();
  TextEditingController discByDoctorController = TextEditingController();
  TextEditingController billStatusController = TextEditingController();
  TextEditingController franchiseNameController = TextEditingController();
  TextEditingController refByDoctorController = TextEditingController();
  TextEditingController diagnosisTypeController = TextEditingController();
  TextEditingController dateOfTestController = TextEditingController();
  TextEditingController dateOfBillController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          height: MediaQuery.of(context).size.height * 0.9,
          width: MediaQuery.of(context).size.width * 0.86,
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.tertiaryFixed.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(defaultPadding / 2),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: defaultPadding / 2),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      appIconName(
                        context: context,
                        firstName: "Lab",
                        secondName: "Ledger",
                        fontSize: 50,
                      ),
                      Text(
                        "Add New Bill                          ",
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.red[400],
                          borderRadius: BorderRadius.circular(
                            defaultPadding / 2,
                          ),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.close,
                            color: Theme.of(
                              context,
                            ).colorScheme.tertiaryFixed.withValues(alpha: 0.9),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: customTextField(
                          label: "Patient Name",
                          controller: patientNameController,
                        ),
                      ),
                    ],
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
