import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/models/diagnosis_type_model.dart';
import 'package:labledger/models/doctors_model.dart';
import 'package:labledger/providers/custom_providers.dart';
import 'package:labledger/providers/diagnosis_type_provider.dart';
import 'package:labledger/providers/doctor_provider.dart';

final selectedDiagnosisType = StateProvider<DiagnosisType?>((ref) => null);
final selectedDoctor = StateProvider<Doctor?>((ref) => null);

void showAddNewBill(BuildContext context, WidgetRef ref) {
  final formKey = GlobalKey<FormState>();
  String? patientName;
  int? patientAge;
  String? patientSex;
  String? franchiseName;
  String billStatus = "Partially Paid";
  int? paidAmount;
  int? discByCenter;
  int? discByDoctor;
  DateTime? dateOfTest;
  DateTime? dateOfBill;
  TextEditingController dateOfTestController = TextEditingController();
  TextEditingController dateOfBillController = TextEditingController();
  bool isFranchiseLab = false;

  final selectedDiagnosis = ref.read(selectedDiagnosisType);
  final selectedDoctorData = ref.read(selectedDoctor);

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Add New Bill'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Consumer(
                  builder: (context, ref, _) {
                    final diagnosisTypesAsync = ref.watch(
                      diagnosisTypeProvider,
                    );
                    return diagnosisTypesAsync.when(
                      data: (diagnosisTypes) {
                        return DropdownButtonFormField<DiagnosisType>(
                          value: selectedDiagnosis,
                          decoration: InputDecoration(
                            labelText: 'Diagnosis Type',
                          ),
                          items: diagnosisTypes.map((type) {
                            return DropdownMenuItem<DiagnosisType>(
                              value: type,
                              child: Text(
                                '${type.name} | ${type.category} | ₹${type.price}',
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            ref.read(selectedDiagnosisType.notifier).state =
                                value;
                            isFranchiseLab = value!.category == "Franchise Lab";
                          },
                          validator: (value) =>
                              value == null ? 'Select Diagnosis Type' : null,
                        );
                      },
                      loading: () => CircularProgressIndicator(),
                      error: (err, _) => Text('Failed to load Diagnosis Types'),
                    );
                  },
                ),
                Consumer(
                  builder: (context, ref, _) {
                    final doctorsAsync = ref.watch(doctorsProvider);
                    return doctorsAsync.when(
                      data: (doctors) {
                        return DropdownButtonFormField<Doctor>(
                          value: selectedDoctorData,
                          decoration: InputDecoration(
                            labelText: 'Referred By Doctor',
                          ),
                          items: doctors.map((doctor) {
                            return DropdownMenuItem<Doctor>(
                              value: doctor,
                              child: Text(
                                '${doctor.firstName} ${doctor.lastName}',
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            ref.read(selectedDoctor.notifier).state = value;
                          },
                          validator: (value) =>
                              value == null ? 'Select Doctor' : null,
                        );
                      },
                      loading: () => CircularProgressIndicator(),
                      error: (err, _) => Text('Failed to load Doctors'),
                    );
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Patient Name'),
                  onChanged: (value) {
                    patientName = value;
                  },
                  validator: (value) =>
                      value!.isEmpty ? 'Enter Patient Name' : null,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Patient Age'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    patientAge = int.tryParse(value);
                  },
                  validator: (value) => value!.isEmpty ? 'Enter Age' : null,
                ),
                DropdownButtonFormField<String>(
                  value: patientSex,
                  decoration: InputDecoration(labelText: 'Sex'),
                  items: ['Male', 'Female', 'Other']
                      .map(
                        (sex) => DropdownMenuItem(value: sex, child: Text(sex)),
                      )
                      .toList(),
                  onChanged: (value) {
                    patientSex = value;
                  },
                  validator: (value) => value == null ? 'Select Sex' : null,
                ),
                if (isFranchiseLab)
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Franchise Name'),
                    onChanged: (value) {
                      franchiseName = value;
                    },
                  ),
                _buildDatePickerField(
                  context,
                  label: 'Date of Test',
                  selectedDate: dateOfTest,
                  controller: dateOfTestController,
                ),
                _buildDatePickerField(
                  context,
                  label: 'Date of Bill',
                  selectedDate: dateOfBill,
                  controller: dateOfBillController,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Paid Amount'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    paidAmount = int.tryParse(value);
                  },
                  validator: (value) =>
                      value!.isEmpty ? 'Enter Paid Amount' : null,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Discount by Center'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    discByCenter = int.tryParse(value);
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Discount by Doctor'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    discByDoctor = int.tryParse(value);
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final requestBody = {
                  "diagnosis_type": selectedDiagnosis!.id,
                  "referred_by_doctor": selectedDoctorData!.id,
                  "center_detail": {
                    "id": 1,
                    "center_name": "RK Diagnostic Center",
                    "address": "Jangipur",
                  },
                  "date_of_test": dateOfTest!.toIso8601String(),
                  "patient_name": patientName,
                  "patient_age": patientAge,
                  "patient_sex": patientSex,
                  "franchise_name": franchiseName,
                  "date_of_bill": dateOfBill!.toIso8601String(),
                  "bill_status": billStatus,
                  "paid_amount": paidAmount,
                  "disc_by_center": discByCenter ?? 0,
                  "disc_by_doctor": discByDoctor ?? 0,
                };

                print(requestBody);
                Navigator.of(context).pop();
              }
            },
            child: Text('Submit'),
          ),
        ],
      );
    },
  );
}

