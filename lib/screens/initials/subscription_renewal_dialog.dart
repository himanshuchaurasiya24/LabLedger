import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:labledger/authentication/config.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/screens/ui_components/tinted_container.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

class SubscriptionRenewalDialog extends StatefulWidget {
  const SubscriptionRenewalDialog({super.key, this.loginIdentifier});

  final String? loginIdentifier;

  @override
  State<SubscriptionRenewalDialog> createState() =>
      _SubscriptionRenewalDialogState();
}

class _SubscriptionRenewalDialogState extends State<SubscriptionRenewalDialog> {
  static const String _supportEmail = 'support@your-domain.com';
  SubscriptionPlanContextViewData? _latestPlanContext;
  late final Future<_RenewalDialogData> _dialogDataFuture;

  @override
  void initState() {
    super.initState();
    _dialogDataFuture = _loadDialogData();
  }

  Future<_RenewalDialogData> _loadDialogData() async {
    final results = await Future.wait([_fetchPlans(), _fetchPlanContext()]);
    final context = results[1] as SubscriptionPlanContextViewData;
    _latestPlanContext = context;

    return _RenewalDialogData(
      plans: results[0] as List<SubscriptionPlanViewData>,
      context: context,
    );
  }

  Future<List<SubscriptionPlanViewData>> _fetchPlans() async {
    final response = await http.get(
      Uri.parse('${globalBaseUrl}center-details/subscription-plan/'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to load plans (${response.statusCode}).');
    }

    final dynamic decoded = jsonDecode(response.body);
    List<dynamic> rawList = const [];

    if (decoded is List) {
      rawList = decoded;
    } else if (decoded is Map<String, dynamic> && decoded['results'] is List) {
      rawList = decoded['results'] as List<dynamic>;
    }

    return rawList
        .whereType<Map<String, dynamic>>()
        .map(SubscriptionPlanViewData.fromJson)
        .toList();
  }

  Future<SubscriptionPlanContextViewData> _fetchPlanContext() async {
    final identifier = (widget.loginIdentifier ?? '').trim();
    if (identifier.isEmpty) {
      return const SubscriptionPlanContextViewData();
    }

    try {
      final response = await http.post(
        Uri.parse('${globalBaseUrl}center-details/subscription-plan-context/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': identifier}),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return const SubscriptionPlanContextViewData();
      }

      final dynamic decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        return const SubscriptionPlanContextViewData();
      }

      return SubscriptionPlanContextViewData.fromJson(decoded);
    } catch (_) {
      return const SubscriptionPlanContextViewData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
        child: TintedContainer(
          baseColor: theme.colorScheme.primary,
          width: 950,
          height: 620,
          radius: 20,
          disablePadding: true,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(defaultPadding),
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.shieldAlert,
                      color: theme.colorScheme.error,
                      size: 24,
                    ),
                    SizedBox(width: defaultWidth / 2),
                    Expanded(
                      child: Text(
                        'Subscription Renewal Required',
                        style: theme.textTheme.headlineSmall,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      label: const Text('Close'),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(horizontal: defaultPadding),
                padding: EdgeInsets.all(defaultPadding * 0.8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer.withValues(
                    alpha: 0.6,
                  ),
                  borderRadius: BorderRadius.circular(defaultRadius),
                  border: Border.all(
                    color: theme.colorScheme.error.withValues(alpha: 0.35),
                  ),
                ),
                child: Text(
                  'Your center subscription is currently inactive or expired. Please review available plans and submit an upgrade request if required.',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              Expanded(child: _buildPlansContent(theme)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlansContent(ThemeData theme) {
    return FutureBuilder<_RenewalDialogData>(
      future: _dialogDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(defaultPadding * 2),
              child: Text(
                'Unable to load plans. Please try again in a moment.',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final dialogData = snapshot.data;
        final plans = dialogData?.plans ?? const [];
        final planContext =
            dialogData?.context ?? const SubscriptionPlanContextViewData();

        int currentPlanIndex = 0;
        if (planContext.currentPlanId != null) {
          for (final plan in plans) {
            if (plan.id == planContext.currentPlanId) {
              currentPlanIndex = plan.planIndex;
              break;
            }
          }
        }

        if (plans.isEmpty) {
          return Center(
            child: Text(
              'No plans are available right now.',
              style: theme.textTheme.titleMedium,
            ),
          );
        }

        final hasCurrentPlanInList =
            planContext.currentPlanId != null &&
            plans.any((plan) => plan.id == planContext.currentPlanId);

        final itemCount = plans.length + 2;

        return ListView.separated(
          padding: EdgeInsets.all(defaultPadding),
          itemCount: itemCount,
          separatorBuilder: (_, _) => SizedBox(height: defaultHeight / 2),
          itemBuilder: (context, index) {
            if (index == plans.length) {
              return _buildCustomCard(theme);
            }

            if (index == plans.length + 1) {
              return _buildContactCard(theme);
            }

            final plan = plans[index];
            final isFreePlan = plan.name.toUpperCase() == 'FREE';
            final isCurrentExpiredPlan =
                planContext.isExpired &&
                planContext.currentPlanId != null &&
                plan.id == planContext.currentPlanId;
            final canUpgrade =
                planContext.canShowUpgradeDialog &&
                plan.planIndex > currentPlanIndex;

            return Container(
              padding: EdgeInsets.all(defaultPadding),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(defaultRadius),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.25),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          plan.name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (isCurrentExpiredPlan)
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.error.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(99),
                            border: Border.all(
                              color: theme.colorScheme.error.withValues(
                                alpha: 0.4,
                              ),
                            ),
                          ),
                          child: Text(
                            'Current expired plan',
                            style: TextStyle(
                              color: theme.colorScheme.error,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          'Price: ${plan.formattedPrice}',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (isFreePlan) ...[
                    SizedBox(height: defaultHeight / 2),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(defaultRadius),
                        border: Border.all(
                          color: theme.colorScheme.error.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        'This plan cannot be renewed.',
                        style: TextStyle(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                  SizedBox(height: defaultHeight / 2),
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      _quotaChip(
                        'Duration',
                        '${plan.durationDays} days',
                        theme,
                      ),
                      _quotaChip('SMS Quota', '${plan.smsQuota}', theme),
                      _quotaChip(
                        'Server Reports',
                        '${plan.serverReportStorageQuotaMb} MB',
                        theme,
                      ),
                      _quotaChip(
                        'Patient Reports',
                        '${plan.patientReportStorageQuotaMb} MB',
                        theme,
                      ),
                    ],
                  ),
                  SizedBox(height: defaultHeight / 2),
                  Row(
                    children: [
                      if (canUpgrade)
                        ElevatedButton.icon(
                          onPressed: () => _openSupportEmail(
                            subject: 'Upgrade request: ${plan.name}',
                            body: _buildFormalSupportRequestBody(
                              targetPlanName: plan.name,
                            ),
                          ),
                          icon: const Icon(Icons.trending_up),
                          label: const Text('Upgrade'),
                        )
                      else
                        Text(
                          planContext.isExpired
                              ? 'Upgrade not available for this tier.'
                              : 'You already have this tier or a higher one.',
                          style: theme.textTheme.bodySmall,
                        ),
                    ],
                  ),
                  if (planContext.isExpired &&
                      planContext.currentPlanId != null &&
                      !hasCurrentPlanInList &&
                      index == 0) ...[
                    SizedBox(height: defaultHeight / 2),
                    Text(
                      'Your current expired plan is ${planContext.currentPlanName ?? 'unavailable'} and is no longer listed.',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCustomCard(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(defaultRadius),
        border: Border.all(
          color: theme.colorScheme.secondary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Custom Plan',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  'Custom',
                  style: TextStyle(
                    color: theme.colorScheme.secondary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: defaultHeight / 2),
          Text(
            'If your center requires different duration or quota limits, we can prepare a tailored subscription plan.',
            style: theme.textTheme.bodyMedium,
          ),
          SizedBox(height: defaultHeight / 2),
          Text(
            'Custom plans are processed manually by support after receiving your formal request.',
            style: theme.textTheme.bodySmall,
          ),
          SizedBox(height: defaultHeight / 2),
          ElevatedButton.icon(
            onPressed: () => _openSupportEmail(
              subject: 'Custom plan request',
              body: _buildFormalSupportRequestBody(
                targetPlanName: 'Custom Plan',
              ),
            ),
            icon: const Icon(Icons.outbox_outlined),
            label: const Text('Request Custom Plan'),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(defaultRadius),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'For subscription renewal and upgrade approval, please contact support via Gmail.',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: defaultHeight / 3),
          InkWell(
            onTap: () => _openSupportEmail(),
            borderRadius: BorderRadius.circular(defaultRadius),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(defaultRadius),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.mail_outline,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  SizedBox(width: defaultWidth / 4),
                  Text(
                    _supportEmail,
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openSupportEmail({String? subject, String? body}) async {
    final computedSubject = (subject != null && subject.isNotEmpty)
        ? subject
        : 'Subscription renewal request';
    final computedBody = (body != null && body.isNotEmpty)
        ? body
        : _buildFormalSupportRequestBody();

    final queryParameters = <String, String>{
      'view': 'cm',
      'fs': '1',
      'to': _supportEmail,
      'su': computedSubject,
      'body': computedBody,
    };

    final uri = Uri.https('mail.google.com', '/mail/', queryParameters);

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      final fallback = Uri(scheme: 'mailto', path: _supportEmail);
      await launchUrl(fallback, mode: LaunchMode.externalApplication);
    }
  }

  Widget _quotaChip(String label, String value, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          color: theme.colorScheme.secondary,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  String _buildFormalSupportRequestBody({String? targetPlanName}) {
    final context = _resolvedContext();
    final requestedPlan = (targetPlanName != null && targetPlanName.isNotEmpty)
        ? targetPlanName
        : 'Not specified';

    return '''Dear Support Team,

I am requesting assistance regarding subscription renewal/upgrade for our center.

Request Details:
- Requested action: ${targetPlanName != null ? 'Upgrade' : 'Renewal / Information'}
- Target plan: $requestedPlan
- Center ID: ${context.centerId?.toString() ?? 'Unknown'}
- Center name: ${context.centerName ?? 'Unknown'}
- Current plan: ${context.currentPlanName ?? 'Unknown'}

Kindly review this request and share the next steps.

Regards,
LabLedger Admin''';
  }

  SubscriptionPlanContextViewData _resolvedContext() {
    final data = _latestPlanContext;
    if (data != null) {
      return data;
    }

    return const SubscriptionPlanContextViewData();
  }
}

class SubscriptionPlanViewData {
  final int id;
  final String name;
  final int planIndex;
  final double price;
  final int durationDays;
  final int smsQuota;
  final int serverReportStorageQuotaMb;
  final int patientReportStorageQuotaMb;
  final bool isCustom;

  const SubscriptionPlanViewData({
    required this.id,
    required this.name,
    required this.planIndex,
    required this.price,
    required this.durationDays,
    required this.smsQuota,
    required this.serverReportStorageQuotaMb,
    required this.patientReportStorageQuotaMb,
    required this.isCustom,
  });

  String get formattedPrice {
    if (price == price.roundToDouble()) {
      return price.toStringAsFixed(0);
    }
    return price.toStringAsFixed(2);
  }

  factory SubscriptionPlanViewData.fromJson(Map<String, dynamic> json) {
    final dynamic rawPrice = json['price'];

    return SubscriptionPlanViewData(
      id: (json['id'] as int?) ?? 0,
      name: (json['name'] as String?) ?? 'Unnamed Plan',
      planIndex: (json['plan_index'] as int?) ?? 0,
      price: rawPrice is num
          ? rawPrice.toDouble()
          : double.tryParse(rawPrice?.toString() ?? '0') ?? 0,
      durationDays: (json['duration_days'] as int?) ?? 0,
      smsQuota: (json['sms_quota'] as int?) ?? 0,
      serverReportStorageQuotaMb:
          (json['server_report_storage_quota_mb'] as int?) ?? 0,
      patientReportStorageQuotaMb:
          (json['patient_report_storage_quota_mb'] as int?) ?? 0,
      isCustom: (json['is_custom'] as bool?) ?? false,
    );
  }
}

class SubscriptionPlanContextViewData {
  final bool canShowUpgradeDialog;
  final int? centerId;
  final String? centerName;
  final int? currentPlanId;
  final String? currentPlanName;
  final bool isExpired;

  const SubscriptionPlanContextViewData({
    this.canShowUpgradeDialog = false,
    this.centerId,
    this.centerName,
    this.currentPlanId,
    this.currentPlanName,
    this.isExpired = false,
  });

  factory SubscriptionPlanContextViewData.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanContextViewData(
      canShowUpgradeDialog: (json['can_show_upgrade_dialog'] as bool?) ?? false,
      centerId: json['center_id'] as int?,
      centerName: json['center_name'] as String?,
      currentPlanId: json['current_plan_id'] as int?,
      currentPlanName: json['current_plan_name'] as String?,
      isExpired: (json['is_expired'] as bool?) ?? false,
    );
  }
}

class _RenewalDialogData {
  final List<SubscriptionPlanViewData> plans;
  final SubscriptionPlanContextViewData context;

  const _RenewalDialogData({required this.plans, required this.context});
}
