import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:labledger/methods/custom_methods.dart';
import 'package:labledger/models/bill_model.dart';
import 'package:labledger/models/center_detail_model.dart';
import 'package:labledger/providers/bills_provider.dart';
import 'package:labledger/providers/custom_providers.dart';
import 'package:labledger/screens/initials/login_screen.dart';

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
  TimeFilter _selectedRange = TimeFilter.thisMonth;

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
  final Map<TimeFilter, String> timeFilterLabels = {
    TimeFilter.thisWeek: 'This Week',
    TimeFilter.thisMonth: 'This Month',
    TimeFilter.thisYear: 'This Year',
    TimeFilter.allTime: 'All Time',
  };

  Widget _buildTimeFilterSelector(
    TimeFilter selected,
    ValueChanged<TimeFilter> onChanged,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: TimeFilter.values.map((filter) {
          final label = timeFilterLabels[filter]!;
          final isSelected = selected == filter;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ChoiceChip(
              label: Text(label),
              checkmarkColor: Colors.white,
              selected: isSelected,
              onSelected: (_) => onChanged(filter),
              selectedColor: Theme.of(context).colorScheme.secondary,
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

  List<String> extractDateLabels(List<Bill> bills) {
    final dailyCounts = <String, int>{};

    for (final bill in bills) {
      final date = DateTime.tryParse(bill.dateOfBill.toString())!.toLocal();

      // if (date != null) {
      //   final key = date.toIso8601String().substring(0, 10);
      //   dailyCounts[key] = (dailyCounts[key] ?? 0) + 1;
      // }
      final key = date.toIso8601String().substring(0, 10);
      dailyCounts[key] = (dailyCounts[key] ?? 0) + 1;
    }

    final sortedDates = dailyCounts.keys.toList()..sort();
    return sortedDates.map((d) {
      final dt = DateTime.parse(d);
      return DateFormat('MMM d yyyy').format(dt);
    }).toList();
  }

  LineChartData _getChartData(List<FlSpot> data, List<String> dates) {
    return LineChartData(
      lineBarsData: [
        LineChartBarData(
          spots: data,
          isCurved: true,
          barWidth: 3,
          color: Theme.of(context).colorScheme.secondary,
          belowBarData: BarAreaData(show: false),
          dotData: FlDotData(show: true),
        ),
      ],
      titlesData: FlTitlesData(show: false),
      gridData: FlGridData(show: false),
      borderData: FlBorderData(show: false),
      lineTouchData: LineTouchData(
        enabled: true,
        getTouchedSpotIndicator: (barData, spotIndexes) {
          return spotIndexes.map((i) {
            return TouchedSpotIndicatorData(
              FlLine(
                color: Theme.of(context).colorScheme.secondary,
                strokeWidth: 3,
              ),
              FlDotData(show: true),
            );
          }).toList();
        },
        touchTooltipData: LineTouchTooltipData(
          fitInsideHorizontally: true,
          fitInsideVertically: true,
          tooltipPadding: const EdgeInsets.all(8),
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((touched) {
              final index = touched.spotIndex;
              final date = (index >= 0 && index < dates.length)
                  ? dates[index]
                  : 'Unknown';
              final y = touched.y.toInt();

              return LineTooltipItem(
                "$y bills\non $date",

                const TextStyle(color: Colors.white),
              );
            }).toList();
          },
        ),
      ),
    );
  }

  List<Bill> filterBillsByTimeFilter(List<Bill> bills, TimeFilter filter) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    late DateTime from;
    late DateTime to;

    switch (filter) {
      case TimeFilter.thisWeek: // last 7 days
        from = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(const Duration(days: 6));
        to = now.add(const Duration(days: 1));
        break;

      case TimeFilter.thisMonth:
        from = DateTime(today.year, today.month, 1);
        to = today.add(Duration(days: 1));
        break;

      case TimeFilter.thisYear:
        from = DateTime(today.year, 1, 1);
        to = today.add(Duration(days: 1));
        break;

      case TimeFilter.allTime:
        return bills;
    }

    return bills.where((bill) {
      final parsedUtc = DateTime.tryParse(bill.dateOfBill.toString());
      final local = parsedUtc?.toLocal();

      if (local == null) return false;

      final localDate = DateTime(local.year, local.month, local.day);

      final inRange =
          (localDate.isAtSameMomentAs(from) || localDate.isAfter(from)) &&
          localDate.isBefore(to);

      // debugPrint(
      //   "BILL DATE: $localDate | FROM: $from | TO: $to | SHOW: $inRange",
      // );
      return inRange;
    }).toList();
  }

  List<FlSpot> prepareSpots(List<Bill> bills) {
    final Map<String, int> dailyCounts = {};

    for (final bill in bills) {
      final rawDate = bill.dateOfBill;
      final parsed = DateTime.tryParse(rawDate.toString());
      if (parsed == null) continue;

      final dateKey =
          "${parsed.year}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}";
      dailyCounts[dateKey] = (dailyCounts[dateKey] ?? 0) + 1;
    }

    final sortedDates = dailyCounts.keys.toList()..sort();

    return List.generate(sortedDates.length, (i) {
      final count = dailyCounts[sortedDates[i]]!;
      return FlSpot(i.toDouble(), count.toDouble());
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
                      horizontalPadding: 0,
                      verticalPadding: 0,
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
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      // spread evenly
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Top Referal Counter",
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

                                  SizedBox(width: smallWidthSpacing),

                                  GlassContainer(
                                    height: containerHeight,
                                    width: containerWidth,
                                    borderRadius: BorderRadius.circular(20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                        Spacer(),

                                        SizedBox(
                                          height:
                                              containerHeight -
                                              defaultPadding -
                                              102,
                                          child: ref
                                              .watch(billsProvider)
                                              .when(
                                                data: (bills) {
                                                  final filteredData =
                                                      filterBillsByTimeFilter(
                                                        bills,
                                                        _selectedRange,
                                                      );
                                                  final chartData =
                                                      prepareSpots(
                                                        filteredData,
                                                      );
                                                  final dateLabels =
                                                      extractDateLabels(
                                                        filteredData,
                                                      );
                                                  return LineChart(
                                                    _getChartData(
                                                      chartData,
                                                      dateLabels,
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
                                        _buildTimeFilterSelector(
                                          _selectedRange,
                                          (newFilter) {
                                            setState(() {
                                              _selectedRange = newFilter;
                                            });
                                          },
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
                                          "Recent Bills",
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
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding ?? defaultPadding,
              vertical: verticalPadding ?? defaultPadding / 2,
            ),
            child: child,
          ),
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
