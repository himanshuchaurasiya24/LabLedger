import 'package:flutter/material.dart';
import 'package:labledger/screens/ui_components/app_inkwell.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/main.dart';
import 'package:labledger/methods/custom_methods.dart';
import 'package:labledger/models/auth_response_model.dart';
import 'package:labledger/providers/bills_provider.dart';
import 'package:labledger/providers/center_detail_provider.dart';
import 'package:labledger/providers/referral_and_bill_chart_provider.dart';
import 'package:labledger/screens/bills/add_update_bill_screen.dart';
import 'package:labledger/screens/diagnosis_types/diagnosis_types_list_screen.dart';
import 'package:labledger/screens/doctors/doctors_list_screen.dart';
import 'package:labledger/screens/franchise_labs/franchise_labs_list_screen.dart';
import 'package:labledger/screens/home/center_detail_dialog.dart';
import 'package:labledger/screens/home/navigation_tile.dart';
import 'package:labledger/screens/incentives/incentive_generation_screen.dart';
import 'package:labledger/screens/categories/category_list_screen.dart';
import 'package:labledger/screens/initials/about_app_dialog.dart';
import 'package:labledger/screens/initials/login_screen.dart';
import 'package:labledger/screens/profile/user_list_screen.dart';
import 'package:labledger/screens/sample_report/sample_report_screen.dart';
import 'package:labledger/screens/ui_components/cards/chart_stats_card.dart';
import 'package:labledger/screens/ui_components/cards/pending_report_bill_card.dart';
import 'package:labledger/screens/ui_components/cards/recent_bills_card.dart';
import 'package:labledger/screens/ui_components/cards/pending_bill_cards.dart';
import 'package:labledger/screens/ui_components/cards/referral_card.dart';
import 'package:labledger/screens/initials/window_scaffold.dart';
import 'package:labledger/screens/profile/user_profile_widget.dart';
import 'package:labledger/screens/ui_components/custom_filter_chips.dart';
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

  Widget _buildNavigationSection(
    BuildContext context, {
    required bool isWide,
    required List<NavigationTile> tiles,
  }) {
    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var index = 0; index < tiles.length; index++) ...[
            if (index > 0) SizedBox(width: defaultWidth),
            Expanded(child: tiles[index]),
          ],
        ],
      );
    }

    return Column(
      children: [
        for (var index = 0; index < tiles.length; index++) ...[
          if (index > 0) SizedBox(height: defaultHeight),
          tiles[index],
        ],
      ],
    );
  }

  Widget _buildHeaderRow(BuildContext context, {required Color baseColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Wrap(
            spacing: 4.0,
            runSpacing: 4.0,
            children: [
              ...["This Week", "This Month", "This Year", "All Time"].map(
                (period) => CustomFilterChips(
                  label: period,
                  selectedPeriod: selectedPeriod,
                  onTap: () {
                    setState(() {
                      selectedPeriod = period;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        UserProfileWidget(
          authResponse: widget.authResponse,
          baseColor: baseColor,
          onLogout: () async {
            await const FlutterSecureStorage().delete(key: "access_token");
            await const FlutterSecureStorage().delete(key: "refresh_token");

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
                    adminId: widget.authResponse.isAdmin
                        ? widget.authResponse.id
                        : 0,
                  );
                },
              ),
            );
          },
          onSettings: () {
            showDialog(
              context: context,
              builder: (context) {
                return AboutAppDialog();
              },
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final referralStatsAsync = ref.watch(referralStatsProvider);
    final chartStatsAsync = ref.watch(billChartStatsProvider);
    final baseColor = widget.baseColor ?? colorScheme.secondary;
    final unpaidBillsAsync = ref.watch(paginatedUnpaidPartialBillsProvider);
    final recentBillsAsync = ref.watch(latestBillsProvider);
    final pendingBillReportAsync = ref.watch(pendingReportBillProvider);
    const double cardBreakpoint = 1100.0;

    return WindowScaffold(
      allowFullScreen: true,
      isInitialScreen: true,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (context) =>
                  AddUpdateBillScreen(themeColor: colorScheme.secondary),
            ),
          );
        },
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        label: const Text(
          "Add Bill",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        icon: const Icon(LucideIcons.plus),
      ),
      centerWidget: Consumer(
        builder: (context, ref, child) {
          final centerDetail = widget.authResponse.centerDetail;
          final asyncCenterDetail = centerDetail.id > 0
              ? ref.watch(singleCenterDetailProvider(centerDetail.id))
              : null;

          final resolvedCenterDetail =
              asyncCenterDetail?.when(
                data: (centerDetail) => centerDetail,
                loading: () => centerDetail,
                error: (_, _) => centerDetail,
              ) ??
              centerDetail;
          final centerLabel =
              resolvedCenterDetail.centerName.isNotEmpty &&
                  resolvedCenterDetail.address.isNotEmpty
              ? "${resolvedCenterDetail.centerName}, ${resolvedCenterDetail.address}"
              : "Center unavailable";

          return AppInkWell(
            borderRadius: BorderRadius.circular(defaultRadius),
            onTap: () {
              if (widget.authResponse.isAdmin) {
                showDialog(
                  context: context,
                  builder: (_) =>
                      CenterDetailDialog(centerDetail: resolvedCenterDetail),
                );
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: defaultPadding * 2,
                vertical: defaultPadding / 2,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(defaultRadius),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (asyncCenterDetail?.isLoading ?? false) ...[
                    SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: defaultWidth),
                  ],
                  Flexible(
                    child: Text(
                      centerLabel,
                      style: TextStyle(
                        fontSize: 20,
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      child: ScrollConfiguration(
        behavior: NoThumbScrollBehavior(),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              _buildHeaderRow(context, baseColor: baseColor),
              SizedBox(height: defaultHeight),
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > cardBreakpoint) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: buildReferralCard(
                            referralStatsAsync,
                            baseColor,
                            context,
                            selectedPeriod,
                          ),
                        ),
                        SizedBox(width: defaultWidth),
                        Expanded(
                          child: buildChartStatsCard(
                            chartStatsAsync,
                            baseColor,
                            context,
                            selectedPeriod,
                          ),
                        ),
                        SizedBox(width: defaultWidth),
                        Expanded(
                          child: buildPendingBillsCard(
                            unpaidBillsAsync,
                            context,
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        buildReferralCard(
                          referralStatsAsync,
                          baseColor,
                          context,
                          selectedPeriod,
                        ),
                        SizedBox(height: defaultHeight),
                        buildChartStatsCard(
                          chartStatsAsync,
                          baseColor,
                          context,
                          selectedPeriod,
                        ),
                        SizedBox(height: defaultHeight),
                        buildPendingBillsCard(unpaidBillsAsync, context),
                      ],
                    );
                  }
                },
              ),
              SizedBox(height: defaultHeight),
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > cardBreakpoint) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: buildRecentBillsCard(
                            recentBillsAsync,
                            baseColor,
                            context,
                          ),
                        ),
                        SizedBox(width: defaultWidth),
                        Expanded(
                          child: pendingReportBill(
                            pendingBillReportAsync,
                            baseColor,
                            context,
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        buildRecentBillsCard(
                          recentBillsAsync,
                          baseColor,
                          context,
                        ),
                        SizedBox(height: defaultHeight),
                        pendingReportBill(
                          pendingBillReportAsync,
                          baseColor,
                          context,
                        ),
                      ],
                    );
                  }
                },
              ),
              SizedBox(height: defaultHeight),
              LayoutBuilder(
                builder: (context, constraints) {
                  final height = MediaQuery.of(context).size.height / 8.1;
                  final primaryTiles = [
                    NavigationTile(
                      icon: FontAwesomeIcons.userDoctor,
                      label: "Doctor's List",
                      color: baseColor,
                      height: height,
                      onTap: () {
                        navigatorKey.currentState?.push(
                          MaterialPageRoute(
                            builder: (context) {
                              return DoctorsListScreen();
                            },
                          ),
                        );
                      },
                    ),
                    NavigationTile(
                      icon: FontAwesomeIcons.buildingColumns,
                      label: "Franchise Labs",
                      color: baseColor,
                      height: height,
                      onTap: () {
                        navigatorKey.currentState?.push(
                          MaterialPageRoute(
                            builder: (context) {
                              return FranchiseListScreen();
                            },
                          ),
                        );
                      },
                    ),
                    NavigationTile(
                      icon: FontAwesomeIcons.microscope,
                      label: "Diagnosis Type",
                      color: baseColor,
                      height: height,
                      onTap: () {
                        navigatorKey.currentState?.push(
                          MaterialPageRoute(
                            builder: (context) {
                              return DiagnosisTypesListScreen();
                            },
                          ),
                        );
                      },
                    ),
                    NavigationTile(
                      icon: LucideIcons.tags,
                      label: "Categories",
                      color: baseColor,
                      height: height,
                      onTap: () {
                        navigatorKey.currentState?.push(
                          MaterialPageRoute(
                            builder: (context) {
                              return CategoryListScreen();
                            },
                          ),
                        );
                      },
                    ),
                  ];

                  return _buildNavigationSection(
                    context,
                    isWide: constraints.maxWidth > cardBreakpoint,
                    tiles: primaryTiles,
                  );
                },
              ),
              if (widget.authResponse.isAdmin) ...[
                SizedBox(height: defaultHeight),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final height = MediaQuery.of(context).size.height / 8.1;
                    final adminTiles = [
                      NavigationTile(
                        icon: FontAwesomeIcons.server,
                        label: "Server Reports",
                        color: baseColor,
                        height: height - 30,
                        onTap: () {
                          navigatorKey.currentState?.push(
                            MaterialPageRoute(
                              builder: (context) {
                                return SampleReportManagementScreen();
                              },
                            ),
                          );
                        },
                      ),
                      NavigationTile(
                        icon: Icons.currency_rupee_rounded,
                        label: "Incentives",
                        color: baseColor,
                        height: height - 30,
                        onTap: () {
                          navigatorKey.currentState?.push(
                            MaterialPageRoute(
                              builder: (context) {
                                return IncentiveGenerationScreen();
                              },
                            ),
                          );
                        },
                      ),
                    ];

                    if (constraints.maxWidth > cardBreakpoint) {
                      return _buildNavigationSection(
                        context,
                        isWide: true,
                        tiles: adminTiles,
                      );
                    } else {
                      return Column(
                        children: [
                          ...adminTiles,
                          SizedBox(height: defaultHeight),
                          NavigationTile(
                            icon: Icons.supervised_user_circle_sharp,
                            label: "Users Profile",
                            color: baseColor,
                            height: height,
                            onTap: () {
                              navigatorKey.currentState?.push(
                                MaterialPageRoute(
                                  builder: (context) {
                                    return UserListScreen(
                                      adminId: widget.authResponse.id,
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    }
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
