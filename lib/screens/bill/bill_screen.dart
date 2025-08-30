import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/main.dart';
import 'package:labledger/methods/custom_methods.dart';
import 'package:labledger/models/bill_model.dart';
import 'package:labledger/providers/bill_status_provider.dart';
import 'package:labledger/providers/bills_provider.dart'; // Import your bills provider
import 'package:labledger/screens/bill/add_update_screen2.dart';
import 'package:labledger/screens/bill/ui_components/bill_card.dart';
import 'package:labledger/screens/bill/ui_components/bill_stats_card.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:window_manager/window_manager.dart';

class BillsScreen extends ConsumerStatefulWidget {
  const BillsScreen({super.key});

  @override
  ConsumerState<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends ConsumerState<BillsScreen> with WindowListener {
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  String _selectedView = 'grid'; // default view
  Timer? _debounce;
  String _currentSearchQuery = '';
  double _aspectRatio = 2.0;
  double fullMaxRatio = 2.2;
  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _checkWindowState();
    searchFocusNode.requestFocus();
    _loadSavedView();
  }

  Future<void> _checkWindowState() async {
    final isFullScreen = await windowManager.isFullScreen();
    final isMaximized = await windowManager.isMaximized();

    setState(() {
      if (isFullScreen) {
        _aspectRatio = fullMaxRatio;
      } else if (isMaximized) {
        _aspectRatio = fullMaxRatio;
      } else {
        _aspectRatio = 2.0;
      }
    });
  }

  // --- WindowListener overrides ---
  @override
  void onWindowEnterFullScreen() {
    setState(() => _aspectRatio = fullMaxRatio);
  }

  @override
  void onWindowLeaveFullScreen() {
    _checkWindowState();
  }

  @override
  void onWindowMaximize() {
    setState(() => _aspectRatio = fullMaxRatio);
  }

  @override
  void onWindowUnmaximize() {
    _checkWindowState();
  }

  @override
  void onWindowResize() {
    _checkWindowState();
  }

  @override
  void dispose() {
    // ✅ remove listener to avoid leaks
    windowManager.removeListener(this);
    _debounce?.cancel();
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadSavedView() async {
    final savedView = await storage.read(key: 'bill_view');
    if (savedView != null) {
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
      setState(() {
        _currentSearchQuery = query.trim();
      });
    });
  }

  void _refreshBillsData() {
    // Invalidate all bill-related providers to refresh data
    ref.invalidate(billsProvider);
    ref.invalidate(searchBillsProvider);
    ref.invalidate(billStatsProvider);

    // If there's a current search, invalidate that specific search
    if (_currentSearchQuery.isNotEmpty) {
      ref.invalidate(searchBillsProvider(_currentSearchQuery));
    }
  }

  Map<String, List<Bill>> _groupBillsByReason(List<Bill> bills) {
    final Map<String, List<Bill>> grouped = {};

    for (var bill in bills) {
      final reasons = (bill.matchReason?.isNotEmpty ?? false)
          ? bill.matchReason!
          : ["Bills List"];

      for (var reason in reasons) {
        grouped.putIfAbsent(reason, () => []);
        grouped[reason]!.add(bill);
      }
    }

    return grouped;
  }

