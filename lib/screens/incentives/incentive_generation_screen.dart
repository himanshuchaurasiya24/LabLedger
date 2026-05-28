import 'package:flutter/material.dart';
import 'package:labledger/screens/ui_components/app_inkwell.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/constants/constants.dart';

import 'package:labledger/providers/diagnosis_type_provider.dart';
import 'package:labledger/providers/doctor_provider.dart';
import 'package:labledger/providers/franchise_lab_provider.dart';
import 'package:labledger/providers/incenitve_generator_provider.dart';

import 'package:labledger/screens/initials/window_scaffold.dart';
import 'package:labledger/screens/ui_components/tinted_container.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:labledger/screens/incentives/components/quick_stats_panel.dart';
import 'package:labledger/screens/incentives/components/action_panel.dart';

class IncentiveGenerationScreen extends ConsumerStatefulWidget {
  const IncentiveGenerationScreen({super.key});

  @override
  ConsumerState<IncentiveGenerationScreen> createState() =>
      _IncentiveGenerationScreenState();
}

class _IncentiveGenerationScreenState
    extends ConsumerState<IncentiveGenerationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(selectedDoctorIdsProvider);
      ref.invalidate(selectedFranchiseIdsProvider);
      ref.invalidate(selectedDiagnosisTypeIdsProvider);

      ref.read(selectedBillStatusesProvider.notifier).state = {'Fully Paid'};

      final now = DateTime.now();
      final firstDayOfMonth = DateTime(now.year, now.month, 1);
      ref.read(reportStartDateProvider.notifier).state = firstDayOfMonth;

      ref.read(reportEndDateProvider.notifier).state = now;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return WindowScaffold(
      child: Padding(
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Section
            Expanded(
              flex: 2,
              child: TintedContainer(
                baseColor: theme.colorScheme.secondary,
                radius: 24,
                intensity: 0.08,
                useGradient: true,
                elevationLevel: 2,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.secondary,
                            theme.colorScheme.secondary.withValues(alpha: 0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.secondary.withValues(
                              alpha: 0.3,
                            ),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        LucideIcons.fileText,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Generate Incentive Report",
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Configure filters and generate detailed incentive reports",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.7,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: defaultHeight),

            // Date Range Section
            Expanded(
              flex: 3,
              child: TintedContainer(
                baseColor: theme.colorScheme.secondary,
                intensity: 0.08,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          LucideIcons.calendar,
                          size: 20,
                          color: theme.colorScheme.secondary,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Date Range",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: defaultHeight),
                    Expanded(child: _DateRangePicker()),
                  ],
                ),
              ),
            ),
            SizedBox(height: defaultHeight),

            // Filters Grid
            Expanded(flex: 5, child: const _FilterPanel()),

            SizedBox(height: defaultHeight * 1.5),

            // Stats and Actions Row
            Expanded(
              flex: 3,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(flex: 3, child: QuickStatsPanel()),
                  SizedBox(width: defaultWidth),
                  Expanded(flex: 2, child: ActionPanel()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterPanel extends ConsumerWidget {
  const _FilterPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctorsAsync = ref.watch(doctorsProvider);
    final franchisesAsync = ref.watch(franchiseProvider);
    final diagnosisTypesAsync = ref.watch(diagnosisTypeProvider);
    final theme = Theme.of(context);
    final Color cardColor = theme.colorScheme.secondary;

    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: doctorsAsync.when(
                  data: (doctors) => TintedContainer(
                    baseColor: cardColor,
                    intensity: 0.08,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              LucideIcons.userCheck,
                              size: 18,
                              color: cardColor,
                            ),
                            SizedBox(width: 8),
                            Text(
                              "Doctors",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: cardColor,
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                        _CompactMultiSelectDropdown<int>(
                          items: {
                            for (var doc in doctors)
                              doc.id!: "${doc.firstName} ${doc.lastName}",
                          },
                          selectedProvider: selectedDoctorIdsProvider,
                          hint: "Select doctors...",
                          baseColor: cardColor,
                        ),
                      ],
                    ),
                  ),
                  loading: () => TintedContainer(
                    baseColor: cardColor,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (e, s) => TintedContainer(
                    baseColor: theme.colorScheme.error,
                    child: Center(child: Text("Error loading doctors")),
                  ),
                ),
              ),
              SizedBox(width: defaultWidth),
              Expanded(
                child: franchisesAsync.when(
                  data: (franchises) => TintedContainer(
                    baseColor: cardColor,
                    intensity: 0.08,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              LucideIcons.building,
                              size: 18,
                              color: cardColor,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Franchise Labs",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: cardColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Optional: Filter by a specific franchise",
                          style: TextStyle(
                            fontSize: 11,
                            color: cardColor.withValues(alpha: 0.8),
                          ),
                        ),
                        Spacer(),
                        _CompactMultiSelectDropdown<int>(
                          items: {
                            for (var f in franchises) f.id!: f.franchiseName!,
                          },
                          selectedProvider: selectedFranchiseIdsProvider,
                          hint: "Select labs...",
                          baseColor: cardColor,
                        ),
                      ],
                    ),
                  ),
                  loading: () => TintedContainer(
                    baseColor: cardColor,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (e, s) => TintedContainer(
                    baseColor: theme.colorScheme.error,
                    child: Center(child: Text("Error loading labs")),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: defaultHeight),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: diagnosisTypesAsync.when(
                  data: (types) => TintedContainer(
                    baseColor: cardColor,
                    intensity: 0.08,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              LucideIcons.clipboardList,
                              size: 18,
                              color: cardColor,
                            ),
                            SizedBox(width: 8),
                            Text(
                              "Diagnosis Types",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: cardColor,
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                        _CompactMultiSelectDropdown<int>(
                          items: {for (var t in types) t.id!: t.name},
                          selectedProvider: selectedDiagnosisTypeIdsProvider,
                          hint: "Select types...",
                          baseColor: cardColor,
                        ),
                      ],
                    ),
                  ),
                  loading: () => TintedContainer(
                    baseColor: cardColor,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (e, s) => TintedContainer(
                    baseColor: theme.colorScheme.error,
                    child: Center(child: Text("Error loading types")),
                  ),
                ),
              ),
              SizedBox(width: defaultWidth),
              Expanded(
                child: TintedContainer(
                  baseColor: cardColor,
                  intensity: 0.08,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            LucideIcons.creditCard,
                            size: 18,
                            color: cardColor,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Bill Status",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: cardColor,
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      _CompactMultiSelectDropdown<String>(
                        items: {
                          'Fully Paid': 'Fully Paid',
                          'Partially Paid': 'Partially Paid',
                          'Unpaid': 'Unpaid',
                        },
                        selectedProvider: selectedBillStatusesProvider,
                        hint: "Select status...",
                        baseColor: cardColor,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DateRangePicker extends ConsumerWidget {
  const _DateRangePicker();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startDate = ref.watch(reportStartDateProvider);
    final endDate = ref.watch(reportEndDateProvider);

    return Row(
      children: [
        Expanded(
          child: _DatePickerCard(
            label: "Start Date",
            date: startDate,
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: startDate,
                firstDate: DateTime(2020),
                lastDate: endDate,
              );
              if (picked != null) {
                ref.read(reportStartDateProvider.notifier).state = picked;
              }
            },
          ),
        ),
        SizedBox(width: defaultWidth),
        Expanded(
          child: _DatePickerCard(
            label: "End Date",
            date: endDate,
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: endDate,
                firstDate: startDate,
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                ref.read(reportEndDateProvider.notifier).state = picked;
              }
            },
          ),
        ),
      ],
    );
  }
}