Widget _buildDatePickerField(
  BuildContext context, {
  required String label,
  required TextEditingController controller,
  required DateTime? selectedDate,
}) {
  return TextFormField(
    readOnly: true,
    decoration: InputDecoration(
      labelText: label,
      suffixIcon: Icon(Icons.calendar_today),
    ),
    onTap: () async {
      final pickedDate = await showDatePicker(
        context: context,
        initialDate: selectedDate ?? DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );
      if (pickedDate != null) {
        controller.text = pickedDate.toIso8601String();
      }
    },
    controller: TextEditingController(
      text: selectedDate != null
          ? "${selectedDate.toLocal()}".split(' ')[0]
          : '',
    ),
    validator: (_) => selectedDate == null ? 'Select $label' : null,
  );
}

Widget customTextField({
  required String label,
  required BuildContext context,
  required TextEditingController controller,
  TextInputType keyboardType = TextInputType.text,
}) {
  return TextFormField(
    onFieldSubmitted: (value) {
      controller.text = value;
    },
    keyboardType: keyboardType,
    decoration: InputDecoration(
      filled: true,
      hintText: label,

      fillColor: Theme.of(context).brightness == Brightness.dark
          ? darkTextFieldFillColor
          : lightTextFieldFillColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(defaultPadding / 2),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(defaultPadding / 2),
      ),
    ),
    onChanged: (value) {
      controller.text = value;
    },
  );
}

class CustomDropDown<T> extends StatelessWidget {
  final BuildContext context;
  final List<T> dropDownList;
  final TextEditingController textController;
  final String Function(T) valueMapper; // For Display Text
  final String Function(T) idMapper; // For Controller Value
  final String hintText;

  const CustomDropDown({
    super.key,
    required this.context,
    required this.dropDownList,
    required this.textController,
    required this.valueMapper,
    required this.idMapper,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    if (dropDownList.isEmpty) {
      return Container(
        height: 55,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[800]
              : Colors.grey[200],
        ),
        child: Text('No items available'),
      );
    }

    return Container(
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[850]
            : Colors.grey[100],
      ),
      child: DropdownButtonFormField<T>(
        isExpanded: true,
        borderRadius: BorderRadius.circular(8),
        decoration: InputDecoration(
          hintText: hintText,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
        value: dropDownList.firstWhere(
          (e) => idMapper(e) == textController.text,
          orElse: () => dropDownList[0],
        ),
        items: dropDownList.map((e) {
          return DropdownMenuItem<T>(
            value: e,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (e is DiagnosisType) Text("${e.category} "),
                Text(valueMapper(e), overflow: TextOverflow.ellipsis),
                if (e is DiagnosisType) Text('₹${e.price}'),
              ],
            ),
          );
        }).toList(),
        onChanged: (T? selected) {
          if (selected != null) {
            textController.text = idMapper(selected);
          }
        },
      ),
    );
  }
}
