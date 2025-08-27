class BillStats {
  final BillPeriodStats currentMonth;
  final BillPeriodStats previousMonth;
  final BillPeriodStats currentYear;
  final BillPeriodStats previousYear;
  final BillPeriodStats currentQuarter;
  final BillPeriodStats previousQuarter;

  BillStats({
    required this.currentMonth,
    required this.previousMonth,
    required this.currentYear,
    required this.previousYear,
    required this.currentQuarter,
    required this.previousQuarter,
  });

  factory BillStats.fromJson(Map<String, dynamic> json) {
    return BillStats(
      currentMonth: BillPeriodStats.fromJson(json['current_month']),
      previousMonth: BillPeriodStats.fromJson(json['previous_month']),
      currentYear: BillPeriodStats.fromJson(json['current_year']),
      previousYear: BillPeriodStats.fromJson(json['previous_year']),
      currentQuarter: BillPeriodStats.fromJson(json['current_quarter']),
      previousQuarter: BillPeriodStats.fromJson(json['previous_quarter']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_month': currentMonth.toJson(),
      'previous_month': previousMonth.toJson(),
      'current_year': currentYear.toJson(),
      'previous_year': previousYear.toJson(),
      'current_quarter': currentQuarter.toJson(),
      'previous_quarter': previousQuarter.toJson(),
    };
  }
}

class BillPeriodStats {
  final int totalBills;
  final Map<String, int> diagnosisCounts;

  BillPeriodStats({
    required this.totalBills,
    required this.diagnosisCounts,
  });

  factory BillPeriodStats.fromJson(Map<String, dynamic> json) {
    final diagnosisMap = <String, int>{};
    if (json['diagnosis_counts'] != null) {
      json['diagnosis_counts'].forEach((key, value) {
        diagnosisMap[key] = value as int;
      });
    }

    return BillPeriodStats(
      totalBills: json['total_bills'] ?? 0,
      diagnosisCounts: diagnosisMap,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_bills': totalBills,
      'diagnosis_counts': diagnosisCounts,
    };
  }
}
