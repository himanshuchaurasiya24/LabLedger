import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/models/sample_report_model.dart';
import 'package:labledger/providers/sample_reports_provider.dart';
import 'package:labledger/screens/initials/window_scaffold.dart';
import 'package:labledger/screens/ui_components/custom_error_dialog.dart';
import 'package:labledger/screens/ui_components/custom_text_field.dart';
import 'package:labledger/screens/ui_components/searchable_dropdown_field.dart';
import 'package:labledger/screens/ui_components/tinted_container.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

const List<String> categoryOptions = [
  "Ultrasound",
  "Franchise Lab",
  "ECG",
  "X-Ray",
  "Pathology",
];

class SampleReportManagementScreen extends ConsumerWidget {
  const SampleReportManagementScreen({super.key, this.baseColor});

  final Color? baseColor;

  int getCrossAxisCount(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if (size.width < 1600 && size.width > 1200) {
      return 3;
    }
    if (size.width < 1200) {
      return 2;
    }
    return 4;
  }

  double getChildAspectRatio(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if (size.width < 1600 && size.width > 1200) {
      return 2.3;
    }
    if (size.width < 1200 || size.width > 1600) {
      return 2.7;
    }
    return 2.3;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveColor = baseColor ?? colorScheme.secondary;
    final sampleReportsAsync = ref.watch(allSampleReportsProvider);

    return WindowScaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(defaultRadius),
        ),
        onPressed: () => _showCreateDialog(context, effectiveColor),
        label: const Text(
          "Add Report",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        icon: const Icon(LucideIcons.plus),
      ),
      child: sampleReportsAsync.when(
        data: (reports) =>
            _buildReportsList(context, ref, reports, effectiveColor),
        loading: () => _buildLoadingState(context, effectiveColor),
        error: (error, stack) =>
            _buildErrorState(context, ref, error, effectiveColor),
      ),
    );
  }

  Widget _buildReportsList(
    BuildContext context,
    WidgetRef ref,
    List<SampleReportModel> reports,
    Color effectiveColor,
  ) {
    if (reports.isEmpty) {
      return _buildEmptyState(context, effectiveColor);
    }

    return GridView.builder(
      padding: EdgeInsets.all(defaultPadding),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: getCrossAxisCount(context),
        crossAxisSpacing: defaultPadding,
        mainAxisSpacing: defaultPadding,
        childAspectRatio: getChildAspectRatio(context),
      ),
      itemCount: reports.length,
      itemBuilder: (context, index) {
        return _buildReportCard(context, ref, reports[index], effectiveColor);
      },
    );
  }

  Widget _buildReportCard(
    BuildContext context,
    WidgetRef ref,
    SampleReportModel report,
    Color effectiveColor,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : effectiveColor;

    return TintedContainer(
      baseColor: effectiveColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(defaultRadius),
        onTap: () {
          _showEditDialog(context, report, effectiveColor);
        },
        child: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: effectiveColor.withValues(alpha: 0.2),
                  child: Icon(Icons.description, color: textColor, size: 32),
                ),
                SizedBox(width: defaultWidth),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        report.diagnosisName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          fontSize: 22,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        report.category,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: textColor,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.insert_drive_file,
                            size: 16,
                            color: textColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            report.sampleReportFile.isNotEmpty
                                ? 'File uploaded'
                                : 'No file',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: textColor,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              top: 40,
              right: 0,
              child: PopupMenuButton<String>(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(defaultRadius),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                color: Theme.of(context).colorScheme.surface,
                icon: Icon(Icons.more_vert, color: textColor),
                onSelected: (value) {
                  if (value == 'edit') {
                    _showEditDialog(context, report, effectiveColor);
                  } else if (value == 'download' &&
                      report.sampleReportFile.isNotEmpty) {
                    _downloadReport(context, report);
                  } else if (value == 'delete') {
                    _confirmDelete(context, ref, report);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: effectiveColor),
                        SizedBox(width: 8),
                        Text('Edit', style: TextStyle(color: effectiveColor)),
                      ],
                    ),
                  ),
                  if (report.sampleReportFile.isNotEmpty)
                    PopupMenuItem(
                      value: 'download',
                      child: Row(
                        children: [
                          Icon(Icons.download, color: effectiveColor),
                          SizedBox(width: 8),
                          Text(
                            'Download',
                            style: TextStyle(color: effectiveColor),
                          ),
                        ],
                      ),
                    ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: theme.colorScheme.error),
                        const SizedBox(width: 8),
                        Text(
                          'Delete',
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context, Color effectiveColor) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final shimmerColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;

    return GridView.builder(
      padding: EdgeInsets.all(defaultPadding),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: getCrossAxisCount(context),
        crossAxisSpacing: defaultPadding,
        mainAxisSpacing: defaultPadding,
        childAspectRatio: getChildAspectRatio(context),
      ),
      itemCount: 8,
      itemBuilder: (context, index) {
        return TintedContainer(
          baseColor: effectiveColor,
          intensity: 0.05,
          child: _buildSkeletonLoader(context, shimmerColor),
        );
      },
    );
  }

  Widget _buildSkeletonLoader(BuildContext context, Color shimmerColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        CircleAvatar(radius: 40, backgroundColor: shimmerColor),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 22,
              width: 180,
              decoration: BoxDecoration(
                color: shimmerColor,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 16,
              width: 150,
              decoration: BoxDecoration(
                color: shimmerColor,
                borderRadius: BorderRadius.circular(7),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    WidgetRef ref,
    Object error,
    Color effectiveColor,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: TintedContainer(
        baseColor: Theme.of(context).colorScheme.error,
        intensity: 0.1,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.error),
            SizedBox(height: defaultPadding),
            Text(
              'Failed to load sample reports',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: defaultPadding),
            ElevatedButton.icon(
              onPressed: () {
                ref.invalidate(allSampleReportsProvider);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: effectiveColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, Color effectiveColor) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: TintedContainer(
        baseColor: effectiveColor,
        intensity: 0.08,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.description_outlined, size: 64, color: effectiveColor),
            SizedBox(height: defaultPadding),
            Text(
              'No sample reports found',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first report to get started',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: defaultPadding),
            ElevatedButton.icon(
              onPressed: () => _showCreateDialog(context, effectiveColor),
              icon: const Icon(Icons.add),
              label: const Text('Add Report'),
              style: ElevatedButton.styleFrom(
                backgroundColor: effectiveColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateDialog(BuildContext context, Color effectiveColor) {
    showDialog(
      context: context,
      builder: (context) =>
          _ReportFormDialog(mode: FormMode.create, themeColor: effectiveColor),
    );
  }

  void _showEditDialog(
    BuildContext context,
    SampleReportModel report,
    Color effectiveColor,
  ) {
    showDialog(
      context: context,
      builder: (context) => _ReportFormDialog(
        mode: FormMode.edit,
        existingReport: report,
        themeColor: effectiveColor,
      ),
    );
  }

  Future<void> _downloadReport(
    BuildContext context,
    SampleReportModel report,
  ) async {
    if (report.sampleReportFile.isEmpty) return;

    try {
      final uri = Uri.parse(report.sampleReportFile);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Could not open file URL');
      }
    } catch (e) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) =>
              ErrorDialog(title: 'Download Failed', errorMessage: e.toString()),
        );
      }
    }
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    SampleReportModel report,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Report'),
        content: Text(
          'Are you sure you want to delete "${report.diagnosisName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(deleteSampleReportProvider(report.id!).future);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
            behavior: SnackBarBehavior.floating,

                      content: Text('Report deleted successfully'),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  showDialog(
                    context: context,
                    builder: (context) => ErrorDialog(
                      title: 'Delete Failed',
                      errorMessage: e.toString(),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

enum FormMode { create, edit }

class _ReportFormDialog extends ConsumerStatefulWidget {
  const _ReportFormDialog({
    required this.mode,
    this.existingReport,
    required this.themeColor,
  });

  final FormMode mode;
  final SampleReportModel? existingReport;
  final Color themeColor;

  @override
  ConsumerState<_ReportFormDialog> createState() => _ReportFormDialogState();
}

class _ReportFormDialogState extends ConsumerState<_ReportFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _diagnosisNameController;
  late final TextEditingController _categoryController;

  String? _selectedCategory;
  File? _selectedFile;
  String? _currentFileName;
  bool _isSubmitting = false;
  final bool _isFromServer = true;

  @override
  void initState() {
    super.initState();
    _diagnosisNameController = TextEditingController(
      text: widget.existingReport?.diagnosisName ?? '',
    );
    _categoryController = TextEditingController(
      text: widget.existingReport?.category ?? '',
    );
    _selectedCategory = widget.existingReport?.category;

    if (widget.existingReport?.sampleReportFile.isNotEmpty ?? false) {
      _currentFileName = widget.existingReport!.sampleReportFile
          .split('/')
          .last;
    }
  }

  @override
  void dispose() {
    _diagnosisNameController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(defaultRadius),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 800),
        child: TintedContainer(
          height: 800,
          baseColor: widget.themeColor,
          intensity: 0.05,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Padding(
                  padding: EdgeInsets.all(defaultPadding),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(defaultPadding * 0.75),
                        decoration: BoxDecoration(
                          color: widget.themeColor.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.description,
                          color: widget.themeColor,
                          size: 28,
                        ),
                      ),
                      SizedBox(width: defaultPadding),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.mode == FormMode.create
                                  ? 'Add Sample Report'
                                  : 'Edit Report',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Upload or select a report template',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: defaultHeight * 0.5),
                Divider(height: 1, color: Colors.grey.shade300),
                SizedBox(height: defaultHeight),

                // Form content
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: defaultPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Diagnosis Name
                        CustomTextField(
                          controller: _diagnosisNameController,
                          label: 'Diagnosis Name',
                          isRequired: true,
                          tintColor: widget.themeColor,
                          prefixIcon: const Icon(Icons.medical_services),
                        ),
                        SizedBox(height: defaultHeight),

                        // Category Dropdown
                        SearchableDropdownField<String>(
                          label: 'Category',
                          controller: _categoryController,
                          color: widget.themeColor,
                          items: categoryOptions,
                          valueMapper: (category) => category,
                          validator: (value) {
                            if (_selectedCategory == null ||
                                _selectedCategory!.isEmpty) {
                              return 'Please select a category';
                            }
                            return null;
                          },
                          onSelected: (category) {
                            setState(() {
                              _selectedCategory = category;
                              _categoryController.text = category;
                            });
                          },
                        ),
                        SizedBox(height: defaultHeight),

                        // File Upload Section
                        TintedContainer(
                          baseColor: widget.themeColor,
                          intensity: 0.08,
                          child: Column(
                            children: [
                              Icon(
                                Icons.upload_file,
                                size: 64,
                                color: widget.themeColor,
                              ),
                              SizedBox(height: defaultHeight),
                              Text(
                                'Choose File from Device',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: widget.themeColor,
                                ),
                              ),
                              SizedBox(height: defaultHeight * 0.5),
                              Text(
                                'Supported formats: DOC, DOCX, RTF',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              SizedBox(height: defaultHeight),
                              if (_selectedFile != null ||
                                  _currentFileName != null)
                                Container(
                                  padding: EdgeInsets.all(
                                    defaultPadding * 0.75,
                                  ),
                                  margin: EdgeInsets.only(
                                    bottom: defaultPadding,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surface,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: widget.themeColor.withValues(
                                        alpha: 0.3,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.description,
                                        color: widget.themeColor,
                                        size: 20,
                                      ),
                                      SizedBox(width: defaultPadding * 0.5),
                                      Expanded(
                                        child: Text(
                                          _selectedFile?.path.split('/').last ??
                                              _currentFileName ??
                                              '',
                                          style: theme.textTheme.bodyMedium,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (_selectedFile != null)
                                        IconButton(
                                          onPressed: () {
                                            setState(() {
                                              _selectedFile = null;
                                            });
                                          },
                                          icon: Icon(
                                            Icons.close,
                                            color: theme.colorScheme.error,
                                            size: 20,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ElevatedButton.icon(
                                onPressed: _pickFile,

                                style: ElevatedButton.styleFrom(
                                  fixedSize: const Size(160, 50),
                                  backgroundColor: widget.themeColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      defaultRadius,
                                    ),
                                  ),
                                ),
                                icon: _isSubmitting
                                    ? const SizedBox(
                                        height: 16,
                                        width: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                    : const Icon(Icons.folder_open),
                                label: Text(
                                  _isSubmitting
                                      ? 'Saving...'
                                      : ("Browse Files"),
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsetsGeometry.all(defaultPadding),
                  child: ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(160, 50),
                      backgroundColor: widget.themeColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(defaultRadius),
                      ),
                    ),
                    icon: _isSubmitting
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
                    label: Text(
                      _isSubmitting
                          ? 'Saving...'
                          : (widget.mode == FormMode.create
                                ? 'Create'
                                : 'Update'),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['doc', 'docx', 'rtf'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
        });
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => ErrorDialog(
            title: 'File Selection Error',
            errorMessage: e.toString(),
          ),
        );
      }
    }
  }

  Future<void> _submitForm() async {
    if (_isFromServer && !_formKey.currentState!.validate()) return;

    if (!_isFromServer &&
        _selectedFile == null &&
        widget.mode == FormMode.create) {
      showDialog(
        context: context,
        builder: (context) => const ErrorDialog(
          title: 'File Required',
          errorMessage: 'Please select a report file to upload.',
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final report = SampleReportModel(
        id: widget.existingReport?.id,
        diagnosisName: _diagnosisNameController.text.trim(),
        category: _selectedCategory!,
        sampleReportFile: widget.existingReport?.sampleReportFile ?? '',
        sampleReportFileLocal: _selectedFile,
      );

      if (widget.mode == FormMode.create) {
        await ref.read(createSampleReportProvider(report).future);
      } else {
        await ref.read(updateSampleReportProvider(report).future);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            
            content: Text(
              'Report ${widget.mode == FormMode.create ? 'created' : 'updated'} successfully',
            ),
            backgroundColor: widget.themeColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => ErrorDialog(
            title: widget.mode == FormMode.create
                ? 'Creation Failed'
                : 'Update Failed',
            errorMessage: e.toString(),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
