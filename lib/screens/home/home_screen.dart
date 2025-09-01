import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/main.dart';
import 'package:labledger/providers/secure_storage_provider.dart';
import 'package:labledger/providers/referral_and_bill_chart_provider.dart';
import 'package:labledger/screens/bill/bill_screen.dart';
import 'package:labledger/screens/home/ui_components/chart_stats_card.dart';
import 'package:labledger/screens/home/ui_components/referral_card.dart';
import 'package:labledger/screens/initials/window_loading_screen.dart';

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
    FlutterSecureStorage secureStorage = ref.read(secureStorageProvider);
    secureStorage.delete(key: 'access_token');
    secureStorage.delete(key: 'refresh_token');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => WindowLoadingScreen()),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                // / --- REFERRAL STATS SECTION ---
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
                    loading: () => const CircularProgressIndicator(),
                    error: (err, _) =>
                        Text("Error loading referral stats: $err"),
                  ),
                ),
                SizedBox(width: defaultWidth),

                /// --- CHART SECTION ---
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
                          accentColor: baseColor,

                          data: chartData,
                        ),
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, _) =>
                        Center(child: Text("Error loading chart data: $err")),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// --- FILTER CHIP WIDGET ---
  Widget buildFilterChip(String label) {
    final isSelected = selectedPeriod == label;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: () {
          setState(() => selectedPeriod = label);
        },
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [
                      Color(0xFF2E86AB), // LabLedger blue
                      Color(0xFF42A5B3), // LabLedger teal
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isSelected ? null : Colors.grey[100],
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? Colors.transparent : Colors.grey[300]!,
              width: 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF2E86AB).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[700],
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  // Alternative version with more customization options
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
                ? isSelected
                      ? Colors.white
                      : primary.withValues(alpha: 0.8)
                : isSelected
                ? primary.withValues(alpha: 0.8)
                : Colors.transparent,
            border: Border.all(
              color: isDark
                  ? Colors.transparent
                  : primary.withValues(alpha: 0.8),
            ),
          ),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              color: isDark
                  ? isSelected
                        ? Colors.black
                        : Colors.white
                  : isSelected
                  ? Colors.white
                  : Colors.black,
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

  // Simple rounded version
  Widget buildSimpleFilterChip(String label) {
    final isSelected = selectedPeriod == label;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {
          setState(() => selectedPeriod = label);
        },
        selectedColor: const Color(0xFF2E86AB),
        backgroundColor: Colors.grey[100],
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          fontSize: 13,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? const Color(0xFF2E86AB) : Colors.grey[300]!,
            width: 1,
          ),
        ),
        elevation: isSelected ? 2 : 0,
        pressElevation: 4,
      ),
    );
  }
}
