import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:labledger/methods/custom_methods.dart';
import 'package:labledger/models/bill_model.dart';
import 'package:labledger/providers/bills_provider.dart';
import 'package:labledger/providers/custom_providers.dart';
import 'package:labledger/screens/initials/login_screen.dart';

enum TimeRange {
  oneDay,
  oneWeek,
  oneMonth,
  threeMonths,
  sixMonths,
  oneYear,
  threeYears,
  fiveYears,
  all,
}

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
  TimeRange _selectedRange = TimeRange.all;

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
  final timeRangeLabels = {
    TimeRange.oneDay: '1D',
    TimeRange.oneWeek: '1W',
    TimeRange.oneMonth: '1M',
    TimeRange.threeMonths: '3M',
    TimeRange.sixMonths: '6M',
    TimeRange.oneYear: '1Y',
    TimeRange.threeYears: '3Y',
    TimeRange.fiveYears: '5Y',
    TimeRange.all: 'All',
  };
  Widget _buildTimeRangeSelector(
    TimeRange selected,
    ValueChanged<TimeRange> onChanged,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: TimeRange.values.map((range) {
          final label = timeRangeLabels[range]!;
          final isSelected = selected == range;
          return Padding(
            padding: EdgeInsetsGeometry.symmetric(
              horizontal: defaultPadding / 6,
            ),
            child: ChoiceChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (value) {
                onChanged(range);
              },
              selectedColor: Colors.blue.shade700,
              backgroundColor: Colors.grey.shade200,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  LineChartData _getChartData(List<FlSpot> data) {
    return LineChartData(
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          // tooltipBgColor: Colors.black87,
          getTooltipItems: (List<LineBarSpot> touchedSpots) {
            return touchedSpots.map((spot) {
              return LineTooltipItem(
                '${spot.y.toInt()} bills',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            }).toList();
          },
        ),
        handleBuiltInTouches: true,
      ),
      lineBarsData: [
        LineChartBarData(
          spots: data,
          isCurved: true,
          color: Theme.of(context).colorScheme.primary,
          barWidth: 3,
          belowBarData: BarAreaData(show: false),
          dotData: FlDotData(show: false),
        ),
      ],
      titlesData: FlTitlesData(show: false),
      gridData: FlGridData(show: false),
      borderData: FlBorderData(show: false),
    );
  }List<Bill> filterBillsByRange(List<Bill> bills, TimeRange range) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day); // Strip time
  DateTime from;

  switch (range) {
    case TimeRange.oneDay:
      from = today.subtract(const Duration(days: 1));
      break;
    case TimeRange.oneWeek:
      from = today.subtract(const Duration(days: 7));
      break;
    case TimeRange.oneMonth:
      from = DateTime(today.year, today.month - 1, today.day);
      break;
    case TimeRange.threeMonths:
      from = DateTime(today.year, today.month - 3, today.day);
      break;
    case TimeRange.sixMonths:
      from = DateTime(today.year, today.month - 6, today.day);
      break;
    case TimeRange.oneYear:
      from = DateTime(today.year - 1, today.month, today.day);
      break;
    case TimeRange.threeYears:
      from = DateTime(today.year - 3, today.month, today.day);
      break;
    case TimeRange.fiveYears:
      from = DateTime(today.year - 5, today.month, today.day);
      break;
    case TimeRange.all:
      return bills;
  }

  return bills.where((bill) {
    final parsed = DateTime.tryParse(bill.dateOfBill.toString())?.toLocal();
    debugPrint("Parsed date: $parsed");
    if (parsed == null) return false;

    final billDate = DateTime(parsed.year, parsed.month, parsed.day);
    debugPrint("Bill date: ${bill.dateOfBill}");


    // return billDate.isAtSameMomentAs(from) || billDate.isAfter(from);
    return !billDate.isBefore(from);

  }).toList();
}



  List<FlSpot> prepareSpots(List<Bill> bills) {
    bills.sort((a, b) => a.dateOfBill.compareTo(b.dateOfBill));
    final Map<String, int> dailyCounts = {};

    for (final bill in bills) {
      final date = bill.dateOfBill.toString().substring(0, 10); // 'YYYY-MM-DD'
      dailyCounts[date] = (dailyCounts[date] ?? 0) + 1;
    }

    final dates = dailyCounts.keys.toList()..sort();
    return List.generate(dates.length, (i) {
      return FlSpot(i.toDouble(), dailyCounts[dates[i]]!.toDouble());
    });
  }

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
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.vertical,
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

                                            ref
                                                .watch(billsProvider)
                                                .when(
                                                  data: (bills) {
                                                    final filteredData =
                                                        filterBillsByRange(
                                                          bills,
                                                          _selectedRange,
                                                        );
                                                    final chartData =
                                                        prepareSpots(
                                                          filteredData,
                                                        );
                                                    return SizedBox(
                                                      height: 230,
                                                      child: LineChart(
                                                        _getChartData(
                                                          chartData,
                                                        ),
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
                                            _buildTimeRangeSelector(
                                              _selectedRange,
                                              (range) {
                                                setState(() {
                                                  _selectedRange = range;
                                                });
                                              },
                                            ),
                                          ],
                                        ),
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
                                      Consumer(
                                        builder: (context, ref, _) {
                                          final billsAsync = ref.watch(
                                            billsProvider,
                                          );
                                          return billsAsync.when(
                                            data: (bills) {
                                              final latest = bills
                                                  .take(5)
                                                  .toList();
                                              return Column(
                                                children: latest.map((bill) {
                                                  return ListTile(
                                                    leading: Icon(
                                                      Icons.receipt_long,
                                                      color: Theme.of(
                                                        context,
                                                      ).primaryColor,
                                                    ),
                                                    title: Text(
                                                      "Bill #${bill.id}",
                                                    ),
                                                    subtitle: Text(
                                                      "Date: ${bill.dateOfBill}",
                                                    ),
                                                    trailing: Text(
                                                      "₹${bill.totalAmount}",
                                                    ),
                                                  );
                                                }).toList(),
                                              );
                                            },
                                            loading: () =>
                                                const CircularProgressIndicator(),
                                            error: (err, _) => Text(
                                              "Error loading bills: $err",
                                            ),
                                          );
                                        },
                                      ),
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
