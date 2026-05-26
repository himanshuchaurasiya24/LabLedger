import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/models/diagnosis_type_model.dart';
import 'package:labledger/providers/authentication_provider.dart';
import 'package:labledger/providers/diagnosis_type_provider.dart';
import 'package:labledger/providers/category_provider.dart';
import 'package:labledger/models/diagnosis_category_model.dart';
import 'package:labledger/screens/initials/window_scaffold.dart';
import 'package:labledger/screens/ui_components/delete_confirmation_dialog.dart';
import 'package:labledger/screens/ui_components/custom_error_dialog.dart';
import 'package:labledger/screens/ui_components/custom_text_field.dart';
import 'package:labledger/screens/ui_components/searchable_dropdown_field.dart';
import 'package:labledger/screens/ui_components/tinted_container.dart';
import 'package:labledger/screens/ui_components/edit_screen_header_card.dart';
import 'package:labledger/methods/snackbar_utils.dart';
import 'package:labledger/methods/string_utils.dart';
class DiagnosisTypeEditScreen extends ConsumerStatefulWidget {
  const DiagnosisTypeEditScreen({
    super.key,
    this.diagnosisTypeId,
    this.themeColor,
  });

  final int? diagnosisTypeId;
  final Color? themeColor;

  @override
  ConsumerState<DiagnosisTypeEditScreen> createState() =>
      _DiagnosisTypeEditScreenState();
}

