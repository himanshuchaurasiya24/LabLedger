import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/models/franchise_model.dart';
import 'package:labledger/providers/authentication_provider.dart';
import 'package:labledger/providers/franchise_lab_provider.dart';
import 'package:labledger/screens/ui_components/window_scaffold.dart';
import 'package:labledger/screens/ui_components/custom_text_field.dart';
import 'package:labledger/screens/ui_components/tinted_container.dart';
import 'package:labledger/screens/ui_components/edit_screen_header_card.dart';
import 'package:labledger/utils/controller_disposer.dart';
import 'package:labledger/methods/string_utils.dart';
import 'package:labledger/screens/franchise_labs/methods/franchise_lab_methods.dart';

class FranchiseEditScreen extends ConsumerStatefulWidget {
  const FranchiseEditScreen({super.key, this.franchiseId, this.themeColor});

  final int? franchiseId;
  final Color? themeColor;

  @override
  ConsumerState<FranchiseEditScreen> createState() =>
      _FranchiseEditScreenState();
}

class _FranchiseEditScreenState extends ConsumerState<FranchiseEditScreen>
    with ControllerDisposer {
  final _detailsFormKey = GlobalKey<FormState>();

  late final TextEditingController _franchiseNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;

  late final FranchiseLabMethods _methods;

  bool get _isEditMode => widget.franchiseId != null;

  @override
  void dispose() {
    _methods.dispose();
    disposeControllers();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _methods = FranchiseLabMethods(context, ref);
    _methods.addListener(() {
      if (mounted) setState(() {});
    });
    _franchiseNameController = createController();
    _phoneController = createController();
    _addressController = createController();
  }

  void _initializeData(FranchiseName franchise) {
    if (!_methods.isDataInitialized) {
      _franchiseNameController.text = franchise.franchiseName ?? '';
      _phoneController.text = franchise.phoneNumber ?? '';
      _addressController.text = franchise.address ?? '';
      _methods.setInitialized();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = ref.watch(currentUserProvider).value?.isAdmin ?? false;
    final effectiveThemeColor =
        widget.themeColor ?? Theme.of(context).colorScheme.secondary;

    final content = _isEditMode
        ? ref
              .watch(singleFranchiseProvider(widget.franchiseId!))
              .when(
                data: (franchise) {
                  _initializeData(franchise);
                  return _buildContent(
                    isAdmin,
                    effectiveThemeColor,
                    franchise: franchise,
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, st) =>
                    _buildErrorWidget("Error loading franchise lab: $err"),
              )
        : _buildContent(isAdmin, effectiveThemeColor);

    return WindowScaffold(child: content);
  }

  Widget _buildContent(bool isAdmin, Color color, {FranchiseName? franchise}) {
    return Column(
      children: [
        _buildFranchiseHeaderCard(isAdmin, color, franchise),
        SizedBox(height: defaultHeight),
        _buildFranchiseDetailsCard(color, franchise: franchise),
      ],
    );
  }

  Widget _buildFranchiseHeaderCard(
    bool isAdmin,
    Color color,
    FranchiseName? franchise,
  ) {
    final title = _isEditMode
        ? franchise?.franchiseName ?? ''
        : 'New Franchise Lab';
    final subtitle = _isEditMode
        ? franchise?.address ?? ''
        : 'Enter lab details below';
    final initials = _isEditMode ? getInitials(franchise?.franchiseName) : 'FL';

    return EditScreenHeaderCard(
      title: title,
      subtitle: subtitle,
      initials: initials,
      color: color,
      isEditMode: _isEditMode,
      isAdmin: isAdmin,
      isSaving: _methods.isSaving,
      isDeleting: _methods.isDeleting,
      onSave: () {
        if (!_detailsFormKey.currentState!.validate()) return;
        _methods.handleSave(
          isEditMode: _isEditMode,
          originalFranchise: franchise,
          franchiseName: _franchiseNameController.text.trim(),
          address: _addressController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
        );
      },
      onDelete: () => _methods.handleDelete(franchise: franchise!),
      saveLabel: _isEditMode ? 'Update' : 'Create',
    );
  }

  Widget _buildFranchiseDetailsCard(Color color, {FranchiseName? franchise}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TintedContainer(
      baseColor: color,
      radius: defaultRadius,
      elevationLevel: 1,
      height: 330,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(defaultPadding * 1.5),
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(defaultRadius),
                topRight: Radius.circular(defaultRadius),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(defaultPadding),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(smallRadius),
                  ),
                  child: Icon(
                    Icons.store_mall_directory_outlined,
                    color: color,
                    size: 20,
                  ),
                ),
                SizedBox(width: defaultWidth / 2),
                Text(
                  'Franchise Lab Information',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: defaultHeight),
          Expanded(
            child: Form(
              key: _detailsFormKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: largePadding),
                child: Column(
                  children: [
                    CustomTextField(
                      label: 'Franchise Lab Name',
                      controller: _franchiseNameController,
                      isRequired: true,
                      tintColor: color,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Franchise name is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: defaultHeight),
                    CustomTextField(
                      label: 'Address',
                      controller: _addressController,
                      tintColor: color,
                      isRequired: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Address is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: defaultHeight),
                    CustomTextField(
                      label: 'Phone Number',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      isRequired: true,
                      tintColor: color,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Phone number is required';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildErrorWidget(String message) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final effectiveThemeColor =
        widget.themeColor ?? theme.colorScheme.secondary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(xlargePadding),
        child: TintedContainer(
          baseColor: theme.colorScheme.error,
          intensity: isDark ? 0.2 : 0.1,
          elevationLevel: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: theme.colorScheme.error,
              ),
              SizedBox(height: defaultHeight),
              Text(
                'Error Loading Franchise',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: defaultHeight / 2),
              Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: defaultHeight),
              ElevatedButton.icon(
                onPressed: () {
                  if (widget.franchiseId != null) {
                    ref.invalidate(
                      singleFranchiseProvider(widget.franchiseId!),
                    );
                  }
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: effectiveThemeColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(defaultRadius),
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
