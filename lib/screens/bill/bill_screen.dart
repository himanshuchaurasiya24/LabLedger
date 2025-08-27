import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/main.dart';
import 'package:labledger/methods/custom_methods.dart';
import 'package:labledger/models/bill_model.dart';
import 'package:labledger/providers/custom_providers.dart';
import 'package:labledger/screens/bill/add_bill_update_screen.dart';
import 'package:labledger/screens/profile/account_list_screen.dart';



class BillsScreen extends ConsumerStatefulWidget {
  const BillsScreen({super.key});

  @override
  ConsumerState<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends ConsumerState<BillsScreen> {
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();
// Global state provider for bills
final billsStateProvider = StateProvider<Map<String, List<Bill>>?>(
  (ref) => null, // null = loading
);
  final Dio dio = Dio();
  CancelToken? _cancelToken;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    setWindowBehavior(removeTitleBar: true);
    searchFocusNode.requestFocus();

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

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    searchFocusNode.dispose();
    _cancelToken?.cancel();
    // ref.read(billsStateProvider.notifier).state = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groupedBills = ref.watch(billsStateProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.tertiaryFixed,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Theme.of(context).colorScheme.primary,
        onPressed: () {
          navigatorKey.currentState?.push(
            MaterialPageRoute(builder: (_) => AddBillScreen()),
          );
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
                    onSearch: (e) {
                      _fetchBills(e);
                    },
                  ),
                  const SizedBox(width: 160),
                ],
              ),
            ),
            Expanded(
              child: Builder(
                builder: (context) {
                  if (groupedBills == null) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (groupedBills.isEmpty) {
                    return Center(
                      child: Text(
                        'No bills found.',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: groupedBills.entries.map((entry) {
                        final category = entry.key;
                        final bills = entry.value;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 6,
                                horizontal: 6,
                              ),
                              child: Text(
                                category,
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineMedium,
                              ),
                            ),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4,
                                    childAspectRatio: 1.64,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                  ),
                              itemCount: bills.length,
                              itemBuilder: (ctx, index) {
                                final bill = bills[index];
                                return GridCard(
                                  context: context,
                                  onTap: () {
                                    navigatorKey.currentState?.push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            AddBillScreen(billData: bill),
                                      ),
                                    );
                                  },
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            height: 55,
                                            width: 55,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                            ),
                                            child: Center(
                                              child: Text(
                                                bill.patientName.isNotEmpty
                                                    ? bill.patientName[0]
                                                          .toUpperCase()
                                                    : "?",
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: ThemeData.light()
                                                      .scaffoldBackgroundColor,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  bill.patientName,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleSmall
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 22,
                                                      ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 2,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary
                                                        .withValues(alpha: 0.8),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    "Dr. ${bill.referredByDoctorOutput?["first_name"] ?? ""} ${bill.referredByDoctorOutput?["last_name"] ?? ""}",
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        "Bill#: ${bill.billNumber ?? "N/A"}",
                                        style: const TextStyle(fontSize: 18),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        "Franchise: ${bill.franchiseName ?? "N/A"}",
                                        style: const TextStyle(fontSize: 18),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        "₹ ${bill.totalAmount} | Paid: ₹ ${bill.paidAmount}",
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                      Text(
                                        "Status: ${bill.billStatus}",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: bill.billStatus == "Fully Paid"
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Container(
                                        height: 40,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary
                                              .withValues(alpha: 0.8),
                                          borderRadius: BorderRadius.circular(
                                            defaultRadius / 2,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            "${bill.diagnosisTypeOutput?["name"] ?? "Unknown Test"} | Incentive: ₹${bill.incentiveAmount}",
                                            style: TextStyle(
                                              color: ThemeData.light()
                                                  .scaffoldBackgroundColor,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
