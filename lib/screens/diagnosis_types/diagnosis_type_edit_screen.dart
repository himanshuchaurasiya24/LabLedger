import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/models/diagnosis_type_model.dart';
import 'package:labledger/providers/authentication_provider.dart';
import 'package:labledger/providers/diagnosis_type_provider.dart';
import 'package:labledger/screens/initials/window_scaffold.dart';
import 'package:labledger/screens/ui_components/custom_error_dialog.dart';
import 'package:labledger/screens/ui_components/custom_text_field.dart';
import 'package:labledger/screens/ui_components/searchable_dropdown_field.dart';
import 'package:labledger/screens/ui_components/tinted_container.dart';

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
  final _categoryController = TextEditingController();
  final _priceController = TextEditingController();

  bool _isSaving = false;
  bool _isDeleting = false;
  bool _isDataInitialized = false;

  bool get _isEditMode => widget.diagnosisTypeId != null;

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _initializeData(DiagnosisType diagnosis) {
    if (!_isDataInitialized) {
      _nameController.text = diagnosis.name;
      _categoryController.text = diagnosis.category;
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final title = _isEditMode ? diagnosis?.name ?? '' : 'New Diagnosis Type';
    final subtitle = _isEditMode
        ? diagnosis?.category ?? ''
        : 'Enter details below';
    final initials = _isEditMode ? _getInitials(diagnosis?.name) : 'DT';
    final lightThemeColor = Color.lerp(
      color,
      isDark ? Colors.black : Colors.white,
      isDark ? 0.3 : 0.2,
    )!;

    return TintedContainer(
      baseColor: color,
      height: 160,
      radius: defaultRadius,
      useGradient: true,
      elevationLevel: 2,
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [color, lightThemeColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: defaultWidth / 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
          // ✅ Conditional visibility for the entire button column.
          // It only shows if it's "create mode" OR if the user is an admin.
          if (!_isEditMode || isAdmin)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _isSaving ? null : () => _handleSave(diagnosis),
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(180, 60),
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(defaultRadius),
                    ),
                  ),
                  icon: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(_isEditMode ? Icons.update : Icons.save),
                  label: Text(
                    _isSaving
                        ? 'Saving...'
                        : (_isEditMode ? 'Update Type' : 'Create Type'),
                  ),
                ),
                // ✅ The delete button is now conditional on BOTH edit mode AND admin status.
                if (_isEditMode && isAdmin) ...[
                  SizedBox(height: defaultHeight / 2),
                  OutlinedButton.icon(
                    onPressed: _isDeleting
                        ? null
                        : () => _handleDelete(diagnosis!),
                    style: OutlinedButton.styleFrom(
                      fixedSize: const Size(180, 60),
                      foregroundColor: Theme.of(context).colorScheme.error,
                      side:  BorderSide(color: Theme.of(context).colorScheme.error),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(defaultRadius),
                      ),
                    ),
                    icon: _isDeleting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.delete_outline),
                    label: Text(_isDeleting ? 'Deleting...' : 'Delete'),
                  ),
                ],
              ],
            ),
        ],
      ),
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
                    SearchableDropdownField<String>(
                      label: 'Category',
                      controller: _categoryController,
                      // ✅ Directly provide the static list of categories here
                      items: const [
                        "Ultrasound",
                        "Pathology",
                        "X-Ray",
                        "ECG",
                        "Franchise Lab",
                      ],
                      color: color,
                      valueMapper: (item) => item,
                      onSelected: (selected) {
                        setState(() => _categoryController.text = selected);
                      },
                      validator: (v) =>
                          v!.isEmpty ? 'Category is required' : null,
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
          category: _categoryController.text.trim(),
          price: int.parse(_priceController.text.trim()),
        );
        await ref.read(updateDiagnosisTypeProvider(updatedDiagnosis).future);
        _showSuccessSnackBar('Diagnosis Type updated successfully!');
      } else {
        final newDiagnosis = DiagnosisType(
          name: _nameController.text.trim(),
          category: _categoryController.text.trim(),
          price: int.parse(_priceController.text.trim()),
        );
        await ref.read(addDiagnosisTypeProvider(newDiagnosis).future);
        _showSuccessSnackBar('Diagnosis Type created successfully!');
      }

      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) _showErrorDialog('Operation Failed', e.toString());
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _handleDelete(DiagnosisType diagnosis) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete "${diagnosis.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child:  Text('Delete', style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isDeleting = true);
    try {
      await ref.read(deleteDiagnosisTypeProvider(diagnosis.id!).future);
      _showSuccessSnackBar('Diagnosis Type deleted successfully!');
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) _showErrorDialog('Delete Failed', e.toString());
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  // --- Helper Widgets & Methods ---

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return '??';
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts.length > 1
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
            behavior: SnackBarBehavior.floating,

        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
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
          style:  TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 16),
        ),
      ),
    );
  }
}
