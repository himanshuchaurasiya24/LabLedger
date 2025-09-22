import 'dart:async';

import 'package:flutter/material.dart';
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
import 'package:labledger/screens/bills/add_update_bill_screen.dart';
import 'package:labledger/screens/doctors/doctor_edit_screen.dart';
import 'package:labledger/screens/initials/window_scaffold.dart';
import 'package:labledger/screens/ui_components/bill_growth_stats_view.dart';
import 'package:labledger/screens/ui_components/paginated_bills_view.dart';
import 'package:labledger/screens/ui_components/tinted_container.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:window_manager/window_manager.dart';

class DoctorDashboardScreen extends ConsumerStatefulWidget {
  final Doctor doctor;

  const DoctorDashboardScreen({super.key, required this.doctor});

  @override
  ConsumerState<DoctorDashboardScreen> createState() =>
      _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends ConsumerState<DoctorDashboardScreen>
    with WindowListener {
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  String _selectedView = 'grid';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    searchFocusNode.requestFocus();
    _loadSavedView();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    _debounce?.cancel();
    searchController.dispose();
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
      ref.read(currentSearchQueryProvider.notifier).state = query.trim();
      ref.read(currentPageProvider.notifier).state = 1;
    });
  }

  void _showViewMenu() async {
    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(200, 420, defaultPadding, 100),
      items: [
        PopupMenuItem(value: 'list', child: Text("List View")),
        PopupMenuItem(value: 'grid', child: Text("Grid View")),
      ],
    );
    if (selected != null) {
      setState(() => _selectedView = selected);
      _saveView(selected);
    }
  }

  void _navigateToBill(Bill bill) {
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => AddBillScreen(
          billData: bill,
          themeColor: bill.billStatus != "Fully Paid"
              ? Theme.of(context).colorScheme.error
              : Theme.of(context).colorScheme.secondary,
        ),
      ),
    );
  }

  // ✅ New method to show the delete confirmation dialog
  Future<void> _confirmDeleteDoctor() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Doctor'),
        content: Text(
          'All the records for Dr. ${widget.doctor.firstName} ${widget.doctor.lastName} will be deleted including bills.\nThis action cannot be undone.\nAre you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        await ref.read(deleteDoctorProvider(widget.doctor.id!).future);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Doctor deleted successfully"),
              backgroundColor: Colors.green,
            ),
          );
          // Pop back to the previous screen
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Failed to delete doctor: $e"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncBills = ref.watch(
      paginatedDoctorBillProvider(widget.doctor.id!),
    );
    final asyncStats = ref.watch(doctorGrowthStatsProvider(widget.doctor.id!));
    final currentQuery = ref.watch(currentSearchQueryProvider);

    return WindowScaffold(
      centerWidget: CenterSearchBar(
        controller: searchController,
        searchFocusNode: searchFocusNode,
        hintText: "Search bills for Dr. ${widget.doctor.firstName}...",
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
                  _buildDoctorHeader(), // ✅ Call the restored header
                  SizedBox(height: defaultHeight),
                  BillGrowthStatsView(
                    statsProvider: asyncStats,
                    onRetry: () => ref.invalidate(
                      doctorGrowthStatsProvider(widget.doctor.id!),
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
                paginatedDoctorBillProvider(widget.doctor.id!),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  // ✅ Restored header widget
  Widget _buildDoctorHeader() {
    final theme = Theme.of(context);
    const Color positiveColor = Colors.teal; // Or any color you prefer

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
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    "${widget.doctor.firstName![0].toUpperCase()}${widget.doctor.lastName![0].toUpperCase()}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${widget.doctor.firstName} ${widget.doctor.lastName}",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "Active",
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
                          DoctorEditScreen(doctorId: widget.doctor.id),
                    ),
                  );
                },
                icon: Icon(LucideIcons.edit, color: theme.colorScheme.primary),
                tooltip: 'Edit Doctor',
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed:
                    _confirmDeleteDoctor, // ✅ Call the confirmation method
                icon: Icon(LucideIcons.trash2, color: theme.colorScheme.error),
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
          Material(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(defaultRadius),
            child: InkWell(
              borderRadius: BorderRadius.circular(defaultRadius),
              onTap: _showViewMenu,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  _selectedView == "grid"
                      ? LucideIcons.layoutGrid
                      : LucideIcons.list,
                  color: theme.colorScheme.onSurface,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
