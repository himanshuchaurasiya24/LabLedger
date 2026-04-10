import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/models/audit_log_model.dart';
import 'package:labledger/methods/pagination_controls.dart';
import 'package:labledger/providers/audit_log_provider.dart';
import 'package:labledger/screens/ui_components/app_inkwell.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AuditLogDialog extends ConsumerWidget {
  const AuditLogDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final logsAsync = ref.watch(auditLogsProvider);
    final currentPage = ref.watch(auditLogsCurrentPageProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 980,
          height: 700,
          constraints: const BoxConstraints(maxHeight: 760),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  border: Border(
                    bottom: BorderSide(
                      color: theme.colorScheme.primary.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(
                          alpha: 0.16,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        LucideIcons.history,
                        color: theme.colorScheme.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Center Audit Logs',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Review create, update, delete and auth events',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.7,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppInkWell(
                      borderRadius: BorderRadius.circular(defaultRadius),
                      onTap: () {
                        ref.read(auditLogsCurrentPageProvider.notifier).state =
                            1;
                        ref.invalidate(auditLogsProvider);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          Icons.refresh,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                      style: IconButton.styleFrom(
                        backgroundColor: theme.colorScheme.surface,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: logsAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => _AuditErrorView(
                    message: error.toString(),
                    onRetry: () {
                      ref.read(auditLogsCurrentPageProvider.notifier).state = 1;
                      ref.invalidate(auditLogsProvider);
                    },
                  ),
                  data: (response) {
                    if (response.logs.isEmpty) {
                      return const _AuditEmptyView();
                    }

                    return Column(
                      children: [
                        Expanded(
                          child: ListView.separated(
                            padding: EdgeInsets.all(defaultPadding),
                            itemCount: response.logs.length,
                            separatorBuilder: (_, _) =>
                                SizedBox(height: defaultHeight / 2),
                            itemBuilder: (context, index) {
                              final log = response.logs[index];
                              return _AuditLogCard(log: log);
                            },
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.35),
                            border: Border(
                              top: BorderSide(
                                color: theme.colorScheme.outline.withValues(
                                  alpha: 0.2,
                                ),
                              ),
                            ),
                          ),
                          child: PaginationControls(
                            totalItems: response.count,
                            itemsPerPage: 40,
                            currentPage: currentPage,
                            onPageChanged: (newPage) {
                              ref
                                      .read(
                                        auditLogsCurrentPageProvider.notifier,
                                      )
                                      .state =
                                  newPage;
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuditLogCard extends StatelessWidget {
  final AuditLogEntry log;

  const _AuditLogCard({required this.log});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final actionColor = _actionColor(theme, log.action);

    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(defaultRadius),
        border: Border.all(color: actionColor.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: actionColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: actionColor.withValues(alpha: 0.35),
                  ),
                ),
                child: Text(
                  log.action,
                  style: TextStyle(
                    color: actionColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
              SizedBox(width: defaultWidth / 2),
              Expanded(
                child: Text(
                  log.modelName,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                _formatTimestamp(log.timestamp),
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          SizedBox(height: defaultHeight / 2),
          Text(
            log.details.isNotEmpty ? log.details : 'No additional details',
            style: theme.textTheme.bodyMedium,
          ),
          SizedBox(height: defaultHeight / 2),
          Wrap(
            spacing: 14,
            runSpacing: 6,
            children: [
              _metaText('User: ${log.userFullName} (${log.username})', theme),
              _metaText('Object ID: ${log.objectId ?? '-'}', theme),
              _metaText('IP: ${log.ipAddress ?? '-'}', theme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metaText(String value, ThemeData theme) {
    return Text(
      value,
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.85),
      ),
    );
  }

  Color _actionColor(ThemeData theme, String action) {
    switch (action.toUpperCase()) {
      case 'CREATE':
        return Colors.green.shade600;
      case 'UPDATE':
        return Colors.blue.shade600;
      case 'DELETE':
        return Colors.red.shade600;
      case 'LOGIN':
        return theme.colorScheme.secondary;
      case 'LOGOUT':
        return Colors.orange.shade600;
      case 'PASSWORD_CHANGE':
        return Colors.purple.shade600;
      case 'PRIVILEGE_CHANGE':
        return Colors.teal.shade700;
      default:
        return theme.colorScheme.primary;
    }
  }

  String _formatTimestamp(DateTime? timestamp) {
    if (timestamp == null) {
      return 'Unknown time';
    }

    final year = timestamp.year.toString().padLeft(4, '0');
    final month = timestamp.month.toString().padLeft(2, '0');
    final day = timestamp.day.toString().padLeft(2, '0');
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final second = timestamp.second.toString().padLeft(2, '0');
    return '$year-$month-$day $hour:$minute:$second';
  }
}

class _AuditEmptyView extends StatelessWidget {
  const _AuditEmptyView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            LucideIcons.history,
            size: 42,
            color: theme.colorScheme.primary.withValues(alpha: 0.6),
          ),
          SizedBox(height: defaultHeight / 2),
          Text(
            'No audit logs found for this center.',
            style: theme.textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}

class _AuditErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _AuditErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(defaultPadding * 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 36, color: theme.colorScheme.error),
            SizedBox(height: defaultHeight / 2),
            Text(
              'Unable to load audit logs',
              style: theme.textTheme.titleMedium,
            ),
            SizedBox(height: defaultHeight / 3),
            Text(
              message,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: defaultHeight),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
