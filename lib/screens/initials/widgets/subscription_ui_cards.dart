import 'package:flutter/material.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/models/subscription_model.dart';

class SubscriptionPlanCard extends StatelessWidget {
  final SubscriptionPlanViewData plan;
  final SubscriptionPlanContextViewData planContext;
  final int index;
  final int currentPlanIndex;
  final bool hasCurrentPlanInList;
  final VoidCallback onUpgrade;

  const SubscriptionPlanCard({
    super.key,
    required this.plan,
    required this.planContext,
    required this.index,
    required this.currentPlanIndex,
    required this.hasCurrentPlanInList,
    required this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isFreePlan = plan.name.toUpperCase() == 'FREE';
    final isCurrentExpiredPlan = planContext.isExpired &&
        planContext.currentPlanId != null &&
        plan.id == planContext.currentPlanId;
    final canUpgrade =
        planContext.canShowUpgradeDialog && plan.planIndex > currentPlanIndex;

    return Container(
      margin: EdgeInsets.only(bottom: defaultHeight / 4),
      padding: EdgeInsets.all(defaultPadding * 1.5),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(mediumRadius),
        border: Border.all(
          color: isCurrentExpiredPlan
              ? theme.colorScheme.error.withValues(alpha: 0.4)
              : theme.colorScheme.outline.withValues(alpha: 0.1),
          width: isCurrentExpiredPlan ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
              SubscriptionQuotaChip(
                label: 'Duration',
                value: '${plan.durationDays} days',
              ),
              SubscriptionQuotaChip(
                label: 'SMS Quota',
                value: '${plan.smsQuota}',
              ),
              SubscriptionQuotaChip(
                label: 'Server Reports',
                value: '${plan.serverReportStorageQuotaMb} MB',
              ),
              SubscriptionQuotaChip(
                label: 'Patient Reports',
                value: '${plan.patientReportStorageQuotaMb} MB',
              ),
            ],
          ),
          SizedBox(height: defaultHeight / 2),
          Row(
            children: [
              if (canUpgrade)
                ElevatedButton.icon(
                  onPressed: onUpgrade,
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
  }
}

class SubscriptionCustomCard extends StatelessWidget {
  final VoidCallback onRequestCustom;

  const SubscriptionCustomCard({super.key, required this.onRequestCustom});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: EdgeInsets.only(bottom: defaultHeight / 4),
      padding: EdgeInsets.all(defaultPadding * 1.5),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(mediumRadius),
        border: Border.all(
          color: theme.colorScheme.secondary.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
            onPressed: onRequestCustom,
            icon: const Icon(Icons.outbox_outlined),
            label: const Text('Request Custom Plan'),
          ),
        ],
      ),
    );
  }
}

class SubscriptionContactCard extends StatelessWidget {
  final VoidCallback onContactSupport;
  final String supportEmail;

  const SubscriptionContactCard({
    super.key,
    required this.onContactSupport,
    required this.supportEmail,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: EdgeInsets.only(bottom: defaultHeight / 4),
      padding: EdgeInsets.all(defaultPadding * 1.5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.08),
            theme.colorScheme.primary.withValues(alpha: 0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(mediumRadius),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
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
            onTap: onContactSupport,
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
                    supportEmail,
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
}

class SubscriptionQuotaChip extends StatelessWidget {
  final String label;
  final String value;

  const SubscriptionQuotaChip({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
}