class _DatePickerCard extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;

  const _DatePickerCard({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppInkWell(
      borderRadius: BorderRadius.circular(defaultRadius),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(defaultPadding * 1.2),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(defaultRadius),
          border: Border.all(
            color: theme.colorScheme.secondary.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  LucideIcons.calendar,
                  size: 16,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                SizedBox(width: 8),
                Text(
                  DateFormat.yMMMd().format(date),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactMultiSelectDropdown<T> extends ConsumerStatefulWidget {
  final Map<T, String> items;
  final StateProvider<Set<T>> selectedProvider;
  final String hint;
  final Color baseColor;

  const _CompactMultiSelectDropdown({
    super.key,
    required this.items,
    required this.selectedProvider,
    required this.hint,
    required this.baseColor,
  });

  @override
  ConsumerState<_CompactMultiSelectDropdown<T>> createState() =>
      __CompactMultiSelectDropdownState<T>();
}

class __CompactMultiSelectDropdownState<T>
    extends ConsumerState<_CompactMultiSelectDropdown<T>> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _closeDropdown();
    super.dispose();
  }

  void _toggleDropdown() {
    if (_overlayEntry != null) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: AppInkWell(
              onTap: _closeDropdown,
              child: Container(color: Colors.transparent),
            ),
          ),
          CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(0, size.height + 4),
            child: Material(
              color: Colors.transparent,
              child: TintedContainer(
                baseColor: widget.baseColor,
                disablePadding: true,
                elevationLevel: 4,
                intensity: 0.08,
                child: SizedBox(
                  width: size.width,
                  child: Container(
                    constraints: BoxConstraints(maxHeight: 250),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(defaultPadding / 2),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _DropdownItem<T>(
                            value: null,
                            text: "Select All",
                            selectedProvider: widget.selectedProvider,
                            allItems: widget.items,
                            baseColor: widget.baseColor,
                            onTap: (_) {
                              final notifier = ref.read(
                                widget.selectedProvider.notifier,
                              );
                              if (notifier.state.length ==
                                  widget.items.length) {
                                notifier.state = {};
                              } else {
                                notifier.state = widget.items.keys.toSet();
                              }
                            },
                          ),
                          Divider(height: 1),
                          ...widget.items.entries.map((entry) {
                            return _DropdownItem<T>(
                              value: entry.key,
                              text: entry.value,
                              selectedProvider: widget.selectedProvider,
                              baseColor: widget.baseColor,
                              onTap: (key) {
                                final notifier = ref.read(
                                  widget.selectedProvider.notifier,
                                );
                                final currentSelection = Set<T>.from(
                                  notifier.state,
                                );
                                if (currentSelection.contains(key)) {
                                  currentSelection.remove(key);
                                } else {
                                  currentSelection.add(key as T);
                                }
                                notifier.state = currentSelection;
                              },
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getDisplayText() {
    final selectedValues = ref.watch(widget.selectedProvider);
    if (selectedValues.isEmpty) return widget.hint;
    if (selectedValues.length == widget.items.length) return "All Selected";
    if (selectedValues.length > 2) {
      return "${selectedValues.length} selected";
    }
    return selectedValues.map((v) => widget.items[v]).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedValues = ref.watch(widget.selectedProvider);
    final bool isExpanded = _overlayEntry != null;

    return CompositedTransformTarget(
      link: _layerLink,
      child: AppInkWell(
        onTap: _toggleDropdown,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(defaultRadius),
            border: Border.all(
              color: isExpanded
                  ? widget.baseColor.withValues(alpha: 0.5)
                  : theme.colorScheme.onSurface.withValues(alpha: 0.2),
              width: isExpanded ? 2 : 1.5,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _getDisplayText(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: selectedValues.isEmpty
                        ? FontWeight.normal
                        : FontWeight.w500,
                    color: selectedValues.isEmpty
                        ? theme.colorScheme.onSurface.withValues(alpha: 0.5)
                        : theme.colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                isExpanded ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                size: 18,
                color: widget.baseColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DropdownItem<T> extends ConsumerWidget {
  final T? value;
  final String text;
  final Map<T, String> allItems;
  final StateProvider<Set<T>> selectedProvider;
  final Function(T? key) onTap;
  final Color baseColor;

  const _DropdownItem({
    super.key,
    required this.value,
    required this.text,
    required this.selectedProvider,
    required this.onTap,
    required this.baseColor,
    this.allItems = const {},
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedValues = ref.watch(selectedProvider);
    final theme = Theme.of(context);

    bool isSelected;
    if (value == null) {
      isSelected =
          selectedValues.isNotEmpty && selectedValues.length == allItems.length;
    } else {
      isSelected = selectedValues.contains(value);
    }

    return Material(
      color: Colors.transparent,
      child: AppInkWell(
        onTap: () => onTap(value),
        borderRadius: BorderRadius.circular(defaultRadius / 2),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: isSelected
                        ? baseColor
                        : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                    width: 2,
                  ),
                  color: isSelected ? baseColor : Colors.transparent,
                ),
                child: isSelected
                    ? Icon(LucideIcons.check, size: 12, color: Colors.white)
                    : null,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: isSelected ? baseColor : theme.colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
