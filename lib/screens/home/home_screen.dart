import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/main.dart';
import 'package:labledger/models/auth_response_model.dart';
import 'package:labledger/models/bill_model.dart';
import 'package:labledger/models/paginated_response.dart';
import 'package:labledger/models/referral_and_bill_chart_model.dart';
import 'package:labledger/providers/bills_provider.dart';
import 'package:labledger/providers/secure_storage_provider.dart';
import 'package:labledger/providers/referral_and_bill_chart_provider.dart';
import 'package:labledger/screens/bill/add_update_screen.dart';
import 'package:labledger/screens/bill/bill_screen.dart';
import 'package:labledger/screens/initials/login_screen.dart';
import 'package:labledger/screens/profile/user_list_screen.dart';
import 'package:labledger/screens/ui_components/cards/chart_stats_card.dart';
import 'package:labledger/screens/ui_components/cards/latest_bills_card.dart';
import 'package:labledger/screens/ui_components/cards/pending_bill_cards.dart';
import 'package:labledger/screens/ui_components/cards/referral_card.dart';
import 'package:labledger/screens/initials/window_loading_screen.dart';
import 'package:labledger/screens/initials/window_scaffold.dart';
import 'package:labledger/screens/profile/user_profile_widget.dart';
import 'package:labledger/screens/ui_components/tinted_container.dart';
import 'package:lucide_icons/lucide_icons.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, required this.authResponse, this.baseColor});
  final AuthResponse authResponse;
  final Color? baseColor;
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String selectedPeriod = "This Month";

  void logout() {
    final secureStorage = ref.read(secureStorageProvider);
    secureStorage.delete(key: 'access_token');
    secureStorage.delete(key: 'refresh_token');

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WindowLoadingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final referralStatsAsync = ref.watch(referralStatsProvider);
    final chartStatsAsync = ref.watch(billChartStatsProvider);
    final baseColor =
        widget.baseColor ?? Theme.of(context).colorScheme.secondary;
    final unpaidBillsAsync = ref.watch(paginatedUnpaidPartialBillsProvider);
    final latestBillAsync = ref.watch(latestBillsProvider);
    const double cardBreakpoint = 1100.0;

    return WindowScaffold(
      allowFullScreen: true,
      isInitialScreen: true,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: widget.baseColor,
        foregroundColor: Colors.white,
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(defaultRadius),
        ),
        onPressed: () async {
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (context) => AddBillScreen(
                themeColor: Theme.of(context).colorScheme.secondary,
              ),
            ),
          );
        },
        label: const Text(
          "Add Bill",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        icon: const Icon(LucideIcons.plus),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // CHANGED: Replaced the outer Wrap with a Row for explicit start/end alignment.
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Wrap(
                    spacing: 4.0,
                    runSpacing: 4.0,
                    children: [
                      ...[
                        "This Week",
                        "This Month",
                        "This Year",
                        "All Time",
                      ].map(
                        (period) => buildFilterChipCustom(
                          period,
                          primaryColor: baseColor,
                        ),
                      ),
                    ],
                  ),
                ),
                // NEW: Spacer pushes the user profile widget to the end.
                const Spacer(),
                // The user profile widget will stay at the end.
                UserProfileWidget(
                  authResponse: widget.authResponse,
                  baseColor: baseColor,
                  onLogout: () async {
                    await const FlutterSecureStorage().delete(
                      key: "access_token",
                    );
                    await const FlutterSecureStorage().delete(
                      key: "refresh_token",
                    );

                    navigatorKey.currentState?.pushReplacement(
                      MaterialPageRoute(
                        builder: (context) {
                          return LoginScreen(initialErrorMessage: "");
                        },
                      ),
                    );
                  },
                  onProfile: () {
                    navigatorKey.currentState?.push(
                      MaterialPageRoute(
                        builder: (context) {
                          return UserListScreen(
                            // baseColor: baseColor,
                            adminId: widget.authResponse.isAdmin
                                ? widget.authResponse.id
                                : 0,
                          );
                        },
                      ),
                    );
                  },
                  onSettings: () {
                    //
                  },
                ),
              ],
            ),
            SizedBox(height: defaultHeight),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > cardBreakpoint) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildReferralCard(
                          referralStatsAsync,
                          baseColor,
                        ),
                      ),
                      SizedBox(width: defaultWidth),
                      Expanded(
                        child: _buildChartStatsCard(chartStatsAsync, baseColor),
                      ),
                      SizedBox(width: defaultWidth),
                      Expanded(child: _buildPendingBillsCard(unpaidBillsAsync)),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildReferralCard(referralStatsAsync, baseColor),
                      SizedBox(height: defaultHeight),
                      _buildChartStatsCard(chartStatsAsync, baseColor),
                      SizedBox(height: defaultHeight),
                      _buildPendingBillsCard(unpaidBillsAsync),
                    ],
                  );
                }
              },
            ),
            SizedBox(height: defaultHeight),
            _buildLatestBillsCard(latestBillAsync, baseColor),
          ],
        ),
      ),
    );
  }

  Widget _buildReferralCard(
    AsyncValue<ReferralStatsResponse> referralStatsAsync,
    Color? baseColor,
  ) {
    final Color accentColor =
        baseColor ?? Theme.of(context).colorScheme.secondary;
    final Color errorColor = Theme.of(context).colorScheme.error;

    return referralStatsAsync.when(
      data: (statsResponse) {
        final data = statsResponse.getDataForPeriod(selectedPeriod);
        return ReferralCard(
          referrals: data,
          selectedPeriod: selectedPeriod,
          baseColor: accentColor,
        );
      },
      loading: () =>
          Center(child: CircularProgressIndicator(color: accentColor)),
      error: (err, _) => Center(
        child: Text(
          "Error: Failed to load referral stats.",
          style: TextStyle(color: errorColor),
        ),
      ),
    );
  }

  Widget _buildChartStatsCard(
    AsyncValue<ChartStatsResponse> chartStatsAsync,
    Color? baseColor,
  ) {
    final Color accentColor =
        baseColor ?? Theme.of(context).colorScheme.secondary;
    final Color errorColor = Theme.of(context).colorScheme.error;
    return chartStatsAsync.when(
      data: (chartResponse) {
        final chartData = chartResponse.getDataForPeriod(selectedPeriod);
        return GestureDetector(
          onTap: () {
            navigatorKey.currentState?.push(
              MaterialPageRoute(builder: (context) => const BillsScreen()),
            );
          },
          child: ChartStatsCard(
            title: selectedPeriod,
            baseColor: accentColor,
            data: chartData,
          ),
        );
      },
      loading: () =>
          Center(child: CircularProgressIndicator(color: accentColor)),
      error: (err, _) => Center(
        child: Text(
          "Error: Failed to load chart data.",
          style: TextStyle(color: errorColor),
        ),
      ),
    );
  }

  Widget _buildPendingBillsCard(
    AsyncValue<PaginatedBillsResponse> unpaidBillsAsync,
  ) {
    final accentColor = Theme.of(context).colorScheme.error;
    return unpaidBillsAsync.when(
      data: (unpaidBillsAsyncResponse) {
        return PendingBillsCard(
          baseColor: unpaidBillsAsyncResponse.bills.isEmpty
              ? Theme.of(context).colorScheme.secondary
              : accentColor,
          bills: unpaidBillsAsyncResponse.bills,
          onBillTap: (bill) {
            navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (context) => AddBillScreen(
                  billData: bill,
                  themeColor: Theme.of(context).colorScheme.error,
                ),
              ),
            );
          },
        );
      },
      loading: () => TintedContainer(
        baseColor: accentColor,

        child: Center(child: CircularProgressIndicator(color: accentColor)),
      ),
      error: (err, _) => Center(
        child: Text(
          "Error: Failed to load pending bills.",
          style: TextStyle(color: accentColor),
        ),
      ),
    );
  }

  Widget buildFilterChipCustom(String label, {Color? primaryColor}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = selectedPeriod == label;
    final primary = primaryColor ?? Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: () {
          setState(() => selectedPeriod = label);
        },
        borderRadius: BorderRadius.circular(25),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: isDark
                ? (isSelected ? Colors.white : primary.withAlpha(204))
                : (isSelected ? primary.withAlpha(204) : Colors.transparent),
            border: Border.all(
              color: isDark ? Colors.transparent : primary.withAlpha(204),
            ),
          ),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              color: isDark
                  ? (isSelected ? Colors.black : Colors.white)
                  : (isSelected ? Colors.white : Colors.black),
              fontWeight: FontWeight.w600,
              fontSize: 14,
              letterSpacing: 0.5,
            ),
            child: Text(label),
          ),
        ),
      ),
    );
  }

  /// Builds a card that displays a list of the latest bills.
  Widget _buildLatestBillsCard(
    AsyncValue<List<Bill>> latestBillsAsync,
    Color? baseColor,
  ) {
    // A way to get context if needed
    final Color accentColor =
        baseColor ?? Theme.of(context).colorScheme.secondary;
    final Color errorColor = Theme.of(context).colorScheme.error;
    return latestBillsAsync.when(
      data: (bills) {
        return LatestBillsCard(bills: bills, baseColor: accentColor);
      },
      // --- Loading and Error States ---
      loading: () => TintedContainer(
        baseColor: accentColor,
        child: Center(child: CircularProgressIndicator(color: baseColor)),
      ),
      error: (err, _) => TintedContainer(
        baseColor: errorColor,
        child: Center(
          child: Text(
            "Error: Failed to load recent bills.",
            style: TextStyle(color: errorColor),
          ),
        ),
      ),
    );
  }
}
