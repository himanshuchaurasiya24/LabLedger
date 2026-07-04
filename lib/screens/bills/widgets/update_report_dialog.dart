import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:labledger/screens/ui_components/app_inkwell.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/main.dart';
import 'package:labledger/authentication/auth_http_client.dart';
import 'package:labledger/providers/sample_reports_provider.dart';
import 'package:labledger/providers/category_provider.dart';
import 'package:labledger/screens/ui_components/custom_elevated_button.dart';
import 'package:labledger/screens/ui_components/custom_error_dialog.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:labledger/utils/file_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:labledger/models/sample_report_model.dart';
import 'package:labledger/models/report_upload_data_model.dart';
import 'package:labledger/providers/patient_report_provider.dart';
import 'package:labledger/screens/ui_components/searchable_dropdown_field.dart';
import 'package:labledger/screens/ui_components/snackbar_utils.dart';
import 'package:labledger/utils/controller_disposer.dart';

class UpdateReportDialog extends ConsumerStatefulWidget {
  final Color color;
  final int billId;

  const UpdateReportDialog({
    super.key,
    required this.color,
    required this.billId,
  });

  @override
  ConsumerState<UpdateReportDialog> createState() => _UpdateReportDialogState();
}

class _UpdateReportDialogState extends ConsumerState<UpdateReportDialog>
    with SingleTickerProviderStateMixin, ControllerDisposer {
  String? _selectedCategory;
  SampleReportModel? _selectedReportFromServer;
  File? _reportFileToUpload;
  bool _isLoading = false;
  bool _isWaitingForEditorClose = false;
  Timer? _editorCloseTimer;
  late TabController _tabController;

  late final TextEditingController _reportNameController;
  late final TextEditingController _categoryNameController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _reportNameController = createController();
    _categoryNameController = createController();
  }

  @override
  void dispose() {
    _editorCloseTimer?.cancel();
    disposeControllers();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _pickLocalFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'odt', 'jpg', 'jpeg', 'png'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _reportFileToUpload = File(result.files.single.path!);
      });
    }
  }

  Future<void> _downloadAndOpenFile() async {
    if (_selectedReportFromServer?.sampleReportFile == null) return;
    setState(() => _isLoading = true);

    try {
      final reportUri = Uri.parse(_selectedReportFromServer!.sampleReportFile);
      final response = await AuthHttpClient.get(
        ref,
        reportUri.toString(),
        throwOnError: false,
      );

      if (response.statusCode != 200) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => ErrorDialog(
              title: 'Download Error',
              errorMessage:
                  'HTTP ${response.statusCode}: The selected report is not available on the server right now. Please upload it again or select another report.',
            ),
          );
        }
        return;
      }

      final tempDir = await getTemporaryDirectory();
      final fileName =
          'LabLedgerServerReport${DateFormat("dd MMM yyy hh ss SSS").format(DateTime.now())}.${_selectedReportFromServer!.sampleReportFile.split('.').last}';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(response.bodyBytes);

      if (mounted) {
        setState(() {
          _reportFileToUpload = file;
          _isWaitingForEditorClose = true;
        });
      }

      final openResult = await FileUtils.openFile(file.path);

      if (openResult.type == ResultType.done) {
        _startWaitingForEditorClose(file);
      } else {
        _editorCloseTimer?.cancel();
        if (mounted) {
          setState(() {
            _isWaitingForEditorClose = false;
          });
        }
        showErrorSnackBar(
          navigatorKey.currentContext!,
          'Could not open file: ${openResult.message}',
        );
      }
    } catch (e) {
      _editorCloseTimer?.cancel();
      if (mounted) {
        setState(() {
          _isWaitingForEditorClose = false;
        });
      }
      showErrorSnackBar(
        navigatorKey.currentContext!,
        'Failed to download report: $e',
      );
    } finally {
      if (mounted && !_isWaitingForEditorClose) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _startWaitingForEditorClose(File file) {
    _editorCloseTimer?.cancel();
    _editorCloseTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (!mounted) return;

      final bool isFileStillInUse = await _isFileStillInUse(file);
      if (!mounted) return;

      if (!isFileStillInUse) {
        _editorCloseTimer?.cancel();
        _editorCloseTimer = null;
        setState(() {
          _isLoading = false;
          _isWaitingForEditorClose = false;
        });
      }
    });
  }

  Future<bool> _isFileStillInUse(File file) async {
    try {
      final access = await file.open(mode: FileMode.writeOnlyAppend);
      await access.close();
      return false;
    } on FileSystemException {
      return true;
    }
  }

  Future<bool> _deleteTempFile(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  void _showCleanupWarning() {
    debugPrint("warning was called!");
    showCustomSnackBar(
      context: navigatorKey.currentContext!,
      message:
          'Report uploaded, but the temporary file could not be deleted. Close the editor after saving to avoid higher disk usage.',
      icon: Icons.warning_rounded,
      backgroundColor: Theme.of(
        navigatorKey.currentContext!,
      ).colorScheme.secondary,
      clearSnackBars: true,
    );
  }

  Future<void> _uploadReport() async {
    if (_reportFileToUpload == null) return;
    final int fileSizeBytes = await _reportFileToUpload!.length();
    if (fileSizeBytes > maxFileSize) {
      showDialog(
        context: navigatorKey.currentContext!,
        builder: (context) {
          return ErrorDialog(
            title: "Size Limit",
            errorMessage: "File size limit is $maxFileSizeMb MB only.",
          );
        },
      );

      return;
    }

    setState(() => _isLoading = true);

    try {
      final uploadData = ReportUploadData(
        billId: widget.billId,
        filePath: _reportFileToUpload!.path,
      );

      if (await _reportFileToUpload!.exists()) {
        await ref.read(createPatientReportProvider(uploadData).future);
        if (mounted) {
          showSuccessSnackBar(
            navigatorKey.currentContext!,
            'Report uploaded successfully!',
          );
        }

        final bool deletedTempFile = await _deleteTempFile(
          _reportFileToUpload!,
        );
        if (!deletedTempFile && mounted) {
          _showCleanupWarning();
        }

        if (mounted) {
          Navigator.of(navigatorKey.currentContext!).pop();
        }
      } else {
        showErrorSnackBar(navigatorKey.currentContext!, 'Report not found');
      }
    } catch (e) {
      showErrorSnackBar(navigatorKey.currentContext!, 'Upload failed: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isReadyToUpload =
        _reportFileToUpload != null && !_isWaitingForEditorClose;
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(largeRadius)),
      child: ClipRRect(
        borderRadius: BorderRadiusGeometry.circular(20),
        child: Container(
          width: 650,
          constraints: const BoxConstraints(maxHeight: 800),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Modern Header
              Container(
                padding: const EdgeInsets.all(xlargePadding),
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(largeRadius),
                    topRight: Radius.circular(largeRadius),
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: widget.color.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(defaultPadding),
                      decoration: BoxDecoration(
                        color: widget.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(defaultRadius),
                      ),
                      child: Icon(
                        Icons.upload_file_rounded,
                        color: widget.color,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: mediumPadding),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Update Report',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: minimalPadding),
                          Text(
                            'Upload or select a report template',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                      style: IconButton.styleFrom(
                        backgroundColor: theme.colorScheme.surface,
                      ),
                    ),
                  ],
                ),
              ),

              // Modern Tab Bar
              Container(
                margin: const EdgeInsets.all(largePadding),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(defaultRadius),
                ),
                child: TabBar(
                  controller: _tabController,
                  splashBorderRadius: BorderRadius.circular(defaultRadius),
                  indicator: BoxDecoration(
                    color: widget.color,
                    borderRadius: BorderRadius.circular(defaultRadius),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: Colors.white,
                  unselectedLabelColor: theme.colorScheme.onSurface.withValues(
                    alpha: 0.6,
                  ),
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                  tabs: const [
                    Tab(
                      icon: Icon(Icons.cloud_download_rounded, size: 20),
                      text: 'From Server',
                      height: 56,
                    ),
                    Tab(
                      icon: Icon(Icons.folder_rounded, size: 20),
                      text: 'From Device',
                      height: 56,
                    ),
                  ],
                ),
              ),

              // Content Area
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [_buildFromServerTab(), _buildFromLocalTab()],
                ),
              ),

              // Modern Action Bar
              Container(
                padding: const EdgeInsets.all(largePadding),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.3,
                  ),
                  border: Border(
                    top: BorderSide(
                      color: theme.colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (isReadyToUpload)
                      Expanded(
                        child: Container(
                          height: 50,
                          padding: const EdgeInsets.symmetric(
                            horizontal: mediumPadding,
                            vertical: defaultPadding,
                          ),
                          decoration: BoxDecoration(
                            color: widget.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(dialogRadius),
                            border: Border.all(
                              color: widget.color.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                color: widget.color,
                                size: 20,
                              ),
                              const SizedBox(width: smallPadding),
                              Expanded(
                                child: Text(
                                  'Ready to upload',
                                  style: TextStyle(
                                    color: widget.color,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      const SizedBox.shrink(),
                    const SizedBox(width: defaultPadding),
                    Row(
                      children: [
                        CustomElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          label: 'Cancel',
                          icon: const Icon(Icons.close_outlined),
                          width: 160,
                          height: 50,
                          outlined: true,
                          foregroundColor: widget.color,
                          borderColor: widget.color,
                        ),
                        const SizedBox(width: smallPadding),
                        if (_isLoading && isReadyToUpload)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: defaultPadding,
                            ),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        else if (isReadyToUpload)
                          CustomElevatedButton(
                            onPressed: _uploadReport,
                            label: 'Upload Report',
                            icon: const Icon(Icons.upload_rounded),
                            width: 200,
                            height: 50,
                            backgroundColor: widget.color,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFromServerTab() {
    final allReportsAsync = ref.watch(allSampleReportsProvider);
    final theme = Theme.of(context);

    return allReportsAsync.when(
      loading: () => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: widget.color),
            const SizedBox(height: mediumPadding),
            Text(
              'Loading templates...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
      error: (err, stack) => Center(
        child: Container(
          padding: const EdgeInsets.all(xlargePadding),
          margin: const EdgeInsets.all(largePadding),
          decoration: BoxDecoration(
            color: theme.colorScheme.errorContainer,
            borderRadius: BorderRadius.circular(defaultRadius),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: defaultPadding),
              Text(
                'Error loading templates',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: smallPadding),
              Text(
                err.toString(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      data: (allReports) {
        final filteredReports = _selectedCategory == null
            ? allReports
            : allReports.where((r) => r.category == _selectedCategory).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: largePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(intermediatePadding),
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(defaultRadius),
                  border: Border.all(
                    color: widget.color.withValues(alpha: 0.25),
                  ),
                ),
                child: Text(
                  'Supported upload formats: PDF, DOC, DOCX, ODT, JPG, JPEG, PNG  •  Max file size: $maxFileSizeMb MB (1 MB = 1024 KB)',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: mediumPadding),

              // Category Selection Card
              Container(
                padding: const EdgeInsets.all(largePadding),
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(mediumRadius),
                  border: Border.all(
                    color: widget.color.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.category_rounded,
                          color: widget.color,
                          size: 20,
                        ),
                        const SizedBox(width: smallPadding),
                        Text(
                          'Select Category',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: widget.color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: defaultPadding),
                    // Dynamic Category Dropdown
                    Consumer(
                      builder: (context, ref, child) {
                        final categoriesAsync = ref.watch(categoriesProvider);

                        return categoriesAsync.when(
                          data: (categories) {
                            final categoryNames = categories
                                .map((c) => c.name)
                                .toList();
                            return SearchableDropdownField<String>(
                              label: 'Select Category',
                              controller: _categoryNameController,
                              items: categoryNames,
                              color: widget.color,
                              valueMapper: (item) => item,
                              onSelected: (value) {
                                setState(() {
                                  _selectedCategory = value;
                                  _categoryNameController.text = value;
                                  // Reset the report selection when the category changes
                                  _selectedReportFromServer = null;
                                  _reportNameController.clear();
                                });
                              },
                            );
                          },
                          loading: () => const Center(
                            child: Padding(
                              padding: EdgeInsets.all(mediumPadding),
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          error: (err, stack) => Padding(
                            padding: const EdgeInsets.all(smallPadding),
                            child: Text(
                              'Error loading categories',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: largePadding),

              // Report Template Selection Card
              Container(
                padding: const EdgeInsets.all(largePadding),
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(mediumRadius),
                  border: Border.all(
                    color: widget.color.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.description_rounded,
                          color: widget.color,
                          size: 20,
                        ),
                        const SizedBox(width: smallPadding),
                        Text(
                          'Report Template',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: widget.color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: defaultPadding),
                    SearchableDropdownField<SampleReportModel>(
                      label: 'Select Report Template',
                      controller: _reportNameController,
                      items: filteredReports,
                      color: widget.color,
                      valueMapper: (report) => report.diagnosisName,
                      onSelected: (report) {
                        setState(() {
                          _selectedReportFromServer = report;
                          _reportNameController.text = report.diagnosisName;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: xlargePadding),

              // Download Action Card
              if (_selectedReportFromServer != null)
                Container(
                  padding: const EdgeInsets.all(largePadding),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.color.withValues(alpha: 0.1),
                        widget.color.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(mediumRadius),
                    border: Border.all(
                      color: widget.color.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.cloud_download_rounded,
                        size: 48,
                        color: widget.color,
                      ),
                      const SizedBox(height: defaultPadding),
                      Text(
                        'Download & Edit Template',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: widget.color,
                        ),
                      ),
                      const SizedBox(height: smallPadding),
                      Text(
                        'Download the template, fill it out, and it will be ready to upload',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: mediumPadding),
                      if (_isLoading)
                        Column(
                          children: [
                            CircularProgressIndicator(color: widget.color),
                            if (_isWaitingForEditorClose) ...[
                              const SizedBox(height: defaultPadding),
                              Text(
                                'Waiting for the editor to close...',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ],
                        )
                      else
                        CustomElevatedButton(
                          onPressed: _downloadAndOpenFile,
                          label: 'Download Template',
                          icon: const Icon(Icons.download_rounded),
                          width: 260,
                          height: 50,
                          backgroundColor: widget.color,
                        ),
                    ],
                  ),
                ),
              const SizedBox(height: largePadding),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFromLocalTab() {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(defaultPadding),
      child: Column(
        children: [
          SizedBox(height: defaultHeight / 3),
          // Upload Area
          AppInkWell(
            onTap: _pickLocalFile,
            borderRadius: BorderRadius.circular(mediumRadius),
            child: Container(
              padding: const EdgeInsets.all(xxlargePadding),
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(mediumRadius),
                border: Border.all(
                  color: widget.color.withValues(alpha: 0.3),
                  width: 2,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(defaultPadding * microPadding),
                    decoration: BoxDecoration(
                      color: widget.color.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.upload_file_rounded,
                      size: 56,
                      color: widget.color,
                    ),
                  ),
                  const SizedBox(height: xlargePadding),
                  Text(
                    'Choose File from Device',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: widget.color,
                    ),
                  ),
                  const SizedBox(height: smallPadding),
                  Text(
                    'Supported formats: PDF, DOC, DOCX, ODT, JPG, JPEG, PNG',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Max file size: $maxFileSizeMb MB (1 MB = 1024 KB)',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  SizedBox(height: defaultHeight),
                  CustomElevatedButton(
                    onPressed: _pickLocalFile,
                    label: 'Browse Files',
                    icon: const Icon(Icons.folder_open_rounded),
                    width: 190,
                    height: 50,
                    backgroundColor: widget.color,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: xlargePadding),

          // Selected File Display
          if (_reportFileToUpload != null)
            Container(
              padding: const EdgeInsets.all(largePadding),
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(mediumRadius),
                border: Border.all(color: widget.color.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(defaultPadding),
                    decoration: BoxDecoration(
                      color: widget.color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(dialogRadius),
                    ),
                    child: Icon(
                      _getFileIcon(_reportFileToUpload!.path),
                      color: widget.color,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: mediumPadding),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selected File',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: minimalPadding),
                        Text(
                          _reportFileToUpload!.path.split('/').last,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: widget.color,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      _editorCloseTimer?.cancel();
                      setState(() {
                        _reportFileToUpload = null;
                        _isWaitingForEditorClose = false;
                      });
                    },
                    icon: const Icon(Icons.close_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: theme.colorScheme.surface,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  IconData _getFileIcon(String path) {
    final extension = path.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'doc':
      case 'docx':
      case 'odt':
        return Icons.description_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }
}
