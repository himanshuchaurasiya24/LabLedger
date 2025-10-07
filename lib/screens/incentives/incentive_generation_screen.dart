import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/main.dart';
import 'package:labledger/providers/diagnosis_type_provider.dart';
import 'package:labledger/providers/doctor_provider.dart';
import 'package:labledger/providers/franchise_lab_provider.dart';
import 'package:labledger/providers/incenitve_generator_provider.dart';
import 'package:labledger/screens/incentives/incentive_detail_screen.dart';
import 'package:labledger/screens/initials/window_scaffold.dart';
import 'package:labledger/screens/ui_components/tinted_container.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

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
      ref.invalidate(selectedBillStatusesProvider);
      ref.invalidate(reportStartDateProvider);
      ref.invalidate(reportEndDateProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return WindowScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Generate Incentive Report",
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          Text(
            "Configure filters and generate detailed incentive reports",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: defaultHeight * 1.5),

          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: _FilterPanel()),
                SizedBox(width: defaultWidth),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      _QuickStatsPanel(),
                      SizedBox(height: defaultHeight),
                      _ActionPanel(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterPanel extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctorsAsync = ref.watch(doctorsProvider);
    final franchisesAsync = ref.watch(franchiseProvider);
    final diagnosisTypesAsync = ref.watch(diagnosisTypeProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TintedContainer(
            baseColor: Theme.of(context).colorScheme.primary,
            height: 150,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      LucideIcons.calendar,
                      size: 20,
                      color: Colors.blue.shade700,
                    ),
                    SizedBox(width: 6),
                    Text(
                      "Date Range",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
                Spacer(),
                _DateRangePicker(),
              ],
            ),
          ),
          SizedBox(height: defaultHeight),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: doctorsAsync.when(
                  data: (doctors) => TintedContainer(
                    height: 128,
                    baseColor: Theme.of(context).colorScheme.secondary,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              LucideIcons.userCheck,
                              size: 18,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            SizedBox(width: 6),
                            Text(
                              "Doctors",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.secondary,
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
                          baseColor: Theme.of(context).colorScheme.secondary,
                        ),
                      ],
                    ),
                  ),
                  loading: () => TintedContainer(
                    baseColor: Theme.of(context).colorScheme.secondary,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (e, s) => TintedContainer(
                    baseColor: Theme.of(context).colorScheme.error,
                    child: Center(child: Text("Error")),
                  ),
                ),
              ),
              SizedBox(width: defaultWidth),
              Expanded(
                child: franchisesAsync.when(
                  data: (franchises) => TintedContainer(
                    baseColor: Theme.of(context).colorScheme.error,
                    height: 128,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              LucideIcons.building,
                              size: 18,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            SizedBox(width: 6),
                            Text(
                              "Franchise Labs",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: defaultHeight / 2),
                        Text(
                          "   Select this only if you want to filter by labs otherwise leave it blank",
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(
                              context,
                            ).colorScheme.error.withValues(alpha: 0.7),
                          ),
                        ),
                        SizedBox(height: defaultHeight / 2),

                        Spacer(),
                        _CompactMultiSelectDropdown<int>(
                          items: {
                            for (var f in franchises) f.id!: f.franchiseName!,
                          },
                          selectedProvider: selectedFranchiseIdsProvider,
                          hint: "Select labs...",
                          baseColor: Theme.of(context).colorScheme.error,
                        ),
                      ],
                    ),
                  ),
                  loading: () => TintedContainer(
                    baseColor: Theme.of(context).colorScheme.error,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (e, s) => TintedContainer(
                    baseColor: Theme.of(context).colorScheme.error,
                    child: Center(child: Text("Error")),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: defaultHeight),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: diagnosisTypesAsync.when(
                  data: (types) => TintedContainer(
                    height: 120,
                    baseColor: Theme.of(context).colorScheme.secondary,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              LucideIcons.clipboardList,
                              size: 18,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            SizedBox(width: 6),
                            Text(
                              "Diagnosis Types",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                        _CompactMultiSelectDropdown<int>(
                          items: {for (var t in types) t.id!: t.name},
                          selectedProvider: selectedDiagnosisTypeIdsProvider,
                          hint: "Select types...",
                          baseColor: Theme.of(context).colorScheme.secondary,
                        ),
                      ],
                    ),
                  ),
                  loading: () => TintedContainer(
                    baseColor: Theme.of(context).colorScheme.secondary,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (e, s) => TintedContainer(
                    baseColor: Theme.of(context).colorScheme.error,
                    child: Center(child: Text("Error")),
                  ),
                ),
              ),
              SizedBox(width: defaultWidth),
              Expanded(
                child: TintedContainer(
                  baseColor: Theme.of(context).colorScheme.secondary,
                  height: 120,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            LucideIcons.creditCard,
                            size: 18,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          SizedBox(width: 6),
                          Text(
                            "Bill Status",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.secondary,
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
                        baseColor: Theme.of(context).colorScheme.secondary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickStatsPanel extends ConsumerWidget {
  const _QuickStatsPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDoctors = ref.watch(selectedDoctorIdsProvider);
    final selectedFranchises = ref.watch(selectedFranchiseIdsProvider);
    final selectedDiagnosisTypes = ref.watch(selectedDiagnosisTypeIdsProvider);
    final selectedBillStatuses = ref.watch(selectedBillStatusesProvider);
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TintedContainer(
                baseColor: colorScheme.secondary,
                height: 80,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      selectedDoctors.length.toString(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.secondary,
                      ),
                    ),
                    Text(
                      "Doctors Selected",
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: defaultWidth),
            Expanded(
              child: TintedContainer(
                baseColor: colorScheme.error,
                height: 80,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      selectedFranchises.length.toString(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.error,
                      ),
                    ),
                    Text(
                      "Labs Selected",
                      style: TextStyle(fontSize: 12, color: colorScheme.error),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: defaultHeight),
        Row(
          children: [
            Expanded(
              child: TintedContainer(
                baseColor: colorScheme.secondary,
                height: 80,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      selectedDiagnosisTypes.length.toString(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.secondary,
                      ),
                    ),
                    Text(
                      "Diagnosis Types",
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: defaultWidth),
            Expanded(
              child: TintedContainer(
                baseColor: colorScheme.secondary,
                height: 80,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      selectedBillStatuses.length.toString(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.secondary,
                      ),
                    ),
                    Text(
                      "Bill Statuses",
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionPanel extends ConsumerWidget {
  const _ActionPanel();

  void _clearFilters(WidgetRef ref) {
    ref.invalidate(selectedDoctorIdsProvider);
    ref.invalidate(selectedFranchiseIdsProvider);
    ref.invalidate(selectedDiagnosisTypeIdsProvider);
    ref.invalidate(selectedBillStatusesProvider);
    ref.invalidate(reportStartDateProvider);
    ref.invalidate(reportEndDateProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return TintedContainer(
      height: 238,
      baseColor: Theme.of(context).colorScheme.primary,
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.fileText,
                color: Colors.indigo.shade700,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                "Generate Report",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo.shade700,
                ),
              ),
            ],
          ),
          SizedBox(height: defaultHeight / 2),
          Text(
            "Review your selected filters and generate the detailed incentive report with comprehensive analytics and breakdowns.",
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              height: 1.4,
            ),
          ),
          Spacer(),
          Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(defaultRadius),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(defaultRadius),
              onTap: () {
                navigatorKey.currentState?.push(
                  MaterialPageRoute(
                    builder: (context) => IncentiveDetailScreen(),
                  ),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.fileText, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    "Generate Report",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: defaultHeight / 2),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              icon: Icon(
                LucideIcons.x,
                size: 16,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              label: Text(
                "Clear All Filters",
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              onPressed: () => _clearFilters(ref),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(defaultRadius),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Date range picker widget
class _DateRangePicker extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startDate = ref.watch(reportStartDateProvider);
    final endDate = ref.watch(reportEndDateProvider);
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(defaultRadius),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(defaultRadius),
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
              child: Padding(
                padding: EdgeInsets.all(defaultPadding * 1.5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Start Date",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      DateFormat.yMMMd().format(startDate),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: defaultWidth),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(defaultRadius),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(defaultRadius),
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
              child: Padding(
                padding: EdgeInsets.all(defaultPadding * 1.5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "End Date",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      DateFormat.yMMMd().format(endDate),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Custom Multi-Select Dropdown
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
            child: GestureDetector(
              onTap: _closeDropdown,
              child: Container(color: Colors.transparent),
            ),
          ),
          CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(0, 4),
            child: Material(
              color: Colors.transparent,
              child: TintedContainer(
                baseColor: widget.baseColor,
                disablePadding: true,
                elevationLevel: 4,
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
                              _closeDropdown();
                            },
                          ),
                          Divider(height: 1),
                          ...widget.items.entries.map((entry) {
                            return _DropdownItem<T>(
                              value: entry.key,
                              text: entry.value,
                              selectedProvider: widget.selectedProvider,
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
      child: GestureDetector(
        onTap: _toggleDropdown,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(defaultRadius),
            border: Border.all(
              color: isExpanded
                  ? widget.baseColor.withValues(alpha: 0.5)
                  : theme.colorScheme.onSurface.withValues(alpha: 0.2),
              width: isExpanded ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _getDisplayText(),
                  style: TextStyle(
                    fontSize: 13,
                    color: selectedValues.isEmpty
                        ? theme.colorScheme.onSurface.withValues(alpha: 0.6)
                        : theme.colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                isExpanded ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                size: 16,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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

  const _DropdownItem({
    super.key,
    required this.value,
    required this.text,
    required this.selectedProvider,
    required this.onTap,
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
      child: InkWell(
        onTap: () => onTap(value),
        borderRadius: BorderRadius.circular(defaultRadius / 2),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    width: 2,
                  ),
                  color: isSelected
                      ? theme.colorScheme.primary
                      : Colors.transparent,
                ),
                child: isSelected
                    ? Icon(
                        LucideIcons.check,
                        size: 10,
                        color: theme.colorScheme.onPrimary,
                      )
                    : null,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface,
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
