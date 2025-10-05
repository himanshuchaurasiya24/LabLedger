import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/main.dart';
import 'package:labledger/methods/custom_methods.dart';
import 'package:labledger/models/bill_model.dart';
import 'package:labledger/models/franchise_model.dart';
import 'package:labledger/providers/bills_provider.dart';
import 'package:labledger/providers/franchise_provider.dart';
import 'package:labledger/screens/bills/add_update_bill_screen.dart';
import 'package:labledger/screens/franchise_labs/franchise_edit_screen.dart';
import 'package:labledger/screens/initials/window_scaffold.dart';
import 'package:labledger/screens/ui_components/paginated_bills_view.dart';
import 'package:labledger/screens/ui_components/tinted_container.dart';
import 'package:labledger/screens/ui_components/view_switcher_menu.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:window_manager/window_manager.dart';

class FranchiseBillsListScreen extends ConsumerStatefulWidget {
  const FranchiseBillsListScreen({super.key, required this.id});
  final int id;

  @override
  ConsumerState<FranchiseBillsListScreen> createState() =>
      _FranchiseBillsListScreenState();
}

class _FranchiseBillsListScreenState
    extends ConsumerState<FranchiseBillsListScreen>
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

  Future<void> _confirmDeleteFranchise(FranchiseName franchise) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Franchise'),
        content: Text(
          'All bills associated with "${franchise.franchiseName}" will be deleted.\nThis action cannot be undone.\nAre you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        await ref.read(deleteFranchiseProvider(widget.id).future);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text("Franchise deleted successfully"),
              backgroundColor: Theme.of(context).colorScheme.secondary,
            ),
          );
          Navigator.of(context).pop(); // Go back to the previous screen
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text("Failed to delete franchise: $e"),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final franchiseBillsAsync = ref.watch(
      paginatedFranchiseBillProvider(widget.id),
    );
    final franchiseAsync = ref.watch(singleFranchiseProvider(widget.id));
    final currentQuery = ref.watch(currentSearchQueryProvider);

    return WindowScaffold(
      centerWidget: franchiseAsync.when(
        data: (franchise) => CenterSearchBar(
          controller: searchController,
          searchFocusNode: searchFocusNode,
          hintText: "Search bills for ${franchise.franchiseName}...",
          width: 400,
          onSearch: _onSearchChanged,
        ),
        loading: () => const SizedBox(),
        error: (_, _) => const SizedBox(),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildFranchiseHeader(franchiseAsync),
            SizedBox(height: defaultHeight),
            _buildSectionHeader(
              context,
              currentQuery.isNotEmpty
                  ? 'Search Results for: "$currentQuery"'
                  : "Franchise Bills",
            ),
            PaginatedBillsView(
              billsProvider: franchiseBillsAsync,
              selectedView: _selectedView,
              headerTitle: currentQuery.isNotEmpty
                  ? 'Search Results for: "$currentQuery"'
                  : "Franchise Bills",
              emptyListMessage: currentQuery.isEmpty
                  ? 'No bills found for this franchise.'
                  : 'No bills found for "$currentQuery"',
              onPageChanged: (newPage) {
                ref.read(currentPageProvider.notifier).state = newPage;
              },
              onBillTap: _navigateToBill,
              onRetry: () =>
                  ref.invalidate(paginatedFranchiseBillProvider(widget.id)),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  // Header widget to show franchise details and actions
  Widget _buildFranchiseHeader(AsyncValue<FranchiseName> franchiseAsync) {
    final theme = Theme.of(context);
    Color headerColor = Theme.of(context).colorScheme.primary;

    return franchiseAsync.when(
      data: (franchise) => TintedContainer(
        baseColor: headerColor,
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
                    color: headerColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Icon(
                      LucideIcons.building2,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      franchise.franchiseName!,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
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
                        "${franchise.address!}, ${franchise.phoneNumber}",
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
                    // Assumes you have an EditFranchiseScreen
                    navigatorKey.currentState?.push(
                      MaterialPageRoute(
                        builder: (context) =>
                            FranchiseEditScreen(franchiseId: widget.id),
                      ),
                    );
                  },
                  icon: Icon(
                    LucideIcons.edit,
                    color: theme.colorScheme.primary,
                  ),
                  tooltip: 'Edit Franchise',
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _confirmDeleteFranchise(franchise),
                  icon: Icon(
                    LucideIcons.trash2,
                    color: theme.colorScheme.error,
                  ),
                  tooltip: 'Delete Franchise',
                ),
              ],
            ),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) =>
          Center(child: Text('Failed to load franchise details: $err')),
    );
  }

  // Section header for the bills list
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
            position: RelativeRect.fromLTRB(200, 230, defaultPadding, 100),
          ),
        ],
      ),
    );
  }
}
