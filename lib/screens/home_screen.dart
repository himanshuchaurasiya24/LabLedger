import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:labledger/methods/custom_methods.dart';
import 'package:labledger/providers/bills_provider.dart';
import 'package:labledger/providers/custom_providers.dart';
import 'package:labledger/screens/initials/login_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({
    super.key,
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.isAdmin,
  });
  final bool isAdmin;
  final int id;
  final String firstName;
  final String lastName;
  final String username;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  void logout() {
    FlutterSecureStorage secureStorage = ref.read(secureStorageProvider);
    secureStorage.delete(key: 'access_token');
    secureStorage.delete(key: 'access_tokenn');
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
  int currentIndex = 0;

  Map<String, int> getBillStats(List<Map<String, dynamic>> bills) {
    final now = DateTime.now();
    final today = now;
    final yesterday = now.subtract(Duration(days: 1));
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfPrevWeek = startOfWeek.subtract(Duration(days: 7));
    final endOfPrevWeek = startOfWeek.subtract(Duration(days: 1));
    final startOfMonth = DateTime(now.year, now.month, 1);
    final startOf3MonthsAgo = DateTime(now.year, now.month - 2, 1);

    int todayCount = 0,
        yesterdayCount = 0,
        thisWeek = 0,
        prevWeek = 0,
        thisMonth = 0,
        pastThreeMonths = 0;

    for (var bill in bills) {
      final date = DateTime.parse(bill['created_at']);
      if (_isSameDay(date, today)) todayCount++;
      if (_isSameDay(date, yesterday)) yesterdayCount++;
      if (date.isAfter(startOfWeek.subtract(Duration(days: 1)))) thisWeek++;
      if (date.isAfter(startOfPrevWeek.subtract(Duration(days: 1))) &&
          date.isBefore(endOfPrevWeek.add(Duration(days: 1)))) {
        prevWeek++;
      }
      if (date.isAfter(startOfMonth.subtract(Duration(days: 1)))) thisMonth++;
      if (date.isAfter(startOf3MonthsAgo.subtract(Duration(days: 1)))) {
        pastThreeMonths++;
      }
    }

    return {
      'Today': todayCount,
      'Yesterday': yesterdayCount,
      'This Week': thisWeek,
      'Previous Week': prevWeek,
      'This Month': thisMonth,
      'Past 3 Months': pastThreeMonths,
    };
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    containerWidth = width / 2.962963;
    sideContainerWidth = width / 3.7037037;
    smallWidthSpacing = width / 80;
    bigWidthSpacing = width / 32;
    wideContainerSize = width / 1.4545455;
    smallheightSpacing = height / 56.25;
    containerHeight = height * 0.388888;
    longContainerHeight = height * 0.475;
    final billsAsync = ref.watch(billsProvider);
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: defaultPadding,
          vertical: defaultPadding / 2,
        ),
        // Remove the SingleChildScrollView here
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TopActionsTab(
                      title: "Overview",
                      selectedColor: Color(0xFF020711),
                      tabIndex: 0,
                      selectedtabIndex: currentIndex,
                      onTap: () => setState(() {
                        currentIndex = 0;
                      }),
                    ),
                    SizedBox(width: smallWidthSpacing),
                    TopActionsTab(
                      title: "Bills",
                      selectedColor: Color(0xFF020711),
                      tabIndex: 1,
                      selectedtabIndex: currentIndex,
                      onTap: () => setState(() {
                        currentIndex = 1;
                      }),
                    ),
                    SizedBox(width: smallWidthSpacing),
                    TopActionsTab(
                      title: "Doctors",
                      selectedColor: Color(0xFF020711),
                      tabIndex: 2,
                      selectedtabIndex: currentIndex,
                      onTap: () => setState(() {
                        currentIndex = 2;
                      }),
                    ),
                    SizedBox(width: smallWidthSpacing),
                    TopActionsTab(
                      title: "Reports",
                      selectedColor: Color(0xFF020711),
                      tabIndex: 3,
                      selectedtabIndex: currentIndex,
                      onTap: () => setState(() {
                        currentIndex = 3;
                      }),
                    ),
                  ],
                ),
                SizedBox(
                  width: bigWidthSpacing,
                ), // Replaced Spacer with a fixed space
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
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
                    SizedBox(width: smallWidthSpacing),
                    GlassContainer(
                      height: 60,
                      width: 120,
                      borderRadius: BorderRadius.circular(30),
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.tertiaryFixed,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          CircleAvatar(
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
                          IconButton(
                            onPressed: () {
                              //
                            },
                            icon: Icon(
                              Icons.menu,
                              size: 38,
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                          ),
                        ],
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
                                    borderRadius: BorderRadius.circular(20),
                                    child: Padding(
                                      padding: EdgeInsetsGeometry.symmetric(
                                        vertical: defaultPadding / 2,
                                        horizontal: defaultPadding,
                                      ), // Larger internal padding
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment
                                            .spaceAround, // spread evenly
                                        children: [
                                          Text(
                                            "Database Overview",
                                            style: Theme.of(
                                              context,
                                            ).textTheme.headlineSmall,
                                          ),
                                          SizedBox(height: smallheightSpacing),
                                          SystemOverviewChips(
                                            chipText: "100",
                                            iconData:
                                                HugeIcons.strokeRoundedDoctor01,
                                          ),
                                          SystemOverviewChips(
                                            iconData:
                                                HugeIcons.strokeRoundedInvoice,
                                            chipText: "3000",
                                          ),
                                          SystemOverviewChips(
                                            iconData: HugeIcons
                                                .strokeRoundedSchoolReportCard,
                                            chipText: "3000",
                                          ),

                                          SystemOverviewChips(
                                            iconData: HugeIcons
                                                .strokeRoundedSchoolReportCard,
                                            chipText: "3000",
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  SizedBox(width: smallWidthSpacing),
                                  GlassContainer(
                                    height: containerHeight,
                                    width: containerWidth,
                                    borderRadius: BorderRadius.circular(20),
                                    child: Padding(
                                      padding: EdgeInsetsGeometry.symmetric(
                                        horizontal: defaultPadding,
                                        vertical: defaultPadding / 2,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Bills Counter",
                                            style: Theme.of(
                                              context,
                                            ).textTheme.headlineSmall,
                                          ),
                                          billsAsync.when(
                                            data: (bills) {
                                              final data = getBillStats(bills);
                                              final keys = data.keys.toList();
                                              return SizedBox(
                                                height: 200,
                                                child: BarChart(
                                                  BarChartData(
                                                    alignment: BarChartAlignment
                                                        .spaceAround,
                                                    barGroups: List.generate(
                                                      keys.length,
                                                      (i) {
                                                        return BarChartGroupData(
                                                          x: i,
                                                          barRods: [
                                                            BarChartRodData(
                                                              toY: data[keys[i]]!
                                                                  .toDouble(),
                                                              color:
                                                                  Colors.blue,
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    ),
                                                    titlesData: FlTitlesData(
                                                      bottomTitles: AxisTitles(
                                                        sideTitles: SideTitles(
                                                          showTitles: true,
                                                          getTitlesWidget:
                                                              (
                                                                value,
                                                                meta,
                                                              ) => Text(
                                                                keys[value
                                                                    .toInt()],
                                                                style:
                                                                    TextStyle(
                                                                      fontSize:
                                                                          10,
                                                                    ),
                                                              ),
                                                        ),
                                                      ),
                                                      leftTitles: AxisTitles(
                                                        sideTitles: SideTitles(
                                                          showTitles: true,
                                                        ),
                                                      ),
                                                    ),
                                                    borderData: FlBorderData(
                                                      show: false,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                            error: (error, stackTrace) {
                                              return Text(
                                                "Error loading bills",
                                              );
                                            },
                                            loading: () {
                                              return CircularProgressIndicator();
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: smallheightSpacing),
                              GlassContainer(
                                height: longContainerHeight,
                                width: wideContainerSize,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: defaultPadding,
                                    vertical: defaultPadding / 2,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Recent Bills",
                                        style: Theme.of(
                                          context,
                                        ).textTheme.headlineSmall,
                                      ),
                                      Text("data"),
                                    ],
                                  ),
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
                              ),
                              SizedBox(height: smallheightSpacing),
                              GlassContainer(
                                height: containerHeight,
                                width: sideContainerWidth,
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

class SystemOverviewChips extends StatelessWidget {
  const SystemOverviewChips({
    super.key,
    required this.iconData,
    required this.chipText,
  });
  final IconData iconData;
  final String chipText;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.tertiary,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              bottomLeft: Radius.circular(15),
            ),
          ),
          height: 55,
          width: 60,
          child: Icon(
            iconData,
            color: Theme.of(context).scaffoldBackgroundColor,
            size: 40,
          ),
        ),
        Container(
          height: 55,
          width: 200,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(15),
              bottomRight: Radius.circular(15),
            ),
          ),
          child: Text(
            chipText,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineLarge!.copyWith(color: Colors.white),
          ),
        ),
      ],
    );
  }
}

// Your existing TopActionsTab and NoThumbScrollBehavior classes remain unchanged.
class TopActionsTab extends StatelessWidget {
  final String title;
  final Color selectedColor;
  final int tabIndex;
  final int selectedtabIndex;
  final void Function() onTap;
  const TopActionsTab({
    super.key,
    required this.title,
    required this.tabIndex,
    required this.selectedColor,
    required this.selectedtabIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ActionBarGlassContainer(
        backgroundColor: tabIndex == selectedtabIndex
            ? Theme.of(context).colorScheme.tertiary
            : Theme.of(context).colorScheme.tertiaryFixed,
        borderRadius: BorderRadius.circular(30),
        height: 60,
        width: 180,
        child: Center(
          child: Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              fontWeight: FontWeight.w500,
              color: tabIndex == selectedtabIndex
                  ? Theme.of(context).colorScheme.tertiaryFixed
                  : Theme.of(context).colorScheme.tertiary,
            ),
          ),
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
  const GlassContainer({
    super.key,
    this.width = 300,
    this.height = 200,
    this.child,
    this.backgroundColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
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
                (Theme.of(context).brightness == Brightness.light
                    ? Theme.of(
                        context,
                      ).colorScheme.tertiaryFixed.withValues(alpha: 0.9)
                    : Theme.of(
                        context,
                      ).colorScheme.tertiaryFixed.withValues(alpha: 0.9)),
            borderRadius: borderRadius,
            border: Border.all(
              color:
                  backgroundColor ??
                  (Theme.of(context).brightness == Brightness.light
                      ? Theme.of(
                          context,
                        ).colorScheme.tertiaryFixed.withValues(alpha: 0.9)
                      : Theme.of(
                          context,
                        ).colorScheme.tertiaryFixed.withValues(alpha: 0.9)),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class ActionBarGlassContainer extends StatelessWidget {
  final double height;
  final double width;
  final BorderRadius borderRadius;
  final Color backgroundColor;
  final Widget? child;
  const ActionBarGlassContainer({
    super.key,
    this.height = 60,
    this.width = 180,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    this.backgroundColor = Colors.white60,
    this.child,
  });
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
        child: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: borderRadius,
            border: Border.all(color: backgroundColor, width: 1.5),
          ),
          child: child,
        ),
      ),
    );
  }
}