class _DiagnosisTypeEditScreenState
    extends ConsumerState<DiagnosisTypeEditScreen> {
  final _detailsFormKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _categoryController = TextEditingController();
  int? _selectedCategoryId; // Store selected category ID

  bool _isSaving = false;
  bool _isDeleting = false;
  bool _isDataInitialized = false;
  List<DiagnosisCategory> _categories = [];

  bool get _isEditMode => widget.diagnosisTypeId != null;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await ref.read(categoriesProvider.future);
      setState(() {
        _categories = categories;
      });
    } catch (e) {
      //
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _initializeData(DiagnosisType diagnosis) {
    if (!_isDataInitialized) {
      _nameController.text = diagnosis.name;
      _selectedCategoryId = diagnosis.category; // Store category ID
      _categoryController.text = diagnosis.categoryName ?? '';
      _priceController.text = diagnosis.price.toString();
      _isDataInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveThemeColor =
        widget.themeColor ?? Theme.of(context).colorScheme.secondary;
    final isAdmin = ref.watch(currentUserProvider).value?.isAdmin ?? false;

    final asyncAllTypes = ref.watch(diagnosisTypeProvider);

    return WindowScaffold(
      child: _isEditMode
          ? asyncAllTypes.when(
              data: (types) {
                try {
                  final typeToEdit = types.firstWhere(
                    (t) => t.id == widget.diagnosisTypeId,
                  );
                  _initializeData(typeToEdit);
                  return _buildContent(
                    isAdmin,
                    effectiveThemeColor,
                    diagnosis: typeToEdit,
                  );
                } catch (e) {
                  return _buildErrorWidget(
                    "Diagnosis Type with ID #${widget.diagnosisTypeId} not found.",
                  );
                }
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, st) =>
                  _buildErrorWidget("Error loading diagnosis type: $err"),
            )
          : _buildContent(isAdmin, effectiveThemeColor),
    );
  }

  Widget _buildContent(bool isAdmin, Color color, {DiagnosisType? diagnosis}) {
    return Column(
      children: [
        _buildHeaderCard(isAdmin, color, diagnosis),
        SizedBox(height: defaultHeight),
        _buildDetailsCard(color, diagnosis: diagnosis),
      ],
    );
  }

  Widget _buildHeaderCard(bool isAdmin, Color color, DiagnosisType? diagnosis) {
    final title = _isEditMode ? diagnosis?.name ?? '' : 'New Diagnosis Type';
    final subtitle = _isEditMode
        ? (diagnosis?.categoryName ?? 'Unknown Category')
        : 'Enter details below';
    final initials = _isEditMode ? getInitials(diagnosis?.name) : 'DT';

    return EditScreenHeaderCard(
      title: title,
      subtitle: subtitle,
      initials: initials,
      color: color,
      isEditMode: _isEditMode,
      isAdmin: isAdmin,
      isSaving: _isSaving,
      isDeleting: _isDeleting,
      onSave: () => _handleSave(diagnosis),
      onDelete: () => _handleDelete(diagnosis!),
      saveLabel: _isEditMode ? 'Update Type' : 'Create Type',
    );
  }

  Widget _buildDetailsCard(Color color, {DiagnosisType? diagnosis}) {
    return TintedContainer(
      baseColor: color,
      radius: defaultRadius,
      height: 330,
      elevationLevel: 1,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(defaultPadding * 1.5),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
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
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.biotech_outlined, color: color, size: 20),
                ),
                SizedBox(width: defaultWidth / 2),
                Text(
                  'Diagnosis Type Details',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
          SizedBox(height: defaultHeight),
          Expanded(
            child: Form(
              key: _detailsFormKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    CustomTextField(
                      label: 'Diagnosis Name',
                      controller: _nameController,
                      isRequired: true,
                      tintColor: color,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Name is required' : null,
                    ),
                    SizedBox(height: defaultHeight),
                    SearchableDropdownField<DiagnosisCategory>(
                      label: 'Category',
                      controller: _categoryController,
                      items: _categories,
                      color: color,
                      valueMapper: (item) => item.name,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategoryId = selected.id;
                          _categoryController.text = selected.name;
                        });
                      },
                      validator: (v) => _selectedCategoryId == null
                          ? 'Category is required'
                          : null,
                    ),
                    SizedBox(height: defaultHeight),
                    CustomTextField(
                      label: 'Price',
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      isRequired: true,
                      tintColor: color,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Price is required' : null,
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

  // --- Handlers ---
  Future<void> _handleSave(DiagnosisType? originalDiagnosis) async {
    if (!_detailsFormKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      if (_isEditMode) {
        final updatedDiagnosis = DiagnosisType(
          id: originalDiagnosis!.id,
          name: _nameController.text.trim(),
          category: _selectedCategoryId!, // Send category ID
          price: int.parse(_priceController.text.trim()),
        );
        await ref.read(updateDiagnosisTypeProvider(updatedDiagnosis).future);
        if (mounted) {
          showSuccessSnackBar(context, 'Diagnosis Type updated successfully!');
        }
      } else {
        final newDiagnosis = DiagnosisType(
          name: _nameController.text.trim(),
          category: _selectedCategoryId!, // Send category ID
          price: int.parse(_priceController.text.trim()),
        );
        await ref.read(addDiagnosisTypeProvider(newDiagnosis).future);
        if (mounted) {
          showSuccessSnackBar(context, 'Diagnosis Type created successfully!');
        }
      }

      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) _showErrorDialog('Operation Failed', e.toString());
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _handleDelete(DiagnosisType diagnosis) async {
    final confirmed = await showDeleteConfirmationDialog(
      context: context,
      title: 'Confirm Deletion',
      message: 'Are you sure you want to delete "${diagnosis.name}"?',
      showWarningIcon: false,
    );

    if (!confirmed) return;

    setState(() => _isDeleting = true);
    try {
      await ref.read(deleteDiagnosisTypeProvider(diagnosis.id!).future);
      if (mounted) {
        showSuccessSnackBar(context, 'Diagnosis Type deleted successfully!');
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) _showErrorDialog('Delete Failed', e.toString());
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }



  void _showErrorDialog(String title, String errorMessage) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) =>
          ErrorDialog(title: title, errorMessage: errorMessage),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          message,
          style: TextStyle(
            color: Theme.of(context).colorScheme.error,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
