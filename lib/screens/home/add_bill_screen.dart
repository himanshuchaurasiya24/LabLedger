import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/methods/custom_methods.dart';
import 'package:labledger/models/diagnosis_type_model.dart';
import 'package:labledger/providers/custom_providers.dart';
import 'package:labledger/providers/diagnosis_type_provider.dart';
import 'package:labledger/screens/home/home_screen_logic.dart';

class AddBillScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? billData; // <-- Add this for Edit Mode

  const AddBillScreen({super.key, this.billData});

  @override
  ConsumerState<AddBillScreen> createState() => _AddBillScreenState();
}

class _AddBillScreenState extends ConsumerState<AddBillScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController patientNameController = TextEditingController();
  final TextEditingController patientAgeController = TextEditingController();
  final TextEditingController patientSexController = TextEditingController();
  final TextEditingController paidAmountController = TextEditingController();
  final TextEditingController discByCenterController = TextEditingController();
  final TextEditingController discByDoctorController = TextEditingController();
  final TextEditingController billStatusController = TextEditingController();
  final TextEditingController franchiseNameController = TextEditingController();
  final TextEditingController refByDoctorController = TextEditingController();
  final TextEditingController diagnosisTypeController = TextEditingController();
  final TextEditingController dateOfTestController = TextEditingController();
  final TextEditingController dateOfBillController = TextEditingController();

  final List<String> sexDropDownList = ["Male", "Female", "Others"];

  @override
  void initState() {
    super.initState();
    if (widget.billData != null) {
      // Prefill controllers if editing
      patientNameController.text = widget.billData!['patientName'] ?? '';
      patientAgeController.text = widget.billData!['patientAge'] ?? '';
      patientSexController.text = widget.billData!['patientSex'] ?? '';
      paidAmountController.text = widget.billData!['paidAmount'] ?? '';
      discByCenterController.text = widget.billData!['discByCenter'] ?? '';
      discByDoctorController.text = widget.billData!['discByDoctor'] ?? '';
      billStatusController.text = widget.billData!['billStatus'] ?? '';
      franchiseNameController.text = widget.billData!['franchiseName'] ?? '';
      refByDoctorController.text = widget.billData!['refByDoctor'] ?? '';
      diagnosisTypeController.text =
          widget.billData!['diagnosisTypeId']?.toString() ?? '';
      dateOfTestController.text = widget.billData!['dateOfTest'] ?? '';
      dateOfBillController.text = widget.billData!['dateOfBill'] ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final diagnosisTypeAsync = ref.watch(diagnosisTypeProvider);

    return Scaffold(
      body: Center(
        child: Container(
          height: MediaQuery.of(context).size.height * 0.9,
          width: MediaQuery.of(context).size.width * 0.4,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.tertiaryFixed,
            borderRadius: BorderRadius.circular(defaultPadding / 2),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: defaultPadding / 2),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 10),
                  customTextField(
                    context: context,
                    label: "Patient Name",
                    controller: patientNameController,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: CustomDropDown<String>(
                          context: context,
                          dropDownList: sexDropDownList,
                          textController: patientSexController,
                          valueMapper: (item) => item,
                          idMapper: (item) => item,
                          hintText: "Select Sex",
                        ),
                      ),
                      SizedBox(width: defaultPadding / 2),
                      Expanded(
                        child: customTextField(
                          label: "Age",
                          context: context,
                          keyboardType: TextInputType.number,
                          controller: patientAgeController,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  diagnosisTypeAsync.when(
                    data: (diagnosisTypes) {
                      if (diagnosisTypes.isEmpty) {
                        return Text("No Diagnosis Types Available");
                      }

                      // Sort Diagnosis Types by category (A-Z)
                      diagnosisTypes.sort(
                        (a, b) => a.category.compareTo(b.category),
                      );

                      // Preselect DiagnosisTypeController Value if Empty
                      if (diagnosisTypeController.text.isEmpty &&
                          widget.billData != null) {
                        final existingDiagnosisType = diagnosisTypes.firstWhere(
                          (item) =>
                              item.id.toString() ==
                              widget.billData!['diagnosisTypeId']?.toString(),
                          orElse: () => diagnosisTypes[0],
                        );
                        diagnosisTypeController.text = existingDiagnosisType.id
                            .toString();
                      }

                      return CustomDropDown<DiagnosisType>(
                        context: context,
                        dropDownList: diagnosisTypes,
                        textController: diagnosisTypeController,
                        valueMapper: (item) => item.name,
                        idMapper: (item) => item.id.toString(),
                        hintText: "Select Diagnosis Type",
                      );
                    },
                    loading: () => const CircularProgressIndicator(),
                    error: (err, stack) => Text('Error: $err'),
                  ),

                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saveBill,
                    child: Text(
                      widget.billData != null ? "Update Bill" : "Add Bill",
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

  Row _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        appIconName(
          context: context,
          firstName: "Lab",
          secondName: "Ledger",
          fontSize: 45,
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.red[400],
            borderRadius: BorderRadius.circular(defaultPadding / 2),
          ),
          child: IconButton(
            icon: Icon(
              Icons.close,
              color: Theme.of(context).colorScheme.tertiaryFixed,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
      ],
    );
  }

  void _saveBill() {
    if (_formKey.currentState!.validate()) {
      final billData = {
        'patientName': patientNameController.text,
        'patientAge': patientAgeController.text,
        'patientSex': patientSexController.text,
        'paidAmount': paidAmountController.text,
        'discByCenter': discByCenterController.text,
        'discByDoctor': discByDoctorController.text,
        'billStatus': billStatusController.text,
        'franchiseName': franchiseNameController.text,
        'refByDoctor': refByDoctorController.text,
        'diagnosisTypeId': diagnosisTypeController.text,
        'dateOfTest': dateOfTestController.text,
        'dateOfBill': dateOfBillController.text,
      };

      if (widget.billData != null) {
        // Update existing bill
        print("Updating Bill: $billData");
        // Call Update API here
      } else {
        // Add new bill
        print("Adding New Bill: $billData");
        // Call Add API here
      }

      Navigator.of(context).pop(); // Close the screen after save
    }
  }
}
