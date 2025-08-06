import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/models/diagnosis_type_model.dart';
import 'package:labledger/models/doctors_model.dart';
import 'package:labledger/providers/custom_providers.dart';

final selectedDiagnosisType = StateProvider<DiagnosisType?>((ref) => null);
final selectedDoctor = StateProvider<Doctor?>((ref) => null);
Widget customTextField({
  required String label,
  required BuildContext context,
  required TextEditingController controller,
  TextInputType keyboardType = TextInputType.text,
}) {
  return TextFormField(
    controller: controller, // <-- THIS is sufficient for binding
    keyboardType: keyboardType,
    validator: (value) {
      if (value == null || value.trim().isEmpty) {
        return 'Please enter $label';
      }
      return null;
    },
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
  );
}
class CustomDropDown<T> extends StatefulWidget {
  final BuildContext context;
  final List<T> dropDownList;
  final TextEditingController textController;
  final String Function(T) valueMapper; // For Display Text
  final String Function(T) idMapper;    // For Controller Value
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
  CustomDropDownState<T> createState() => CustomDropDownState<T>();
}

class CustomDropDownState<T> extends State<CustomDropDown<T>> {
  T? selectedValue;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncControllerWithValue();
    });
  }

  @override
  void didUpdateWidget(covariant CustomDropDown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dropDownList != widget.dropDownList ||
        oldWidget.textController.text != widget.textController.text) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _syncControllerWithValue();
      });
    }
  }
void _syncControllerWithValue() {
  if (widget.dropDownList.isEmpty) return;

  final existing = widget.dropDownList.firstWhere(
    (e) => widget.idMapper(e) == widget.textController.text,
    orElse: () => widget.dropDownList.first,
  );

  if (mounted) {
    setState(() {
      selectedValue = existing;
      widget.textController.text = widget.idMapper(existing);
    });
  }
}


  @override
  Widget build(BuildContext context) {
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
        value: selectedValue,
        borderRadius: BorderRadius.circular(8),
        decoration: InputDecoration(
          hintText: widget.hintText,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          filled: true,
          fillColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[850]
              : Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
        items: widget.dropDownList.map((e) {
          return DropdownMenuItem<T>(
            value: e,
            child: Text(widget.valueMapper(e), overflow: TextOverflow.ellipsis),
          );
        }).toList(),
        onChanged: (T? selected) {
          if (selected != null) {
            setState(() {
              selectedValue = selected;
            });
            widget.textController.text = widget.idMapper(selected);
          }
        },
      ),
    );
  }
}

