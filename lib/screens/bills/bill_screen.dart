import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/main.dart';
import 'package:labledger/methods/custom_methods.dart';
import 'package:labledger/models/bill_model.dart';
import 'package:labledger/providers/bills_provider.dart';
import 'package:labledger/screens/bills/add_update_bill_screen.dart';
import 'package:labledger/screens/initials/window_scaffold.dart';
import 'package:labledger/screens/ui_components/bill_growth_stats_view.dart';
import 'package:labledger/screens/ui_components/paginated_bills_view.dart';
import 'package:labledger/screens/ui_components/view_switcher_menu.dart';
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
    });
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
            position: RelativeRect.fromLTRB(200, 434, defaultPadding, 100),
          ),
        ],
      ),
    );
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
        onSearch: _onSearchChanged,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (context) => AddBillScreen(
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
            _buildSectionHeader(
              context,
              currentQuery.isNotEmpty
                  ? 'Search Results for: "$currentQuery"'
                  : 'All Bills',
            ),
            SizedBox(height: defaultHeight / 2),

            PaginatedBillsView(
              billsProvider: asyncBills,
              selectedView: _selectedView,
              headerTitle: currentQuery.isNotEmpty
                  ? 'Search Results for: "$currentQuery"'
                  : 'All Bills',
              emptyListMessage: currentQuery.isEmpty
                  ? 'No bills found.'
                  : 'No bills found for "$currentQuery"',
              onPageChanged: (newPage) {
                ref.read(currentPageProvider.notifier).state = newPage;
              },
              onBillTap: _navigateToBill,
              onRetry: () => ref.invalidate(paginatedBillsProvider),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
