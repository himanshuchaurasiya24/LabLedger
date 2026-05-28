import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/models/diagnosis_category_model.dart';
import 'package:labledger/providers/authentication_provider.dart';
import 'package:labledger/providers/category_provider.dart';
import 'package:labledger/screens/initials/window_scaffold.dart';
import 'package:labledger/screens/ui_components/custom_confirmation_dialog.dart';
import 'package:labledger/screens/ui_components/custom_error_dialog.dart';
import 'package:labledger/screens/ui_components/custom_text_field.dart';
import 'package:labledger/screens/ui_components/tinted_container.dart';
import 'package:labledger/screens/ui_components/edit_screen_header_card.dart';
import 'package:labledger/methods/string_utils.dart';
import 'package:labledger/screens/ui_components/snackbar_utils.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:labledger/utils/controller_disposer.dart';

class CategoryEditScreen extends ConsumerStatefulWidget {
  const CategoryEditScreen({super.key, this.category, this.themeColor});

  final DiagnosisCategory? category;
  final Color? themeColor;

  @override
  ConsumerState<CategoryEditScreen> createState() => _CategoryEditScreenState();
}

class _CategoryEditScreenState extends ConsumerState<CategoryEditScreen>
    with ControllerDisposer {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  bool _isFranchiseLab = false;
  bool _isSaving = false;
  bool _isDeleting = false;

  bool get _isEditMode => widget.category != null;

  @override
  void initState() {
    super.initState();
    _nameController = createController(widget.category?.name ?? '');
    _descriptionController = createController(
      widget.category?.description ?? '',
    );
    if (_isEditMode) {
      _isFranchiseLab = widget.category!.isFranchiseLab;
    }
  }

  @override
  void dispose() {
    disposeControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = ref.watch(currentUserProvider).value?.isAdmin ?? false;
    final effectiveColor =
        widget.themeColor ?? Theme.of(context).colorScheme.secondary;

    return WindowScaffold(
      child: Column(
        children: [
          _buildHeaderCard(isAdmin, effectiveColor),
          SizedBox(height: defaultHeight),
          _buildDetailsCard(effectiveColor),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(bool isAdmin, Color color) {
    final title = _isEditMode ? widget.category!.name : 'New Category';
    final subtitle = _isEditMode
        ? widget.category!.description ?? 'Edit category details'
        : 'Enter category details below';
    final initials = _isEditMode ? getInitials(widget.category!.name) : 'NC';

    return EditScreenHeaderCard(
      title: title,
      subtitle: subtitle,
      initials: initials,
      color: color,
      isEditMode: _isEditMode,
      isAdmin: isAdmin,
      isSaving: _isSaving,
      isDeleting: _isDeleting,
      onSave: _handleSave,
      onDelete: _handleDelete,
      saveLabel: _isEditMode ? 'Update Category' : 'Create Category',
    );
  }

  Widget _buildDetailsCard(Color color) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TintedContainer(
      baseColor: color,
      radius: defaultRadius,
      elevationLevel: 1,
      height: 400,
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
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(LucideIcons.tags, color: color, size: 20),
                ),
                SizedBox(width: defaultWidth / 2),
                Text(
                  'Category Information',
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
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  children: [
                    CustomTextField(
                      label: 'Category Name',
                      controller: _nameController,
                      isRequired: true,
                      tintColor: color,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Category name is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: defaultHeight),
                    CustomTextField(
                      label: 'Description (Optional)',
                      controller: _descriptionController,
                      tintColor: color,
                    ),
                    SizedBox(height: defaultHeight),
                    // Franchise Lab Checkbox
                    Container(
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(defaultRadius),
                        border: Border.all(color: color.withValues(alpha: 0.2)),
                      ),
                      child: CheckboxListTile(
                        title: Text(
                          'Franchise Lab Category',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          'Enable this if bills with this category require franchise name',
                          style: theme.textTheme.bodySmall,
                        ),
                        value: _isFranchiseLab,
                        activeColor: color,
                        onChanged: (value) {
                          setState(() {
                            _isFranchiseLab = value ?? false;
                          });
                        },
                      ),
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

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final category = DiagnosisCategory(
        id: _isEditMode ? widget.category!.id : 0,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        isFranchiseLab: _isFranchiseLab,
        isActive: true,
      );

      if (_isEditMode) {
        await ref.read(updateCategoryProvider(category).future);
        if (mounted) {
          showSuccessSnackBar(context, 'Category updated successfully!');
        }
      } else {
        await ref.read(addCategoryProvider(category).future);
        if (mounted) {
          showSuccessSnackBar(context, 'Category created successfully!');
        }
      }

      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        _showErrorDialog(
          'Operation Failed',
          e.toString().replaceAll("Exception: ", ""),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _handleDelete() async {
    final confirmed = await showDeleteConfirmationDialog(
      context: context,
      title: 'Confirm Deletion',
      message:
          'Are you sure you want to delete ${widget.category!.name}?\nThis action cannot be undone.',
    );

    if (!confirmed) return;

    setState(() => _isDeleting = true);
    try {
      await ref.read(deleteCategoryProvider(widget.category!.id).future);
      if (mounted) {
        showSuccessSnackBar(context, 'Category deleted successfully!');
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(
          'Delete Failed',
          e.toString().replaceAll("Exception: ", ""),
        );
      }
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  void _showErrorDialog(String title, String errorMessage) {
    showDialog(
      context: context,
      builder: (context) =>
          ErrorDialog(title: title, errorMessage: errorMessage),
    );
  }
}
