import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:labledger/models/bill_model.dart';
import 'package:labledger/models/diagnosis_type_model.dart';
import 'package:labledger/models/doctors_model.dart';
import 'package:labledger/models/franchise_model.dart';
import 'package:labledger/providers/bills_provider.dart';
import 'package:labledger/providers/diagnosis_type_provider.dart';
import 'package:labledger/providers/doctor_provider.dart';
import 'package:labledger/providers/franchise_provider.dart';
import 'package:labledger/screens/ui_components/custom_action_button.dart';
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

  bool _dataLoaded = false;

  @override
  void initState() {
    super.initState();
    billStatusController.addListener(() => setState(() {}));

    if (widget.billData != null) {
      _preFillData();
    }
  }

  @override
  void dispose() {
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
    if (widget.billData == null || _dataLoaded) return;
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
    _dataLoaded = true;
  }

  void _updateDisplayControllers(
    List<DiagnosisType> diagnosisTypes,
    List<FranchiseName> franchises,
    List<Doctor> doctors,
  ) {
    if (widget.billData == null) return;
    try {
      _selectedDiagnosisType = diagnosisTypes.firstWhere(
        (type) => type.id.toString() == diagnosisTypeController.text,
      );
      diagnosisTypeDisplayController.text =
          '${_selectedDiagnosisType!.category} ${_selectedDiagnosisType!.name}';
      if (franchiseNameController.text.isNotEmpty) {
        _selectedFranchise = franchises.firstWhere(
          (f) => f.franchiseName == franchiseNameController.text,
        );
        franchiseNameDisplayController.text =
            "${_selectedFranchise!.franchiseName}, ${_selectedFranchise!.address}";
      }
      _selectedDoctor = doctors.firstWhere(
        (doc) => doc.id.toString() == refByDoctorController.text,
      );
      refByDoctorDisplayController.text =
          '${_selectedDoctor!.firstName} ${_selectedDoctor!.lastName ?? ''}';
    } catch (e) {
      debugPrint("Error updating display controllers: $e");
    }
  }

  Widget _buildPopupMenuField<T>({
    required BuildContext context,
    required String label,
    required TextEditingController displayController,
    required List<T> items,
    required String Function(T item) valueMapper,
    required Function(T item) onSelected,
    String? Function(String?)? validator,
    Color? tintColor,
  }) {
    final GlobalKey key = GlobalKey();
    final theme = Theme.of(context);

    return InkWell(
      key: key,
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        if (items.isEmpty) return;
        HapticFeedback.selectionClick();
        final RenderBox renderBox =
            key.currentContext!.findRenderObject() as RenderBox;
        final size = renderBox.size;
        final position = renderBox.localToGlobal(Offset.zero);
        final isDark = theme.brightness == Brightness.dark;
        final Color baseColor = tintColor ?? theme.colorScheme.primary;
        final Color menuBackgroundColor = isDark
            ? Color.alphaBlend(
                baseColor.withValues(alpha: 0.25),
                theme.colorScheme.surface,
              )
            : Color.alphaBlend(
                baseColor.withValues(alpha: 0.1),
                theme.colorScheme.surface,
              );
        final Color menuBorderColor = baseColor.withValues(
          alpha: isDark ? 0.5 : 0.4,
        );

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
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: menuBorderColor, width: 1),
          ),
          items: items.map((item) {
            return PopupMenuItem<T>(
              value: item,
              child: Text(
                valueMapper(item),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
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
          tintColor: tintColor,
          suffixIcon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color:
                tintColor ?? theme.colorScheme.primary.withValues(alpha: 0.7),
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelector({
    required String label,
    required TextEditingController controller,
    required Function(String isoDate) onDateSelected,
    String? Function(String?)? validator,
    Color? tintColor,
  }) {
    final theme = Theme.of(context);
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
          tintColor: tintColor,
          suffixIcon: Icon(
            Icons.calendar_month_rounded,
            size: 22,
            color: (tintColor ?? theme.colorScheme.primary).withValues(
              alpha: 0.9,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveBill() async {
    if (billStatusController.text == "Unpaid") {
      paidAmountController.text = "0";
      discByCenterController.text = "0";
      discByDoctorController.text = "0";
    }
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final billDataMap = {
      'patient_name': patientNameController.text,
      'patient_age': int.parse(patientAgeController.text),
      'patient_sex': patientSexController.text,
      'diagnosis_type': int.parse(diagnosisTypeController.text),
      'franchise_name': franchiseNameController.text,
      'referred_by_doctor': int.parse(refByDoctorController.text),
      'date_of_test': selectedTestDateISO,
      'date_of_bill': selectedBillDateISO,
      'bill_status': billStatusController.text,
      'paid_amount': int.parse(paidAmountController.text),
      'disc_by_center': int.parse(discByCenterController.text),
      'disc_by_doctor': int.parse(discByDoctorController.text),
    };
    final bill = Bill.fromJson({...billDataMap, 'id': widget.billData?.id});
    try {
      if (widget.billData != null) {
        final updatedBill = await ref.read(updateBillProvider(bill).future);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Bill updated successfully: ${updatedBill.billNumber}',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, updatedBill);
      } else {
        final newBill = await ref.read(createBillProvider(bill).future);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bill created successfully: ${newBill.billNumber}'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, newBill);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save bill: $e'),
          backgroundColor: Colors.red,
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
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isLargeScreen ? 48 : (isMediumScreen ? 32 : 24),
              vertical: 16,
            ),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surface.withValues(alpha: 0.8),
              border: Border(
                top: BorderSide(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!isSmallScreen) ...[
                  CustomActionButton(
                    label: 'Cancel',
                    onPressed: () => Navigator.pop(context),
                    isPrimary: false,
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  flex: isSmallScreen ? 1 : 0,
                  child: CustomActionButton(
                    label: isEditing ? 'Update Bill' : 'Add Bill',
                    icon: isEditing
                        ? Icons.save_as_rounded
                        : Icons.add_circle_outline_rounded,
                    onPressed: _saveBill,
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
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: _buildFormContent(context, isLargeScreen, isMediumScreen),
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
          child: Form(
            key: _formKey,
            child: _buildFormContent(context, isLargeScreen, isMediumScreen),
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
    if (isLargeScreen || isMediumScreen) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                _buildPatientDetailsCard(context),
                const SizedBox(height: _cardSpacing),
                _buildDiagnosisDetailsCard(context),
              ],
            ),
          ),
          const SizedBox(width: _cardSpacing),
          Expanded(
            child: Column(
              children: [
                _buildBillingDetailsCard(context),
                const SizedBox(height: _cardSpacing),
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
      return Column(
        children: [
          _buildPatientDetailsCard(context),
          const SizedBox(height: _cardSpacing),
          _buildDiagnosisDetailsCard(context),
          const SizedBox(height: _cardSpacing),
          _buildBillingDetailsCard(context),
          const SizedBox(height: _cardSpacing),
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

  Widget _buildPatientDetailsCard(BuildContext context) {
    final Color tint = Colors.blue;
    return _buildModernCard(
      context: context,
      title: "Patient Details",
      icon: Icons.person_outline_rounded,
      iconColor: tint,
      child: Column(
        children: [
          CustomTextField(
            label: "Patient Name",
            controller: patientNameController,
            tintColor: tint,
            validator: (v) =>
                v!.trim().isEmpty ? 'Patient name is required' : null,
          ),
          const SizedBox(height: _spacing),
          Row(
            children: [
              Expanded(
                child: _buildPopupMenuField<String>(
                  context: context,
                  label: "Select Sex",
                  displayController: patientSexController,
                  items: sexDropDownList,
                  valueMapper: (item) => item,
                  tintColor: tint,
                  validator: (v) => v!.isEmpty ? 'Please select sex' : null,
                  onSelected: (sex) =>
                      setState(() => patientSexController.text = sex),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomTextField(
                  label: "Age",
                  controller: patientAgeController,
                  keyboardType: TextInputType.number,
                  tintColor: tint,
                  validator: (v) {
                    if (v!.trim().isEmpty) return 'Age is required';
                    if (int.tryParse(v.trim()) == null) {
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
    final Color tint = Colors.green;

    return _buildModernCard(
      context: context,
      title: "Diagnosis Details",
      icon: Icons.medical_services_rounded,
      iconColor: tint,
      child: Column(
        children: [
          diagnosisTypeAsync.when(
            data: (types) {
              // ⭐️⭐️⭐️ BUG FIX IS HERE ⭐️⭐️⭐️
              // This logic ensures that when editing a bill, the `_selectedDiagnosisType`
              // object is set as soon as the types are loaded, which correctly
              // reveals the 'Franchise Name' field without needing a user tap.
              if (widget.billData != null && _selectedDiagnosisType == null) {
                try {
                  final billDiagnosisId = diagnosisTypeController.text;
                  _selectedDiagnosisType = types.firstWhere(
                    (type) => type.id.toString() == billDiagnosisId,
                  );
                } catch (e) {
                  debugPrint("Could not find pre-selected diagnosis type: $e");
                }
              }
              // ======================= FIX END =======================

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
                tintColor: tint,
                valueMapper: (item) =>
                    '${item.category} ${item.name}, ₹${item.price}',
                validator: (v) =>
                    v!.isEmpty ? 'Please select diagnosis type' : null,
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
          const SizedBox(height: _spacing),
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
                          tintColor: tint,
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
                        const SizedBox(height: _spacing),
                      ],
                    ),
                    loading: () => Column(
                      children: [
                        _buildShimmerLoader(),
                        const SizedBox(height: _spacing),
                      ],
                    ),
                    error: (e, s) => Column(
                      children: [
                        _buildErrorWidget("Error loading franchises"),
                        const SizedBox(height: _spacing),
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
              tintColor: tint,
              valueMapper: (item) =>
                  '${item.firstName} ${item.lastName ?? ''}, ${item.address ?? ""}',
              validator: (v) =>
                  v!.isEmpty ? 'Please select referring doctor' : null,
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
    final Color tint = Colors.orange;
    return _buildModernCard(
      context: context,
      title: "Billing Details",
      icon: Icons.receipt_long_rounded,
      iconColor: tint,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildDateSelector(
                  label: "Date of Test",
                  controller: dateOfTestController,
                  tintColor: tint,
                  onDateSelected: (iso) => selectedTestDateISO = iso,
                  validator: (v) => v!.isEmpty ? 'Test date is required' : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDateSelector(
                  label: "Date of Bill",
                  controller: dateOfBillController,
                  tintColor: tint,
                  onDateSelected: (iso) => selectedBillDateISO = iso,
                  validator: (v) => v!.isEmpty ? 'Bill date is required' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: _spacing),
          _buildPopupMenuField<String>(
            context: context,
            label: "Bill Status",
            displayController: billStatusController,
            items: billStatusList,
            tintColor: tint,
            valueMapper: (item) => item,
            validator: (v) => v!.isEmpty ? 'Please select bill status' : null,
            onSelected: (status) =>
                setState(() => billStatusController.text = status),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountDetailsCard(BuildContext context) {
    final Color tint = Colors.purple;
    return _buildModernCard(
      context: context,
      title: "Amount Details",
      icon: Icons.payments_rounded,
      iconColor: tint,
      child: Column(
        children: [
          CustomTextField(
            label: "Paid Amount",
            controller: paidAmountController,
            keyboardType: TextInputType.number,
            tintColor: tint,
            validator: (v) {
              if (v!.trim().isEmpty) return 'Paid amount is required';
              if (double.tryParse(v.trim()) == null) {
                return 'Enter valid amount';
              }
              return null;
            },
          ),
          const SizedBox(height: _spacing),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: "Doctor's Discount",
                  controller: discByDoctorController,
                  keyboardType: TextInputType.number,
                  tintColor: tint,
                  validator: (v) {
                    if (v!.trim().isNotEmpty &&
                        double.tryParse(v.trim()) == null) {
                      return 'Enter valid discount';
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
                  tintColor: tint,
                  validator: (v) {
                    if (v!.trim().isNotEmpty &&
                        double.tryParse(v.trim()) == null) {
                      return 'Enter valid discount';
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

  Widget _buildModernCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Widget child,
    required Color iconColor,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = Color.alphaBlend(
      iconColor.withValues(alpha: isDark ? 0.15 : 0.08),
      theme.colorScheme.surface,
    );
    final borderColor = iconColor.withValues(alpha: isDark ? 0.5 : 0.4);

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
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
            border: Border.all(color: iconColor.withValues(alpha: 0.2)),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerLoader() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
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

  Widget _buildErrorWidget(String message) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(
          context,
        ).colorScheme.errorContainer.withValues(alpha: 0.2),
        border: Border.all(
          color: Theme.of(context).colorScheme.error.withValues(alpha: 0.4),
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
