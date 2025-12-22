import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/models/bill_model.dart';
import 'package:labledger/models/diagnosis_type_model.dart';
import 'package:labledger/models/doctors_model.dart';
import 'package:labledger/models/franchise_model.dart';
import 'package:labledger/providers/bills_provider.dart';
import 'package:labledger/providers/diagnosis_type_provider.dart';
import 'package:labledger/providers/doctor_provider.dart';
import 'package:labledger/providers/franchise_lab_provider.dart';
import 'package:labledger/providers/patient_report_provider.dart';
import 'package:labledger/screens/bills/report/update_report_dialog.dart';
import 'package:labledger/screens/initials/window_scaffold.dart';
import 'package:labledger/screens/ui_components/custom_error_dialog.dart';
import 'package:labledger/screens/ui_components/custom_text_field.dart';
import 'package:labledger/screens/ui_components/searchable_dropdown_field.dart';
import 'package:labledger/screens/ui_components/tinted_container.dart';
import 'package:url_launcher/url_launcher.dart';

class AddUpdateBillScreen extends ConsumerStatefulWidget {
  final int? billId;
  final Color themeColor;

  const AddUpdateBillScreen({super.key, this.billId, required this.themeColor});

  @override
  ConsumerState<AddUpdateBillScreen> createState() =>
      _AddUpdateBillScreenState();
}

