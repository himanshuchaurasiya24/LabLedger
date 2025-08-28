// models/referral_stat.dart
class ReferralStat {
  final int referredByDoctorId;
  final String doctorFullName;
  final int total;
  final int ultrasound;
  final int ecg;
  final int xray;
  final int pathology;
  final int franchiseLab;
  final int incentiveAmount;

  ReferralStat({
    required this.referredByDoctorId,
    required this.doctorFullName,
    required this.total,
    required this.ultrasound,
    required this.ecg,
    required this.xray,
    required this.pathology,
    required this.franchiseLab,
    required this.incentiveAmount,
  });

  factory ReferralStat.fromJson(Map<String, dynamic> json) {
    return ReferralStat(
      referredByDoctorId: json['referred_by_doctor__id'] ?? 0,
      doctorFullName: json['doctor_full_name'] ?? '',
      total: json['total'] ?? 0,
      ultrasound: json['ultrasound'] ?? 0,
      ecg: json['ecg'] ?? 0,
      xray: json['xray'] ?? 0,
      pathology: json['pathology'] ?? 0,
      franchiseLab: json['franchise_lab'] ?? 0,
      incentiveAmount: json['incentive_amount'] ?? 0,
    );
  }
}

// models/referral_stats_response.dart
class ReferralStatsResponse {
  final List<ReferralStat> thisWeek;
  final List<ReferralStat> thisMonth;
  final List<ReferralStat> thisYear;
  final List<ReferralStat> allTime;

  ReferralStatsResponse({
    required this.thisWeek,
    required this.thisMonth,
    required this.thisYear,
    required this.allTime,
  });

  factory ReferralStatsResponse.fromJson(Map<String, dynamic> json) {
    return ReferralStatsResponse(
      thisWeek: (json['this_week'] as List? ?? [])
          .map((e) => ReferralStat.fromJson(e))
          .toList(),
      thisMonth: (json['this_month'] as List? ?? [])
          .map((e) => ReferralStat.fromJson(e))
          .toList(),
      thisYear: (json['this_year'] as List? ?? [])
          .map((e) => ReferralStat.fromJson(e))
          .toList(),
      allTime: (json['all_time'] as List? ?? [])
          .map((e) => ReferralStat.fromJson(e))
          .toList(),
    );
  }

  List<ReferralStat> getDataForPeriod(String period) {
    switch (period.toLowerCase()) {
      case 'this week':
        return thisWeek;
      case 'this month':
        return thisMonth;
      case 'this year':
        return thisYear;
      case 'all time':
        return allTime;
      default:
        return thisMonth;
    }
  }
}

// models/chart_data.dart
class ChartData {
  final String day;
  final int total;
  final int ultrasound;
  final int ecg;
  final int xray;
  final int pathology;
  final int franchiseLab;

  ChartData({
    required this.day,
    required this.total,
    required this.ultrasound,
    required this.ecg,
    required this.xray,
    required this.pathology,
    required this.franchiseLab,
  });

  factory ChartData.fromJson(Map<String, dynamic> json) {
    return ChartData(
      day: json['day'] ?? '',
      total: json['total'] ?? 0,
      ultrasound: json['ultrasound'] ?? 0,
      ecg: json['ecg'] ?? 0,
      xray: json['xray'] ?? 0,
      pathology: json['pathology'] ?? 0,
      franchiseLab: json['franchise_lab'] ?? 0,
    );
  }
}

// models/chart_stats_response.dart
class ChartStatsResponse {
  final List<ChartData> thisWeek;
  final List<ChartData> thisMonth;
  final List<ChartData> thisYear;
  final List<ChartData> allTime;

  ChartStatsResponse({
    required this.thisWeek,
    required this.thisMonth,
    required this.thisYear,
    required this.allTime,
  });

  factory ChartStatsResponse.fromJson(Map<String, dynamic> json) {
    return ChartStatsResponse(
      thisWeek: (json['this_week'] as List? ?? [])
          .map((e) => ChartData.fromJson(e))
          .toList(),
      thisMonth: (json['this_month'] as List? ?? [])
          .map((e) => ChartData.fromJson(e))
          .toList(),
      thisYear: (json['this_year'] as List? ?? [])
          .map((e) => ChartData.fromJson(e))
          .toList(),
      allTime: (json['all_time'] as List? ?? [])
          .map((e) => ChartData.fromJson(e))
          .toList(),
    );
  }

  List<ChartData> getDataForPeriod(String period) {
    switch (period.toLowerCase()) {
      case 'this week':
        return thisWeek;
      case 'this month':
        return thisMonth;
      case 'this year':
        return thisYear;
      case 'all time':
        return allTime;
      default:
        return thisMonth;
    }
  }
}