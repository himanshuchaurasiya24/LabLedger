import 'package:flutter/material.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/models/subscription_model.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class CenterSubscriptionInfoCard extends StatelessWidget {
  final Subscription subscription;
  final bool isActive;
  final Future<bool> canUpgradeFuture;
  final VoidCallback onUpgradeTap;

  const CenterSubscriptionInfoCard({
    super.key,
    required this.subscription,
    required this.isActive,
    required this.canUpgradeFuture,
    required this.onUpgradeTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final statusColor = isActive
        ? theme.colorScheme.secondary
        : theme.colorScheme.error;

    return Container(
      padding: const EdgeInsets.all(mediumPadding),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(defaultRadius),
        border: Border.all(color: statusColor.withValues(alpha: 0.75)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Current Subscription',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: formPadding,
                  vertical: minimalPadding,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(circularRadius),
                ),
                child: Text(
                  isActive ? 'Active' : 'Expired',
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildInfoRow(
            'Plan',
            subscription.planType,
            LucideIcons.gem,
            context,
          ),
          const Divider(height: 16),
          _buildInfoRow(
            'Expires On',
            subscription.expiryDate,
            LucideIcons.calendar_clock,
            context,
          ),
          const Divider(height: 16),
          _buildInfoRow(
            'Days Left',
            '${subscription.daysLeft} days',
            LucideIcons.hourglass,
            context,
          ),
          if (!subscription.isCustom) ...[
            const SizedBox(height: defaultPadding),
            FutureBuilder<bool>(
              future: canUpgradeFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                }

                final canUpgrade = snapshot.data ?? false;
                if (!canUpgrade) {
                  return const SizedBox.shrink();
                }

                return Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: onUpgradeTap,
                    icon: const Icon(Icons.trending_up),
                    label: const Text('Upgrade Plan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(defaultRadius),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon,
    BuildContext context,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            const SizedBox(width: smallPadding),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
