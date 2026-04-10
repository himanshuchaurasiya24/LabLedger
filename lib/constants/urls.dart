class AppUrls {
  const AppUrls._();

  static const String githubJsonRaw =
      'https://raw.githubusercontent.com/himanshuchaurasiya24/SampleLabReports/main/usg.json';
  static const String localBaseUrl = 'http://127.0.0.1:8000/';

  static const String developerGithub =
      'https://github.com/himanshuchaurasiya24';
  static const String releasesPage =
      'https://github.com/himanshuchaurasiya24/LabLedger/releases/';

  static const String token = 'api/token/';
  static const String tokenRefresh = 'api/token/refresh/';
  static const String tokenVerify = 'api/token/verify/';
  static const String verifyAuth = 'verify-auth/';
  static const String appInfo = 'api/app-info/';

  static const String staffBase = 'auth/staffs/staff';

  static const String centerDetail = 'center-details/center-detail/';
  static const String subscriptionPlan = 'center-details/subscription-plan/';
  static const String subscriptionPlanContext =
      'center-details/subscription-plan-context/';

  static const String diagnosisBill = 'diagnosis/bill/';
  static const String diagnosisPendingReports = 'diagnosis/pending-reports/';
  static const String diagnosisBillGrowthStats =
      'diagnosis/bills/growth-stats/';
  static const String diagnosisDoctor = 'diagnosis/doctor/';
  static const String diagnosisDiagnosisType = 'diagnosis/diagnosis-type/';
  static const String diagnosisSampleTestReport =
      'diagnosis/sample-test-report/';
  static const String diagnosisFranchiseName = 'diagnosis/franchise-name/';
  static const String diagnosisReferralStat = 'diagnosis/referral-stat/';
  static const String diagnosisBillChartStat = 'diagnosis/bill-chart-stat/';
  static const String diagnosisAuditLogs = 'diagnosis/audit-logs/';
  static const String diagnosisIncentives = 'diagnosis/incentives/';
  static const String diagnosisCategories = 'diagnosis/categories/';
  static const String diagnosisPatientReport = 'diagnosis/patient-report/';

  static String diagnosisPatientReportDetail(int reportId) =>
      'diagnosis/patient-report/$reportId/';

  static String diagnosisDoctorGrowthStats(int doctorId) =>
      'diagnosis/doctors/$doctorId/growth-stats/';
}
