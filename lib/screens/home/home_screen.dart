// screens/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/main.dart';
import 'package:labledger/providers/secure_storage_provider.dart';
import 'package:labledger/providers/referral_and_bill_chart_provider.dart';
import 'package:labledger/screens/bill/bill_screen.dart';
import 'package:labledger/screens/home/ui_components/chart_stats_card.dart';
import 'package:labledger/screens/home/ui_components/referral_card.dart';
import 'package:labledger/screens/initials/window_loading_screen.dart';
import 'package:labledger/screens/window_scaffold.dart'; // Import for navigation

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({
    super.key,
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.isAdmin,
    required this.centerDetail,
  });
  final int id;
  final bool isAdmin;
  final String firstName;
  final String lastName;
  final String username;
  final Map<String, dynamic> centerDetail;
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
    // Note: All ref.listen blocks have been removed.

    final referralStatsAsync = ref.watch(referralStatsProvider);
    final chartStatsAsync = ref.watch(chartStatsProvider);
    final width = MediaQuery.of(context).size.width;
    final baseColor = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: defaultPadding),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: referralStatsAsync.when(
                    data: (statsResponse) {
                      final data = statsResponse.getDataForPeriod(
                        selectedPeriod,
                      );
                      return Stack(
                        children: [
                          ReferralCard(
                            referrals: data,
                            selectedPeriod: selectedPeriod,
                            baseColor: baseColor,
                          ),
                          Positioned(
                            bottom: 12,
                            left: (width - defaultWidth) / 8.5,
                            right: 0,
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                buildFilterChipCustom(
                                  "This Week",
                                  primaryColor: baseColor,
                                ),
                                buildFilterChipCustom(
                                  "This Month",
                                  primaryColor: baseColor,
                                ),
                                buildFilterChipCustom(
                                  "This Year",
                                  primaryColor: baseColor,
                                ),
                                buildFilterChipCustom(
                                  "All Time",
                                  primaryColor: baseColor,
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, _) =>
                        Center(child: Text("Error: Failed to load referral stats.")),
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
                          // This navigation logic now correctly pushes a WindowScaffold
                          navigatorKey.currentState?.push(
                            MaterialPageRoute(
                              builder: (context) {
                                return const WindowScaffold(
                                  child: BillsScreen(),
                                );
                              },
                            ),
                          );
                        },
                        child: ChartStatsCard(
                          title: selectedPeriod,
                          accentColor: baseColor,
                          data: chartData,
                        ),
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, _) =>
                        Center(child: Text("Error: Failed to load chart data.")),
                  ),
                ),
              ],
            ),
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