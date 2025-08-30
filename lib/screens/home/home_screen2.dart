import 'dart:io';
import 'dart:ui';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/main.dart';
import 'package:labledger/methods/custom_methods.dart';
import 'package:labledger/models/center_detail_model.dart';
import 'package:labledger/models/doctors_model.dart';
import 'package:labledger/providers/bills_provider.dart';
import 'package:labledger/providers/secure_storage_provider.dart';
import 'package:labledger/providers/theme_providers.dart';
import 'package:labledger/providers/doctor_provider.dart';
import 'package:labledger/screens/bill/add_update_screen2.dart';
import 'package:labledger/screens/bill/bill_screen.dart';
import 'package:labledger/screens/home/home_screen_logic.dart';
import 'package:labledger/screens/initials/login_screen.dart';
import 'package:labledger/screens/initials/window_loading_screen.dart';
import 'package:labledger/screens/database_overview/database_screen.dart';
import 'package:labledger/screens/profile/account_list_screen.dart';
import 'package:labledger/screens/profile/profile_screen.dart';
import 'package:labledger/screens/window_scaffold.dart';

enum TimeFilter { thisWeek, thisMonth, thisYear, allTime }

class HomeScreen2 extends ConsumerStatefulWidget {
  const HomeScreen2({
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
  ConsumerState<HomeScreen2> createState() => _HomeScreen2State();
}

class _HomeScreen2State extends ConsumerState<HomeScreen2> {
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
    isLoginScreen.value = false;
  }

  @override
  Widget build(BuildContext context) {
    final doctorsAsync = ref.watch(doctorsProvider);
    final billsAsync = ref.watch(billsProvider);
    final themeMode = ref.read(themeNotifierProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return AddBillScreen2();
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
          horizontal: defaultPadding,
          vertical: defaultPadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            SizedBox(
              height: 65,
              child: Row(
                children: [
                  appIconName(
                    context: context,
                    firstName: "Lab",
                    secondName: "Ledger",
                    fontSize: 50,
                  ),
                  const Spacer(),
                  Expanded(
                    flex: 4,
                    child: Center(
                      child: Text(
                        "${widget.centerDetail.centerName}, ${widget.centerDetail.address}"
                            .toUpperCase(),
                        style: Theme.of(
                          context,
                        ).textTheme.headlineLarge!.copyWith(fontSize: 35),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisSize: MainAxisSize.min,
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
                          child: Icon(Icons.notifications_outlined, size: 34),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () async {
                          final selected = await showMenu(
                            context: context,
                            position: RelativeRect.fromLTRB(100, 90, 10, 0),
                            color: Theme.of(
                              context,
                            ).colorScheme.tertiaryFixed.withValues(alpha: 0.9),
                            shadowColor: Theme.of(
                              context,
                            ).scaffoldBackgroundColor,
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                defaultRadius,
                              ),
                              side: BorderSide(
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? ThemeData.light().scaffoldBackgroundColor
                                    : ThemeData.dark().scaffoldBackgroundColor,
                                width: 2,
                              ),
                            ),
                            constraints: BoxConstraints(minWidth: 300),
                            items: [
                              PopupMenuItem(
                                value: 'userDetails',
                                child: ListTile(
                                  leading: Icon(
                                    Icons.verified_user,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
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
                                    ThemeMode.system =>
                                      "Current Theme : System",
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
                                builder: (context) =>
                                    ProfileScreen(userId: widget.id),
                              ),
                            );
                          } else if (selected == "accountControl") {
                            navigatorKey.currentState?.push(
                              MaterialPageRoute(
                                builder: (context) => AccountListScreen(),
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
                                builder: (context) {
                                  return WindowLoadingScreen();
                                },
                              ),
                            );
                          } else if (selected == "exit") {
                            exit(0);
                          }
                        },
                        icon: CircleAvatar(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.tertiary,
                          radius: 30,
                          child: Text(
                            widget.firstName[0].toUpperCase(),
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.tertiaryFixed,
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
            ),
            SizedBox(height: defaultHeight),
            // Main Content
            Expanded(
              child: ScrollConfiguration(
                behavior: NoThumbScrollBehavior(),
                child: SingleChildScrollView(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Column - Main content area
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Top Row - Two containers side by side
                            SizedBox(
                              height: screenHeight * 0.4,
                              child: Row(
                                children: [
                                  // Top Referral Counter
                                  Expanded(
                                    child: GlassContainer(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  "Top Referral Counter",
                                                  style: Theme.of(
                                                    context,
                                                  ).textTheme.headlineSmall,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              IconButton(
                                                onPressed: () {},
                                                icon: Icon(
                                                  Icons.arrow_forward_ios,
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.primary,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Expanded(
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

                                                    List<dynamic> currentList;
                                                    switch (_selectedRangeForTopReferrals) {
                                                      case TimeFilter.thisWeek:
                                                        currentList =
                                                            leaderboard.week;
                                                        break;
                                                      case TimeFilter.thisYear:
                                                        currentList =
                                                            leaderboard.year;
                                                        break;
                                                      case TimeFilter.allTime:
                                                        currentList =
                                                            leaderboard.allTime;
                                                        break;
                                                      default:
                                                        currentList =
                                                            leaderboard.month;
                                                    }

                                                    return ListView.builder(
                                                      shrinkWrap: true,
                                                      itemCount:
                                                          currentList.length < 4
                                                          ? currentList.length
                                                          : 3,
                                                      itemBuilder: (context, i) {
                                                        return ListTile(
                                                          dense: true,
                                                          leading: CircleAvatar(
                                                            backgroundColor:
                                                                Theme.of(
                                                                      context,
                                                                    )
                                                                    .colorScheme
                                                                    .primary,
                                                            child: Text(
                                                              '${i + 1}',
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 20,
                                                              ),
                                                            ),
                                                          ),
                                                          title: Text(
                                                            "${currentList[i].doctor.firstName} ${currentList[i].doctor.lastName}",
                                                            style: Theme.of(context)
                                                                .textTheme
                                                                .bodyLarge!
                                                                .copyWith(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 1,
                                                          ),
                                                          subtitle: Text(
                                                            "Incentive: ₹${currentList[i].incentive}",
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 1,
                                                            style: Theme.of(context)
                                                                .textTheme
                                                                .titleMedium!
                                                                .copyWith(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w100,
                                                                ),
                                                          ),
                                                          trailing: Text(
                                                            "USG: ${currentList[i].ultrasound} "
                                                            "Path: ${currentList[i].pathology} "
                                                            "ECG: ${currentList[i].ecg} "
                                                            "X-Ray: ${currentList[i].xray} "
                                                            "Fr: ${currentList[i].franchiseLab} ",
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 1,
                                                            style: Theme.of(context)
                                                                .textTheme
                                                                .titleMedium!
                                                                .copyWith(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w100,
                                                                ),
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  },
                                                  loading: () => const Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  ),
                                                  error: (err, stack) => Text(
                                                    "Error loading bills: $err",
                                                  ),
                                                );
                                              },
                                              loading: () => const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                              error: (err, stack) => Text(
                                                "Error loading doctors: $err",
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 16),
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
                                  ),
                                  SizedBox(width: screenWidth * 0.01),
                                  // Bills Counter
                                  Expanded(
                                    child: GlassContainer(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  "Bills Counter",
                                                  style: Theme.of(
                                                    context,
                                                  ).textTheme.headlineSmall,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              IconButton(
                                                onPressed: () {},
                                                icon: Icon(
                                                  Icons.arrow_forward_ios,
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.primary,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Expanded(
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
                                          const SizedBox(height: 16),
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
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.015),
                            // Recently Added Bills - Full width bottom container
                            SizedBox(
                              height: screenHeight * 0.48,
                              child: GlassContainer(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "Recently Added Bills",
                                            style: Theme.of(
                                              context,
                                            ).textTheme.headlineSmall,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            navigatorKey.currentState?.push(
                                              MaterialPageRoute(
                                                builder: (context) {
                                                  return BillsScreen();
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
                                    Expanded(
                                      child: billsAsync.when(
                                        data: (bills) {
                                          final fetchedBills = bills.toList();

                                          final latest = fetchedBills.take(20);
                                          return ListView.builder(
                                            itemCount: latest.length,
                                            itemBuilder: (context, index) {
                                              final bill = latest.elementAt(
                                                index,
                                              );
                                              return ListTile(
                                                onTap: () {
                                                  navigatorKey.currentState
                                                      ?.push(
                                                        MaterialPageRoute(
                                                          builder: (context) {
                                                            return AddBillScreen2(
                                                              billData: bill,
                                                            );
                                                          },
                                                        ),
                                                      );
                                                },
                                                leading: Icon(
                                                  Icons.receipt_long,
                                                  size: 35,
                                                  color:
                                                      bill.billStatus ==
                                                          "Fully Paid"
                                                      ? Colors.green[300]
                                                      : Colors.red[300],
                                                ),
                                                title: Text(
                                                  bill.patientName,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                subtitle: Text(
                                                  "Date: ${bill.dateOfBill}",
                                                  style: Theme.of(
                                                    context,
                                                  ).textTheme.bodyMedium,
                                                ),
                                                trailing: Container(
                                                  height: 40,
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                      ),
                                                  constraints:
                                                      const BoxConstraints(
                                                        maxWidth: 170,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                    border: Border.all(
                                                      color:
                                                          bill.billStatus ==
                                                              "Fully Paid"
                                                          ? Colors.green[300]!
                                                          : Colors.red[300]!,
                                                      width: 3,
                                                    ),
                                                    color:
                                                        bill.billStatus ==
                                                            "Fully Paid"
                                                        ? Colors.green[200]
                                                        : Colors.red[200],
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      if (bill.billStatus !=
                                                          "Fully Paid")
                                                        Text(
                                                          "Pending : ",
                                                          style: TextStyle(
                                                            color:
                                                                Colors.black54,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                      Flexible(
                                                        child: Text(
                                                          bill.billStatus ==
                                                                  "Fully Paid"
                                                              ? "₹${bill.totalAmount}"
                                                              : "₹${bill.totalAmount - bill.paidAmount}",
                                                          style: TextStyle(
                                                            color:
                                                                Colors.black54,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 16,
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        loading: () => const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                        error: (err, _) =>
                                            Text("Error loading bills: $err"),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.01),
                      // Right Column - Sidebar
                      SizedBox(
                        width: screenWidth * 0.25,
                        child: Column(
                          children: [
                            // New Card - Taller container
                            SizedBox(
                              height: screenHeight * 0.48,
                              child: GlassContainer(
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "New Card",
                                            style: Theme.of(
                                              context,
                                            ).textTheme.headlineSmall,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {},
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
                            ),
                            SizedBox(
                              height: screenHeight * 0.015,
                            ), // Database Overview - Shorter container
                            SizedBox(
                              height: screenHeight * 0.4,
                              child: GlassContainer(
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "Database Overview",
                                            style: Theme.of(
                                              context,
                                            ).textTheme.headlineSmall,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            if (widget.isAdmin) {
                                              navigatorKey.currentState?.push(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      DatabaseScreen(
                                                        userId: widget.id,
                                                      ),
                                                ),
                                              );
                                            } else {
                                              showDialog(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          defaultRadius,
                                                        ), // ⬅ Rounded corners
                                                  ),
                                                  title: const Text(
                                                    "Access Denied",
                                                  ),
                                                  content: Text(
                                                    "You need to be an administrator to access this section.",
                                                    style: Theme.of(
                                                      context,
                                                    ).textTheme.titleMedium,
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.of(
                                                            context,
                                                          ).pop(),
                                                      child: const Text("OK"),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }
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
                            ),
                          ],
                        ),
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



class GlassContainer extends StatelessWidget {
  final Widget? child;
  final BorderRadius borderRadius;
  final Color? backgroundColor;
  final double? horizontalPadding;
  final double? verticalPadding;

  const GlassContainer({
    super.key,
    this.child,
    this.horizontalPadding = 24,
    this.verticalPadding = 12,
    this.backgroundColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
        child: Container(
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
