import 'dart:io';
import 'package:flutter/material.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/screens/ui_components/custom_elevated_button.dart';

class FileUploadWidget extends StatelessWidget {
  final Color themeColor;
  final File? selectedFile;
  final String? currentFileName;
  final bool isSubmitting;
  final VoidCallback onClearFile;
  final VoidCallback onPickFile;

  const FileUploadWidget({
    super.key,
    required this.themeColor,
    this.selectedFile,
    this.currentFileName,
    required this.isSubmitting,
    required this.onClearFile,
    required this.onPickFile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 340,
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: themeColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(defaultRadius),
        border: Border.all(color: themeColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.upload_file,
            size: 64,
            color: themeColor,
          ),
          SizedBox(height: defaultHeight),
          Text(
            'Choose File from Device',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: themeColor,
            ),
          ),
          SizedBox(height: defaultHeight * 0.5),
          Text(
            'Supported formats: DOC, DOCX, RTF, ODT',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: minimalPadding),
          Text(
            'Max file size: $maxFileSizeMb MB (1 MB = 1024 KB)',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: defaultHeight),
          if (selectedFile != null || currentFileName != null)
            Container(
              padding: EdgeInsets.all(defaultPadding * 0.75),
              margin: EdgeInsets.only(bottom: defaultPadding),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(smallRadius),
                border: Border.all(color: themeColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.description,
                    color: themeColor,
                    size: 20,
                  ),
                  SizedBox(width: defaultPadding * 0.5),
                  Expanded(
                    child: Text(
                      selectedFile?.path.split('/').last ??
                          currentFileName ??
                          '',
                      style: theme.textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (selectedFile != null)
                    IconButton(
                      onPressed: onClearFile,
                      icon: Icon(
                        Icons.close,
                        color: theme.colorScheme.error,
                        size: 20,
                      ),
                    ),
                ],
              ),
            ),
          CustomElevatedButton(
            onPressed: onPickFile,
            backgroundColor: theme.colorScheme.secondary,
            icon: isSubmitting
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.folder_open),
            label: isSubmitting ? 'Saving...' : "Browse Files",
          ),
        ],
      ),
    );
  }
}
