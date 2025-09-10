// screens/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/main.dart';
import 'package:labledger/models/auth_response_model.dart';
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
import 'package:labledger/screens/ui_components/cards/pending_bill_cards.dart';
import 'package:labledger/screens/ui_components/cards/referral_card.dart';
import 'package:labledger/screens/initials/window_loading_screen.dart';
import 'package:labledger/screens/initials/window_scaffold.dart';
import 'package:labledger/screens/profile/user_profile_widget.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, required this.authResponse});
  final AuthResponse authResponse;
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
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final referralStatsAsync = ref.watch(referralStatsProvider);
    final chartStatsAsync = ref.watch(billChartStatsProvider);
    final baseColor = Theme.of(context).colorScheme.secondary;
    final unpaidBillsAsync = ref.watch(paginatedUnpaidPartialBillsProvider);

    // NEW: Define a breakpoint for when to switch from Row to Column
    const double cardBreakpoint = 1100.0;

    return WindowScaffold(
      allowFullScreen: true,
      isInitialScreen: true,
      // CHANGED: Removed outer Padding, it will be handled inside the scroll view.
      child: SingleChildScrollView(
        // NEW: Make the whole screen scrollable
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: defaultPadding),
          child: Column(
            children: [
              // CHANGED: Used Wrap for the top bar to make it responsive
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                runSpacing:
                    defaultHeight, // Spacing when items wrap to the next line
                children: [
                  // This Wrap handles the filter chips
                  Wrap(
                    spacing: 4.0, // Horizontal space between chips
                    runSpacing: 4.0, // Vertical space if chips wrap
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
                  UserProfileWidget(
                    authResponse: widget.authResponse,
                    baseColor: Theme.of(context).colorScheme.secondary,
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
                              baseColor: baseColor,
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
              // NEW: Use LayoutBuilder to choose between Row and Column for cards
              LayoutBuilder(
                builder: (context, constraints) {
                  // If the screen is wide, use a Row
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
                          child: _buildChartStatsCard(
                            chartStatsAsync,
                            baseColor,
                          ),
                        ),
                        SizedBox(width: defaultWidth),
                        Expanded(
                          child: _buildPendingBillsCard(unpaidBillsAsync),
                        ),
                      ],
                    );
                  } else {
                    // If the screen is narrow, use a Column
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
            ],
          ),
        ),
      ),
    );
  }

  // NEW: Extracted card building logic into separate methods for clarity

  Widget _buildReferralCard(
    AsyncValue<ReferralStatsResponse> referralStatsAsync,
    Color baseColor,
  ) {
    return referralStatsAsync.when(
      data: (statsResponse) {
        final data = statsResponse.getDataForPeriod(selectedPeriod);
        return ReferralCard(
          referrals: data,
          selectedPeriod: selectedPeriod,
          baseColor: baseColor,
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) =>
          const Center(child: Text("Error: Failed to load referral stats.")),
    );
  }

  Widget _buildChartStatsCard(
    AsyncValue<ChartStatsResponse> chartStatsAsync,
    Color baseColor,
  ) {
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
            baseColor: baseColor,
            data: chartData,
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) =>
          const Center(child: Text("Error: Failed to load chart data.")),
    );
  }

  Widget _buildPendingBillsCard(
    AsyncValue<PaginatedBillsResponse> unpaidBillsAsync,
  ) {
    return unpaidBillsAsync.when(
      data: (unpaidBillsAsyncResponse) {
        return PendingBillsCard(
          baseColor: unpaidBillsAsyncResponse.bills.isEmpty
              ? Theme.of(context).colorScheme.secondary
              : Colors.red,
          bills: unpaidBillsAsyncResponse.bills,
          onBillTap: (bill) {
            navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (context) => AddBillScreen(billData: bill),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) =>
          const Center(child: Text("Error: Failed to load pending bills.")),
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
}
