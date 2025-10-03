import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:labledger/main.dart';
import 'package:labledger/providers/sample_reports_provider.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:labledger/models/sample_report_model.dart';
import 'package:labledger/models/report_upload_data_model.dart'; // Still need this one
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

class _UpdateReportDialogState extends ConsumerState<UpdateReportDialog> {
  // State variables (remain the same)
  String? _selectedCategory;
  SampleReportModel? _selectedReportFromServer;
  File? _reportFileToUpload;
  bool _isLoading = false;

  final _reportNameController = TextEditingController();
  final List<String> _categories = const [
    "Ultrasound",
    "Franchise Lab",
    "ECG",
    "X-Ray",
    "Pathology",
  ];

  // ... dispose, _pickLocalFile, and _downloadAndOpenFile methods remain the same ...
  @override
  void dispose() {
    _reportNameController.dispose();
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
    if (_selectedReportFromServer?.sampleReportFileUrl == null) return;
    setState(() => _isLoading = true);

    try {
      final response = await http.get(
        Uri.parse(_selectedReportFromServer!.sampleReportFileUrl!),
      );
      final tempDir = await getTemporaryDirectory();
      final fileName =
          'report_for_bill_${widget.billId}.${_selectedReportFromServer!.sampleReportFileUrl!.split('.').last}';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(response.bodyBytes);

      final openResult = await OpenFile.open(file.path);

      if (openResult.type == ResultType.done) {
        setState(() {
          _reportFileToUpload = file;
        });
      } else {
        ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
          SnackBar(content: Text('Could not open file: ${openResult.message}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        navigatorKey.currentContext!,
      ).showSnackBar(SnackBar(content: Text('Failed to download report: $e')));
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
      await ref.read(createPatientReportProvider(uploadData).future);

      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        const SnackBar(
          content: Text('Report uploaded successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(navigatorKey.currentContext!).pop(); // Close dialog on success
    } catch (e) {
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        SnackBar(
          content: Text('Upload failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // The entire build method and its children (_buildFromServerTab, _buildFromLocalTab)
  // remain exactly the same as the previous version.
  @override
  Widget build(BuildContext context) {
    final bool isReadyToUpload = _reportFileToUpload != null;

    return DefaultTabController(
      length: 2,
      child: AlertDialog(
        title: const Text('Update Report'),
        content: SizedBox(
          width: double.maxFinite,
          height: 350,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const TabBar(
                tabs: [
                  Tab(text: 'From Server'),
                  Tab(text: 'From Local'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [_buildFromServerTab(), _buildFromLocalTab()],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          Visibility(
            visible: isReadyToUpload && !_isLoading,
            child: ElevatedButton(
              onPressed: _uploadReport, // This now calls the simplified method
              child: const Text('Upload'),
            ),
          ),
          if (_isLoading && isReadyToUpload)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFromServerTab() {
    final allReportsAsync = ref.watch(allSampleReportsProvider);

    return allReportsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (allReports) {
        final filteredReports = _selectedCategory == null
            ? allReports
            : allReports
                  .where(
                    (r) => r.diagnosisTypeOutput?.category == _selectedCategory,
                  )
                  .toList();

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Select Category',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                initialValue: _selectedCategory,
                items: _categories
                    .map(
                      (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                    _selectedReportFromServer = null;
                    _reportNameController.clear();
                  });
                },
              ),
              const SizedBox(height: 16),
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
              const Spacer(),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton.icon(
                  onPressed: _selectedReportFromServer != null
                      ? _downloadAndOpenFile
                      : null,
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Download & Open'),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFromLocalTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: _pickLocalFile,
            icon: const Icon(Icons.attach_file),
            label: const Text('Choose File from Device'),
          ),
          const SizedBox(height: 20),
          if (_reportFileToUpload != null)
            Text(
              'Selected: ${_reportFileToUpload!.path.split('/').last}',
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }
}
