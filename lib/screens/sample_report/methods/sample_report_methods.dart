import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:labledger/constants/constants.dart';
import 'package:labledger/main.dart';
import 'package:labledger/models/sample_report_model.dart';
import 'package:labledger/providers/sample_reports_provider.dart';
import 'package:labledger/authentication/auth_http_client.dart';
import 'package:labledger/screens/ui_components/custom_error_dialog.dart';
import 'package:labledger/screens/ui_components/snackbar_utils.dart';
import 'package:labledger/screens/ui_components/custom_confirmation_dialog.dart';

enum FormMode { create, edit }

class SampleReportMethods extends ChangeNotifier {
  final BuildContext context;
  final WidgetRef ref;

  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();
  String searchQuery = '';

  // Form State
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController diagnosisNameController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  String? selectedCategory;
  File? selectedFile;
  String? currentFileName;
  bool isSubmitting = false;

  SampleReportMethods(this.context, this.ref) {
    searchFocusNode.requestFocus();
  }

  @override
  void dispose() {
    searchController.dispose();
    searchFocusNode.dispose();
    diagnosisNameController.dispose();
    categoryController.dispose();
    super.dispose();
  }

  // --- Main Screen Methods ---

  void onSearchChanged(String query) {
    searchQuery = query;
    notifyListeners();
  }

  List<SampleReportModel> filterReports(List<SampleReportModel> reports) {
    if (searchQuery.isEmpty) return reports;

    return reports.where((report) {
      final diagnosisName = report.diagnosisName
          .trim()
          .toLowerCase()
          .replaceAll(RegExp(r'\s+'), ' ');
      final category = report.category.trim().toLowerCase().replaceAll(
        RegExp(r'\s+'),
        ' ',
      );
      final fileName = report.sampleReportFile.trim().toLowerCase().replaceAll(
        RegExp(r'\s+'),
        ' ',
      );
      
      final query = searchQuery.trim().toLowerCase();
      return diagnosisName.contains(query) ||
          category.contains(query) ||
          fileName.contains(query);
    }).toList();
  }

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

  Future<void> downloadReport(SampleReportModel report) async {
    if (report.sampleReportFile.isEmpty) return;

    try {
      final uri = Uri.parse(report.sampleReportFile);
      final response = await AuthHttpClient.get(
        ref,
        uri.toString(),
        throwOnError: false,
      );

      if (response.statusCode != 200) {
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (context) => ErrorDialog(
              title: 'Download Error',
              errorMessage:
                  'HTTP ${response.statusCode}: The report file is missing on the server. Please upload it again or contact support.',
            ),
          );
        }
        return;
      }

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

  Future<void> confirmDelete(SampleReportModel report) async {
    final confirmed = await showDeleteConfirmationDialog(
      context: context,
      title: 'Delete Report',
      message: 'Are you sure you want to delete "${report.diagnosisName}"?',
      showWarningIcon: false,
    );
    if (!confirmed) return;

    try {
      await ref.read(deleteSampleReportProvider(report.id!).future);
      if (context.mounted) {
        showSuccessSnackBar(context, 'Report deleted successfully');
      }
    } catch (e) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) =>
              ErrorDialog(title: 'Delete Failed', errorMessage: e.toString()),
        );
      }
    }
  }

  // --- Form Dialog Methods ---

  void initializeForm(SampleReportModel? existingReport) {
    diagnosisNameController.text = existingReport?.diagnosisName ?? '';
    categoryController.text = existingReport?.category ?? '';
    selectedCategory = existingReport?.category;

    if (existingReport?.sampleReportFile.isNotEmpty ?? false) {
      currentFileName = existingReport!.sampleReportFile.split('/').last;
    } else {
      currentFileName = null;
    }
    selectedFile = null;
    isSubmitting = false;
  }

  void updateSelectedCategory(String category) {
    selectedCategory = category;
    categoryController.text = category;
    notifyListeners();
  }

  void clearSelectedFile() {
    selectedFile = null;
    notifyListeners();
  }

  Future<void> pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['doc', 'docx', 'rtf', 'odt'],
      );

      if (result != null && result.files.single.path != null) {
        selectedFile = File(result.files.single.path!);
        notifyListeners();
      }
    } catch (e) {
      if (context.mounted) {
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

  Future<void> submitForm(FormMode mode, SampleReportModel? existingReport) async {
    if (!formKey.currentState!.validate()) return;

    if (selectedFile == null && mode == FormMode.create) {
      showDialog(
        context: context,
        builder: (context) => const ErrorDialog(
          title: 'File Required',
          errorMessage: 'Please select a report file to upload.',
        ),
      );
      return;
    }

    isSubmitting = true;
    notifyListeners();

    try {
      final report = SampleReportModel(
        id: existingReport?.id,
        diagnosisName: diagnosisNameController.text.trim(),
        category: selectedCategory!,
        sampleReportFile: existingReport?.sampleReportFile ?? '',
        sampleReportFileLocal: selectedFile,
      );

      if (selectedFile != null) {
        final int fileSizeBytes = await selectedFile!.length();
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
          isSubmitting = false;
          notifyListeners();
          return;
        }
      }

      if (mode == FormMode.create) {
        await ref.read(createSampleReportProvider(report).future);
      } else {
        await ref.read(updateSampleReportProvider(report).future);
      }

      if (context.mounted) {
        Navigator.pop(context);
        showSuccessSnackBar(context, 'Report ${mode == FormMode.create ? 'created' : 'updated'} successfully');
      }
    } catch (e) {
      if (context.mounted) {
        final errorText = e.toString();
        final String? infoMessage = errorText.contains('Status: 500')
            ? 'The server encountered an internal error while processing this update. If this happens again, please retry after a few seconds or contact support with the operation details.'
            : null;

        showDialog(
          context: context,
          builder: (context) => ErrorDialog(
            title: mode == FormMode.create
                ? 'Creation Failed'
                : 'Update Failed',
            errorMessage: errorText,
            infoMessage: infoMessage,
          ),
        );
      }
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }
}
