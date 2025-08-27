import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/methods/custom_methods.dart';
import 'package:labledger/models/bill_model.dart';
import 'package:labledger/models/diagnosis_type_model.dart';
import 'package:labledger/models/doctors_model.dart';
import 'package:labledger/providers/bills_provider.dart';
import 'package:labledger/providers/custom_providers.dart';
import 'package:labledger/providers/diagnosis_type_provider.dart';
import 'package:labledger/providers/doctor_provider.dart';
import 'package:labledger/providers/franchise_provider.dart';
import 'package:labledger/screens/home/home_screen_logic.dart';

class AddBillScreen extends ConsumerStatefulWidget {
  final Bill? billData; // <-- Add this for Edit Mode

  const AddBillScreen({super.key, this.billData});

  @override
  ConsumerState<AddBillScreen> createState() => _AddBillScreenState();
}

class _AddBillScreenState extends ConsumerState<AddBillScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  DiagnosisType? selectedDiagnosisType;
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
  final List<String> billStatusList = [
    "Fully Paid",
    "Partially Paid",
    "Unpaid",
  ];
  String selectedTestDateISO = DateTime.now()
      .toIso8601String(); // <-- for API submission
  String selectedBillDateISO = DateTime.now()
      .toIso8601String(); // <-- for API submission
  void datePicker({
    required TextEditingController dateController,
    required ValueChanged<String> onDateSelected,
  }) async {
    final rawDate = await showDatePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );

    if (rawDate != null) {
      final DateTime fullDateTime = DateTime(
        rawDate.year,
        rawDate.month,
        rawDate.day,
        DateTime.now().hour,
        DateTime.now().minute,
        DateTime.now().second,
      );
      final String displayDate =
          "${rawDate.day.toString().padLeft(2, '0')}-"
          "${rawDate.month.toString().padLeft(2, '0')}-"
          "${rawDate.year}";

      setState(() {
        dateController.text = displayDate;
      });
      onDateSelected(fullDateTime.toIso8601String()); // <-- Pass back to parent
    }
  }

  @override
  void initState() {
    super.initState();
    diagnosisTypeController.addListener(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    });
    billStatusController.addListener(() {
      setState(() {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() {});
        });
      });
    });

    if (widget.billData != null) {
      patientNameController.text = widget.billData!.patientName;
      patientAgeController.text = widget.billData!.patientAge.toString();
      patientSexController.text = widget.billData!.patientSex;
      paidAmountController.text = widget.billData!.paidAmount.toString();
      discByCenterController.text = widget.billData!.discByCenter.toString();
      discByDoctorController.text = widget.billData!.discByDoctor.toString();
      billStatusController.text = widget.billData!.billStatus;
      franchiseNameController.text = widget.billData!.franchiseName??"";
      refByDoctorController.text = widget.billData!.referredByDoctor.toString();
      diagnosisTypeController.text = widget.billData!.diagnosisType.toString();
      dateOfTestController.text = widget.billData!.dateOfTest.toString();
      dateOfBillController.text = widget.billData!.dateOfBill.toString();
    }
  }

  @override
  void dispose() {
    // Remove listeners
    diagnosisTypeController.removeListener(() {
      //
    });
    billStatusController.removeListener(() {});
    // Dispose controllers
    patientNameController.dispose();
    patientAgeController.dispose();
    patientSexController.dispose();
    paidAmountController.dispose();
    discByCenterController.dispose();
    discByDoctorController.dispose();
    billStatusController.dispose();
    franchiseNameController.dispose();
    refByDoctorController.dispose();
    diagnosisTypeController.dispose();
    dateOfTestController.dispose();
    dateOfBillController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final diagnosisTypeAsync = ref.watch(diagnosisTypeProvider);
    final franchiseNamesAsync = ref.watch(franchiseNamesProvider);
    final doctorAsync = ref.watch(doctorsProvider);
    return Scaffold(
      body: CustomCardContainer(
        xHeight: 0.95,
        xWidth: 0.5,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              pageHeader(context: context, centerWidget: null),
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
                  SizedBox(width: defaultWidth),
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
              Text(
                "Select Diagnosis Type",
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              diagnosisTypeAsync.when(
                data: (diagnosisTypes) {
                  if (diagnosisTypes.isEmpty) {
                    return Text("No Diagnosis Types Available");
                  }
                  diagnosisTypes.sort(
                    (a, b) => a.category.compareTo(b.category),
                  );
                  // Update selectedDiagnosisType based on controller's current value
                  selectedDiagnosisType = diagnosisTypes.firstWhere(
                    (item) =>
                        item.id.toString() == diagnosisTypeController.text,
                    orElse: () => diagnosisTypes[0],
                  );

                  return CustomDropDown<DiagnosisType>(
                    context: context,
                    dropDownList: diagnosisTypes,
                    textController: diagnosisTypeController,
                    valueMapper: (item) =>
                        '${item.category} ${item.name}, ₹${item.price}',
                    idMapper: (item) => item.id.toString(),
                    hintText: "Select Diagnosis Type",
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (err, stack) => Text('Error: $err'),
              ),
              const SizedBox(height: 10),
              Visibility(
                visible: selectedDiagnosisType?.category == 'Franchise Lab',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Franchise Name",
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    franchiseNamesAsync.when(
                      data: (franchises) => CustomDropDown<FranchiseName>(
                        context: context,
                        dropDownList: franchises,
                        textController: franchiseNameController,
                        valueMapper: (item) =>
                            "${item.franchiseName} , ${item.address}", // For display text
                        idMapper: (item) => item
                            .franchiseName, // For controller value (ID in your case is franchiseName string)
                        hintText: "Select Franchise Name",
                      ),
                      loading: () => CircularProgressIndicator(),
                      error: (err, stack) => Text('Error loading franchises'),
                    ),

                    const SizedBox(height: 10),
                  ],
                ),
              ),
              Text(
                "Referred By Doctor",
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              doctorAsync.when(
                data: (doctor) {
                  if (doctor.isEmpty) {
                    return Text("No Doctor Available");
                  }

                  doctor.sort(
                    (a, b) => (a.firstName ?? '').compareTo(b.firstName ?? ''),
                  );

                  if (refByDoctorController.text.isEmpty &&
                      widget.billData != null) {
                    final existingDoctor = doctor.firstWhere(
                      (item) =>
                          item.id.toString() ==
                          widget.billData!.referredByDoctor.toString(),
                      orElse: () => doctor[0],
                    );
                    refByDoctorController.text = existingDoctor.id.toString();
                  }

                  return CustomDropDown<Doctor>(
                    context: context,
                    dropDownList: doctor,
                    textController: refByDoctorController,
                    valueMapper: (item) =>
                        '${item.firstName!} ${item.lastName ?? ''}, ${item.address ?? ""}, ${item.phoneNumber ?? ""}',
                    idMapper: (item) => item.id.toString(),
                    hintText: "Select Doctor",
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (err, stack) => Text('Error: $err'),
              ),
              const SizedBox(height: 10),
              Text(
                "Select Dates",
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  Flexible(
                    child: dateSelectorWiget(
                      context: context,
                      dateController: dateOfTestController,
                      hintText: "Date of Test",
                      onDateSelected: (isoDate) {
                        selectedTestDateISO =
                            isoDate; // <-- Correctly updates parent variable
                      },
                    ),
                  ),

                  const SizedBox(width: 10),
                  Flexible(
                    child: dateSelectorWiget(
                      context: context,
                      dateController: dateOfBillController,
                      hintText: "Date of Bill",
                      onDateSelected: (isoDate) {
                        selectedBillDateISO =
                            isoDate; // <-- Correctly updates parent variable
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                "Bill Status",
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              CustomDropDown<String>(
                context: context,
                dropDownList: billStatusList,
                textController: billStatusController,
                valueMapper: (item) => item,
                idMapper: (item) => item, // <-- Ensure this is set properly
                hintText: "Select Bill Status",
              ),

              const SizedBox(height: 10),
              Visibility(
                visible: billStatusController.text != "Unpaid",
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Amount Details",
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        Flexible(
                          child: customTextField(
                            label: "Paid Amount",
                            context: context,
                            controller: paidAmountController,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: customTextField(
                            label: "Doctor's Discount",
                            context: context,
                            controller: discByDoctorController,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: customTextField(
                            label: "Center's Discount",
                            context: context,
                            controller: discByCenterController,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: _saveBill,
                child: Container(
                  height: 50,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(defaultRadius),
                  ),
                  child: Center(
                    child: Text(
                      "Add Bill",
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium!.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Container dateSelectorWiget({
    required BuildContext context,
    required TextEditingController dateController,
    required String hintText,
    required ValueChanged<String> onDateSelected,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? lightTextFieldFillColor
            : darkTextFieldFillColor,
        borderRadius: BorderRadius.circular(defaultRadius),
      ),
      child: Row(
        children: [
          Expanded(
            child: customTextField(
              label: hintText,
              context: context,
              controller: dateController,
            ),
          ),
          IconButton(
            onPressed: () {
              datePicker(
                dateController: dateController,
                onDateSelected: onDateSelected,
              );
            },
            icon: Icon(Icons.calendar_month_outlined),
          ),
        ],
      ),
    );
  }

  void _saveBill() async {
    if (_formKey.currentState!.validate()) {
      final billData = {
        'patient_name': patientNameController.text,
        'patient_age': int.parse(patientAgeController.text),
        'patient_sex': patientSexController.text,
        'diagnosis_type': int.parse(diagnosisTypeController.text),
        'franchise_name': franchiseNameController.text,
        'referred_by_doctor': int.parse(refByDoctorController.text),
        'date_of_test': DateTime.parse(selectedTestDateISO).toString(),
        'date_of_bill': DateTime.parse(selectedBillDateISO).toString(),
        'bill_status': billStatusController.text,
        'paid_amount': int.parse(paidAmountController.text),
        'disc_by_center': int.parse(discByCenterController.text),
        'disc_by_doctor': int.parse(discByDoctorController.text),
      };
      final bill = Bill.fromJson({
        ...billData,
        'id': widget.billData?.id, // ensure the existing id is preserved
      });

      try {
        if (widget.billData != null) {
          final updatedBill = await ref.read(updateBillProvider(bill).future);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              content: Text(
                'Bill updated successfully: ${updatedBill.billNumber}',
              ),
            ),
          );

          Navigator.pop(context, updatedBill);
        } else {
          final newBill = await ref.read(createBillProvider(bill).future);

          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Theme.of(context).colorScheme.secondary,

              content: Text('Bill created successfully: ${newBill.billNumber}'),
            ),
          );

          Navigator.pop(context, newBill);
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).colorScheme.error,

            content: Text('Failed: $e'),
          ),
        );
      }
    }
  }
}

void showError(BuildContext context, message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
      duration: Duration(seconds: 2),
    ),
  );
}
