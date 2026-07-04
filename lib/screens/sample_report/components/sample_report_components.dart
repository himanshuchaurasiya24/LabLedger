import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/models/sample_report_model.dart';
import 'package:labledger/providers/category_provider.dart';
import 'package:labledger/screens/sample_report/methods/sample_report_methods.dart';
import 'package:labledger/screens/ui_components/custom_elevated_button.dart';
import 'package:labledger/screens/ui_components/custom_text_field.dart';
import 'package:labledger/screens/ui_components/searchable_dropdown_field.dart';
import 'package:labledger/screens/sample_report/components/file_upload_widget.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class ReportFormDialog extends ConsumerStatefulWidget {
  const ReportFormDialog({
    super.key,
    required this.mode,
    this.existingReport,
    required this.themeColor,
  });

  final FormMode mode;
  final SampleReportModel? existingReport;
  final Color themeColor;

  @override
  ConsumerState<ReportFormDialog> createState() => _ReportFormDialogState();
}

class _ReportFormDialogState extends ConsumerState<ReportFormDialog> {
  late SampleReportMethods _methods;

  @override
  void initState() {
    super.initState();
    _methods = SampleReportMethods(context, ref);
    _methods.initializeForm(widget.existingReport);
  }

  @override
  void dispose() {
    _methods.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _methods,
      builder: (context, _) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(largeRadius)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(largeRadius),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 700, maxHeight: 800),
            color: theme.colorScheme.surface,
            child: Form(
              key: _methods.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(xlargePadding),
                    decoration: BoxDecoration(
                      color: widget.themeColor.withValues(alpha: 0.1),
                      border: Border(
                        bottom: BorderSide(
                          color: widget.themeColor.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(formPadding),
                          decoration: BoxDecoration(
                            color: widget.themeColor.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(dialogRadius),
                          ),
                          child: Icon(
                            Icons.description,
                            color: widget.themeColor,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: defaultPadding),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.mode == FormMode.create
                                    ? 'Add Sample Report'
                                    : 'Edit Report',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.87,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Upload or select a report template',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.75,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close_rounded),
                          style: IconButton.styleFrom(
                            backgroundColor: theme.colorScheme.surface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(defaultPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Diagnosis Name
                          CustomTextField(
                            controller: _methods.diagnosisNameController,
                            label: 'Diagnosis Name',
                            isRequired: true,
                            tintColor: widget.themeColor,
                            prefixIcon: const Icon(Icons.medical_services),
                          ),
                          SizedBox(height: defaultHeight),

                          // Category Dropdown (dynamic from backend)
                          Consumer(
                            builder: (context, ref, child) {
                              final categoriesAsync = ref.watch(
                                categoriesProvider,
                              );

                              return categoriesAsync.when(
                                data: (categories) {
                                  final categoryNames = categories
                                      .map((c) => c.name)
                                      .toList();
                                  return SearchableDropdownField<String>(
                                    label: 'Category',
                                    controller: _methods.categoryController,
                                    color: widget.themeColor,
                                    items: categoryNames,
                                    valueMapper: (category) => category,
                                    validator: (value) {
                                      if (_methods.selectedCategory == null ||
                                          _methods.selectedCategory!.isEmpty) {
                                        return 'Please select a category';
                                      }
                                      return null;
                                    },
                                    onSelected: (category) {
                                      _methods.updateSelectedCategory(category);
                                    },
                                  );
                                },
                                loading: () => CustomTextField(
                                  label: 'Category',
                                  controller: _methods.categoryController,
                                  readOnly: true,
                                  tintColor: widget.themeColor,
                                  suffixIcon: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation(
                                        widget.themeColor,
                                      ),
                                    ),
                                  ),
                                ),
                                error: (err, stack) => CustomTextField(
                                  label: 'Category (Error loading)',
                                  controller: _methods.categoryController,
                                  readOnly: true,
                                  tintColor: Colors.red,
                                  suffixIcon: Icon(
                                    Icons.error,
                                    color: Colors.red,
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: defaultHeight),

                          FileUploadWidget(
                            themeColor: widget.themeColor,
                            selectedFile: _methods.selectedFile,
                            currentFileName: _methods.currentFileName,
                            isSubmitting: _methods.isSubmitting,
                            onClearFile: _methods.clearSelectedFile,
                            onPickFile: _methods.pickFile,
                          ),
                        ],
                      ),
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.all(largePadding),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.35,
                      ),
                      border: Border(
                        top: BorderSide(
                          color: theme.colorScheme.outline.withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CustomElevatedButton(
                          onPressed: _methods.isSubmitting
                              ? null
                              : () => Navigator.pop(context),
                          label: 'Cancel',
                          icon: const Icon(Icons.close_outlined),
                          width: 130,
                          height: 46,
                          outlined: true,
                          foregroundColor: widget.themeColor,
                          borderColor: widget.themeColor,
                        ),
                        const SizedBox(width: 10),
                        CustomElevatedButton(
                          onPressed: _methods.isSubmitting ? null : () => _methods.submitForm(widget.mode, widget.existingReport),
                          width: 160,
                          height: 46,
                          backgroundColor: widget.themeColor,
                          icon: _methods.isSubmitting
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Icon(
                                  widget.mode == FormMode.create
                                      ? Icons.add
                                      : LucideIcons.upload,
                                  size: 16,
                                ),
                          label: _methods.isSubmitting
                              ? 'Saving...'
                              : (widget.mode == FormMode.create
                                    ? 'Create'
                                    : 'Update'),
                          fontSize: 16,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
