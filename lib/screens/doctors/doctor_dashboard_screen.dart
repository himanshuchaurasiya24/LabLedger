import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/main.dart';
import 'package:labledger/methods/custom_methods.dart';
import 'package:labledger/models/bill_model.dart';
import 'package:labledger/models/doctors_model.dart';
import 'package:labledger/providers/bills_provider.dart';
import 'package:labledger/providers/doctor_provider.dart';
import 'package:labledger/providers/referral_and_bill_chart_provider.dart';
import 'package:labledger/screens/doctors/doctor_edit_screen.dart';
import 'package:labledger/screens/bills/add_update_bill_screen.dart';
import 'package:labledger/screens/ui_components/window_scaffold.dart';
import 'package:labledger/screens/bills/widgets/bill_growth_stats_view.dart';
import 'package:labledger/screens/ui_components/custom_error_state_widget.dart';
import 'package:labledger/screens/ui_components/paginated_bills_view.dart';
import 'package:labledger/screens/ui_components/tinted_container.dart';
import 'package:labledger/screens/ui_components/view_switcher_menu.dart';
import 'package:window_manager/window_manager.dart';
import 'package:labledger/utils/controller_disposer.dart';
import 'package:labledger/screens/doctors/methods/doctor_methods.dart';

class DoctorDashboardScreen extends ConsumerStatefulWidget {
  final int doctorId;

  const DoctorDashboardScreen({super.key, required this.doctorId});

  @override
  ConsumerState<DoctorDashboardScreen> createState() =>
      _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends ConsumerState<DoctorDashboardScreen>
    with WindowListener, ControllerDisposer {
  late final TextEditingController searchController;
  final FocusNode searchFocusNode = FocusNode();
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  String _selectedView = 'grid';
  Timer? _debounce;
  late final DoctorMethods _methods;

  @override
  void initState() {
    super.initState();
    _methods = DoctorMethods(context, ref);
    _methods.addListener(() {
      if (mounted) setState(() {});
    });
    windowManager.addListener(this);
    searchController = createController();
    searchFocusNode.requestFocus();
    _loadSavedView();
  }

  @override
  void dispose() {
    _methods.dispose();
    windowManager.removeListener(this);
    _debounce?.cancel();
    disposeControllers();
    searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadSavedView() async {
    final savedView = await storage.read(key: 'bill_view');
    if (savedView != null && mounted) {
      setState(() => _selectedView = savedView);
    }
  }

  Future<void> _saveView(String view) async {
    await storage.write(key: 'bill_view', value: view);
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(currentSearchQueryProvider.notifier).state = query;
      ref.read(currentPageProvider.notifier).state = 1;
    });
  }

  void _navigateToBill(Bill bill) {
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => AddUpdateBillScreen(
          billId: bill.id,
          themeColor: bill.billStatus != "Fully Paid"
              ? Theme.of(context).colorScheme.error
              : Theme.of(context).colorScheme.secondary,
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    final asyncDoctor = ref.watch(singleDoctorProvider(widget.doctorId));
    final asyncBills = ref.watch(paginatedDoctorBillProvider(widget.doctorId));
    final asyncStats = ref.watch(doctorGrowthStatsProvider(widget.doctorId));
    final currentQuery = ref.watch(currentSearchQueryProvider);

    return asyncDoctor.when(
      loading: () => const WindowScaffold(
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => WindowScaffold(
        child: buildErrorState(
          context: context,
          error: error,
          theme: Theme.of(context),
          onTap: () => ref.invalidate(singleDoctorProvider(widget.doctorId)),
          errorHeading: 'Failed to load doctor details',
          errorTitle: error.toString(),
          buttonLabel: 'Retry',
          icon: const Icon(Icons.refresh),
        ),
      ),
      data: (doctor) {
        return WindowScaffold(
          centerWidget: CenterSearchBar(
            controller: searchController,
            searchFocusNode: searchFocusNode,
            hintText: "Search bills for Dr. ${doctor.firstName}...",
            width: 400,
            onSearch: _onSearchChanged,
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                Visibility(
                  visible: searchController.text.isEmpty,
                  child: Column(
                    children: [
                      _buildDoctorHeader(doctor),
                      SizedBox(height: defaultHeight),
                      BillGrowthStatsView(
                        statsProvider: asyncStats,
                        onRetry: () => ref.invalidate(
                          doctorGrowthStatsProvider(widget.doctorId),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: defaultHeight),
                _buildSectionHeader(
                  context,
                  currentQuery.isNotEmpty
                      ? 'Search Results for: "$currentQuery"'
                      : "Referred Bills",
                ),
                PaginatedBillsView(
                  billsProvider: asyncBills,
                  selectedView: _selectedView,
                  headerTitle: currentQuery.isNotEmpty
                      ? 'Search Results for: "$currentQuery"'
                      : "Referred Bills",
                  emptyListMessage: currentQuery.isEmpty
                      ? 'No bills found for this doctor.'
                      : 'No bills found for "$currentQuery"',
                  onPageChanged: (newPage) {
                    ref.read(currentPageProvider.notifier).state = newPage;
                  },
                  onBillTap: _navigateToBill,
                  onRetry: () => ref.invalidate(
                    paginatedDoctorBillProvider(widget.doctorId),
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDoctorHeader(Doctor doctor) {
    final theme = Theme.of(context);
    const Color positiveColor = Colors.teal;

    return TintedContainer(
      baseColor: positiveColor,
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: positiveColor,
                  borderRadius: BorderRadius.circular(mediumRadius),
                ),
                child: Center(
                  child: Text(
                    "${doctor.firstName![0].toUpperCase()}${doctor.lastName![0].toUpperCase()}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: mediumPadding),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${doctor.firstName} ${doctor.lastName}",
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: minimalPadding),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: smallPadding,
                      vertical: minimalPadding,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(smallRadius),
                    ),
                    child: Text(
                      "${doctor.hospitalName}, ${doctor.address}",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  navigatorKey.currentState?.push(
                    MaterialPageRoute(
                      builder: (context) =>
                          DoctorEditScreen(doctorId: doctor.id),
                    ),
                  );
                },
                icon: Icon(LucideIcons.pen, color: theme.colorScheme.primary),
                tooltip: 'Edit Doctor',
              ),
              const SizedBox(width: smallPadding),
              IconButton(
                onPressed: () => _methods.confirmDeleteDoctor(doctor),
                icon: Icon(LucideIcons.trash_2, color: theme.colorScheme.error),
                tooltip: 'Delete Doctor',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: defaultPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          ViewSwitcherMenu(
            initialView: _selectedView,
            onViewChanged: (value) {
              setState(() => _selectedView = value);
              _saveView(value);
            },
            position: RelativeRect.fromLTRB(200, 554, defaultPadding, 100),
          ),
        ],
      ),
    );
  }
}