  void _showViewMenu() async {
    final selected = await showMenu<String>(
      context: context,
      position: const RelativeRect.fromLTRB(200, 385, 0, 100),
      color: Theme.of(context).colorScheme.tertiaryFixed,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(defaultRadius),
        side: BorderSide(color: Theme.of(context).scaffoldBackgroundColor),
      ),
      items: [
        const PopupMenuItem(
          value: 'list',
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [Icon(Icons.list_rounded), Text("List View")],
          ),
        ),
        const PopupMenuItem(
          value: 'grid',
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [Icon(Icons.grid_on_rounded), Text("Grid View")],
          ),
        ),
      ],
    );

    if (selected != null) {
      setState(() {
        _selectedView = selected;
      });
      _saveView(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use the appropriate provider based on search query
    final billsAsyncValue = _currentSearchQuery.isEmpty
        ? ref.watch(billsProvider)
        : ref.watch(searchBillsProvider(_currentSearchQuery));

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.tertiaryFixed,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Theme.of(context).colorScheme.primary,
        onPressed: () async {
          await navigatorKey.currentState
              ?.push(MaterialPageRoute(builder: (context) => AddBillScreen2()))
              .then((value) {
                // Refresh bills data when returning from add bill screen
                _refreshBillsData();
              });
        },
        label: Text(
          "Add Bill",
          style: TextStyle(
            color: ThemeData.light().scaffoldBackgroundColor,
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            pageHeader(
              context: context,
              centerWidget: Row(
                children: [
                  CenterSearchBar(
                    controller: searchController,
                    searchFocusNode: searchFocusNode,
                    hintText: "Search Bills...",
                    width: 400,
                    onSearch: _onSearchChanged,
                  ),
                  const SizedBox(width: 180),
                ],
              ),
            ),
            Expanded(
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: ScrollConfiguration(
                  behavior: NoThumbScrollBehavior(),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        // Stats section - only show when not searching
                        Visibility(
                          visible: _currentSearchQuery.isEmpty,
                          child: Container(
                            height: 310,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                defaultRadius,
                              ),
                            ),
                            child: ref
                                .watch(billStatsProvider)
                                .when(
                                  data: (stats) {
                                    return Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        BillStatsCard(
                                          title: "Monthly Growth",
                                          currentPeriod: stats.currentMonth,
                                          previousPeriod: stats.previousMonth,
                                        ),
                                        SizedBox(width: defaultWidth),
                                        BillStatsCard(
                                          title: "Quarterly Growth",
                                          currentPeriod: stats.currentQuarter,
                                          previousPeriod: stats.previousQuarter,
                                        ),
                                        SizedBox(width: defaultWidth),
                                        BillStatsCard(
                                          title: "Yearly Growth",
                                          currentPeriod: stats.currentYear,
                                          previousPeriod: stats.previousYear,
                                        ),
                                      ],
                                    );
                                  },
                                  loading: () => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                  error: (err, stack) => Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text("Error loading stats: $err"),
                                        const SizedBox(height: 10),
                                        ElevatedButton(
                                          onPressed: () {
                                            ref.invalidate(billStatsProvider);
                                          },
                                          child: const Text("Retry"),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                          ),
                        ),

                        // Bills list section
                        billsAsyncValue.when(
                          data: (bills) {
                            if (bills.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(height: 50),
                                    Text(
                                      _currentSearchQuery.isEmpty
                                          ? 'No bills found.'
                                          : 'No bills found for "$_currentSearchQuery"',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.headlineLarge,
                                    ),
                                    if (_currentSearchQuery.isNotEmpty) ...[
                                      const SizedBox(height: 20),
                                      ElevatedButton(
                                        onPressed: () {
                                          searchController.clear();
                                          setState(() {
                                            _currentSearchQuery = '';
                                          });
                                        },
                                        child: const Text("Clear Search"),
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            }

                            final groupedBills = _groupBillsByReason(bills);

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: groupedBills.entries.map((entry) {
                                final category = entry.key;
                                final categoryBills = entry.value;

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          category,
                                          style: TextStyle(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.secondary,
                                            fontSize: 28,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: _showViewMenu,
                                          icon: Icon(
                                            _selectedView == "grid"
                                                ? LucideIcons.home
                                                : LucideIcons.list,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.secondary,
                                            size: 40,
                                          ),
                                        ),
                                      ],
                                    ),

                                    // Grid View
                                    if (_selectedView == "grid")
                                      LayoutBuilder(
                                        builder: (context, constraints) {
                                          // For example, 4 columns → calculate height dynamically
                                          final crossAxisCount = 4;
                                          return GridView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            gridDelegate:
                                                SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount:
                                                      crossAxisCount,
                                                  childAspectRatio:
                                                      _aspectRatio,
                                                  crossAxisSpacing:
                                                      defaultWidth,
                                                  mainAxisSpacing:
                                                      defaultHeight,
                                                ),
                                            itemCount: categoryBills.length,
                                            itemBuilder: (ctx, index) {
                                              final bill = categoryBills[index];
                                              return GestureDetector(
                                                onTap: () async {
                                                  await navigatorKey
                                                      .currentState
                                                      ?.push(
                                                        MaterialPageRoute(
                                                          builder: (_) =>
                                                              AddBillScreen2(
                                                                billData: bill,
                                                              ),
                                                        ),
                                                      )
                                                      .then((result) {
                                                        // Refresh data if bill was modified
                                                        if (result == true) {
                                                          _refreshBillsData();
                                                        }
                                                      });
                                                },
                                                child: BillCard(bill: bill),
                                              );
                                            },
                                          );
                                        },
                                      ),

                                    // List View
                                    if (_selectedView == "list")
                                      ListView.separated(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: categoryBills.length,
                                        separatorBuilder: (_, __) =>
                                            SizedBox(height: defaultHeight),
                                        itemBuilder: (ctx, index) {
                                          final bill = categoryBills[index];
                                          return GestureDetector(
                                            onTap: () async {
                                              await navigatorKey.currentState
                                                  ?.push(
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          AddBillScreen2(
                                                            billData: bill,
                                                          ),
                                                    ),
                                                  )
                                                  .then((result) {
                                                    // Refresh data if bill was modified
                                                    if (result == true) {
                                                      _refreshBillsData();
                                                    }
                                                  });
                                            },
                                            child: BillCard(bill: bill),
                                          );
                                        },
                                      ),

                                    const SizedBox(height: 20),
                                  ],
                                );
                              }).toList(),
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
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(height: 50),
                                  Icon(
                                    Icons.error_outline,
                                    size: 64,
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    "Failed to load bills",
                                    style: Theme.of(
                                      context,
                                    ).textTheme.headlineMedium,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    err.toString().contains("Authentication")
                                        ? "Please check your internet connection and try again"
                                        : "Please try again",
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 20),
                                  ElevatedButton.icon(
                                    onPressed: _refreshBillsData,
                                    icon: const Icon(Icons.refresh),
                                    label: const Text("Retry"),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
