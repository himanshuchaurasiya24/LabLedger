import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/main.dart';
import 'package:labledger/models/bill_model.dart';
import 'package:labledger/models/diagnosis_type_model.dart';
import 'package:labledger/models/doctors_model.dart';
import 'package:labledger/models/franchise_model.dart';
import 'package:labledger/providers/bills_provider.dart';
import 'package:labledger/providers/diagnosis_type_provider.dart';
import 'package:labledger/providers/doctor_provider.dart';
import 'package:labledger/providers/franchise_provider.dart';
import 'package:labledger/screens/ui_components/custom_text_field.dart';
import 'package:labledger/screens/ui_components/tinted_container.dart';
import 'package:labledger/screens/initials/window_scaffold.dart';

class AddBillScreen extends ConsumerStatefulWidget {
  final Bill? billData;
  final Color themeColor;

  const AddBillScreen({super.key, this.billData, required this.themeColor});

  @override
  ConsumerState<AddBillScreen> createState() => _AddBillScreenState();
}

class _AddBillScreenState extends ConsumerState<AddBillScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final patientNameController = TextEditingController();
  final patientAgeController = TextEditingController();
  final patientSexController = TextEditingController();
  final diagnosisTypeController = TextEditingController();
  final franchiseNameController = TextEditingController();
  final refByDoctorController = TextEditingController();
  final dateOfTestController = TextEditingController();
  final dateOfBillController = TextEditingController();
  final billStatusController = TextEditingController();
  final paidAmountController = TextEditingController();
  final discByDoctorController = TextEditingController();
  final discByCenterController = TextEditingController();

  // Display controllers for dropdowns
  final diagnosisTypeDisplayController = TextEditingController();
  final franchiseNameDisplayController = TextEditingController();
  final refByDoctorDisplayController = TextEditingController();

  String selectedTestDateISO = DateTime.now().toIso8601String();
  String selectedBillDateISO = DateTime.now().toIso8601String();

  DiagnosisType? _selectedDiagnosisType;
  FranchiseName? _selectedFranchise;
  Doctor? _selectedDoctor;

  final List<String> sexDropDownList = ["Male", "Female", "Others"];
  final List<String> billStatusList = [
    "Fully Paid",
    "Partially Paid",
    "Unpaid",
  ];

  bool _isControllersInitialized = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    billStatusController.addListener(() => setState(() {}));

    if (widget.billData != null) {
      _preFillData();
    } else {
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
    diagnosisTypeDisplayController.dispose();
    franchiseNameDisplayController.dispose();
    refByDoctorDisplayController.dispose();
    super.dispose();
  }

  void _preFillData() {
    if (widget.billData == null || _isControllersInitialized) return;
    final bill = widget.billData!;
    final dateFormat = DateFormat('dd-MM-yyyy');
    patientNameController.text = bill.patientName;
    patientAgeController.text = bill.patientAge.toString();
    patientSexController.text = bill.patientSex;
    diagnosisTypeController.text = bill.diagnosisType.toString();
    franchiseNameController.text = bill.franchiseName ?? '';
    refByDoctorController.text = bill.referredByDoctor.toString();
    dateOfTestController.text = dateFormat.format(bill.dateOfTest);
    dateOfBillController.text = dateFormat.format(bill.dateOfBill);
    selectedTestDateISO = bill.dateOfTest.toIso8601String();
    selectedBillDateISO = bill.dateOfBill.toIso8601String();
    billStatusController.text = bill.billStatus;
    paidAmountController.text = bill.paidAmount.toString();
    discByDoctorController.text = bill.discByDoctor.toString();
    discByCenterController.text = bill.discByCenter.toString();
    _isControllersInitialized = true;
  }

  void _updateDisplayControllers(
    List<DiagnosisType> diagnosisTypes,
    List<FranchiseName> franchises,
    List<Doctor> doctors,
  ) {
    if (widget.billData == null || !_isControllersInitialized) return;

    try {
      // Update diagnosis type display
      if (diagnosisTypeController.text.isNotEmpty) {
        final diagnosisId = int.tryParse(diagnosisTypeController.text);
        if (diagnosisId != null) {
          _selectedDiagnosisType = diagnosisTypes.firstWhere(
            (type) => type.id == diagnosisId,
            orElse: () => throw Exception('Diagnosis type not found'),
          );
          diagnosisTypeDisplayController.text =
              '${_selectedDiagnosisType!.category} ${_selectedDiagnosisType!.name}';
        }
      }

      // Update doctor display
      if (refByDoctorController.text.isNotEmpty) {
        final doctorId = int.tryParse(refByDoctorController.text);
        if (doctorId != null) {
          _selectedDoctor = doctors.firstWhere(
            (doc) => doc.id == doctorId,
            orElse: () => throw Exception('Doctor not found'),
          );
          refByDoctorDisplayController.text =
              '${_selectedDoctor!.firstName} ${_selectedDoctor!.lastName ?? ''}';
        }
      }

      // Update franchise display if applicable
      if (_selectedDiagnosisType?.category == 'Franchise Lab' &&
          franchiseNameController.text.isNotEmpty) {
        try {
          _selectedFranchise = franchises.firstWhere(
            (f) => f.franchiseName == franchiseNameController.text,
            orElse: () => throw Exception('Franchise not found'),
          );
          franchiseNameDisplayController.text =
              "${_selectedFranchise!.franchiseName}, ${_selectedFranchise!.address}";
        } catch (e) {
          debugPrint("Franchise not found: ${franchiseNameController.text}");
        }
      }

      // Trigger rebuild to show updated values
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint("Error updating display controllers: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.billData != null;
    final isLargeScreen = MediaQuery.of(context).size.width > 1200;
    final Color finalThemeColor = widget.themeColor;

    return WindowScaffold(
      child: Form(
        // Wrap the entire content in a Form
        key: _formKey,
        child: Column(
          children: [
            _buildBillHeaderCard(isEditing, color: finalThemeColor),
            SizedBox(height: defaultHeight),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (isLargeScreen) {
                    return _buildLargeScreenLayout(color: finalThemeColor);
                  } else {
                    return Column(
                      children: [
                        _buildTabBar(color: finalThemeColor),
                        Expanded(
                          child: _buildTabContent(color: finalThemeColor),
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- UI BUILDING BLOCKS ---

  Widget _buildBillHeaderCard(bool isEditing, {required Color color}) {
    // This widget remains the same as before
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
                isEditing ? Icons.edit_note : Icons.add_circle_outline,
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
                  isEditing ? 'Edit Bill' : 'Create New Bill',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : theme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: defaultHeight / 2),
                Text(
                  isEditing
                      ? 'Bill #${widget.billData?.billNumber ?? 'N/A'}'
                      : 'Fill in the details to create a new bill',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? Colors.white70
                        : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                SizedBox(height: defaultHeight / 2),
                Row(
                  children: [
                    _buildStatusBadge(
                      isEditing ? 'Edit Mode' : 'New Bill',
                      color,
                    ),
                    if (isEditing) ...[
                      SizedBox(width: defaultWidth / 2),
                      _buildStatusBadge(
                        widget.billData?.billStatus ?? 'Unknown',
                        _getStatusColor(widget.billData?.billStatus),
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
                onPressed: _isSubmitting ? null : _saveBill,
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(160, 50),
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
                    : Icon(isEditing ? Icons.save : Icons.add, size: 16),
                label: Text(
                  _isSubmitting
                      ? 'Saving...'
                      : (isEditing ? 'Update Bill' : 'Create Bill'),
                  style: TextStyle(fontSize: 16),
                ),
              ),
              if (isEditing) ...[
                SizedBox(height: defaultHeight / 2),
                OutlinedButton.icon(
                  onPressed: () => _deleteBill(widget.billData!.id!),

                  style: OutlinedButton.styleFrom(
                    fixedSize: Size(160, 50),

                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
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
    // This widget remains the same
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

  /// **NEW:** The 2x2 grid layout for large screens.
  Widget _buildLargeScreenLayout({required Color color}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column
        Expanded(
          child: Column(
            children: [
              _buildPatientDetailsCard(defaultColor: color),
              SizedBox(height: defaultHeight),
              _buildDiagnosisDetailsCard(defaultColor: color),
              const Spacer(), // Pushes cards up
            ],
          ),
        ),
        SizedBox(width: defaultWidth),
        // Right Column
        Expanded(
          child: Column(
            children: [
              _buildBillingDetailsCard(defaultColor: color),
              SizedBox(height: defaultHeight),
              // The Amount card is conditionally visible
              AnimatedSize(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOutCubic,
                child: billStatusController.text != "Unpaid"
                    ? _buildAmountDetailsCard(defaultColor: color)
                    : const SizedBox.shrink(),
              ),
              const Spacer(), // Pushes cards up
            ],
          ),
        ),
      ],
    );
  }

  /// **UPDATED:** Tab content for small screens.
  Widget _buildTabContent({required Color color}) {
    return TabBarView(
      controller: _tabController,
      children: [
        // Tab 1: Patient
        SingleChildScrollView(
          padding: EdgeInsets.all(defaultPadding),
          child: _buildPatientDetailsCard(defaultColor: color, height: 254),
        ),
        // Tab 2: Diagnosis
        SingleChildScrollView(
          padding: EdgeInsets.all(defaultPadding),
          child: _buildDiagnosisDetailsCard(defaultColor: color, height: 318),
        ),
        // Tab 3: Billing & Amount combined
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

  // --- FORM CARDS ---

  Widget _buildPatientDetailsCard({
    required Color defaultColor,
    double? height,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = defaultColor;

    return TintedContainer(
      baseColor: color,
      height: height ?? 254,
      radius: defaultRadius,
      // intensity: isDark ? 0.1 : 0.05,
      elevationLevel: 1,
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildCardHeader(
              theme: theme,
              color: color,
              isDark: isDark,
              icon: Icons.person_outline,
              title: 'Patient Details',
            ),
            SizedBox(height: defaultHeight),
            CustomTextField(
              label: 'Patient Name',
              controller: patientNameController,
              isRequired: true,
              tintColor: color,
            ),
            SizedBox(height: defaultHeight),
            Row(
              children: [
                Expanded(
                  child: _buildPopupMenuField<String>(
                    label: 'Select Sex',
                    controller: patientSexController,
                    items: sexDropDownList,
                    color: color,
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
                    tintColor: color,
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = defaultColor;
    final diagnosisTypesAsync = ref.watch(diagnosisTypeProvider);
    final franchiseNamesAsync = ref.watch(franchiseNamesProvider);
    final doctorsAsync = ref.watch(doctorsProvider);

    return TintedContainer(
      baseColor: color,
      height: height ?? 318,
      radius: defaultRadius,
      // intensity: isDark ? 0.1 : 0.05,
      elevationLevel: 1,
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildCardHeader(
              theme: theme,
              color: color,
              isDark: isDark,
              icon: Icons.medical_services_outlined,
              title: 'Diagnosis Details',
            ),
            SizedBox(height: defaultHeight),
            diagnosisTypesAsync.when(
              data: (types) {
                if (doctorsAsync.hasValue &&
                    franchiseNamesAsync.hasValue &&
                    widget.billData != null &&
                    _isControllersInitialized &&
                    diagnosisTypeDisplayController.text.isEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _updateDisplayControllers(
                      types,
                      franchiseNamesAsync.value!,
                      doctorsAsync.value!,
                    );
                  });
                }

                return _buildPopupMenuField<DiagnosisType>(
                  label: 'Diagnosis Type',
                  controller: diagnosisTypeDisplayController,
                  items: types,
                  color: color,
                  valueMapper: (item) =>
                      '${item.category} ${item.name}, ₹${item.price}',
                  onSelected: (selected) {
                    setState(() {
                      _selectedDiagnosisType = selected;
                      diagnosisTypeController.text = selected.id.toString();
                      diagnosisTypeDisplayController.text =
                          '${selected.category} ${selected.name}, ₹${selected.price}';
                      if (selected.category != 'Franchise Lab') {
                        _selectedFranchise = null;
                        franchiseNameController.clear();
                        franchiseNameDisplayController.clear();
                      }
                    });
                  },
                  validator: (v) =>
                      v!.isEmpty ? 'Diagnosis type is required' : null,
                );
              },
              loading: () => _buildLoadingField(),
              error: (e, s) =>
                  _buildErrorField('Error loading diagnosis types'),
            ),
            SizedBox(height: defaultHeight),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              child: _selectedDiagnosisType?.category == 'Franchise Lab'
                  ? Padding(
                      padding: EdgeInsets.only(bottom: defaultPadding),
                      child: franchiseNamesAsync.when(
                        data: (franchises) => _buildPopupMenuField<FranchiseName>(
                          label: 'Franchise Name',
                          controller: franchiseNameDisplayController,
                          items: franchises,
                          color: color,
                          valueMapper: (item) =>
                              "${item.franchiseName}, ${item.address}",
                          onSelected: (selected) {
                            setState(() {
                              _selectedFranchise = selected;
                              franchiseNameController.text =
                                  selected.franchiseName!;
                              franchiseNameDisplayController.text =
                                  "${selected.franchiseName}, ${selected.address}";
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
              data: (doctors) => _buildPopupMenuField<Doctor>(
                label: 'Referred By Doctor',
                controller: refByDoctorDisplayController,
                items: doctors,
                color: color,
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

  /// **UPDATED:** Now only contains billing info.
  Widget _buildBillingDetailsCard({
    required Color defaultColor,
    double? height,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = defaultColor;

    return TintedContainer(
      baseColor: color,
      height: height ?? 254,
      radius: defaultRadius,
      // intensity: isDark ? 0.1 : 0.05,
      elevationLevel: 1,
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildCardHeader(
              theme: theme,
              color: color,
              isDark: isDark,
              icon: Icons.receipt_long,
              title: 'Billing Details',
            ),
            SizedBox(height: defaultHeight),
            Row(
              children: [
                Expanded(
                  child: _buildDateSelector(
                    label: 'Date of Test',
                    controller: dateOfTestController,
                    color: color,
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
                    color: color,
                    onDateSelected: (iso) => selectedBillDateISO = iso,
                    validator: (v) =>
                        v!.isEmpty ? 'Bill date is required' : null,
                  ),
                ),
              ],
            ),
            SizedBox(height: defaultHeight),
            _buildPopupMenuField<String>(
              label: 'Bill Status',
              controller: billStatusController,
              items: billStatusList,
              color: color,
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

  /// **NEW:** Card dedicated to amount fields.
  Widget _buildAmountDetailsCard({
    required Color defaultColor,
    double? height,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = defaultColor;
    return TintedContainer(
      baseColor: color,
      height: height ?? 318,
      radius: defaultRadius,
      // intensity: isDark ? 0.1 : 0.05,
      elevationLevel: 1,
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildCardHeader(
              theme: theme,
              color: color,
              isDark: isDark,
              icon: Icons.payments_rounded,
              title: 'Amount Details',
            ),
            SizedBox(height: defaultHeight),
            CustomTextField(
              label: 'Paid Amount',
              controller: paidAmountController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              isRequired: true,
              isNumeric: true,
              tintColor: color,
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
                    tintColor: color,
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
                    tintColor: color,
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

  // --- HELPER WIDGETS ---

  Widget _buildCardHeader({
    required ThemeData theme,
    required Color color,
    required bool isDark,
    required IconData icon,
    required String title,
  }) {
    // This widget remains the same
    return Container(
      padding: EdgeInsets.all(defaultPadding * 2),
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
              color: isDark ? Colors.white : theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  /// A unified, searchable popup menu field.
  Widget _buildPopupMenuField<T>({
    required String label,
    required TextEditingController controller,
    required List<T> items,
    required String Function(T) valueMapper,
    required Function(T) onSelected,
    required Color color,
    String? Function(String?)? validator,
  }) {
    final GlobalKey key = GlobalKey();

    return InkWell(
      key: key,
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        if (items.isEmpty) return;
        HapticFeedback.selectionClick();
        _showSearchableMenu<T>(
          context: context,
          anchorKey: key,
          color: color,
          items: items,
          valueMapper: valueMapper,
          onSelected: onSelected,
        );
      },
      child: AbsorbPointer(
        child: CustomTextField(
          label: label,
          controller: controller,
          readOnly: true,
          validator: validator,
          tintColor: color,
          suffixIcon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: color.withValues(alpha: 0.7),
            size: 24,
          ),
        ),
      ),
    );
  }

  /// **FIXED:** Shows a popup menu with a working search field.
  Future<void> _showSearchableMenu<T>({
    required BuildContext context,
    required GlobalKey anchorKey,
    required Color color,
    required List<T> items,
    required String Function(T) valueMapper,
    required Function(T) onSelected,
  }) async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final RenderBox renderBox =
        anchorKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final position = renderBox.localToGlobal(Offset.zero);

    final RelativeRect menuPosition = RelativeRect.fromLTRB(
      position.dx,
      position.dy + size.height + 4,
      position.dx + size.width,
      position.dy,
    );

    final Color menuBackgroundColor = isDark
        ? Color.alphaBlend(
            color.withValues(alpha: 0.25),
            theme.colorScheme.surface,
          )
        : Color.alphaBlend(
            color.withValues(alpha: 0.1),
            theme.colorScheme.surface,
          );
    final Color menuBorderColor = color.withValues(alpha: isDark ? 0.5 : 0.4);

    await showMenu<T>(
      context: context,
      position: menuPosition,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.2),
      color: menuBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: menuBorderColor, width: 1),
      ),
      items: [
        PopupMenuItem<T>(
          enabled: false,
          child: _SearchableMenuContent<T>(
            items: items,
            valueMapper: valueMapper,
            onSelected: onSelected,
            color: color,
            parentSize: size,
            menuBorderColor: menuBorderColor,
          ),
        ),
      ],
    );
  }

  // Other helper widgets (_buildDateSelector, _buildLoadingField, etc.) remain the same...
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
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      ),
      child: Center(
        child: SizedBox(
          width: defaultWidth,
          height: defaultHeight,
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

  // --- FORM ACTIONS AND HELPERS ---

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Fully Paid':
        return Colors.green;
      case 'Partially Paid':
        return Colors.orange;
      case 'Unpaid':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: defaultPadding / 0.75,
        vertical: defaultPadding / 3,
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

  Future<void> _saveBill() async {
    // This function remains the same
    if (billStatusController.text == "Unpaid") {
      paidAmountController.text = "0";
      discByCenterController.text = "0";
      discByDoctorController.text = "0";
    }

    if (discByCenterController.text.isEmpty) discByCenterController.text = "0";
    if (discByDoctorController.text.isEmpty) discByDoctorController.text = "0";

    if (!_formKey.currentState!.validate()) {
      _showSnackBar(
        message: "Please correct the errors in the form.",
        backgroundColor: Colors.red,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final billDataMap = {
      'patient_name': patientNameController.text,
      'patient_age': int.parse(patientAgeController.text),
      'patient_sex': patientSexController.text,
      'diagnosis_type': int.parse(diagnosisTypeController.text),
      'franchise_name': franchiseNameController.text.isEmpty
          ? null
          : franchiseNameController.text,
      'referred_by_doctor': int.parse(refByDoctorController.text),
      'center_detail': 1, // Adjust this based on your requirements
      'date_of_test': selectedTestDateISO,
      'date_of_bill': selectedBillDateISO,
      'bill_status': billStatusController.text,
      'paid_amount': int.parse(paidAmountController.text),
      'disc_by_center': int.parse(discByCenterController.text),
      'disc_by_doctor': int.parse(discByDoctorController.text),
      'total_amount':
          _selectedDiagnosisType?.price ?? widget.billData?.totalAmount ?? 0,
      'incentive_amount': 0,
    };

    final bill = Bill.fromJson({...billDataMap, 'id': widget.billData?.id});

    try {
      if (widget.billData != null) {
        final updatedBill = await ref.read(updateBillProvider(bill).future);
        if (!mounted) return;
        _showSnackBar(
          message: 'Bill updated successfully: ${updatedBill.billNumber}',
          backgroundColor: Colors.green,
        );
        Navigator.pop(context, updatedBill);
      } else {
        final newBill = await ref.read(createBillProvider(bill).future);
        if (!mounted) return;
        _showSnackBar(
          message: 'Bill created successfully: ${newBill.billNumber}',
          backgroundColor: Colors.green,
        );
        Navigator.pop(context, newBill);
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(
        message: 'Failed to save bill: $e',
        backgroundColor: Colors.red,
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _deleteBill(int id) async {
    // This function remains the same
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (shouldDelete == true) {
      ref.read(deleteBillProvider(id));
      if (mounted) {
        _showSnackBar(
          message: "Bill deleted successfully",
          backgroundColor: Colors.red.withValues(alpha: 0.9),
        );
        navigatorKey.currentState?.pop();
      }
    }
  }

  void _showSnackBar({
    required String message,
    required Color backgroundColor,
  }) {
    // This function remains the same
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              backgroundColor == Colors.green
                  ? Icons.check_circle
                  : Icons.error,
              color: Colors.white,
            ),
            SizedBox(width: defaultWidth / 2),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

/// **NEW WIDGET:** A dedicated StatefulWidget to manage the search state.
/// This is more robust than using a StatefulBuilder for this task.
class _SearchableMenuContent<T> extends StatefulWidget {
  const _SearchableMenuContent({
    super.key,
    required this.items,
    required this.valueMapper,
    required this.onSelected,
    required this.color,
    required this.parentSize,
    required this.menuBorderColor,
  });

  final List<T> items;
  final String Function(T) valueMapper;
  final Function(T) onSelected;
  final Color color;
  final Size parentSize;
  final Color menuBorderColor;

  @override
  State<_SearchableMenuContent<T>> createState() =>
      _SearchableMenuContentState<T>();
}

class _SearchableMenuContentState<T> extends State<_SearchableMenuContent<T>> {
  List<T> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
  }

  void _filterItems(String query) {
    setState(() {
      _filteredItems = widget.items
          .where(
            (item) => widget
                .valueMapper(item)
                .toLowerCase()
                .contains(query.toLowerCase()),
          )
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: widget.parentSize.width,
      height: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.all(defaultPadding),
            child: TextField(
              onChanged: _filterItems,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(Icons.search, size: 18, color: widget.color),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  vertical: defaultHeight / 2,
                  horizontal: defaultWidth / 2,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(defaultRadius),
                  borderSide: BorderSide(color: widget.menuBorderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(defaultRadius),
                  borderSide: BorderSide(color: widget.color, width: 1.5),
                ),
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredItems.length,
              itemBuilder: (context, index) {
                final item = _filteredItems[index];
                return ListTile(
                  title: Text(
                    widget.valueMapper(item),
                    style: theme.textTheme.bodyMedium,
                  ),
                  onTap: () {
                    widget.onSelected(item);
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
