import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:labledger/main.dart';
import 'package:labledger/methods/custom_methods.dart';
import 'package:labledger/models/bill_model.dart';
import 'package:labledger/providers/bill_status_provider.dart';
import 'package:labledger/providers/custom_providers.dart';
import 'package:labledger/screens/bill/add_bill_update_screen.dart';
import 'package:labledger/screens/bill/ui_components/bill_card.dart';
import 'package:labledger/screens/bill/ui_components/bill_stats_card.dart';

class BillsScreen extends ConsumerStatefulWidget {
  const BillsScreen({super.key});

  @override
  ConsumerState<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends ConsumerState<BillsScreen> {
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  String _selectedView = 'list'; // default view

  final Dio dio = Dio();
  CancelToken? _cancelToken;
  Timer? _debounce;
  // Global state provider for bills
  final billsStateProvider = StateProvider<Map<String, List<Bill>>?>(
    (ref) => null, // null = loading
  );
  @override
  void initState() {
    super.initState();
    setWindowBehavior(removeTitleBar: true);
    searchFocusNode.requestFocus();
    _loadSavedView();
    // Initial fetch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchBills(""); // fetch all bills on screen load
    });
  }

  void _fetchBills(String query) async {
    _debounce?.cancel();
    _cancelToken?.cancel();
    _cancelToken = CancelToken();

    _debounce = Timer(const Duration(milliseconds: 300), () async {
      // Set loading state
      ref.read(billsStateProvider.notifier).state = null;

      try {
        final token = await ref.read(tokenProvider.future);
        final response = await dio.get(
          "$baseURL/diagnosis/bills/bill/",
          queryParameters: {"search": query},
          options: Options(headers: {"Authorization": "Bearer $token"}),
          cancelToken: _cancelToken,
        );

        final List data = response.data;
        final bills = data.map((json) => Bill.fromJson(json)).toList();
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

        // Update provider
        ref.read(billsStateProvider.notifier).state = grouped;
      } catch (e) {
        // Error: show empty
        debugPrint(e.toString());
        ref.read(billsStateProvider.notifier).state = {};
      }
    });
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

  void _showViewMenu() async {
    final selected = await showMenu<String>(
      context: context,
      position: const RelativeRect.fromLTRB(
        200,
        385,
        0,
        100,
      ), // adjust if needed
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
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    searchFocusNode.dispose();
    _cancelToken?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groupedBills = ref.watch(billsStateProvider);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.tertiaryFixed,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Theme.of(
          context,
        ).colorScheme.primary.withValues(alpha: 0.7),
        onPressed: () async {
          await navigatorKey.currentState
              ?.push(
                MaterialPageRoute(
                  builder: (context) {
                    return AddBillScreen();
                  },
                ),
              )
              .then((value) {
                _fetchBills("");
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
        padding: EdgeInsets.symmetric(horizontal: defaultPadding * 2),
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
                    onSearch: (e) {
                      _fetchBills(e);
                    },
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
                    physics: BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        Visibility(
                          visible: searchController.text.trim().isEmpty,
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
                                  error: (err, stack) =>
                                      Center(child: Text("Error: $err")),
                                ),
                          ),
                        ),
                        Builder(
                          builder: (context) {
                            if (groupedBills == null) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            if (groupedBills.isEmpty) {
                              return Center(
                                child: Text(
                                  'No bills found.',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineLarge,
                                ),
                              );
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: groupedBills.entries.map((entry) {
                                final category = entry.key;
                                final bills = entry.value;

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          category,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.headlineMedium,
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            _showViewMenu();
                                          },
                                          icon: Icon(
                                            _selectedView == "grid"
                                                ? Icons.grid_on_rounded
                                                : Icons.list,
                                            size: 40,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (_selectedView == "grid")
                                      GridView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),

                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 4,
                                              childAspectRatio: 1.45,
                                              crossAxisSpacing: 16,
                                              mainAxisSpacing: 16,
                                            ),
                                        itemCount: bills.length,

                                        itemBuilder: (ctx, index) {
                                          final bill = bills[index];
                                          return GestureDetector(
                                            onTap: () async {
                                              navigatorKey.currentState
                                                  ?.push(
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          AddBillScreen(
                                                            billData: bill,
                                                          ),
                                                    ),
                                                  )
                                                  .then((value) {
                                                    _fetchBills("");
                                                  });
                                            },
                                            child: BillCard(bill: bill),
                                          );
                                        },
                                      ),
                                    if (_selectedView == "list")
                                      ListView.separated(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: bills.length,
                                        separatorBuilder: (_, __) =>
                                            SizedBox(height: defaultHeight),
                                        itemBuilder: (ctx, index) {
                                          final bill = bills[index];
                                          return GestureDetector(
                                            onTap: () async {
                                              navigatorKey.currentState
                                                  ?.push(
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          AddBillScreen(
                                                            billData: bill,
                                                          ),
                                                    ),
                                                  )
                                                  .then((value) {
                                                    _fetchBills("");
                                                  });
                                            },
                                            child: BillCard(bill: bill),
                                          );
                                        },
                                      ),
                                  ],
                                );
                              }).toList(),
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
