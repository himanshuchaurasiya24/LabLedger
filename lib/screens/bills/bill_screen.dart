import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/main.dart';
import 'package:labledger/methods/custom_methods.dart';
import 'package:labledger/providers/bills_provider.dart';
import 'package:labledger/screens/bills/add_update_bill_screen.dart';
import 'package:labledger/screens/bills/methods/bill_methods.dart';
import 'package:labledger/screens/ui_components/window_scaffold.dart';
import 'package:labledger/screens/bills/widgets/bill_growth_stats_view.dart';
import 'package:labledger/screens/ui_components/paginated_bills_view.dart';
import 'package:labledger/screens/bills/widgets/section_header.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:window_manager/window_manager.dart';
import 'package:labledger/utils/controller_disposer.dart';

class BillsScreen extends ConsumerStatefulWidget {
  const BillsScreen({super.key});

  @override
  ConsumerState<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends ConsumerState<BillsScreen>
    with WindowListener, ControllerDisposer {
  late final TextEditingController searchController;
  final FocusNode searchFocusNode = FocusNode();
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  late BillMethods _methods;

  @override
  void initState() {
    super.initState();
    _methods = BillMethods(ref, context);
    _methods.addListener(() {
      if (mounted) setState(() {});
    });
    windowManager.addListener(this);
    searchController = createController();
    searchFocusNode.requestFocus();
    _methods.loadSavedView();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    _methods.disposeDebounce();
    _methods.dispose();
    disposeControllers();
    searchFocusNode.dispose();
    super.dispose();
  }





  @override
  Widget build(BuildContext context) {
    final asyncBills = ref.watch(paginatedBillsProvider);
    final asyncStats = ref.watch(billGrowthStatsProvider);
    final currentQuery = ref.watch(currentSearchQueryProvider);

    return WindowScaffold(
      centerWidget: CenterSearchBar(
        controller: searchController,
        searchFocusNode: searchFocusNode,
        hintText: "Search Bills...",
        width: 400,
        onSearch: _methods.onSearchChanged,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (context) => AddUpdateBillScreen(
                themeColor: Theme.of(context).colorScheme.secondary,
              ),
            ),
          );
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        label: const Text(
          "Add Bill",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        icon: const Icon(LucideIcons.plus),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Visibility(
              visible: currentQuery.isEmpty,
              child: Column(
                children: [
                  BillGrowthStatsView(
                    statsProvider: asyncStats,
                    onRetry: () => ref.invalidate(billGrowthStatsProvider),
                  ),
                  SizedBox(height: defaultHeight / 2),
                ],
              ),
            ),
            SectionHeader(
              title: currentQuery.isNotEmpty
                  ? 'Search Results for: "$currentQuery"'
                  : 'All Bills',
              initialView: _methods.selectedView,
              onViewChanged: (value) => _methods.saveView(value),
            ),
            SizedBox(height: defaultHeight / 2),

            PaginatedBillsView(
              billsProvider: asyncBills,
              selectedView: _methods.selectedView,
              headerTitle: currentQuery.isNotEmpty
                  ? 'Search Results for: "$currentQuery"'
                  : 'All Bills',
              emptyListMessage: currentQuery.isEmpty
                  ? 'No bills found.'
                  : 'No bills found for "$currentQuery"',
              onPageChanged: (newPage) {
                ref.read(currentPageProvider.notifier).state = newPage;
              },
              onBillTap: (bill) => _methods.navigateToBill(
                bill,
                bill.billStatus != "Fully Paid"
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.secondary,
              ),
              onRetry: () => ref.invalidate(paginatedBillsProvider),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
