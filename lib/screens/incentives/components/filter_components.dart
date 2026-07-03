import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/screens/ui_components/app_inkwell.dart';
import 'package:labledger/screens/ui_components/tinted_container.dart';
import 'package:labledger/providers/incenitve_generator_provider.dart';
import 'package:labledger/providers/diagnosis_type_provider.dart';
import 'package:labledger/providers/doctor_provider.dart';
import 'package:labledger/providers/franchise_lab_provider.dart';

class IncentiveFilterPanel extends ConsumerWidget {
  const IncentiveFilterPanel({super.key});

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
                              LucideIcons.user_check,
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
                        CompactMultiSelectDropdown<int>(
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
                        CompactMultiSelectDropdown<int>(
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
                              LucideIcons.clipboard_list,
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
                        CompactMultiSelectDropdown<int>(
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
                            LucideIcons.credit_card,
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
                      CompactMultiSelectDropdown<String>(
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

class IncentiveDateRangePicker extends ConsumerWidget {
  const IncentiveDateRangePicker({super.key});

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

class CompactMultiSelectDropdown<T> extends ConsumerStatefulWidget {
  final Map<T, String> items;
  final StateProvider<Set<T>> selectedProvider;
  final String hint;
  final Color baseColor;

  const CompactMultiSelectDropdown({
    super.key,
    required this.items,
    required this.selectedProvider,
    required this.hint,
    required this.baseColor,
  });

  @override
  ConsumerState<CompactMultiSelectDropdown<T>> createState() =>
      _CompactMultiSelectDropdownState<T>();
}

class _CompactMultiSelectDropdownState<T>
    extends ConsumerState<CompactMultiSelectDropdown<T>> {
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
                isExpanded ? LucideIcons.chevron_up : LucideIcons.chevron_down,
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
