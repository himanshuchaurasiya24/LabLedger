import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/main.dart';
import 'package:labledger/methods/custom_methods.dart';
import 'package:labledger/models/bill_model.dart';
import 'package:labledger/providers/bill_status_provider.dart';
import 'package:labledger/providers/bills_provider.dart';
import 'package:labledger/screens/bill/add_update_screen2.dart';
import 'package:labledger/screens/bill/ui_components/bill_card.dart';
import 'package:labledger/screens/bill/ui_components/bill_stats_card.dart';
import 'package:labledger/screens/window_scaffold.dart';
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
  double aspectRatio = 2.0;

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
    ref.invalidate(billsProvider);
    ref.invalidate(searchBillsProvider);
    ref.invalidate(billStatsProvider);

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final Color baseColor = theme.colorScheme.secondary;

    // --- 🎨 Applying the same color logic as BillCards to the popup menu ---
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
              Icon(Icons.list_rounded, color: theme.colorScheme.secondary),
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
      setState(() {
        _selectedView = selected;
      });
      _saveView(selected);
    }
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: defaultPadding,
        vertical: defaultPadding * 1.5,
      ),
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
    final billsAsyncValue = _currentSearchQuery.isEmpty
        ? ref.watch(billsProvider)
        : ref.watch(searchBillsProvider(_currentSearchQuery));

    const Color positiveColor = Colors.teal;
    const Color negativeColor = Colors.red;
    const Color neutralColor = Colors.amber;

    return WindowScaffold(
      centerWidget: CenterSearchBar(
        controller: searchController,
        searchFocusNode: searchFocusNode,
        hintText: "Search Bills...",
        width: 400,
        onSearch: _onSearchChanged,
      ),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.tertiaryFixed,
        floatingActionButton: FloatingActionButton.extended(
          // Use a color that matches the positive-themed cards in your UI
          backgroundColor: Theme.of(
            context,
          ).colorScheme.secondary, // A nice teal color
          // Use foregroundColor for the color of the label and icon
          foregroundColor: Colors.white,
          elevation: 4.0, // A slightly more subtle shadow
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              16.0,
            ), // Match the rounded corners of your cards
          ),
          onPressed: () async {
            await navigatorKey.currentState
                ?.push(
                  MaterialPageRoute(builder: (context) => AddBillScreen2()),
                )
                .then((value) {
                  _refreshBillsData();
                });
          },
          label: const Text(
            "Add Bill",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18, // Slightly reduced for a cleaner look
            ),
          ),
          icon: const Icon(LucideIcons.plus),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: defaultPadding),
          child: ScrollConfiguration(
            behavior: NoThumbScrollBehavior(),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  Visibility(
                    visible: _currentSearchQuery.isEmpty,
                    child: Container(
                      height: 310,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(defaultRadius),
                      ),
                      child: ref
                          .watch(billStatsProvider)
                          .when(
                            data: (stats) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: BillStatsCard(
                                      title: "Monthly Growth",
                                      currentPeriod: stats.currentMonth,
                                      previousPeriod: stats.previousMonth,
                                      positiveColor: positiveColor,
                                      negativeColor: negativeColor,
                                    ),
                                  ),
                                  SizedBox(width: defaultWidth),
                                  Expanded(
                                    child: BillStatsCard(
                                      title: "Quarterly Growth",
                                      currentPeriod: stats.currentQuarter,
                                      previousPeriod: stats.previousQuarter,
                                      positiveColor: positiveColor,
                                      negativeColor: negativeColor,
                                    ),
                                  ),
                                  SizedBox(width: defaultWidth),
                                  Expanded(
                                    child: BillStatsCard(
                                      title: "Yearly Growth",
                                      currentPeriod: stats.currentYear,
                                      previousPeriod: stats.previousYear,
                                      positiveColor: positiveColor,
                                      negativeColor: negativeColor,
                                    ),
                                  ),
                                ],
                              );
                            },
                            loading: () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            error: (err, stack) => Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Error loading stats: $err"),
                                  const SizedBox(height: 10),
                                  ElevatedButton(
                                    onPressed: () =>
                                        ref.invalidate(billStatsProvider),
                                    child: const Text("Retry"),
                                  ),
                                ],
                              ),
                            ),
                          ),
                    ),
                  ),
                  billsAsyncValue.when(
                    data: (bills) {
                      if (bills.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 50.0),
                            child: Text(
                              _currentSearchQuery.isEmpty
                                  ? 'No bills found.'
                                  : 'No bills found for "$_currentSearchQuery"',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
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
                              _buildSectionHeader(context, category),
                              if (_selectedView == "grid")
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 4,
                                        childAspectRatio: aspectRatio,
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
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: categoryBills.length,
                                  separatorBuilder: (_, __) =>
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
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 50.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, size: 48),
                              const SizedBox(height: 16),
                              Text(
                                "Failed to load bills",
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineSmall,
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
          ),
        ),
      ),
    );
  }

  void _navigateToBill(Bill bill) async {
    final result = await navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (_) => AddBillScreen2(billData: bill)),
    );
    if (result == true) {
      _refreshBillsData();
    }
  }
}
