import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    final referralStatsAsync = ref.watch(referralStatsProvider);
    final chartStatsAsync = ref.watch(billChartStatsProvider);
    final baseColor =
        widget.baseColor ?? Theme.of(context).colorScheme.secondary;
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
      centerWidget: Consumer(
        builder: (context, ref, child) {
          // Watch the provider for real-time updates
          final asyncCenterDetail = ref.watch(
            singleCenterDetailProvider(widget.authResponse.centerDetail.id),
          );

          return asyncCenterDetail.when(
            data: (centerDetail) {
              return InkWell(
                borderRadius: BorderRadius.circular(defaultRadius),
                onTap: () {
                  if (widget.authResponse.isAdmin) {
                    showDialog(
                      context: context,
                      builder: (_) =>
                          CenterDetailDialog(centerDetail: centerDetail),
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
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    "${centerDetail.centerName}, ${centerDetail.address}",
                    style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              );
            },
            loading: () => const SizedBox(
              height: 40,
              width: 40,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            // Error state
            error: (error, _) => Container(
              padding: EdgeInsets.symmetric(
                horizontal: defaultPadding * 2,
                vertical: defaultPadding / 2,
              ),
              child: Text(
                'Error loading center',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          );
        },
      ),
      child: ScrollConfiguration(
        behavior: NoThumbScrollBehavior(),
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),

          child: Column(
            children: [
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
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AboutAppDialog();
                        },
                      );
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

                  if (constraints.maxWidth > cardBreakpoint) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(defaultRadius),

                            onTap: () {
                              navigatorKey.currentState?.push(
                                MaterialPageRoute(
                                  builder: (context) {
                                    return DoctorsListScreen();
                                  },
                                ),
                              );
                            },
                            child: TintedContainer(
                              height: height,
                              baseColor: baseColor,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Icon(
                                    FontAwesomeIcons.userDoctor,
                                    color: baseColor,
                                    size: 50,
                                  ),
                                  Text(
                                    "Doctor's List",
                                    style: TextStyle(
                                      color: baseColor,
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios_outlined,
                                    color: baseColor,
                                    size: 30,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: defaultWidth),
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(defaultRadius),

                            onTap: () {
                              navigatorKey.currentState?.push(
                                MaterialPageRoute(
                                  builder: (context) {
                                    return FranchiseListScreen();
                                  },
                                ),
                              );
                            },
                            child: TintedContainer(
                              height: height,

                              baseColor: baseColor,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Icon(
                                    FontAwesomeIcons.buildingColumns,
                                    color: baseColor,
                                    size: 50,
                                  ),
                                  Text(
                                    "Franchise Labs",
                                    style: TextStyle(
                                      color: baseColor,
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios_outlined,
                                    color: baseColor,
                                    size: 30,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: defaultWidth),
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(defaultRadius),

                            onTap: () {
                              navigatorKey.currentState?.push(
                                MaterialPageRoute(
                                  builder: (context) {
                                    return DiagnosisTypesListScreen();
                                  },
                                ),
                              );
                            },
                            child: TintedContainer(
                              height: height,
                              baseColor: baseColor,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Icon(
                                    FontAwesomeIcons.microscope,
                                    color: baseColor,
                                    size: 50,
                                  ),
                                  Text(
                                    "Diagnosis Type",
                                    style: TextStyle(
                                      color: baseColor,
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios_outlined,
                                    color: baseColor,
                                    size: 30,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: defaultWidth),
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(defaultRadius),

                            onTap: () {
                              navigatorKey.currentState?.push(
                                MaterialPageRoute(
                                  builder: (context) {
                                    return CategoryListScreen();
                                  },
                                ),
                              );
                            },
                            child: TintedContainer(
                              height: height,

                              baseColor: baseColor,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Icon(
                                    LucideIcons.tags,
                                    color: baseColor,
                                    size: 50,
                                  ),
                                  Text(
                                    "Categories",
                                    style: TextStyle(
                                      color: baseColor,
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios_outlined,
                                    color: baseColor,
                                    size: 30,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        InkWell(
                          borderRadius: BorderRadius.circular(defaultRadius),

                          onTap: () {
                            navigatorKey.currentState?.push(
                              MaterialPageRoute(
                                builder: (context) {
                                  return DoctorsListScreen();
                                },
                              ),
                            );
                          },
                          child: TintedContainer(
                            height: height,
                            baseColor: baseColor,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Icon(
                                  FontAwesomeIcons.userDoctor,
                                  color: baseColor,
                                  size: 50,
                                ),
                                Text(
                                  "Doctor's List",
                                  style: TextStyle(
                                    color: baseColor,
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios_outlined,
                                  color: baseColor,
                                  size: 30,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: defaultHeight),
                        InkWell(
                          borderRadius: BorderRadius.circular(defaultRadius),

                          onTap: () {
                            navigatorKey.currentState?.push(
                              MaterialPageRoute(
                                builder: (context) {
                                  return FranchiseListScreen();
                                },
                              ),
                            );
                          },
                          child: TintedContainer(
                            height: height,

                            baseColor: baseColor,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Icon(
                                  FontAwesomeIcons.buildingColumns,
                                  color: baseColor,
                                  size: 50,
                                ),
                                Text(
                                  "Franchise Labs",
                                  style: TextStyle(
                                    color: baseColor,
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios_outlined,
                                  color: baseColor,
                                  size: 30,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: defaultHeight),
                        InkWell(
                          borderRadius: BorderRadius.circular(defaultRadius),

                          onTap: () {
                            navigatorKey.currentState?.push(
                              MaterialPageRoute(
                                builder: (context) {
                                  return DiagnosisTypesListScreen();
                                },
                              ),
                            );
                          },
                          child: TintedContainer(
                            height: height,
                            baseColor: baseColor,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Icon(
                                  FontAwesomeIcons.microscope,
                                  color: baseColor,
                                  size: 50,
                                ),
                                Text(
                                  "Diagnosis Type",
                                  style: TextStyle(
                                    color: baseColor,
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios_outlined,
                                  color: baseColor,
                                  size: 30,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: defaultHeight),
                        InkWell(
                          borderRadius: BorderRadius.circular(defaultRadius),

                          onTap: () {
                            navigatorKey.currentState?.push(
                              MaterialPageRoute(
                                builder: (context) {
                                  return CategoryListScreen();
                                },
                              ),
                            );
                          },
                          child: TintedContainer(
                            height: height,

                            baseColor: baseColor,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Icon(
                                  LucideIcons.tags,
                                  color: baseColor,
                                  size: 50,
                                ),
                                Text(
                                  "Categories",
                                  style: TextStyle(
                                    color: baseColor,
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios_outlined,
                                  color: baseColor,
                                  size: 30,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
              if (widget.authResponse.isAdmin) ...[
                SizedBox(height: defaultHeight),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final height = MediaQuery.of(context).size.height / 8.1;

                    if (constraints.maxWidth > cardBreakpoint) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(
                                defaultRadius,
                              ),

                              onTap: () {
                                navigatorKey.currentState?.push(
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return SampleReportManagementScreen();
                                    },
                                  ),
                                );
                              },
                              child: TintedContainer(
                                height: height - 30,
                                baseColor: baseColor,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Icon(
                                      FontAwesomeIcons.server,
                                      color: baseColor,
                                      size: 50,
                                    ),
                                    Text(
                                      "Server Reports",
                                      style: TextStyle(
                                        color: baseColor,
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios_outlined,
                                      color: baseColor,
                                      size: 30,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: defaultWidth),
                          Expanded(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(
                                defaultRadius,
                              ),

                              onTap: () {
                                navigatorKey.currentState?.push(
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return IncentiveGenerationScreen();
                                    },
                                  ),
                                );
                              },
                              child: TintedContainer(
                                height: height - 30,
                                baseColor: baseColor,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Icon(
                                      Icons.currency_rupee_rounded,
                                      color: baseColor,
                                      size: 50,
                                    ),
                                    Text(
                                      "Incentives",
                                      style: TextStyle(
                                        color: baseColor,
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios_outlined,
                                      color: baseColor,
                                      size: 30,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Column(
                        children: [
                          InkWell(
                            borderRadius: BorderRadius.circular(defaultRadius),

                            onTap: () {
                              navigatorKey.currentState?.push(
                                MaterialPageRoute(
                                  builder: (context) {
                                    return SampleReportManagementScreen();
                                  },
                                ),
                              );
                            },
                            child: TintedContainer(
                              height: height,
                              baseColor: baseColor,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Icon(
                                    FontAwesomeIcons.server,
                                    color: baseColor,
                                    size: 50,
                                  ),
                                  Text(
                                    "Server Reports",
                                    style: TextStyle(
                                      color: baseColor,
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios_outlined,
                                    color: baseColor,
                                    size: 30,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: defaultHeight),
                          InkWell(
                            borderRadius: BorderRadius.circular(defaultRadius),

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
                            child: TintedContainer(
                              height: height,
                              baseColor: baseColor,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Icon(
                                    Icons.supervised_user_circle_sharp,
                                    color: baseColor,
                                    size: 50,
                                  ),
                                  Text(
                                    "Users Profile",
                                    style: TextStyle(
                                      color: baseColor,
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios_outlined,
                                    color: baseColor,
                                    size: 30,
                                  ),
                                ],
                              ),
                            ),
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
