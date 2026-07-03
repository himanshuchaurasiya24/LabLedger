import 'package:flutter/material.dart';
import 'package:labledger/screens/ui_components/app_inkwell.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/models/sample_report_model.dart';
import 'package:labledger/providers/sample_reports_provider.dart';
import 'package:labledger/screens/ui_components/window_scaffold.dart';
import 'package:labledger/screens/ui_components/custom_empty_state_widget.dart';
import 'package:labledger/screens/ui_components/custom_error_state_widget.dart';
import 'package:labledger/screens/ui_components/tinted_container.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:labledger/methods/custom_methods.dart';
import 'package:labledger/screens/sample_report/methods/sample_report_methods.dart';
import 'package:labledger/screens/sample_report/components/sample_report_components.dart';

class SampleReportManagementScreen extends ConsumerStatefulWidget {
  const SampleReportManagementScreen({super.key, this.baseColor});

  final Color? baseColor;

  @override
  ConsumerState<SampleReportManagementScreen> createState() =>
      _SampleReportManagementScreenState();
}

class _SampleReportManagementScreenState
    extends ConsumerState<SampleReportManagementScreen> {
  late SampleReportMethods _methods;

  @override
  void initState() {
    super.initState();
    _methods = SampleReportMethods(context, ref);
  }

  @override
  void dispose() {
    _methods.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveColor = widget.baseColor ?? colorScheme.secondary;
    final sampleReportsAsync = ref.watch(allSampleReportsProvider);

    return AnimatedBuilder(
      animation: _methods,
      builder: (context, _) => WindowScaffold(
        centerWidget: CenterSearchBar(
          controller: _methods.searchController,
          searchFocusNode: _methods.searchFocusNode,
          hintText: 'Search Reports...',
          width: 400,
          onSearch: _methods.onSearchChanged,
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(defaultRadius),
          ),
          onPressed: () => _showCreateDialog(context, effectiveColor),
          label: const Text(
            'Add Report',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          icon: const Icon(LucideIcons.plus),
        ),
        child: sampleReportsAsync.when(
          data: (reports) {
            final filteredReports = _methods.filterReports(reports);
            return _buildReportsList(
              context,
              ref,
              filteredReports,
              effectiveColor,
            );
          },
          loading: () => _buildLoadingState(context, effectiveColor),
          error: (error, stack) =>
              _buildErrorState(context, ref, error, effectiveColor),
        ),
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
        crossAxisCount: _methods.getCrossAxisCount(context),
        crossAxisSpacing: defaultPadding,
        mainAxisSpacing: defaultPadding,
        childAspectRatio: _methods.getChildAspectRatio(context),
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
      child: AppInkWell(
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
                    _methods.downloadReport(report);
                  } else if (value == 'delete') {
                    _methods.confirmDelete(report);
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
        crossAxisCount: _methods.getCrossAxisCount(context),
        crossAxisSpacing: defaultPadding,
        mainAxisSpacing: defaultPadding,
        childAspectRatio: _methods.getChildAspectRatio(context),
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
    return buildErrorState(
      context: context,
      error: error,
      theme: theme,
      onTap: () => ref.invalidate(allSampleReportsProvider),
      errorHeading: 'Failed to load sample reports',
      errorTitle: error.toString(),
      buttonLabel: 'Retry',
      icon: const Icon(Icons.refresh),
    );
  }

  Widget _buildEmptyState(BuildContext context, Color effectiveColor) {
    return buildEmptyState(
      context: context,
      effectiveColor: effectiveColor,
      onAddPressed: () {
        _showCreateDialog(context, effectiveColor);
      },
      title: 'No reports found',
      subtitle: 'Add your first report to get started',
      icon: LucideIcons.server,
      label: 'Add Report',
    );
  }

  void _showCreateDialog(BuildContext context, Color effectiveColor) {
    showDialog(
      context: context,
      builder: (context) =>
          ReportFormDialog(mode: FormMode.create, themeColor: effectiveColor),
    );
  }

  void _showEditDialog(
    BuildContext context,
    SampleReportModel report,
    Color effectiveColor,
  ) {
    showDialog(
      context: context,
      builder: (context) => ReportFormDialog(
        mode: FormMode.edit,
        existingReport: report,
        themeColor: effectiveColor,
      ),
    );
  }
}
