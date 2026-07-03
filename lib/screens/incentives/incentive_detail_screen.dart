import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/models/incentive_model.dart';
import 'package:labledger/providers/incenitve_generator_provider.dart';
import 'package:labledger/screens/ui_components/window_scaffold.dart';
import 'package:labledger/screens/incentives/widgets/animated_progress_indicator.dart';
import 'package:labledger/screens/ui_components/custom_text_field.dart';
import 'package:labledger/screens/ui_components/custom_error_state_widget.dart';
import 'package:labledger/screens/incentives/widgets/incentive_ui_components.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:labledger/utils/controller_disposer.dart';
import 'package:labledger/screens/incentives/methods/incentive_methods.dart';

class IncentiveDetailScreen extends ConsumerStatefulWidget {
  const IncentiveDetailScreen({super.key});

  @override
  ConsumerState<IncentiveDetailScreen> createState() =>
      _IncentiveDetailScreenState();
}

class _IncentiveDetailScreenState extends ConsumerState<IncentiveDetailScreen>
    with ControllerDisposer {
  late final TextEditingController _searchController;
  late final IncentiveMethods _methods;

  @override
  void initState() {
    super.initState();
    _searchController = createController();
    _methods = IncentiveMethods(context, ref);
    _methods.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    disposeControllers();
    _methods.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    final reportAsync = ref.watch(incentiveReportProvider);
    final theme = Theme.of(context);

    return WindowScaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _methods.showReportGenerationDialog,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        label: const Text("Generate Report"),
        icon: const Icon(Icons.picture_as_pdf_outlined),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(theme),
          if (_methods.isRefreshingReport) ...[
            AnimatedLabProgressIndicator(),
            // SizedBox(height: defaultHeight),
          ],
          SizedBox(height: defaultHeight),
          _buildSearchBar(theme),
          SizedBox(height: defaultHeight),
          Expanded(
            child: reportAsync.when(
              data: (report) => _buildReportContent(report, theme),
              loading: () => _buildLoadingState(),
              error: (err, stack) => buildErrorState(
                context: context,
                error: err,
                theme: theme,
                onTap: () => ref.refresh(incentiveReportProvider),
                errorHeading: "Failed to Load Report",
                errorTitle: err.toString(),
                buttonLabel: "Retry",
                icon: Icon(LucideIcons.refresh_ccw),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(defaultPadding),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withAlpha(77),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            LucideIcons.trending_up,
            color: theme.colorScheme.primary,
            size: 28,
          ),
        ),
        SizedBox(width: defaultPadding),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Incentive Report",
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Doctor performance and earnings overview",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(LucideIcons.refresh_cw, color: theme.colorScheme.primary),
          tooltip: "Refresh Report",
          onPressed: _methods.refreshReport,
        ),
      ],
    );
  }


  Widget _buildSearchBar(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withAlpha(128),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withAlpha(51)),
      ),
      child: CustomTextField(
        tintColor: theme.colorScheme.secondary,
        controller: _searchController,
        label: "Search doctors...",
        onChanged: (value) => _methods.setSearchQuery(value.toLowerCase()),
      ),
    );
  }

  Widget _buildReportContent(List<DoctorReport> report, ThemeData theme) {
    if (report.isEmpty) {
      return IncentiveEmptyState(theme: theme);
    }

    final filteredReports = report.where((doctorReport) {
      final firstName = doctorReport.doctor.firstName ?? '';
      final lastName = doctorReport.doctor.lastName ?? '';
      final fullName = '$firstName $lastName'.toLowerCase();
      return fullName.contains(_methods.searchQuery);
    }).toList();

    if (filteredReports.isEmpty) {
      return IncentiveNoSearchResults(theme: theme);
    }

    final totalIncentives = filteredReports.fold<int>(
      0,
      (sum, doctor) => sum + doctor.totalIncentive,
    );
    final totalBills = filteredReports.fold<int>(
      0,
      (sum, doctor) => sum + doctor.bills.length,
    );
    
    final startDate = ref.read(reportStartDateProvider);
    final endDate = ref.read(reportEndDateProvider);

    return Column(
      children: [
        IncentiveSummaryCards(
          doctorCount: filteredReports.length,
          totalIncentives: totalIncentives,
          totalBills: totalBills,
          theme: theme,
        ),
        SizedBox(height: defaultHeight),
        Expanded(
          child: ListView.builder(
            itemCount: filteredReports.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(bottom: defaultPadding),
                child: DoctorIncentiveExpansionTile(
                  doctorReport: filteredReports[index],
                  index: index,
                  theme: theme,
                  startDate: startDate,
                  endDate: endDate,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text("Loading incentive report..."),
        ],
      ),
    );
  }
}
