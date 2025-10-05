import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/main.dart';
import 'package:labledger/providers/sample_reports_provider.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:labledger/models/sample_report_model.dart';
import 'package:labledger/models/report_upload_data_model.dart';
import 'package:labledger/providers/patient_report_provider.dart';
import 'package:labledger/screens/ui_components/searchable_dropdown_field.dart';

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
    with SingleTickerProviderStateMixin {
  String? _selectedCategory;
  SampleReportModel? _selectedReportFromServer;
  File? _reportFileToUpload;
  bool _isLoading = false;
  late TabController _tabController;

  final _reportNameController = TextEditingController();
  final _categoryNameController =
      TextEditingController(); // ✅ Add this controller

  final List<String> _categories = const [
    "Ultrasound",
    "Franchise Lab",
    "ECG",
    "X-Ray",
    "Pathology",
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _reportNameController.dispose();
    _tabController.dispose();
    _categoryNameController.dispose();
    super.dispose();
  }

  Future<void> _pickLocalFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['doc', 'docx', 'pdf'],
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
      final response = await http.get(
        Uri.parse(_selectedReportFromServer!.sampleReportFile),
      );
      final tempDir = await getTemporaryDirectory();
      final fileName =
          'LabLedgerServerReport${DateFormat("dd MMM yyy hh ss SSS").format(DateTime.now())}.${_selectedReportFromServer!.sampleReportFile.split('.').last}';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(response.bodyBytes);

      final openResult = await OpenFile.open(file.path);

      if (openResult.type == ResultType.done) {
        setState(() {
          _reportFileToUpload = file;
        });
      } else {
        ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
          SnackBar(
            content: Text('Could not open file: ${openResult.message}'),
            backgroundColor: Theme.of(
              navigatorKey.currentContext!,
            ).colorScheme.error,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        SnackBar(
          content: Text('Failed to download report: $e'),
          backgroundColor: Theme.of(
            navigatorKey.currentContext!,
          ).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _uploadReport() async {
    if (_reportFileToUpload == null) return;
    setState(() => _isLoading = true);

    try {
      final uploadData = ReportUploadData(
        billId: widget.billId,
        filePath: _reportFileToUpload!.path,
      );

      if (await _reportFileToUpload!.exists()) {
        await ref.read(createPatientReportProvider(uploadData).future);
        try {
          final Directory tempDir = await getTemporaryDirectory();

          if (_reportFileToUpload!.path.startsWith(tempDir.path)) {
            await _reportFileToUpload!.delete();
          }
        } catch (e) {
          ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
            SnackBar(
              duration: Duration(seconds: 7),
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(
                    "Please close the editor before pressing the \"Upload Report\" button to optimize disk usage",
                  ),
                ],
              ),
              backgroundColor: Theme.of(
                navigatorKey.currentContext!,
              ).colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.of(navigatorKey.currentContext!).pop();
        }
        ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text('Report uploaded successfully!'),
              ],
            ),
            backgroundColor: Theme.of(
              navigatorKey.currentContext!,
            ).colorScheme.secondary,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(navigatorKey.currentContext!).pop();
      } else {
        ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
          SnackBar(
            content: Text('Report not found'),
            backgroundColor: Theme.of(
              navigatorKey.currentContext!,
            ).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        SnackBar(
          content: Text('Upload failed: $e'),
          backgroundColor: Theme.of(
            navigatorKey.currentContext!,
          ).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isReadyToUpload = _reportFileToUpload != null;
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
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
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.upload_file_rounded,
                        color: widget.color,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
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
                          const SizedBox(height: 4),
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
                margin: const EdgeInsets.all(20),
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
                padding: const EdgeInsets.all(20),
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
                    // File indicator
                    if (isReadyToUpload)
                      Expanded(
                        child: Container(
                          height: 50,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: widget.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
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
                              const SizedBox(width: 8),
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
                    const SizedBox(width: 12),
                    // Action buttons
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            fixedSize: const Size(160, 50),
                            foregroundColor: widget.color,
                            side: BorderSide(color: widget.color),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                defaultRadius,
                              ),
                            ),
                          ),
                          icon: const Icon(Icons.close_outlined),
                          label: const Text('Cancel'),
                        ),

                        const SizedBox(width: 8),
                        if (_isLoading && isReadyToUpload)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 12,
                            ),
                            child: const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        else if (isReadyToUpload)
                          ElevatedButton.icon(
                            onPressed: _uploadReport,
                            icon: const Icon(Icons.upload_rounded, size: 20),
                            label: const Text('Upload Report'),
                            style: ElevatedButton.styleFrom(
                              fixedSize: const Size(200, 50),
                              backgroundColor: widget.color,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  defaultRadius,
                                ),
                              ),
                            ),
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
            const SizedBox(height: 16),
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
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.errorContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 12),
              Text(
                'Error loading templates',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
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
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Category Selection Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
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
                        const SizedBox(width: 8),
                        Text(
                          'Select Category',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: widget.color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SearchableDropdownField<String>(
                      label: 'Select Category',
                      controller:
                          _categoryNameController, // Use the new controller
                      items: _categories,
                      color: widget.color,
                      valueMapper: (item) =>
                          item, // The item itself is the string to display
                      onSelected: (value) {
                        setState(() {
                          _selectedCategory = value;
                          _categoryNameController.text =
                              value; // Update the text field
                          // Reset the report selection when the category changes
                          _selectedReportFromServer = null;
                          _reportNameController.clear();
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Report Template Selection Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
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
                        const SizedBox(width: 8),
                        Text(
                          'Report Template',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: widget.color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
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
              const SizedBox(height: 24),

              // Download Action Card
              if (_selectedReportFromServer != null)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.color.withValues(alpha: 0.1),
                        widget.color.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
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
                      const SizedBox(height: 12),
                      Text(
                        'Download & Edit Template',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: widget.color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Download the template, fill it out, and it will be ready to upload',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      if (_isLoading)
                        const CircularProgressIndicator()
                      else
                        ElevatedButton.icon(
                          onPressed: _downloadAndOpenFile,
                          icon: const Icon(Icons.download_rounded),
                          label: const Text('Download Template'),
                          style: ElevatedButton.styleFrom(
                            fixedSize: const Size(200, 50),
                            backgroundColor: widget.color,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                defaultRadius,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
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
          InkWell(
            onTap: _pickLocalFile,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
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
                    padding: EdgeInsets.all(defaultPadding * 2),
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
                  const SizedBox(height: 24),
                  Text(
                    'Choose File from Device',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: widget.color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Supported formats: PDF, DOC, DOCX',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  SizedBox(height: defaultHeight),
                  ElevatedButton.icon(
                    onPressed: _pickLocalFile,
                    icon: const Icon(Icons.folder_open_rounded),
                    label: const Text('Browse Files'),
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(160, 50),
                      backgroundColor: widget.color,
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
          const SizedBox(height: 24),

          // Selected File Display
          if (_reportFileToUpload != null)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: widget.color.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: widget.color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getFileIcon(_reportFileToUpload!.path),
                      color: widget.color,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
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
                        const SizedBox(height: 4),
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
                      setState(() {
                        _reportFileToUpload = null;
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
        return Icons.description_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }
}
