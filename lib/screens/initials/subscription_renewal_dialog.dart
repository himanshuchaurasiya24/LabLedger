import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:labledger/authentication/config.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/constants/urls.dart';

import 'package:labledger/screens/ui_components/blurred_dialog.dart';
import 'package:labledger/models/subscription_model.dart';
import 'package:labledger/screens/initials/widgets/subscription_ui_cards.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
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
      Uri.parse('$globalBaseUrl${AppUrls.subscriptionPlan}'),
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
        Uri.parse('$globalBaseUrl${AppUrls.subscriptionPlanContext}'),
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
        child: PremiumDialog(
          width: 980,
          height: 700,
          accentColor: theme.colorScheme.primary,
          headerIcon: LucideIcons.shield_alert,
          title: 'Subscription Renewal Required',
          subtitle: 'Review available plans and submit an upgrade request',
          content: Column(
            children: [
              Container(
                width: double.infinity,
                margin: EdgeInsets.fromLTRB(defaultPadding, defaultPadding, defaultPadding, 0),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.error.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: theme.colorScheme.error, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your center subscription is currently inactive or expired.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(child: _buildPlansContent(theme)),
            ],
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
              return SubscriptionCustomCard(
                onRequestCustom: () => _openSupportEmail(
                  subject: 'Custom plan request',
                  body: _buildFormalSupportRequestBody(
                    targetPlanName: 'Custom Plan',
                  ),
                ),
              );
            }

            if (index == plans.length + 1) {
              return SubscriptionContactCard(
                supportEmail: _supportEmail,
                onContactSupport: () => _openSupportEmail(),
              );
            }

            final plan = plans[index];

            return SubscriptionPlanCard(
              plan: plan,
              planContext: planContext,
              index: index,
              currentPlanIndex: currentPlanIndex,
              hasCurrentPlanInList: hasCurrentPlanInList,
              onUpgrade: () => _openSupportEmail(
                subject: 'Upgrade request: ${plan.name}',
                body: _buildFormalSupportRequestBody(
                  targetPlanName: plan.name,
                ),
              ),
            );
          },
        );
      },
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

class _RenewalDialogData {
  final List<SubscriptionPlanViewData> plans;
  final SubscriptionPlanContextViewData context;

  const _RenewalDialogData({required this.plans, required this.context});
}
