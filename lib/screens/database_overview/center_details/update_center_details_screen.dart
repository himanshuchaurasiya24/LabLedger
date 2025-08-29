import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/main.dart';
import 'package:labledger/methods/custom_methods.dart';
import 'package:labledger/models/center_detail_model.dart';
import 'package:labledger/providers/center_detail_provider.dart';
import 'package:labledger/screens/home/home_screen_logic.dart';
import 'package:labledger/screens/initials/window_loading_screen.dart';

class UpdateCenterDetailsScreen extends ConsumerStatefulWidget {
  final CenterDetail centerDetail;

  const UpdateCenterDetailsScreen({super.key, required this.centerDetail});

  @override
  ConsumerState<UpdateCenterDetailsScreen> createState() =>
      _UpdateCenterDetailsScreenState();
}

class _UpdateCenterDetailsScreenState
    extends ConsumerState<UpdateCenterDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController centerNameController;
  late final TextEditingController ownerNameController;
  late final TextEditingController ownerPhoneController;
  late final TextEditingController centerAddressController;

  @override
  void initState() {
    super.initState();
    final detail = widget.centerDetail;
    centerNameController = TextEditingController(text: detail.centerName);
    ownerNameController = TextEditingController(text: detail.ownerName);
    ownerPhoneController = TextEditingController(text: detail.ownerPhone);
    centerAddressController = TextEditingController(text: detail.address);
  }

  @override
  void dispose() {
    for (final controller in [
      centerNameController,
      ownerNameController,
      ownerPhoneController,
      centerAddressController,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<(bool success, String? error)> updateCenterDetailData(
    CenterDetail updatedDetail,
    WidgetRef ref,
  ) async {
    try {
      await ref.read(updateCenterDetailProvider(updatedDetail).future);
      return (true, null); // ✅ success
    } catch (e) {
      debugPrint("Update failed: $e");
      return (false, e.toString()); // ❌ failure with error message
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final updatedDetail = widget.centerDetail.copyWith(
        id: widget.centerDetail.id,
        centerName: centerNameController.text.trim(),
        ownerName: ownerNameController.text.trim(),
        ownerPhone: ownerPhoneController.text.trim(),
        address: centerAddressController.text.trim(),
      );

      final (success, error) = await updateCenterDetailData(updatedDetail, ref);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? "Center details updated successfully!"
                : "Failed to update center details: $error",
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );

      if (success) {
        // ref.invalidate(centerDetailsProvider);
        // ref.invalidate(singleCenterDetailProvider(widget.centerDetail.id));
        navigatorKey.currentState?.pushReplacement(
          MaterialPageRoute(
            builder: (context) {
              return WindowLoadingScreen();
            },
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomCardContainer(
        xWidth: 0.5,
        xHeight: 0.7,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              pageHeader(context: context, centerWidget: null),
              SizedBox(height: defaultHeight),
              customTextField(
                label: "Center Name",
                context: context,
                controller: centerNameController,
              ),
              SizedBox(height: defaultHeight),
              customTextField(
                label: "Center Address",
                context: context,
                controller: centerAddressController,
              ),
              SizedBox(height: defaultHeight),
              customTextField(
                label: "Owner Name",
                context: context,
                controller: ownerNameController,
              ),
              SizedBox(height: defaultHeight),
              customTextField(
                label: "Owner Phone",
                context: context,
                controller: ownerPhoneController,
                keyboardType: TextInputType.number,
              ),

              const Spacer(),
              InkWell(
                onTap: () {
                  if (_formKey.currentState!.validate()) {
                    _submitForm();
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
                      "Update Details",
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
}