class _AddUpdateBillScreenState extends ConsumerState<AddUpdateBillScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  final patientNameController = TextEditingController();
  final patientAgeController = TextEditingController();
  final patientSexController = TextEditingController();
  final patientPhoneNumberController = TextEditingController();
  final diagnosisTypeController = TextEditingController();
  final franchiseNameController = TextEditingController();
  final refByDoctorController = TextEditingController();
  final dateOfTestController = TextEditingController();
  final dateOfBillController = TextEditingController();
  final billStatusController = TextEditingController();
  final paidAmountController = TextEditingController();
  final discByDoctorController = TextEditingController();
  final discByCenterController = TextEditingController();
  final diagnosisTypeDisplayController = TextEditingController();
  final franchiseNameDisplayController = TextEditingController();
  final refByDoctorDisplayController = TextEditingController();

  String selectedTestDateISO = DateTime.now().toIso8601String();
  String selectedBillDateISO = DateTime.now().toIso8601String();

  List<DiagnosisType> _selectedDiagnosisTypes = [];
  FranchiseName? _selectedFranchise;
  Doctor? _selectedDoctor;

  final List<String> sexDropDownList = ["Male", "Female", "Others"];
  final List<String> billStatusList = [
    "Fully Paid",
    "Partially Paid",
    "Unpaid",
  ];

  bool _isDataInitialized = false; // Renamed for consistency
  bool _isSubmitting = false;

  bool get _isEditMode => widget.billId != null;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    billStatusController.addListener(() => setState(() {}));

    if (!_isEditMode) {
      final defaultDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
      dateOfTestController.text = defaultDate;
      dateOfBillController.text = defaultDate;
      billStatusController.text = billStatusList.first;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    patientNameController.dispose();
    patientAgeController.dispose();
    patientSexController.dispose();
    diagnosisTypeController.dispose();
    franchiseNameController.dispose();
    refByDoctorController.dispose();
    dateOfTestController.dispose();
    dateOfBillController.dispose();
    billStatusController.dispose();
    paidAmountController.dispose();
    discByDoctorController.dispose();
    discByCenterController.dispose();
    patientPhoneNumberController.dispose();
    diagnosisTypeDisplayController.dispose();
    franchiseNameDisplayController.dispose();
    refByDoctorDisplayController.dispose();
    super.dispose();
  }

  void _initializeData(Bill bill) {
    if (_isDataInitialized) return;

    final dateFormat = DateFormat('dd-MM-yyyy');
    patientNameController.text = bill.patientName;
    patientAgeController.text = bill.patientAge.toString();
    patientSexController.text = bill.patientSex;
    patientPhoneNumberController.text = bill.patientPhoneNumber.toString();
    dateOfTestController.text = dateFormat.format(bill.dateOfTest);
    dateOfBillController.text = dateFormat.format(bill.dateOfBill);
    selectedTestDateISO = bill.dateOfTest.toIso8601String();
    selectedBillDateISO = bill.dateOfBill.toIso8601String();
    billStatusController.text = bill.billStatus;
    paidAmountController.text = bill.paidAmount.toString();
    discByDoctorController.text = bill.discByDoctor.toString();
    discByCenterController.text = bill.discByCenter.toString();

    // Load multiple diagnosis types
    if (bill.diagnosisTypesOutput != null &&
        bill.diagnosisTypesOutput!.isNotEmpty) {
      _selectedDiagnosisTypes = bill.diagnosisTypesOutput!
          .map((dt) => DiagnosisType.fromJson(dt))
          .toList();
    }
    if (bill.referredByDoctorOutput != null) {
      _selectedDoctor = Doctor.fromJson(bill.referredByDoctorOutput!);
    }
    if (bill.franchiseNameOutput != null) {
      _selectedFranchise = FranchiseName.fromJson(bill.franchiseNameOutput!);
    }
    diagnosisTypeController.text = bill.diagnosisTypes.join(',');
    refByDoctorController.text = bill.referredByDoctor.toString();
    franchiseNameController.text = bill.franchiseName?.toString() ?? '';

    // Display diagnosis types as comma-separated list or chips
    diagnosisTypeDisplayController.text = _selectedDiagnosisTypes
        .map((dt) => '${dt.categoryName ?? "Unknown"} ${dt.name}')
        .join(', ');
    refByDoctorDisplayController.text =
        '${bill.referredByDoctorOutput?['first_name']} ${bill.referredByDoctorOutput?['last_name']}';
    franchiseNameDisplayController.text =
        bill.franchiseNameOutput?['franchise_name'] ?? '';

    _isDataInitialized = true;
  }

  void _updateDisplayControllers(
    List<DiagnosisType> diagnosisTypes,
    List<FranchiseName> franchises,
    List<Doctor> doctors,
  ) {
    if (!_isEditMode || !_isDataInitialized) return;
    try {
      // Load diagnosis types from controller (comma-separated IDs)
      if (diagnosisTypeController.text.isNotEmpty) {
        final diagnosisIds = diagnosisTypeController.text
            .split(',')
            .map((id) => int.tryParse(id.trim()))
            .whereType<int>()
            .toList();

        if (diagnosisIds.isNotEmpty) {
          _selectedDiagnosisTypes = diagnosisTypes
              .where((type) => diagnosisIds.contains(type.id))
              .toList();
          diagnosisTypeDisplayController.text = _selectedDiagnosisTypes
              .map((dt) => '${dt.categoryName ?? "Unknown"} ${dt.name}')
              .join(', ');
        }
      }

      if (refByDoctorController.text.isNotEmpty) {
        final doctorId = int.tryParse(refByDoctorController.text);
        if (doctorId != null) {
          _selectedDoctor = doctors.firstWhere((doc) => doc.id == doctorId);
          refByDoctorDisplayController.text =
              '${_selectedDoctor!.firstName} ${_selectedDoctor!.lastName ?? ''}';
        }
      }

      // Check if any selected diagnosis type is Franchise Lab
      bool hasFranchiseLab = _selectedDiagnosisTypes.any(
        (dt) => dt.categoryName?.toLowerCase() == 'franchise lab',
      );
      if (hasFranchiseLab && franchiseNameController.text.isNotEmpty) {
        _selectedFranchise = franchises.firstWhere(
          (f) => f.franchiseName == franchiseNameController.text,
        );
        franchiseNameDisplayController.text =
            "${_selectedFranchise!.franchiseName}, ${_selectedFranchise!.address}";
      }

      if (mounted) setState(() {});
    } catch (e) {
      debugPrint("Error updating display controllers: $e");
    }
  }

  /// Recalculates total amount based on selected diagnosis types
  void _updateTotalAmount() {
    // Calculate total from selected diagnosis types
    int total = _selectedDiagnosisTypes.fold(0, (sum, dt) => sum + dt.price);

    // The Bill model will recalculate when saved, but this helps user see the total
    // Note: There's no totalAmountController because total is calculated from diagnosis types
    debugPrint("Total amount recalculated: $total");
  }

  @override
  Widget build(BuildContext context) {
    final content = _isEditMode
        ? ref
              .watch(singleBillProvider(widget.billId!))
              .when(
                data: (bill) {
                  _initializeData(bill);
                  return _buildContent(bill: bill);
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, st) =>
                    _buildErrorWidget("Error loading bill: $err"),
              )
        : _buildContent();

    return WindowScaffold(child: content);
  }

  Widget _buildContent({Bill? bill}) {
    final isLargeScreen = MediaQuery.of(context).size.width > 1200;
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildBillHeaderCard(color: widget.themeColor, bill: bill),
          SizedBox(height: defaultHeight),
          Expanded(
            child: isLargeScreen
                ? _buildLargeScreenLayout(color: widget.themeColor)
                : Column(
                    children: [
                      _buildTabBar(color: widget.themeColor),
                      Expanded(
                        child: _buildTabContent(color: widget.themeColor),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillHeaderCard({required Color color, Bill? bill}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final lightThemeColor = Color.lerp(
      color,
      isDark ? Colors.black : Colors.white,
      isDark ? 0.3 : 0.2,
    )!;

    return TintedContainer(
      baseColor: color,
      height: 160,
      radius: defaultRadius,
      elevationLevel: 1,
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [color, lightThemeColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                _isEditMode ? Icons.edit_note : Icons.add_circle_outline,
                color: Colors.white,
                size: 36,
              ),
            ),
          ),
          SizedBox(width: defaultWidth),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _isEditMode ? 'Edit Bill' : 'Create New Bill',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : theme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: defaultHeight / 2),
                Row(
                  children: [
                    Text(
                      _isEditMode
                          ? 'Bill #${bill?.billNumber ?? 'N/A'}'
                          : 'Fill in the details to create a new bill',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? Colors.white70
                            : theme.colorScheme.onSurface.withValues(
                                alpha: 0.7,
                              ),
                      ),
                    ),
                    if (_isEditMode)
                      IconButton(
                        tooltip: "Copy bill number",
                        icon: Icon(
                          Icons.copy,
                          color: theme.colorScheme.outline,
                          size: 14,
                        ),
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(text: bill!.billNumber!),
                          );
                          _showSuccessSnackBar(
                            message:
                                "Bill number ${bill.billNumber} copied to clipboard.",
                          );
                        },
                      ),
                  ],
                ),
                SizedBox(height: defaultHeight / 2),
                Row(
                  children: [
                    _buildStatusBadge(
                      _isEditMode ? 'Edit Mode' : 'New Bill',
                      color,
                    ),
                    if (_isEditMode) ...[
                      SizedBox(width: defaultWidth / 2),
                      _buildStatusBadge(
                        bill?.billStatus ?? 'Unknown',
                        _getStatusColor(bill?.billStatus),
                      ),
                      SizedBox(width: defaultWidth / 2),
                      InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return UpdateReportDialog(
                                color: color,
                                billId: widget.billId!,
                              );
                            },
                          );
                        },
                        child: _buildStatusBadge(
                          bill != null && bill.reportUrl != null
                              ? 'Update Report'
                              : 'Upload Report',
                          color,
                        ),
                      ),
                      SizedBox(width: defaultWidth / 2),
                      if (bill != null && bill.reportUrl != null)
                        InkWell(
                          onTap: () async {
                            final uri = Uri.parse(bill.reportUrl!);
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri);
                            } else {
                              debugPrint('Could not launch ${bill.reportUrl}');
                            }
                          },
                          child: _buildStatusBadge("Download Report", color),
                        ),
                      SizedBox(width: defaultWidth / 2),
                      if (bill != null && bill.reportUrl != null)
                        Consumer(
                          builder: (context, ref, child) {
                            final reportAsyncValue = ref.watch(
                              getReportForBillProvider(bill.id!),
                            );
                            if (reportAsyncValue.hasValue &&
                                reportAsyncValue.value != null) {
                              final report = reportAsyncValue.value!;
                              return InkWell(
                                onTap: () {
                                  ref.read(
                                    deletePatientReportProvider((
                                      reportId: report.id,
                                      billId: bill.id!,
                                    )).future,
                                  );
                                },
                                child: _buildStatusBadge(
                                  "Delete Report",
                                  _getStatusColor("Unpaid"),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _isSubmitting ? null : () => _saveBill(bill),
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size(160, 50),
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(defaultRadius),
                  ),
                ),
                icon: _isSubmitting
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Icon(_isEditMode ? Icons.save : Icons.add, size: 16),
                label: Text(
                  _isSubmitting
                      ? 'Saving...'
                      : (_isEditMode ? 'Update Bill' : 'Create Bill'),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              if (_isEditMode) ...[
                SizedBox(height: defaultHeight / 2),
                OutlinedButton.icon(
                  onPressed: () => _deleteBill(bill!),
                  style: OutlinedButton.styleFrom(
                    fixedSize: const Size(160, 50),
                    foregroundColor: Theme.of(context).colorScheme.error,
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.error,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(defaultRadius),
                    ),
                  ),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar({required Color color}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: isDark
            ? Colors.white70
            : theme.colorScheme.onSurface.withValues(alpha: 0.7),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(
            height: 44,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_outline, size: 18),
                SizedBox(width: 8),
                Text('Patient'),
              ],
            ),
          ),
          Tab(
            height: 44,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.medical_services_outlined, size: 18),
                SizedBox(width: 8),
                Text('Diagnosis'),
              ],
            ),
          ),
          Tab(
            height: 44,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long, size: 18),
                SizedBox(width: 8),
                Text('Billing & Amount'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLargeScreenLayout({required Color color}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              _buildPatientDetailsCard(defaultColor: color),
              SizedBox(height: defaultHeight),
              _buildDiagnosisDetailsCard(defaultColor: color),
              const Spacer(),
            ],
          ),
        ),
        SizedBox(width: defaultWidth),
        Expanded(
          child: Column(
            children: [
              _buildBillingDetailsCard(defaultColor: color),
              SizedBox(height: defaultHeight),
              AnimatedSize(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOutCubic,
                child: billStatusController.text != "Unpaid"
                    ? _buildAmountDetailsCard(defaultColor: color)
                    : const SizedBox.shrink(),
              ),
              const Spacer(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabContent({required Color color}) {
    return TabBarView(
      controller: _tabController,
      children: [
        SingleChildScrollView(
          padding: EdgeInsets.all(defaultPadding),
          child: _buildPatientDetailsCard(defaultColor: color, height: 254),
        ),
        SingleChildScrollView(
          padding: EdgeInsets.all(defaultPadding),
          child: _buildDiagnosisDetailsCard(defaultColor: color, height: 318),
        ),
        SingleChildScrollView(
          padding: EdgeInsets.all(defaultPadding),
          child: Column(
            children: [
              _buildBillingDetailsCard(defaultColor: color, height: 254),
              SizedBox(height: defaultHeight),
              AnimatedSize(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOutCubic,
                child: billStatusController.text != "Unpaid"
                    ? _buildAmountDetailsCard(defaultColor: color, height: 254)
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPatientDetailsCard({
    required Color defaultColor,
    double? height,
  }) {
    return TintedContainer(
      baseColor: defaultColor,
      height: height ?? 258,
      radius: defaultRadius,
      elevationLevel: 1,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          children: [
            _buildCardHeader(
              icon: Icons.person_outline,
              title: 'Patient Details',
              color: defaultColor,
            ),
            SizedBox(height: defaultHeight),
            CustomTextField(
              label: 'Patient Name',
              controller: patientNameController,
              isRequired: true,
              tintColor: defaultColor,
            ),
            SizedBox(height: defaultHeight),
            Row(
              children: [
                Expanded(
                  child: SearchableDropdownField<String>(
                    label: 'Select Sex',
                    controller: patientSexController,
                    items: sexDropDownList,
                    color: defaultColor,
                    onSelected: (value) =>
                        setState(() => patientSexController.text = value),
                    valueMapper: (item) => item,
                    validator: (v) => v!.isEmpty ? 'Please select sex' : null,
                  ),
                ),
                SizedBox(width: defaultWidth / 2),
                Expanded(
                  child: CustomTextField(
                    label: 'Age',
                    controller: patientAgeController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    isRequired: true,
                    isNumeric: true,
                    tintColor: defaultColor,
                  ),
                ),
                SizedBox(width: defaultWidth / 2),
                Expanded(
                  child: CustomTextField(
                    label: 'Phone Number',
                    controller: patientPhoneNumberController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    isRequired: true,
                    isNumeric: true,
                    tintColor: defaultColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiagnosisDetailsCard({
    required Color defaultColor,
    double? height,
  }) {
    final diagnosisTypesAsync = ref.watch(diagnosisTypeProvider);
    final franchiseNamesAsync = ref.watch(franchiseProvider);
    final doctorsAsync = ref.watch(doctorsProvider);

    return TintedContainer(
      baseColor: defaultColor,
      height: height ?? 318,
      radius: defaultRadius,
      elevationLevel: 1,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          children: [
            _buildCardHeader(
              icon: Icons.medical_services_outlined,
              title: 'Diagnosis Details',
              color: defaultColor,
            ),
            SizedBox(height: defaultHeight),
            diagnosisTypesAsync.when(
              data: (types) {
                if (doctorsAsync.hasValue &&
                    franchiseNamesAsync.hasValue &&
                    _isEditMode &&
                    _isDataInitialized &&
                    diagnosisTypeDisplayController.text.isEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _updateDisplayControllers(
                      types,
                      franchiseNamesAsync.value!,
                      doctorsAsync.value!,
                    );
                  });
                }
                // Multi-select UI with chips
                return Column(
                  children: [
                    // Always show chips wrap (even if empty) to maintain consistent layout
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _selectedDiagnosisTypes.map((dt) {
                        return Chip(
                          label: Text(
                            '${dt.categoryName ?? "Unknown"} ${dt.name} (₹${dt.price})',
                            style: TextStyle(fontSize: 12),
                          ),
                          backgroundColor: defaultColor.withValues(alpha: 0.1),
                          deleteIconColor: defaultColor,
                          onDeleted: () {
                            setState(() {
                              _selectedDiagnosisTypes.remove(dt);
                              diagnosisTypeController.text =
                                  _selectedDiagnosisTypes
                                      .map((d) => d.id.toString())
                                      .join(',');
                              diagnosisTypeDisplayController.text =
                                  _selectedDiagnosisTypes
                                      .map((d) => '${d.category} ${d.name}')
                                      .join(', ');
                              // Recalculate total amount
                              _updateTotalAmount();
                            });
                          },
                        );
                      }).toList(),
                    ),
                    SizedBox(height: defaultHeight / 2),
                    SearchableDropdownField<DiagnosisType>(
                      label: 'Add Diagnosis Type',
                      controller:
                          TextEditingController(), // Empty controller for adding
                      items: types,
                      color: defaultColor,
                      valueMapper: (item) =>
                          '${item.categoryName ?? "Unknown"} ${item.name}, ₹${item.price}',
                      onSelected: (selected) {
                        setState(() {
                          // Add to list if not already present
                          if (!_selectedDiagnosisTypes.any(
                            (dt) => dt.id == selected.id,
                          )) {
                            _selectedDiagnosisTypes.add(selected);
                            diagnosisTypeController.text =
                                _selectedDiagnosisTypes
                                    .map((d) => d.id.toString())
                                    .join(',');
                            diagnosisTypeDisplayController
                                .text = _selectedDiagnosisTypes
                                .map(
                                  (d) =>
                                      '${d.categoryName ?? "Unknown"} ${d.name}',
                                )
                                .join(', ');

                            // Clear franchise if no Franchise Lab types
                            bool hasFranchiseLab = _selectedDiagnosisTypes.any(
                              (dt) =>
                                  dt.categoryName?.toLowerCase() ==
                                  'franchise lab',
                            );
                            if (!hasFranchiseLab) {
                              _selectedFranchise = null;
                              franchiseNameController.clear();
                              franchiseNameDisplayController.clear();
                            }

                            // Recalculate total amount
                            _updateTotalAmount();
                          }
                        });
                      },
                      validator: (v) => _selectedDiagnosisTypes.isEmpty
                          ? 'At least one diagnosis type is required'
                          : null,
                    ),
                  ],
                );
              },
              loading: () => _buildLoadingField(),
              error: (e, s) =>
                  _buildErrorField('Error loading diagnosis types'),
            ),
            SizedBox(height: defaultHeight),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              child:
                  _selectedDiagnosisTypes.any(
                    (dt) => dt.categoryName?.toLowerCase() == 'franchise lab',
                  )
                  ? Padding(
                      padding: EdgeInsets.only(bottom: defaultPadding),
                      child: franchiseNamesAsync.when(
                        data: (franchises) =>
                            SearchableDropdownField<FranchiseName>(
                              label: 'Franchise Name',
                              controller: franchiseNameDisplayController,
                              items: franchises,
                              color: defaultColor,
                              valueMapper: (item) =>
                                  "${item.franchiseName}, ${item.address}",
                              onSelected: (selected) {
                                setState(() {
                                  _selectedFranchise = selected;
                                  franchiseNameController.text = selected.id
                                      .toString();
                                  franchiseNameDisplayController.text =
                                      selected.franchiseName ?? '';
                                });
                              },
                              validator: (v) =>
                                  v!.isEmpty ? 'Franchise is required' : null,
                            ),
                        loading: () => _buildLoadingField(),
                        error: (e, s) =>
                            _buildErrorField('Error loading franchises'),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            doctorsAsync.when(
              data: (doctors) => SearchableDropdownField<Doctor>(
                label: 'Referred By Doctor',
                controller: refByDoctorDisplayController,
                items: doctors,
                color: defaultColor,
                valueMapper: (item) =>
                    '${item.firstName} ${item.lastName ?? ''}, ${item.address ?? ""}',
                onSelected: (selected) {
                  setState(() {
                    _selectedDoctor = selected;
                    refByDoctorController.text = selected.id.toString();
                    refByDoctorDisplayController.text =
                        '${selected.firstName} ${selected.lastName ?? ''}';
                  });
                },
                validator: (v) =>
                    v!.isEmpty ? 'Referring doctor is required' : null,
              ),
              loading: () => _buildLoadingField(),
              error: (e, s) => _buildErrorField('Error loading doctors'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillingDetailsCard({
    required Color defaultColor,
    double? height,
  }) {
    return TintedContainer(
      baseColor: defaultColor,
      height: height ?? 258,
      radius: defaultRadius,
      elevationLevel: 1,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          children: [
            _buildCardHeader(
              icon: Icons.receipt_long,
              title: 'Billing Details',
              color: defaultColor,
            ),
            SizedBox(height: defaultHeight),
            Row(
              children: [
                Expanded(
                  child: _buildDateSelector(
                    label: 'Date of Test',
                    controller: dateOfTestController,
                    color: defaultColor,
                    onDateSelected: (iso) => selectedTestDateISO = iso,
                    validator: (v) =>
                        v!.isEmpty ? 'Test date is required' : null,
                  ),
                ),
                SizedBox(width: defaultWidth / 2),
                Expanded(
                  child: _buildDateSelector(
                    label: 'Date of Bill',
                    controller: dateOfBillController,
                    color: defaultColor,
                    onDateSelected: (iso) => selectedBillDateISO = iso,
                    validator: (v) =>
                        v!.isEmpty ? 'Bill date is required' : null,
                  ),
                ),
              ],
            ),
            SizedBox(height: defaultHeight),
            SearchableDropdownField<String>(
              label: 'Bill Status',
              controller: billStatusController,
              items: billStatusList,
              color: defaultColor,
              valueMapper: (item) => item,
              onSelected: (value) =>
                  setState(() => billStatusController.text = value),
              validator: (v) => v!.isEmpty ? 'Bill status is required' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountDetailsCard({
    required Color defaultColor,
    double? height,
  }) {
    return TintedContainer(
      baseColor: defaultColor,
      height: height ?? 318,
      radius: defaultRadius,
      elevationLevel: 1,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          children: [
            _buildCardHeader(
              icon: Icons.payments_rounded,
              title: 'Amount Details',
              color: defaultColor,
            ),
            SizedBox(height: defaultHeight),
            // Display calculated total from selected diagnosis types
            Container(
              padding: EdgeInsets.all(defaultPadding),
              decoration: BoxDecoration(
                color: defaultColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: defaultColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Amount:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '₹${_selectedDiagnosisTypes.fold(0, (sum, dt) => sum + dt.price)}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: defaultColor,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: defaultHeight),
            CustomTextField(
              label: 'Paid Amount',
              controller: paidAmountController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              isRequired: true,
              isNumeric: true,
              tintColor: defaultColor,
            ),
            SizedBox(height: defaultHeight),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    label: "Doctor's Discount",
                    controller: discByDoctorController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    tintColor: defaultColor,
                    isNumeric: true,
                  ),
                ),
                SizedBox(width: defaultWidth),
                Expanded(
                  child: CustomTextField(
                    label: "Center's Discount",
                    controller: discByCenterController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    tintColor: defaultColor,
                    isNumeric: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Updated _saveBill to accept the original bill for preserving output fields
  Future<void> _saveBill(Bill? originalBill) async {
    if (billStatusController.text == "Unpaid") {
      paidAmountController.text = "0";
      discByCenterController.text = "0";
      discByDoctorController.text = "0";
    }
    if (discByCenterController.text.isEmpty) discByCenterController.text = "0";
    if (discByDoctorController.text.isEmpty) discByDoctorController.text = "0";

    if (!_formKey.currentState!.validate()) {
      _showErrorDialog(
        "Form Not Valid",
        "Please correct the errors before saving.",
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final billToSave = Bill(
      id: widget.billId,
      patientName: patientNameController.text,
      patientAge: int.parse(patientAgeController.text),
      patientSex: patientSexController.text,
      dateOfTest: DateTime.parse(selectedTestDateISO),
      dateOfBill: DateTime.parse(selectedBillDateISO),
      billStatus: billStatusController.text,
      paidAmount: int.parse(paidAmountController.text),
      discByCenter: int.parse(discByCenterController.text),
      discByDoctor: int.parse(discByDoctorController.text),
      patientPhoneNumber: patientPhoneNumberController.text,
      diagnosisTypes: _selectedDiagnosisTypes
          .map((dt) => dt.id)
          .whereType<int>()
          .toList(),
      referredByDoctor: int.parse(refByDoctorController.text),
      franchiseName: franchiseNameController.text.isNotEmpty
          ? int.parse(franchiseNameController.text)
          : null,
      diagnosisTypesOutput: originalBill?.diagnosisTypesOutput,
      referredByDoctorOutput: originalBill?.referredByDoctorOutput,
      franchiseNameOutput: originalBill?.franchiseNameOutput,
      testDoneBy: originalBill?.testDoneBy,
      centerDetail: originalBill?.centerDetail,
      billNumber: null,
      totalAmount: 0,
      incentiveAmount: 0,
    );

    try {
      if (_isEditMode) {
        final updatedBill = await ref.read(
          updateBillProvider(billToSave).future,
        );
        if (!mounted) return;
        _showSuccessSnackBar(
          message: 'Bill updated successfully: #${updatedBill.billNumber}',
        );
        Navigator.pop(context, updatedBill);
      } else {
        final newBill = await ref.read(createBillProvider(billToSave).future);
        if (!mounted) return;
        _showSuccessSnackBar(
          message: 'Bill created successfully: #${newBill.billNumber}',
        );
        Navigator.pop(context, newBill);
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog('Failed to Save Bill', e.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // Updated _deleteBill to accept the Bill object
  Future<void> _deleteBill(Bill bill) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Bill'),
        content: const Text(
          'Are you sure you want to delete this bill? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (shouldDelete == true) {
      try {
        await ref.read(deleteBillProvider(bill.id!).future);
        if (mounted) {
          _showSuccessSnackBar(message: "Bill deleted successfully");
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          _showErrorDialog('Delete Failed', e.toString());
        }
      }
    }
  }

  void _showErrorDialog(String title, String errorMessage) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) =>
          ErrorDialog(title: title, errorMessage: errorMessage),
    );
  }

  void _showSuccessSnackBar({required String message}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,

        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: defaultWidth / 2),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildCardHeader({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.all(defaultPadding * 1.5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(defaultRadius),
          topRight: Radius.circular(defaultRadius),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(defaultPadding),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(width: defaultWidth / 2),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector({
    required String label,
    required TextEditingController controller,
    required Function(String isoDate) onDateSelected,
    required Color color,
    String? Function(String?)? validator,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        HapticFeedback.selectionClick();
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
        );
        if (pickedDate != null) {
          final now = DateTime.now();
          final fullDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            now.hour,
            now.minute,
            now.second,
          );
          controller.text = DateFormat('dd-MM-yyyy').format(fullDateTime);
          onDateSelected(fullDateTime.toIso8601String());
        }
      },
      child: AbsorbPointer(
        child: CustomTextField(
          label: label,
          controller: controller,
          readOnly: true,
          validator: validator,
          tintColor: color,
          suffixIcon: Icon(
            Icons.calendar_month_rounded,
            size: 22,
            color: color.withValues(alpha: 0.9),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingField() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(defaultRadius),
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      ),
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _buildErrorField(String message) {
    final theme = Theme.of(context);
    return Container(
      height: 56,
      padding: EdgeInsets.symmetric(horizontal: defaultPadding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.2),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.4),
        ),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: theme.colorScheme.error,
              size: 20,
            ),
            SizedBox(width: defaultWidth),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Fully Paid':
        return Theme.of(context).colorScheme.secondary;
      case 'Partially Paid':
        return Colors.orange;
      case 'Unpaid':
        return Theme.of(context).colorScheme.error;
      default:
        return Colors.grey;
    }
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: defaultPadding * 1.25,
        vertical: defaultPadding * 0.5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(defaultRadius),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Error widget for when the bill fails to load
  Widget _buildErrorWidget(String message) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: TintedContainer(
          baseColor: theme.colorScheme.error,
          intensity: isDark ? 0.2 : 0.1,
          elevationLevel: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: theme.colorScheme.error,
              ),
              SizedBox(height: defaultHeight),
              Text(
                'Error Loading Bill',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: defaultHeight / 2),
              Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: defaultHeight),
              ElevatedButton.icon(
                onPressed: () {
                  if (widget.billId != null) {
                    ref.invalidate(singleBillProvider(widget.billId!));
                  }
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.themeColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
