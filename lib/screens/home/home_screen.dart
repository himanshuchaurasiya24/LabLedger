// screens/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/main.dart';
import 'package:labledger/models/auth_response_model.dart';
import 'package:labledger/providers/bills_provider.dart';
import 'package:labledger/providers/secure_storage_provider.dart';
import 'package:labledger/providers/referral_and_bill_chart_provider.dart';
import 'package:labledger/screens/bill/add_update_screen.dart';
import 'package:labledger/screens/bill/bill_screen.dart';
import 'package:labledger/screens/initials/login_screen.dart';
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
    // final isDark = ThemeData().brightness == Brightness.dark;
    final referralStatsAsync = ref.watch(referralStatsProvider);
    final chartStatsAsync = ref.watch(billChartStatsProvider);
    final baseColor = Theme.of(context).colorScheme.secondary;
    final unpaidBillsAsync = ref.watch(paginatedUnpaidPartialBillsProvider);

    return WindowScaffold(
      allowFullScreen: true,
      isInitialScreen: true,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: defaultPadding),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...["This Week", "This Month", "This Year", "All Time"].map(
                      (period) => Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: buildFilterChipCustom(
                          period,
                          primaryColor: baseColor,
                        ),
                      ),
                    ),
                  ],
                ),

                UserProfileWidget(
                  authResponse: widget.authResponse,
                  baseColor: Theme.of(context).colorScheme.secondary,
                  onLogout: () async {
                    await FlutterSecureStorage().delete(key: "access_token");
                    await FlutterSecureStorage().delete(key: "refresh_token");
                    navigatorKey.currentState?.pushReplacement(
                      MaterialPageRoute(
                        builder: (context) {
                          return LoginScreen(initialErrorMessage: "");
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: defaultHeight),
            Row(
              children: [
                Expanded(
                  child: referralStatsAsync.when(
                    data: (statsResponse) {
                      final data = statsResponse.getDataForPeriod(
                        selectedPeriod,
                      );
                      return ReferralCard(
                        referrals: data,
                        selectedPeriod: selectedPeriod,
                        baseColor: baseColor,
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, _) => Center(
                      child: Text("Error: Failed to load referral stats."),
                    ),
                  ),
                ),
                SizedBox(width: defaultWidth),
                Expanded(
                  child: chartStatsAsync.when(
                    data: (chartResponse) {
                      final chartData = chartResponse.getDataForPeriod(
                        selectedPeriod,
                      );
                      return GestureDetector(
                        onTap: () {
                          navigatorKey.currentState?.push(
                            MaterialPageRoute(
                              builder: (context) {
                                return BillsScreen();
                              },
                            ),
                          );
                        },
                        child: ChartStatsCard(
                          title: selectedPeriod,
                          baseColor: baseColor,
                          data: chartData,
                        ),
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, _) => Center(
                      child: Text("Error: Failed to load chart data."),
                    ),
                  ),
                ),
                SizedBox(width: defaultWidth),

                Expanded(
                  child: unpaidBillsAsync.when(
                    data: (unpaidBillsAsyncResponse) {
                      final unpaidBillsAsyncData = unpaidBillsAsyncResponse;
                      return PendingBillsCard(
                        baseColor: unpaidBillsAsyncData.bills.isEmpty
                            ? Theme.of(context).colorScheme.secondary
                            : Colors.red,
                        bills: unpaidBillsAsyncData.bills,
                        onBillTap: (bill) {
                          navigatorKey.currentState?.push(
                            MaterialPageRoute(
                              builder: (context) {
                                return AddBillScreen(billData: bill);
                              },
                            ),
                          );
                        },
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, _) => Center(
                      child: Text("Error: Failed to load chart data."),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: defaultHeight),
          ],
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
}
