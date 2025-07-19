// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

import 'package:labledger/methods/custom_methods.dart';
import 'package:labledger/models/bill_model.dart';
import 'package:labledger/models/center_detail_model.dart';
import 'package:labledger/models/doctors_model.dart';
import 'package:labledger/providers/bills_provider.dart';
import 'package:labledger/providers/custom_providers.dart';
import 'package:labledger/providers/doctor_provider.dart';
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

  List<DoctorStats> getDoctorStats(List<Bill> bills, List<Doctor> allDoctors) {
    final Map<int, DoctorStats> statsMap = {};

    for (final bill in bills) {
      int doctorId = bill.referredByDoctor;
      final Doctor doctor = allDoctors.firstWhere((d) => d.id == doctorId);

      statsMap.putIfAbsent(doctorId, () {
        return DoctorStats(
          doctor: doctor,
          ultrasound: 0,
          pathology: 0,
          ecg: 0,
          xray: 0,
          franchiseLab: 0,
          incentive: 0,
        );
      });

      final category = bill.diagnosisTypeOutput?['category'];
      final current = statsMap[doctorId]!;

      statsMap[doctorId] = DoctorStats(
        doctor: doctor,
        ultrasound: current.ultrasound + (category == 'Ultrasound' ? 1 : 0),
        pathology: current.pathology + (category == 'Pathology' ? 1 : 0),
        ecg: current.ecg + (category == 'ECG' ? 1 : 0),
        xray: current.xray + (category == 'XRay' ? 1 : 0),
        franchiseLab:
            current.franchiseLab + (category == 'Franchise Lab' ? 1 : 0),
        incentive: current.incentive + (bill.incentiveAmount),
      );
    }

    return statsMap.values.toList();
  }

  TopReferrerModel topReferralFinder({
    required List<Bill> filteredData,
    required List<Doctor> allDoctors,
  }) {
    DateTime now = DateTime.now();

    List<Bill> weekBills = filteredData.where((bill) {
      final billDate = bill.dateOfBill;
      return billDate.isAfter(
            now.subtract(Duration(days: 6)).subtract(Duration(seconds: 1)),
          ) &&
          billDate.isBefore(now.add(Duration(days: 1)));
    }).toList();

    List<Bill> monthBills = filteredData.where((bill) {
      return bill.dateOfBill.month == now.month &&
          bill.dateOfBill.year == now.year;
    }).toList();

    List<Bill> yearBills = filteredData.where((bill) {
      return bill.dateOfBill.year == now.year;
    }).toList();

    List<Bill> allTimeBills = List.from(filteredData);

    List<DoctorStats> sortedWeek = getDoctorStats(weekBills, allDoctors)
      ..sort((a, b) => b.incentive.compareTo(a.incentive));
    List<DoctorStats> sortedMonth = getDoctorStats(monthBills, allDoctors)
      ..sort((a, b) => b.incentive.compareTo(a.incentive));
    List<DoctorStats> sortedYear = getDoctorStats(yearBills, allDoctors)
      ..sort((a, b) => b.incentive.compareTo(a.incentive));
    List<DoctorStats> sortedAll = getDoctorStats(allTimeBills, allDoctors)
      ..sort((a, b) => b.incentive.compareTo(a.incentive));

    return TopReferrerModel(
      week: sortedWeek,
      month: sortedMonth,
      year: sortedYear,
      allTime: sortedAll,
    );
  }

  @override
  Widget build(BuildContext context) {
    final doctorsAsync = ref.watch(doctorsProvider);
    final billsAsync = ref.watch(billsProvider);
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
                                              defaultPadding -
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

                                                  // Example: top weekly doctor
                                                  if (leaderboard
                                                      .week
                                                      .isEmpty) {
                                                    return const Text(
                                                      "No referrals this week.",
                                                    );
                                                  }

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
                                        _buildTimeFilterSelector(
                                          _selectedRangeForTopReferrals,
                                          (newFilter) {
                                            setState(() {
                                              _selectedRangeForTopReferrals =
                                                  newFilter;
                                            });
                                          },
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
                                              defaultPadding -
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
                                          _selectedRangeForBills,
                                          (newFilter) {
                                            setState(() {
                                              _selectedRangeForBills =
                                                  newFilter;
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
