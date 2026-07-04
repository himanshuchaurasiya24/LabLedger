import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:labledger/authentication/config.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/constants/urls.dart';
import 'package:labledger/models/center_detail_model_with_subscription.dart';
import 'package:labledger/providers/center_detail_provider.dart'; // Your provider file
import 'package:labledger/screens/ui_components/custom_elevated_button.dart';
import 'package:labledger/screens/ui_components/custom_outlined_button.dart';
import 'package:labledger/screens/ui_components/custom_text_field.dart';
import 'package:labledger/screens/ui_components/blurred_dialog.dart';
import 'package:labledger/screens/home/widgets/center_subscription_info_card.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:labledger/screens/ui_components/snackbar_utils.dart';
import 'package:labledger/utils/controller_disposer.dart';
import 'package:url_launcher/url_launcher.dart';

class CenterDetailDialog extends ConsumerStatefulWidget {
  final CenterDetail centerDetail;

  const CenterDetailDialog({super.key, required this.centerDetail});

  @override
  ConsumerState<CenterDetailDialog> createState() => _CenterDetailDialogState();
}

class _CenterDetailDialogState extends ConsumerState<CenterDetailDialog>
    with ControllerDisposer {
  static const String _supportEmail = 'himanshuchaurasiya24@gmail.com';
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _centerNameController;
  late final TextEditingController _addressController;
  late final TextEditingController _ownerNameController;
  late final TextEditingController _ownerPhoneController;
  late final Future<bool> _canUpgradeFuture;

  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _centerNameController = createController(widget.centerDetail.centerName);
    _addressController = createController(widget.centerDetail.address);
    _ownerNameController = createController(widget.centerDetail.ownerName);
    _ownerPhoneController = createController(widget.centerDetail.ownerPhone);
    _canUpgradeFuture = _canUpgradeCurrentPlan();
  }

  @override
  void dispose() {
    disposeControllers();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    // Validate the form before proceeding
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final updatedDetail = CenterDetail(
      id: widget.centerDetail.id,
      centerName: _centerNameController.text,
      address: _addressController.text,
      ownerName: _ownerNameController.text,
      ownerPhone: _ownerPhoneController.text,
      isActive: widget.centerDetail.isActive,
      subscription: widget.centerDetail.subscription,
    );

    try {
      await ref.read(updateCenterDetailProvider(updatedDetail).future);

      if (mounted) {
        showSuccessSnackBar(context, "Center details updated successfully!");
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(context, "Failed to update: $e");
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<bool> _canUpgradeCurrentPlan() async {
    final current = widget.centerDetail.subscription;

    if (current.isCustom) {
      return false;
    }

    try {
      final response = await http.get(
        Uri.parse('$globalBaseUrl${AppUrls.subscriptionPlan}'),
        headers: {'Content-Type': 'application/json'},
      );

      final dynamic decoded = jsonDecode(response.body);
      final List<dynamic> raw = decoded is List
          ? decoded
          : (decoded is Map<String, dynamic> && decoded['results'] is List)
          ? decoded['results'] as List<dynamic>
          : const [];

      final int currentIndex = current.planIndex;
      for (final item in raw) {
        if (item is! Map<String, dynamic>) continue;
        final int planIndex = (item['plan_index'] as int?) ?? 0;
        final bool isCustom = (item['is_custom'] as bool?) ?? false;
        if (!isCustom && planIndex > currentIndex) {
          return true;
        }
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> _contactSupportForUpgrade() async {
    final center = widget.centerDetail;
    final subscription = center.subscription;

    final body =
        '''Dear Support Team,

Please assist with upgrading our center subscription.

Center Details:
- Center ID: ${center.id}
- Center Name: ${center.centerName}

Current Plan:
- Plan: ${subscription.planType}
- Expiry Date: ${subscription.expiryDate}

Regards,
LabLedger Center Admin''';

    final uri = Uri.https('mail.google.com', '/mail/', {
      'view': 'cm',
      'fs': '1',
      'to': _supportEmail,
      'su': 'Upgrade request: ${center.centerName}',
      'body': body,
    });

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      final fallback = Uri(scheme: 'mailto', path: _supportEmail);
      await launchUrl(fallback, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final centerDetail = widget.centerDetail;
    return PremiumDialog(
      width: 500,
      height: 600,
      accentColor: theme.colorScheme.primary,
      headerIcon: LucideIcons.building,
      title: 'Center Details',
      subtitle: 'Manage center information',
      content: ListView(
        padding: const EdgeInsets.only(top: mediumPadding),
        children: [
                    // --- Form Fields ---
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: defaultPadding),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            CustomTextField(
                              controller: _centerNameController,
                              tintColor: Theme.of(context).colorScheme.primary,
                              label: 'Center Name',
                              prefixIcon: const Icon(
                                Icons.local_hospital_outlined,
                              ),
                              readOnly: !_isEditing,
                              isRequired: true,
                            ),
                            SizedBox(height: defaultHeight),
                            CustomTextField(
                              tintColor: Theme.of(context).colorScheme.primary,

                              controller: _addressController,
                              label: 'Address',
                              prefixIcon: const Icon(LucideIcons.map_pin),
                              readOnly: !_isEditing,
                              isRequired: true,
                            ),
                            SizedBox(height: defaultHeight),
                            CustomTextField(
                              tintColor: Theme.of(context).colorScheme.primary,

                              controller: _ownerNameController,
                              label: 'Owner Name',
                              prefixIcon: const Icon(LucideIcons.user),
                              readOnly: !_isEditing,
                              isRequired: true,
                            ),
                            SizedBox(height: defaultHeight),
                            CustomTextField(
                              controller: _ownerPhoneController,
                              tintColor: Theme.of(context).colorScheme.primary,

                              label: 'Owner Phone',
                              prefixIcon: const Icon(LucideIcons.phone),
                              readOnly: !_isEditing,
                              isRequired: true,
                              isNumeric: true,
                              keyboardType: TextInputType.phone,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: defaultHeight),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: defaultPadding),
                      child: CenterSubscriptionInfoCard(
                        subscription: widget.centerDetail.subscription,
                        isActive: centerDetail.isActive,
                        canUpgradeFuture: _canUpgradeFuture,
                        onUpgradeTap: _contactSupportForUpgrade,
                      ),
                    ),
                    SizedBox(height: defaultHeight),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: defaultPadding,
                        vertical: defaultPadding,
                      ),
                      child: _buildActionButtons(),
                    ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_isEditing) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CustomOutlinedButton(
            onPressed: () {
              _formKey.currentState?.reset();
              _centerNameController.text = widget.centerDetail.centerName;
              _addressController.text = widget.centerDetail.address;
              _ownerNameController.text = widget.centerDetail.ownerName;
              _ownerPhoneController.text = widget.centerDetail.ownerPhone;
              setState(() => _isEditing = false);
            },
            icon: const Icon(Icons.cancel_outlined),
            label: 'Cancel',
            width: 160,
            height: 50,
          ),
          SizedBox(width: defaultWidth),
          CustomElevatedButton(
            onPressed: _handleUpdate,
            backgroundColor: Theme.of(context).colorScheme.primary,
            icon: const Icon(LucideIcons.save),
            label: 'Update',
            width: 160,
            height: 50,
          ),
        ],
      );
    } else {
      return Align(
        alignment: Alignment.centerRight,
        child: CustomElevatedButton(
          onPressed: () => setState(() => _isEditing = true),
          backgroundColor: Theme.of(context).colorScheme.primary,
          icon: const Icon(LucideIcons.pen, size: 16),
          label: 'Edit Details',
          width: 160,
          height: 50,
        ),
      );
    }
  }
}

