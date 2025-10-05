import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/models/center_detail_model_with_subscription.dart';
import 'package:labledger/models/subscription_model.dart';
import 'package:labledger/providers/center_detail_provider.dart'; // Your provider file
import 'package:labledger/screens/ui_components/custom_text_field.dart'; // Import CustomTextField
import 'package:labledger/screens/ui_components/tinted_container.dart'; // Import TintedContainer
import 'package:lucide_icons/lucide_icons.dart';

class CenterDetailDialog extends ConsumerStatefulWidget {
  final CenterDetail centerDetail;

  const CenterDetailDialog({super.key, required this.centerDetail});

  @override
  ConsumerState<CenterDetailDialog> createState() => _CenterDetailDialogState();
}

class _CenterDetailDialogState extends ConsumerState<CenterDetailDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _centerNameController;
  late final TextEditingController _addressController;
  late final TextEditingController _ownerNameController;
  late final TextEditingController _ownerPhoneController;

  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _centerNameController = TextEditingController(
      text: widget.centerDetail.centerName,
    );
    _addressController = TextEditingController(
      text: widget.centerDetail.address,
    );
    _ownerNameController = TextEditingController(
      text: widget.centerDetail.ownerName,
    );
    _ownerPhoneController = TextEditingController(
      text: widget.centerDetail.ownerPhone,
    );
  }

  @override
  void dispose() {
    _centerNameController.dispose();
    _addressController.dispose();
    _ownerNameController.dispose();
    _ownerPhoneController.dispose();
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
      subscription: widget.centerDetail.subscription,
    );

    try {
      await ref.read(updateCenterDetailProvider(updatedDetail).future);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Center details updated successfully!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to update: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      backgroundColor:
          Colors.transparent, // Let TintedContainer handle the background
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: TintedContainer(
        baseColor: theme.colorScheme.primary,
        width: 500,
        height: 550, // Let the content define the height
        radius: 20,
        disablePadding: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.all(defaultPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Center Details', style: theme.textTheme.headlineSmall),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

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
                      prefixIcon: const Icon(Icons.local_hospital_outlined),
                      readOnly: !_isEditing,
                      isRequired: true,
                    ),
                    SizedBox(height: defaultHeight),
                    CustomTextField(
                      tintColor: Theme.of(context).colorScheme.primary,

                      controller: _addressController,
                      label: 'Address',
                      prefixIcon: const Icon(LucideIcons.mapPin),
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
              child: _SubscriptionInfoCard(
                subscription: widget.centerDetail.subscription,
              ),
            ),
            Spacer(),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: defaultPadding,
                vertical: defaultPadding,
              ),
              child: _buildActionButtons(),
            ),
          ],
        ),
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
          OutlinedButton.icon(
            onPressed: () {
              _formKey.currentState?.reset();
              _centerNameController.text = widget.centerDetail.centerName;
              _addressController.text = widget.centerDetail.address;
              _ownerNameController.text = widget.centerDetail.ownerName;
              _ownerPhoneController.text = widget.centerDetail.ownerPhone;
              setState(() => _isEditing = false);
            },
            icon: const Icon(Icons.cancel_outlined),
            label: const Text('Cancel'),
            style: OutlinedButton.styleFrom(
              fixedSize: const Size(160, 50),
              foregroundColor: Theme.of(context).colorScheme.error,
              side: BorderSide(color: Theme.of(context).colorScheme.error),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(defaultRadius),
              ),
            ),
          ),
          SizedBox(width: defaultWidth),
          ElevatedButton.icon(
            onPressed: _handleUpdate,
            style: ElevatedButton.styleFrom(
              fixedSize: const Size(160, 50),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(defaultRadius),
              ),
            ),
            icon: const Icon(LucideIcons.save),
            label: Text('Update', style: const TextStyle(fontSize: 16)),
          ),
        ],
      );
    } else {
      return Align(
        alignment: Alignment.centerRight,
        child: ElevatedButton.icon(
          onPressed: () => setState(() => _isEditing = true),
          style: ElevatedButton.styleFrom(
            fixedSize: const Size(160, 50),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(defaultRadius),
            ),
          ),
          icon: const Icon(LucideIcons.edit, size: 16),
          label: Text('Edit Details', style: const TextStyle(fontSize: 16)),
        ),
      );
    }
  }
}

class _SubscriptionInfoCard extends StatelessWidget {
  final Subscription subscription;
  const _SubscriptionInfoCard({required this.subscription});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isActive = subscription.isActive;

    final Color cardColor = isActive
        ? theme.colorScheme.secondary
        : theme.colorScheme.error;

    return Card(
      elevation: 0,
      color: cardColor.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(defaultRadius),
        side: BorderSide(color: cardColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildInfoRow(
              'Plan Type',
              subscription.planType,
              LucideIcons.gem,
              context,
            ),
            const Divider(height: 16),
            _buildInfoRow(
              'Expires On',
              subscription.expiryDate,
              LucideIcons.calendarClock,
              context,
            ),
            const Divider(height: 16),
            _buildInfoRow(
              'Days Left',
              '${subscription.daysLeft} days',
              LucideIcons.hourglass,
              context,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon,
    BuildContext context,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
