import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/models/diagnosis_category_model.dart';
import 'package:labledger/providers/authentication_provider.dart';
import 'package:labledger/providers/category_provider.dart';
import 'package:labledger/screens/initials/window_scaffold.dart';
import 'package:labledger/screens/ui_components/custom_elevated_button.dart';
import 'package:labledger/screens/ui_components/custom_error_dialog.dart';
import 'package:labledger/screens/ui_components/custom_outlined_button.dart';
import 'package:labledger/screens/ui_components/custom_text_field.dart';
import 'package:labledger/screens/ui_components/tinted_container.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CategoryEditScreen extends ConsumerStatefulWidget {
  const CategoryEditScreen({super.key, this.category, this.themeColor});

  final DiagnosisCategory? category;
  final Color? themeColor;

  @override
  ConsumerState<CategoryEditScreen> createState() => _CategoryEditScreenState();
}

class _CategoryEditScreenState extends ConsumerState<CategoryEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isFranchiseLab = false;
  bool _isSaving = false;
  bool _isDeleting = false;

  bool get _isEditMode => widget.category != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _nameController.text = widget.category!.name;
      _descriptionController.text = widget.category!.description ?? '';
      _isFranchiseLab = widget.category!.isFranchiseLab;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final title = _isEditMode ? widget.category!.name : 'New Category';
    final subtitle = _isEditMode
        ? widget.category!.description ?? 'Edit category details'
        : 'Enter category details below';

    final initials = _isEditMode ? _getInitials(widget.category!.name) : 'NC';

    final lightThemeColor = Color.lerp(
      color,
      isDark ? Colors.black : Colors.white,
      isDark ? 0.3 : 0.2,
    )!;

    return TintedContainer(
      baseColor: color,
      height: 160,
      radius: defaultRadius,
      intensity: isDark ? 0.15 : 0.08,
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
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
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
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? Colors.white70
                        : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: defaultHeight / 2),
                Row(
                  children: [
                    if (isAdmin && _isEditMode) ...[
                      _buildStatusBadge('Admin Edit Mode', Colors.purple),
                      SizedBox(width: defaultWidth / 2),
                    ],
                    _buildStatusBadge(
                      _isEditMode ? 'Edit Mode' : 'Create Mode',
                      _isEditMode
                          ? theme.colorScheme.primary
                          : theme.colorScheme.secondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (!_isEditMode || isAdmin)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomElevatedButton(
                  onPressed: _isSaving ? null : _handleSave,
                  label: _isSaving
                      ? 'Saving...'
                      : (_isEditMode ? 'Update Category' : 'Create Category'),
                  backgroundColor: color,
                  icon: _isSaving
                      ? SizedBox(
                          height: defaultHeight,
                          width: defaultWidth,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Icon(_isEditMode ? Icons.update : Icons.save),
                ),
                if (_isEditMode && isAdmin) ...[
                  SizedBox(height: defaultHeight / 2),
                  CustomOutlinedButton(
                    onPressed: _isDeleting ? null : _handleDelete,
                    label: _isDeleting ? 'Deleting...' : 'Delete',
                    icon: _isDeleting
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.colorScheme.error,
                            ),
                          )
                        : const Icon(Icons.delete_outline),
                  ),
                ],
              ],
            ),
        ],
      ),
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
        _showSuccessSnackBar('Category updated successfully!');
      } else {
        await ref.read(addCategoryProvider(category).future);
        _showSuccessSnackBar('Category created successfully!');
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 8),
            const Text('Confirm Deletion'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete ${widget.category!.name}?\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Delete',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isDeleting = true);
    try {
      await ref.read(deleteCategoryProvider(widget.category!.id).future);
      if (mounted) {
        _showSuccessSnackBar('Category deleted successfully!');
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

  String _getInitials(String name) {
    if (name.isEmpty) return '??';
    final parts = name.trim().split(RegExp(r'\\s+'));
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else {
      return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
    }
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

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showErrorDialog(String title, String errorMessage) {
    showDialog(
      context: context,
      builder: (context) =>
          ErrorDialog(title: title, errorMessage: errorMessage),
    );
  }
}
