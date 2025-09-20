import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/main.dart';
import 'package:labledger/methods/custom_methods.dart';
import 'package:labledger/models/bill_model.dart';
import 'package:labledger/providers/bills_provider.dart';
import 'package:labledger/providers/doctor_provider.dart';
import 'package:labledger/screens/bills/add_update_bill_screen.dart';
import 'package:labledger/methods/pagination_controls.dart';
import 'package:labledger/screens/doctors/doctor_edit_screen.dart';
import 'package:labledger/screens/doctors/doctor_stats_view.dart';
import 'package:labledger/screens/ui_components/cards/bill_card.dart';
import 'package:labledger/screens/initials/window_scaffold.dart';
import 'package:labledger/screens/ui_components/tinted_container.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:window_manager/window_manager.dart';

class DoctorDashboardScreen extends ConsumerStatefulWidget {
  final int doctorId;
  final String doctorName;

  const DoctorDashboardScreen({
    super.key,
    required this.doctorId,
    required this.doctorName,
  });

  @override
  ConsumerState<DoctorDashboardScreen> createState() =>
      _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends ConsumerState<DoctorDashboardScreen>
    with WindowListener {
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  String _selectedView = 'grid'; // default view
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
      setState(() {
        _selectedView = savedView;
      });
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
      // The paginatedDoctorBillProvider will auto-refresh
    });
  }

  void _refreshBillsData() {
    // Invalidate the family provider with the correct doctorId
    ref.invalidate(paginatedDoctorBillProvider(widget.doctorId));
  }

  Map<String, List<Bill>> _groupBillsByReason(List<Bill> bills) {
    // This grouping is simple for this screen, but we keep the structure
    // for layout consistency with BillsScreen.
    return {'Referred Bills': bills};
  }

  void _showViewMenu() async {
    // This method is copied directly and remains unchanged.
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final Color baseColor = theme.colorScheme.secondary;
    final Color menuBackgroundColor = (baseColor is MaterialColor)
        ? (isDark
              ? baseColor.shade900.withValues(alpha: 0.95)
              : baseColor.shade50)
        : (isDark
              ? Color.alphaBlend(
                  baseColor.withValues(alpha: 0.4),
                  theme.colorScheme.surface,
                )
              : Color.alphaBlend(
                  baseColor.withValues(alpha: 0.1),
                  theme.colorScheme.surface,
                ));
    final Color menuBorderColor = (baseColor is MaterialColor)
        ? (isDark ? baseColor.shade200 : baseColor.shade600)
        : HSLColor.fromColor(baseColor).withLightness(0.5).toColor();

    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(200, 420, defaultPadding, 100),
      color: menuBackgroundColor,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(defaultRadius),
        side: BorderSide(color: menuBorderColor.withValues(alpha: 0.3)),
      ),
      items: [
        PopupMenuItem(
          value: 'list',
          child: Row(
            children: [
              Icon(Icons.list, color: theme.colorScheme.secondary),
              SizedBox(width: defaultWidth),
              Text(
                "List View",
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'grid',
          child: Row(
            children: [
              Icon(Icons.grid_on_rounded, color: theme.colorScheme.secondary),
              SizedBox(width: defaultWidth),
              Text(
                "Grid View",
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
            ],
          ),
        ),
      ],
    );

    if (selected != null) {
      setState(() => _selectedView = selected);
      _saveView(selected);
    }
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    // This method is copied directly and remains unchanged.
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

  @override
  Widget build(BuildContext context) {
    // ✅ Main Change: Watch the family provider with the specific doctorId
    final asyncResponse = ref.watch(
      paginatedDoctorBillProvider(widget.doctorId),
    );
    final currentQuery = ref.watch(currentSearchQueryProvider);
    final size = MediaQuery.of(context).size;

    const Color positiveColor = Colors.teal;
    const Color negativeColor = Colors.red;
    const Color neutralColor = Colors.amber;

    return WindowScaffold(
      centerWidget: CenterSearchBar(
        controller: searchController,
        searchFocusNode: searchFocusNode,
        hintText: "Search Dr. ${widget.doctorName} Bills...",
        width: 400,
        onSearch: _onSearchChanged,
      ),
      // ❌ FloatingActionButton and BillStatsCards are removed.
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            TintedContainer(
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
                            widget.doctorName[0].toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Dr. ${widget.doctorName}",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          SizedBox(height: 4),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "Active",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          onTap: () {
                            navigatorKey.currentState?.push(
                              MaterialPageRoute(
                                builder: (context) {
                                  return DoctorEditScreen(
                                    doctorId: widget.doctorId,
                                  );
                                },
                              ),
                            );
                          },
                          child: Icon(
                            LucideIcons.edit,
                            size: 20,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          onTap: () {
                            ref.read(deleteDoctorProvider(widget.doctorId));
                          },
                          child: Icon(
                            LucideIcons.trash2,
                            size: 20,
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: defaultHeight),
            DoctorStatsView(doctorId: widget.doctorId),
            SizedBox(height: defaultHeight),

            asyncResponse.when(
              data: (response) {
                final bills = response.bills;

                if (bills.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 50),
                      child: Text(
                        currentQuery.isEmpty
                            ? 'No bills found for this doctor.'
                            : 'No bills found for "$currentQuery"',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                  );
                }

                final groupedBills = _groupBillsByReason(bills);
                final isSearching = currentQuery.isNotEmpty;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...groupedBills.entries.map((entry) {
                      final category = entry.key;
                      final categoryBills = entry.value;
                      final headerTitle = isSearching
                          ? 'Search Results for: "$currentQuery"'
                          : '$category by ${widget.doctorName}'; // "Referred Bills"

                      return Column(
                        children: [
                          _buildSectionHeader(context, headerTitle),
                          SizedBox(height: defaultHeight),
                          if (_selectedView == "grid")
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4,
                                    childAspectRatio: size.width > 1600
                                        ? 2.4
                                        : 2.0,
                                    crossAxisSpacing: defaultWidth,
                                    mainAxisSpacing: defaultHeight,
                                  ),
                              itemCount: categoryBills.length,
                              itemBuilder: (ctx, index) {
                                final bill = categoryBills[index];
                                return BillCard(
                                  bill: bill,
                                  onTap: () => _navigateToBill(bill),
                                  fullyPaidColor: positiveColor,
                                  partiallyPaidColor: neutralColor,
                                  unpaidColor: negativeColor,
                                );
                              },
                            ),
                          if (_selectedView == "list")
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const BouncingScrollPhysics(),
                              itemCount: categoryBills.length,
                              separatorBuilder: (_, _) =>
                                  SizedBox(height: defaultHeight),
                              itemBuilder: (ctx, index) {
                                final bill = categoryBills[index];
                                return BillCard(
                                  bill: bill,
                                  onTap: () => _navigateToBill(bill),
                                  fullyPaidColor: positiveColor,
                                  partiallyPaidColor: neutralColor,
                                  unpaidColor: negativeColor,
                                );
                              },
                            ),
                          const SizedBox(height: 20),
                        ],
                      );
                    }),
                    PaginationControls(
                      totalItems: response.count,
                      itemsPerPage: 40, // Should match your API's page_size
                      currentPage: ref.watch(currentPageProvider),
                      onPageChanged: (newPage) {
                        ref.read(currentPageProvider.notifier).state = newPage;
                      },
                    ),
                  ],
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(50.0),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (err, stack) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 50.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          "Failed to load doctor's bills",
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(err.toString(), textAlign: TextAlign.center),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _refreshBillsData,
                          icon: const Icon(Icons.refresh),
                          label: const Text("Retry"),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  void _navigateToBill(Bill bill) {
    // This method is copied directly and remains unchanged.
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
}
