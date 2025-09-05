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
import 'package:labledger/providers/franchise_provider.dart';
import 'package:labledger/screens/ui_components/custom_text_field.dart';
import 'package:labledger/screens/ui_components/window_scaffold.dart';

const _spacing = 16.0;
const _cardSpacing = 20.0;

class AddBillScreen extends ConsumerStatefulWidget {
  final Bill? billData;

  const AddBillScreen({super.key, this.billData});

  @override
  ConsumerState<AddBillScreen> createState() => _AddBillScreenState();
}

class _AddBillScreenState extends ConsumerState<AddBillScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _slideController;
  late AnimationController _fadeController;

  // Controllers for storing IDs or simple text values
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

  // Controllers for displaying user-friendly text in popup fields
  final diagnosisTypeDisplayController = TextEditingController();
  final franchiseNameDisplayController = TextEditingController();
  final refByDoctorDisplayController = TextEditingController();

  // State variables for API submission
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

  // Flag to track if data has been loaded to prevent re-initialization
  bool _dataLoaded = false;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Add listener to rebuild UI when bill status changes (for showing/hiding amount fields)
    billStatusController.addListener(() => setState(() {}));

    // If we are editing, pre-fill the form fields right away
    if (widget.billData != null) {
      _preFillData();
    }

    // Start animations
    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();

    // Dispose all controllers to prevent memory leaks
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

  /// Pre-fill form data when editing. This populates controllers with initial values.
  void _preFillData() {
    if (widget.billData == null || _dataLoaded) return;

    final bill = widget.billData!;
    final dateFormat = DateFormat('dd-MM-yyyy');

    // Fill basic patient info
    patientNameController.text = bill.patientName;
    patientAgeController.text = bill.patientAge.toString();
    patientSexController.text = bill.patientSex;

    // Fill IDs for dropdowns/popups
    diagnosisTypeController.text = bill.diagnosisType.toString();
    franchiseNameController.text = bill.franchiseName ?? '';
    refByDoctorController.text = bill.referredByDoctor.toString();

    // Fill dates and update ISO strings for API submission
    dateOfTestController.text = dateFormat.format(bill.dateOfTest);
    dateOfBillController.text = dateFormat.format(bill.dateOfBill);
    selectedTestDateISO = bill.dateOfTest.toIso8601String();
    selectedBillDateISO = bill.dateOfBill.toIso8601String();

    // Fill bill status and amounts
    billStatusController.text = bill.billStatus;
    paidAmountController.text = bill.paidAmount.toString();
    discByDoctorController.text = bill.discByDoctor.toString();
    discByCenterController.text = bill.discByCenter.toString();

    // Set flag to true to avoid re-filling data on subsequent builds
    _dataLoaded = true;
  }

  /// Update display controllers after async data (diagnosis types, doctors) has been loaded.
  void _updateDisplayControllers(
    List<DiagnosisType> diagnosisTypes,
    List<FranchiseName> franchises,
    List<Doctor> doctors,
  ) {
    if (widget.billData == null) return;

    // Find and set the selected diagnosis type object and its display text
    _selectedDiagnosisType = diagnosisTypes.firstWhere(
      (type) => type.id.toString() == diagnosisTypeController.text,
      orElse: () => diagnosisTypes.first,
    );
    diagnosisTypeDisplayController.text =
        '${_selectedDiagnosisType!.category} ${_selectedDiagnosisType!.name}';

    // Find and set franchise if applicable
    if (franchiseNameController.text.isNotEmpty) {
      _selectedFranchise = franchises.firstWhere(
        (franchise) => franchise.franchiseName == franchiseNameController.text,
        orElse: () => franchises.isNotEmpty ? franchises.first : franchises[0],
      );
      if (_selectedFranchise != null) {
        franchiseNameDisplayController.text =
            "${_selectedFranchise!.franchiseName}, ${_selectedFranchise!.address}";
      }
    }

    // Find and set the selected doctor object and its display text
    _selectedDoctor = doctors.firstWhere(
      (doctor) => doctor.id.toString() == refByDoctorController.text,
      orElse: () => doctors.first,
    );
    refByDoctorDisplayController.text =
        '${_selectedDoctor!.firstName} ${_selectedDoctor!.lastName ?? ''}';
  }

  /// Modern dropdown with improved styling
  Widget _buildPopupMenuField<T>({
    required BuildContext context,
    required String label,
    required TextEditingController displayController,
    required List<T> items,
    required String Function(T item) valueMapper,
    required Function(T item) onSelected,
    String? Function(String?)? validator,
  }) {
    final GlobalKey key = GlobalKey();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final Color baseColor = theme.colorScheme.secondary;

    // Modern menu background color
    final Color menuBackgroundColor = (baseColor is MaterialColor)
        ? (isDark
              ? baseColor.shade900.withValues(alpha: 0.95)
              : baseColor.shade50)
        : (isDark
              ? Color.alphaBlend(
                  baseColor.withValues(alpha: 0.4),
                  theme.colorScheme.surface,
                )
              : Color.alphaBlend(
                  baseColor.withValues(alpha: 0.1),
                  theme.colorScheme.surface,
                ));

    final Color menuBorderColor = (baseColor is MaterialColor)
        ? (isDark ? baseColor.shade200 : baseColor.shade600)
        : HSLColor.fromColor(baseColor).withLightness(0.5).toColor();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        key: key,
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          if (items.isEmpty) return;
          HapticFeedback.selectionClick();
          final RenderBox renderBox =
              key.currentContext!.findRenderObject() as RenderBox;
          final size = renderBox.size;
          final position = renderBox.localToGlobal(Offset.zero);

          final selected = await showMenu<T>(
            context: context,
            position: RelativeRect.fromLTRB(
              position.dx,
              position.dy + size.height + 4,
              position.dx + size.width,
              position.dy,
            ),
            elevation: 0,
            shadowColor: Colors.transparent,
            color: menuBackgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(defaultRadius),
              side: BorderSide(color: menuBorderColor.withValues(alpha: 0.3)),
            ),
            items: items.map((item) {
              return PopupMenuItem<T>(
                value: item,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 4,
                  ),
                  child: Text(
                    valueMapper(item),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              );
            }).toList(),
          );

          if (selected != null) {
            onSelected(selected);
          }
        },
        child: AbsorbPointer(
          child: CustomTextField(
            label: label,
            controller: displayController,
            readOnly: true,
            validator: validator,
            suffixIcon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.7),
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the modern date selector widget.
  Widget _buildDateSelector({
    required String label,
    required TextEditingController controller,
    required Function(String isoDate) onDateSelected,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          HapticFeedback.selectionClick();

          final pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime(2100),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  dialogTheme: DialogThemeData(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                child: child!,
              );
            },
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
            suffixIcon: Icon(
              Icons.calendar_month_rounded,
              size: 22,
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.7),
            ),
          ),
        ),
      ),
    );
  }

  /// Save or Update bill logic
  Future<void> _saveBill() async {
    // If bill is unpaid, reset amount fields to 0
    if (billStatusController.text == "Unpaid") {
      paidAmountController.text = "0";
      discByCenterController.text = "0";
      discByDoctorController.text = "0";
    }

    if (!_formKey.currentState!.validate()) {
      return; // If form is not valid, do nothing.
    }

    // Prepare data payload for the API
    final billData = {
      'patient_name': patientNameController.text,
      'patient_age': int.parse(patientAgeController.text),
      'patient_sex': patientSexController.text,
      'diagnosis_type': int.parse(diagnosisTypeController.text),
      'franchise_name': franchiseNameController.text,
      'referred_by_doctor': int.parse(refByDoctorController.text),
      'date_of_test': DateTime.parse(selectedTestDateISO).toString(),
      'date_of_bill': DateTime.parse(selectedBillDateISO).toString(),
      'bill_status': billStatusController.text,
      'paid_amount': int.parse(paidAmountController.text),
      'disc_by_center': int.parse(discByCenterController.text),
      'disc_by_doctor': int.parse(discByDoctorController.text),
    };

    // Create a Bill object, preserving the ID if we are editing
    final bill = Bill.fromJson({...billData, 'id': widget.billData?.id});

    try {
      if (widget.billData != null) {
        // --- UPDATE LOGIC ---
        final updatedBill = await ref.read(updateBillProvider(bill).future);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text('Bill updated successfully: ${updatedBill.billNumber}'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
        Navigator.pop(context, updatedBill);
      } else {
        // --- CREATE LOGIC ---
        final newBill = await ref.read(createBillProvider(bill).future);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text('Bill created successfully: ${newBill.billNumber}'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
        Navigator.pop(context, newBill);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text('Failed: $e')),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.billData != null;
    final screenSize = MediaQuery.of(context).size;
    final isLargeScreen = screenSize.width > 1400;
    final isMediumScreen = screenSize.width > 1000;
    final isSmallScreen = screenSize.width < 800;

    return WindowScaffold(
      child: Column(
        children: [
          Expanded(
            child: isSmallScreen
                ? _buildScrollableContent(
                    context,
                    isLargeScreen,
                    isMediumScreen,
                  )
                : _buildCenteredContent(context, isLargeScreen, isMediumScreen),
          ),

          // Bottom Action Bar
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isLargeScreen ? 48 : (isMediumScreen ? 32 : 24),
              vertical: 16,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!isSmallScreen) ...[
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Container(
                  constraints: BoxConstraints(
                    minWidth: isSmallScreen ? double.infinity : 160,
                  ),
                  child: ElevatedButton(
                    onPressed: _saveBill,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isEditing ? Icons.save_as_rounded : Icons.add_rounded,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isEditing ? 'Update Bill' : 'Add Bill',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScrollableContent(
    BuildContext context,
    bool isLargeScreen,
    bool isMediumScreen,
  ) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(24),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
            .animate(
              CurvedAnimation(
                parent: _slideController,
                curve: Curves.easeOutCubic,
              ),
            ),
        child: FadeTransition(
          opacity: _fadeController,
          child: Form(
            key: _formKey,
            child: _buildFormContent(context, isLargeScreen, isMediumScreen),
          ),
        ),
      ),
    );
  }

  Widget _buildCenteredContent(
    BuildContext context,
    bool isLargeScreen,
    bool isMediumScreen,
  ) {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Container(
          width: isLargeScreen ? 1200 : (isMediumScreen ? 900 : 700),
          padding: EdgeInsets.symmetric(
            horizontal: isLargeScreen ? 48 : (isMediumScreen ? 32 : 24),
            vertical: 32,
          ),
          child: SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(0, 0.1),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: _slideController,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: FadeTransition(
              opacity: _fadeController,
              child: Form(
                key: _formKey,
                child: _buildFormContent(
                  context,
                  isLargeScreen,
                  isMediumScreen,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormContent(
    BuildContext context,
    bool isLargeScreen,
    bool isMediumScreen,
  ) {
    if (isLargeScreen) {
      // Three-column layout for large screens
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                _buildPatientDetailsCard(context),
                SizedBox(height: _cardSpacing),
                _buildDiagnosisDetailsCard(context),
              ],
            ),
          ),
          SizedBox(width: _cardSpacing),
          Expanded(
            child: Column(
              children: [
                _buildBillingDetailsCard(context),
                SizedBox(height: _cardSpacing),
                AnimatedSize(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOutCubic,
                  child: billStatusController.text != "Unpaid"
                      ? _buildAmountDetailsCard(context)
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      );
    } else if (isMediumScreen) {
      // Two-column layout for medium screens
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                _buildPatientDetailsCard(context),
                SizedBox(height: _cardSpacing),
                _buildDiagnosisDetailsCard(context),
              ],
            ),
          ),
          SizedBox(width: _cardSpacing),
          Expanded(
            child: Column(
              children: [
                _buildBillingDetailsCard(context),
                SizedBox(height: _cardSpacing),
                AnimatedSize(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOutCubic,
                  child: billStatusController.text != "Unpaid"
                      ? _buildAmountDetailsCard(context)
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      // Single column layout for small screens
      return Column(
        children: [
          _buildPatientDetailsCard(context),
          SizedBox(height: _cardSpacing),
          _buildDiagnosisDetailsCard(context),
          SizedBox(height: _cardSpacing),
          _buildBillingDetailsCard(context),
          SizedBox(height: _cardSpacing),
          AnimatedSize(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOutCubic,
            child: billStatusController.text != "Unpaid"
                ? _buildAmountDetailsCard(context)
                : const SizedBox.shrink(),
          ),
        ],
      );
    }
  }

  // --- Modern Card Builder Methods ---

  Widget _buildPatientDetailsCard(BuildContext context) {
    return _buildModernCard(
      context: context,
      title: "Patient Details",
      icon: Icons.person_outline_rounded,
      iconColor: Colors.blue,
      child: Column(
        children: [
          CustomTextField(
            label: "Patient Name",
            controller: patientNameController,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Patient name is required';
              }
              return null;
            },
          ),
          SizedBox(height: _spacing),
          Row(
            children: [
              Expanded(
                child: _buildPopupMenuField<String>(
                  context: context,
                  label: "Select Sex",
                  displayController: patientSexController,
                  items: sexDropDownList,
                  valueMapper: (item) => item,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please select sex';
                    }
                    return null;
                  },
                  onSelected: (selectedSex) {
                    setState(() => patientSexController.text = selectedSex);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomTextField(
                  label: "Age",
                  controller: patientAgeController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Age is required';
                    }
                    if (int.tryParse(value.trim()) == null) {
                      return 'Enter valid age';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosisDetailsCard(BuildContext context) {
    final diagnosisTypeAsync = ref.watch(diagnosisTypeProvider);
    final franchiseNamesAsync = ref.watch(franchiseNamesProvider);
    final doctorAsync = ref.watch(doctorsProvider);

    return _buildModernCard(
      context: context,
      title: "Diagnosis Details",
      icon: Icons.medical_services_rounded,
      iconColor: Colors.green,
      child: Column(
        children: [
          diagnosisTypeAsync.when(
            data: (types) {
              if (widget.billData != null && _selectedDiagnosisType == null) {
                final billDiagnosisId = diagnosisTypeController.text;
                _selectedDiagnosisType = types.firstWhere(
                  (type) => type.id.toString() == billDiagnosisId,
                  orElse: () => types.isNotEmpty ? types.first : types[0],
                );
              }
              // ========================== FIX END ==========================

              // Update display controllers when data is first loaded during an edit
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (doctorAsync.hasValue &&
                    franchiseNamesAsync.hasValue &&
                    widget.billData != null) {
                  _updateDisplayControllers(
                    types,
                    franchiseNamesAsync.value!,
                    doctorAsync.value!,
                  );
                }
              });

              return _buildPopupMenuField<DiagnosisType>(
                context: context,
                label: "Diagnosis Type",
                displayController: diagnosisTypeDisplayController,
                items: types,
                valueMapper: (item) =>
                    '${item.category} ${item.name}, ₹${item.price}',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please select diagnosis type';
                  }
                  return null;
                },
                onSelected: (selected) {
                  setState(() {
                    _selectedDiagnosisType = selected;
                    diagnosisTypeController.text = selected.id.toString();
                    diagnosisTypeDisplayController.text =
                        '${selected.category} ${selected.name}';
                  });
                },
              );
            },
            loading: () => _buildShimmerLoader(),
            error: (e, s) => _buildErrorWidget("Error loading diagnosis types"),
          ),
          SizedBox(height: _spacing),
          AnimatedSize(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOutCubic,
            child: _selectedDiagnosisType?.category == 'Franchise Lab'
                ? franchiseNamesAsync.when(
                    data: (franchises) => Column(
                      children: [
                        _buildPopupMenuField<FranchiseName>(
                          context: context,
                          label: "Franchise Name",
                          displayController: franchiseNameDisplayController,
                          items: franchises,
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
                        ),
                        SizedBox(height: _spacing),
                      ],
                    ),
                    loading: () => Column(
                      children: [
                        _buildShimmerLoader(),
                        SizedBox(height: _spacing),
                      ],
                    ),
                    error: (e, s) => Column(
                      children: [
                        _buildErrorWidget("Error loading franchises"),
                        SizedBox(height: _spacing),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          doctorAsync.when(
            data: (doctors) => _buildPopupMenuField<Doctor>(
              context: context,
              label: "Referred By Doctor",
              displayController: refByDoctorDisplayController,
              items: doctors,
              valueMapper: (item) =>
                  '${item.firstName} ${item.lastName ?? ''}, ${item.address ?? ""}',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please select referring doctor';
                }
                return null;
              },
              onSelected: (selected) {
                setState(() {
                  _selectedDoctor = selected;
                  refByDoctorController.text = selected.id.toString();
                  refByDoctorDisplayController.text =
                      '${selected.firstName} ${selected.lastName ?? ''}';
                });
              },
            ),
            loading: () => _buildShimmerLoader(),
            error: (e, s) => _buildErrorWidget("Error loading doctors"),
          ),
        ],
      ),
    );
  }

  Widget _buildBillingDetailsCard(BuildContext context) {
    return _buildModernCard(
      context: context,
      title: "Billing Details",
      icon: Icons.receipt_long_rounded,
      iconColor: Colors.orange,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildDateSelector(
                  label: "Date of Test",
                  controller: dateOfTestController,
                  onDateSelected: (iso) => selectedTestDateISO = iso,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Test date is required';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDateSelector(
                  label: "Date of Bill",
                  controller: dateOfBillController,
                  onDateSelected: (iso) => selectedBillDateISO = iso,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Bill date is required';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: _spacing),
          _buildPopupMenuField<String>(
            context: context,
            label: "Bill Status",
            displayController: billStatusController,
            items: billStatusList,
            valueMapper: (item) => item,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please select bill status';
              }
              return null;
            },
            onSelected: (status) {
              setState(() {
                billStatusController.text = status;
                if (status == "Unpaid") {
                  paidAmountController.text = "0";
                  discByDoctorController.text = "0";
                  discByCenterController.text = "0";
                }
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAmountDetailsCard(BuildContext context) {
    return _buildModernCard(
      context: context,
      title: "Amount Details",
      icon: Icons.payments_rounded,
      iconColor: Colors.purple,
      child: Column(
        children: [
          CustomTextField(
            label: "Paid Amount",
            controller: paidAmountController,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Paid amount is required';
              }
              if (double.tryParse(value.trim()) == null) {
                return 'Enter valid amount';
              }
              return null;
            },
          ),
          SizedBox(height: _spacing),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: "Doctor's Discount",
                  controller: discByDoctorController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value != null && value.trim().isNotEmpty) {
                      if (double.tryParse(value.trim()) == null) {
                        return 'Enter valid discount';
                      }
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomTextField(
                  label: "Center's Discount",
                  controller: discByCenterController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value != null && value.trim().isNotEmpty) {
                      if (double.tryParse(value.trim()) == null) {
                        return 'Enter valid discount';
                      }
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Modern card wrapper with enhanced design
  Widget _buildModernCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Widget child,
    required Color iconColor,
  }) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(defaultPadding),
        side: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildModernSectionHeader(context, title, icon, iconColor),
            const SizedBox(height: 24),
            child,
          ],
        ),
      ),
    );
  }

  // Modern section header with improved design
  Widget _buildModernSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
    Color iconColor,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: iconColor.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                height: 2,
                width: 32,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Enhanced shimmer loading effect
  Widget _buildShimmerLoader() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Loading...',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Enhanced error widget
  Widget _buildErrorWidget(String message) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(
          context,
        ).colorScheme.errorContainer.withValues(alpha: 0.1),
        border: Border.all(
          color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
        ),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: Theme.of(context).colorScheme.error,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
