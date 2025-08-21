import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:labledger/models/bill_model.dart';
import 'package:labledger/models/diagnosis_type_model.dart';
import 'package:labledger/models/doctors_model.dart';
import 'package:labledger/providers/custom_providers.dart';
import 'package:labledger/screens/home/home_screen.dart';

final selectedDiagnosisType = StateProvider<DiagnosisType?>((ref) => null);
final selectedDoctor = StateProvider<Doctor?>((ref) => null);
Widget customTextField({
  required String label,
  required BuildContext context,
  required TextEditingController controller,
  TextInputType keyboardType = TextInputType.text,
}) {
  return TextFormField(
    controller: controller, // <-- THIS is sufficient for binding
    keyboardType: keyboardType,
    validator: (value) {
      if (value == null || value.trim().isEmpty) {
        return 'Please enter $label';
      }
      return null;
    },
    decoration: InputDecoration(
      filled: true,
      hintText: label,
      fillColor: Theme.of(context).brightness == Brightness.dark
          ? darkTextFieldFillColor
          : lightTextFieldFillColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(defaultRadius),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(defaultRadius),
      ),
    ),
  );
}

class CustomDropDown<T> extends StatefulWidget {
  final BuildContext context;
  final List<T> dropDownList;
  final TextEditingController textController;
  final String Function(T) valueMapper; // For Display Text
  final String Function(T) idMapper; // For Controller Value
  final String hintText;
  final TextStyle? textStyle;
  const CustomDropDown({
    super.key,
    required this.context,
    required this.dropDownList,
    required this.textController,
    required this.valueMapper,
    required this.idMapper,
    required this.hintText,
    this.textStyle,
  });

  @override
  CustomDropDownState<T> createState() => CustomDropDownState<T>();
}

class CustomDropDownState<T> extends State<CustomDropDown<T>> {
  T? selectedValue;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncControllerWithValue();
    });
  }

  @override
  void didUpdateWidget(covariant CustomDropDown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dropDownList != widget.dropDownList ||
        oldWidget.textController.text != widget.textController.text) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _syncControllerWithValue();
      });
    }
  }

  void _syncControllerWithValue() {
    if (widget.dropDownList.isEmpty) return;

    final existing = widget.dropDownList.firstWhere(
      (e) => widget.idMapper(e) == widget.textController.text,
      orElse: () => widget.dropDownList.first,
    );

    if (mounted) {
      setState(() {
        selectedValue = existing;
        widget.textController.text = widget.idMapper(existing);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).brightness == Brightness.dark
            ? darkTextFieldFillColor
            : lightTextFieldFillColor,
      ),
      child: DropdownButtonFormField<T>(
        isExpanded: true,
        value: selectedValue,
        style: widget.textStyle,
        borderRadius: BorderRadius.circular(8),
        decoration: InputDecoration(
          hintText: widget.hintText,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          filled: true,
          fillColor: Theme.of(context).brightness == Brightness.dark
              ? darkTextFieldFillColor
              : lightTextFieldFillColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
        items: widget.dropDownList.map((e) {
          return DropdownMenuItem<T>(
            value: e,
            child: Text(widget.valueMapper(e), overflow: TextOverflow.ellipsis),
          );
        }).toList(),
        onChanged: (T? selected) {
          if (selected != null) {
            setState(() {
              selectedValue = selected;
            });
            widget.textController.text = widget.idMapper(selected);
          }
        },
      ),
    );
  }
}

final Map<TimeFilter, String> timeFilterLabels = {
    TimeFilter.thisWeek: 'This Week',
    TimeFilter.thisMonth: 'This Month',
    TimeFilter.thisYear: 'This Year',
    TimeFilter.allTime: 'All Time',
  };

  Widget buildTimeFilterSelector(
    TimeFilter selected,
    ValueChanged<TimeFilter> onChanged,
    BuildContext context
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

  LineChartData getChartData(List<FlSpot> data, List<String> dates,    BuildContext context
) {
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
