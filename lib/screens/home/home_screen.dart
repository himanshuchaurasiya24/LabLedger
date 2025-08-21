// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';
import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:labledger/main.dart';

import 'package:labledger/methods/custom_methods.dart';
import 'package:labledger/models/center_detail_model.dart';
import 'package:labledger/models/doctors_model.dart';
import 'package:labledger/providers/bills_provider.dart';
import 'package:labledger/providers/custom_providers.dart';
import 'package:labledger/providers/doctor_provider.dart';
import 'package:labledger/screens/bill/bill_screen.dart';
import 'package:labledger/screens/home/home_screen_logic.dart';
import 'package:labledger/screens/initials/login_screen.dart';
import 'package:labledger/screens/initials/window_loading_screen.dart';
import 'package:labledger/screens/database_screen.dart';
import 'package:labledger/screens/profile/account_list_screen.dart';
import 'package:labledger/screens/profile/profile_screen.dart';

enum TimeFilter { thisWeek, thisMonth, thisYear, allTime }

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
  final CenterDetail centerDetail;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  TimeFilter _selectedRangeForBills = TimeFilter.thisMonth;
  TimeFilter _selectedRangeForTopReferrals = TimeFilter.thisMonth;
  void logout() {
    FlutterSecureStorage secureStorage = ref.read(secureStorageProvider);
    secureStorage.delete(key: 'access_token');
    setWindowBehavior(isForLogin: true);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  void initState() {
    super.initState();
    setWindowBehavior();
  }

  double containerWidth = 540;
  double sideContainerWidth = 432;
  double containerHeight = 0;
  double longContainerHeight = 0;
  double smallWidthSpacing = 0;
  double bigWidthSpacing = 0;
  double wideContainerSize = 0;
  double smallheightSpacing = 0;
  // int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final doctorsAsync = ref.watch(doctorsProvider);
    final billsAsync = ref.watch(billsProvider);
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final themeMode = ref.read(themeNotifierProvider);
    containerWidth = width / 2.962963;
    sideContainerWidth = width / 3.7037037;
    smallWidthSpacing = width / 80;
    bigWidthSpacing = width / 32;
    wideContainerSize = width / 1.4545455;
    smallheightSpacing = height / 56.25;
    containerHeight = height * 0.388888;
    longContainerHeight = height * 0.475;
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return BillScreen();
              },
            ),
          );
        },
        label: Text(
          "Add New Bill",
          style: TextStyle(
            color: ThemeData.light().scaffoldBackgroundColor,
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: defaultPadding * 2,
          vertical: defaultPadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment
                  .spaceBetween, // This will have limited effect if children are not constrained
              children: [
                appIconName(
                  context: context,
                  firstName: "Lab",
                  secondName: "Ledger",
                  fontSize: 50,
                ),
                SizedBox(
                  width: bigWidthSpacing,
                ), // Replaced Spacer with a fixed space for horizontal scrolling
                Text(
                  "${widget.centerDetail.centerName}, ${widget.centerDetail.address}",
                  style: Theme.of(context).textTheme.headlineLarge,
                ),

                SizedBox(
                  width: bigWidthSpacing,
                ), // Replaced Spacer with a fixed space
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        //
                      },
                      icon: CircleAvatar(
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.tertiaryFixed,
                        radius: 30,
                        child: IconButton(
                          onPressed: () {
                            //
                          },
                          icon: Icon(Icons.notifications_outlined, size: 34),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        final selected = await showMenu(
                          context: context,
                          position: RelativeRect.fromLTRB(
                            100,
                            90,
                            10,
                            0,
                          ), // adjust as needed
                          color: Theme.of(
                            context,
                          ).colorScheme.tertiaryFixed.withValues(alpha: 0.9),
                          shadowColor: Theme.of(
                            context,
                          ).scaffoldBackgroundColor,
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(defaultRadius),
                            side: BorderSide(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? ThemeData.light().scaffoldBackgroundColor
                                  : ThemeData.dark().scaffoldBackgroundColor,
                              width: 2,
                            ),
                          ),
                          constraints: BoxConstraints(
                            minWidth: 300, // make it wider
                          ),

                          items: [
                            PopupMenuItem(
                              value: 'userDetails',
                              child: ListTile(
                                leading: Icon(
                                  Icons.verified_user,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 40,
                                ),
                                title: Text(
                                  "${widget.firstName.toUpperCase()} ${widget.lastName.toUpperCase()}",
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                  ),
                                ),
                                subtitle: widget.isAdmin
                                    ? Text(
                                        "Administrator",
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.secondary,
                                          fontSize: 20,
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                            if (widget.isAdmin)
                              PopupMenuItem(
                                value: 'accountControl',
                                child: ListTile(
                                  leading: Icon(Icons.lock),
                                  title: Text(
                                    "Account Control",
                                    style: TextStyle(fontSize: 20),
                                  ),
                                ),
                              ),
                            PopupMenuItem(
                              value: 'theme',
                              child: ListTile(
                                leading: Icon(Icons.brightness_6),
                                title: Text(switch (themeMode) {
                                  ThemeMode.dark => "Current Theme : Dark",
                                  ThemeMode.light => "Current Theme : Light",
                                  ThemeMode.system => "Current Theme : System",
                                }, style: TextStyle(fontSize: 20)),
                              ),
                            ),
                            PopupMenuItem(
                              value: 'logout',
                              child: ListTile(
                                leading: Icon(Icons.logout),
                                title: Text(
                                  "Logout",
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                            ),
                            PopupMenuItem(
                              value: 'exit',
                              child: ListTile(
                                leading: Icon(
                                  Icons.exit_to_app,
                                  color: Colors.red,
                                ),
                                title: Text(
                                  "Exit",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );

                        if (selected == null) return;
                        if (selected == 'userDetails') {
                          navigatorKey.currentState?.push(
                            MaterialPageRoute(
                              builder: (context) {
                                return ProfileScreen(userId: widget.id);
                              },
                            ),
                          );
                        } else if (selected == "accountControl") {
                          navigatorKey.currentState?.push(
                            MaterialPageRoute(
                              builder: (context) {
                                return AccountListScreen();
                              },
                            ),
                          );
                        } else if (selected == 'theme') {
                          final current = ref.read(themeNotifierProvider);
                          final notifier = ref.read(
                            themeNotifierProvider.notifier,
                          );

                          final nextMode = switch (current) {
                            ThemeMode.system => ThemeMode.light,
                            ThemeMode.light => ThemeMode.dark,
                            ThemeMode.dark => ThemeMode.system,
                          };

                          notifier.toggleTheme(nextMode);
                        } else if (selected == 'logout') {
                          final storage = ref.read(secureStorageProvider);
                          await storage.delete(key: 'access_token');
                          navigatorKey.currentState?.pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => WindowLoadingScreen(
                                onLoginScreen: isLoginScreen,
                              ),
                            ),
                          );
                        } else if (selected == "exit") {
                          exit(0);
                        }
                      },
                      icon: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.tertiary,
                        radius: 30,
                        child: Text(
                          widget.firstName[0].toUpperCase(),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.tertiaryFixed,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: smallheightSpacing / 2),
            Expanded(
              child: ScrollConfiguration(
                behavior: NoThumbScrollBehavior(),

                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              Row(
                                children: [
                                  GlassContainer(
                                    height: containerHeight,
                                    width: containerWidth,
                                    // borderRadius: BorderRadius.circular(
                                    //   defaultRadius,
                                    // ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Top Referral Counter",
                                              style: Theme.of(
                                                context,
                                              ).textTheme.headlineSmall,
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                //
                                              },
                                              icon: Icon(
                                                Icons.arrow_forward_ios,
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height:
                                              containerHeight -
                                              defaultPadding * 2 -
                                              102,
                                          child: doctorsAsync.when(
                                            data: (doctors) {
                                              return billsAsync.when(
                                                data: (bills) {
                                                  final TopReferrerModel
                                                  leaderboard =
                                                      topReferralFinder(
                                                        filteredData: bills,
                                                        allDoctors: doctors,
                                                      );
                                                  if (_selectedRangeForTopReferrals ==
                                                      TimeFilter.thisWeek) {
                                                    return Column(
                                                      children: [
                                                        for (
                                                          int i = 0;
                                                          i <
                                                              leaderboard
                                                                  .week
                                                                  .length;
                                                          i++
                                                        )
                                                          ListTile(
                                                            leading:
                                                                CircleAvatar(
                                                                  child: Text(
                                                                    '${i + 1}',
                                                                  ),
                                                                ),
                                                            title: Text(
                                                              "${leaderboard.week[i].doctor.firstName} ${leaderboard.week[i].doctor.lastName}",
                                                            ),
                                                            subtitle: Text(
                                                              "Incentive: ₹${leaderboard.week[i].incentive}",
                                                            ),
                                                            trailing: Text(
                                                              "USG: ${leaderboard.week[i].ultrasound}",
                                                            ),
                                                          ),
                                                      ],
                                                    );
                                                  }

                                                  if (_selectedRangeForTopReferrals ==
                                                      TimeFilter.thisYear) {
                                                    return Column(
                                                      children: [
                                                        for (
                                                          int i = 0;
                                                          i <
                                                              leaderboard
                                                                  .year
                                                                  .length;
                                                          i++
                                                        )
                                                          ListTile(
                                                            leading:
                                                                CircleAvatar(
                                                                  child: Text(
                                                                    '${i + 1}',
                                                                  ),
                                                                ),
                                                            title: Text(
                                                              "${leaderboard.year[i].doctor.firstName} ${leaderboard.year[i].doctor.lastName}",
                                                            ),
                                                            subtitle: Text(
                                                              "Incentive: ₹${leaderboard.year[i].incentive}",
                                                            ),
                                                            trailing: Text(
                                                              "USG: ${leaderboard.year[i].ultrasound}",
                                                            ),
                                                          ),
                                                      ],
                                                    );
                                                  }
                                                  if (_selectedRangeForTopReferrals ==
                                                      TimeFilter.allTime) {
                                                    return Column(
                                                      children: [
                                                        for (
                                                          int i = 0;
                                                          i <
                                                              leaderboard
                                                                  .allTime
                                                                  .length;
                                                          i++
                                                        )
                                                          ListTile(
                                                            leading:
                                                                CircleAvatar(
                                                                  child: Text(
                                                                    '${i + 1}',
                                                                  ),
                                                                ),
                                                            title: Text(
                                                              "${leaderboard.allTime[i].doctor.firstName} ${leaderboard.allTime[i].doctor.lastName}",
                                                            ),
                                                            subtitle: Text(
                                                              "Incentive: ₹${leaderboard.allTime[i].incentive}",
                                                            ),
                                                            trailing: Text(
                                                              "USG: ${leaderboard.allTime[i].ultrasound}",
                                                            ),
                                                          ),
                                                      ],
                                                    );
                                                  }
                                                  return Column(
                                                    children: [
                                                      for (
                                                        int i = 0;
                                                        i <
                                                            leaderboard
                                                                .month
                                                                .length;
                                                        i++
                                                      )
                                                        ListTile(
                                                          leading: CircleAvatar(
                                                            child: Text(
                                                              '${i + 1}',
                                                            ),
                                                          ),
                                                          title: Text(
                                                            "${leaderboard.month[i].doctor.firstName} ${leaderboard.month[i].doctor.lastName}",
                                                          ),
                                                          subtitle: Text(
                                                            "Incentive: ₹${leaderboard.month[i].incentive}",
                                                          ),
                                                          trailing: Text(
                                                            "USG: ${leaderboard.month[i].ultrasound}",
                                                          ),
                                                        ),
                                                    ],
                                                  );
                                                },
                                                loading: () => Center(
                                                  child:
                                                      const CircularProgressIndicator(),
                                                ),
                                                error: (err, stack) => Text(
                                                  "Error loading bills: $err",
                                                ),
                                              );
                                            },
                                            loading: () => Center(
                                              child:
                                                  const CircularProgressIndicator(),
                                            ),
                                            error: (err, stack) => Text(
                                              "Error loading doctors: $err",
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 25),
                                        buildTimeFilterSelector(
                                          _selectedRangeForTopReferrals,
                                          (newFilter) {
                                            setState(() {
                                              _selectedRangeForTopReferrals =
                                                  newFilter;
                                            });
                                          },
                                          context,
                                        ),
                                      ],
                                    ),
                                  ),

                                  SizedBox(width: smallWidthSpacing),

                                  GlassContainer(
                                    height: containerHeight,
                                    width: containerWidth,
                                    // borderRadius: BorderRadius.circular(20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Bills Counter",
                                              style: Theme.of(
                                                context,
                                              ).textTheme.headlineSmall,
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                //
                                              },
                                              icon: Icon(
                                                Icons.arrow_forward_ios,
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                              ),
                                            ),
                                          ],
                                        ),

                                        SizedBox(
                                          height:
                                              containerHeight -
                                              defaultPadding * 2 -
                                              102,
                                          child: billsAsync.when(
                                            data: (bills) {
                                              final filteredData =
                                                  filterBillsByTimeFilter(
                                                    bills,
                                                    _selectedRangeForBills,
                                                  );
                                              final chartData = prepareSpots(
                                                filteredData,
                                              );
                                              final dateLabels =
                                                  extractDateLabels(
                                                    filteredData,
                                                  );
                                              return LineChart(
                                                getChartData(
                                                  chartData,
                                                  dateLabels,
                                                  context,
                                                ),
                                              );
                                            },
                                            loading: () => const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                            error: (err, _) => Text(
                                              "Error loading chart: $err",
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 25),
                                        buildTimeFilterSelector(
                                          _selectedRangeForBills,
                                          (newFilter) {
                                            setState(() {
                                              _selectedRangeForBills =
                                                  newFilter;
                                            });
                                          },
                                          context,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: smallheightSpacing),
                              GlassContainer(
                                height: longContainerHeight,
                                width: wideContainerSize,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Recently Added Bills",
                                          style: Theme.of(
                                            context,
                                          ).textTheme.headlineSmall,
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            //
                                          },
                                          icon: Icon(
                                            Icons.arrow_forward_ios,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Consumer(
                                      builder: (context, ref, _) {
                                        final billsAsync = ref.watch(
                                          billsProvider,
                                        );
                                        return billsAsync.when(
                                          data: (bills) {
                                            final fetchedBills = bills
                                                .toList()
                                                .reversed;
                                            final latest = fetchedBills.take(
                                              20,
                                            );
                                            return Expanded(
                                              child: SingleChildScrollView(
                                                scrollDirection: Axis.vertical,
                                                child: Column(
                                                  children: latest.map((bill) {
                                                    return ListTile(
                                                      leading: Icon(
                                                        Icons.receipt_long,
                                                        size: 35,
                                                        color:
                                                            bill.billStatus ==
                                                                "Fully Paid"
                                                            ? (Colors.green[300] ??
                                                                  Colors.green)
                                                            : (Colors.red[300] ??
                                                                  Colors.red),
                                                      ),
                                                      title: Text(
                                                        bill.patientName,
                                                      ),
                                                      subtitle: Text(
                                                        "Date: ${bill.dateOfBill}",
                                                        style: Theme.of(
                                                          context,
                                                        ).textTheme.bodyMedium,
                                                      ),
                                                      trailing: Container(
                                                        height: 40,
                                                        width:
                                                            bill.billStatus ==
                                                                "Fully Paid"
                                                            ? 100
                                                            : 170,
                                                        decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                10,
                                                              ),
                                                          border: Border.all(
                                                            color:
                                                                bill.billStatus ==
                                                                    "Fully Paid"
                                                                ? (Colors.green[300] ??
                                                                      Colors
                                                                          .green)
                                                                : (Colors.red[300] ??
                                                                      Colors
                                                                          .red),
                                                            width: 3,
                                                          ),
                                                          color:
                                                              bill.billStatus ==
                                                                  "Fully Paid"
                                                              ? Colors
                                                                    .green[200]
                                                              : Colors.red[200],
                                                        ),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Visibility(
                                                              visible:
                                                                  bill.billStatus !=
                                                                  "Fully Paid",
                                                              child: Text(
                                                                "Pending : ",
                                                                style: TextStyle(
                                                                  color: Colors
                                                                      .black54,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 16,
                                                                ),
                                                              ),
                                                            ),

                                                            Text(
                                                              bill.billStatus ==
                                                                      "Fully Paid"
                                                                  ? "₹${bill.totalAmount}"
                                                                  : "₹${bill.totalAmount - bill.paidAmount}",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .black54,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 16,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  }).toList(),
                                                ),
                                              ),
                                            );
                                          },
                                          loading: () =>
                                              const CircularProgressIndicator(),
                                          error: (err, _) =>
                                              Text("Error loading bills: $err"),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: smallWidthSpacing),
                          Column(
                            children: [
                              GlassContainer(
                                height: longContainerHeight,
                                width: sideContainerWidth,
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "New Card",
                                          style: Theme.of(
                                            context,
                                          ).textTheme.headlineSmall,
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            //
                                          },
                                          icon: Icon(
                                            Icons.arrow_forward_ios,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: smallheightSpacing),
                              GlassContainer(
                                height: containerHeight,
                                width: sideContainerWidth,
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Database Overview",
                                          style: Theme.of(
                                            context,
                                          ).textTheme.headlineSmall,
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            navigatorKey.currentState?.push(
                                              MaterialPageRoute(
                                                builder: (context) {
                                                  return DatabaseScreen();
                                                },
                                              ),
                                            );
                                          },
                                          icon: Icon(
                                            Icons.arrow_forward_ios,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NoThumbScrollBehavior extends ScrollBehavior {
  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}

class GlassContainer extends StatelessWidget {
  final double width;
  final double height;
  final Widget? child;
  final BorderRadius borderRadius;
  final Color? backgroundColor;
  final double? horizontalPadding;
  final double? verticalPadding;
  const GlassContainer({
    super.key,
    this.width = 300,
    this.height = 200,
    this.child,
    this.horizontalPadding = 24,
    this.verticalPadding = 12,
    this.backgroundColor,
    this.borderRadius =   const BorderRadius.all(Radius.circular(12)),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color:
                backgroundColor ??
                Theme.of(
                  context,
                ).colorScheme.tertiaryFixed.withValues(alpha: 0.9),
            borderRadius: borderRadius,
            border: Border.all(
              color:
                  backgroundColor ??
                  Theme.of(
                    context,
                  ).colorScheme.tertiaryFixed.withValues(alpha: 0.9),

              width: 1.5,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding!,
              vertical: verticalPadding!,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
