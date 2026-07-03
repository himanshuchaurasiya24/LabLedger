import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/providers/doctor_provider.dart';
import 'package:labledger/models/bill_model.dart';
import 'package:labledger/models/diagnosis_type_model.dart';
import 'package:labledger/models/doctors_model.dart';
import 'package:labledger/models/franchise_model.dart';
import 'package:labledger/providers/bills_provider.dart';
import 'package:labledger/providers/diagnosis_type_provider.dart';
import 'package:labledger/providers/franchise_lab_provider.dart';
import 'package:labledger/providers/patient_report_provider.dart';
import 'package:labledger/screens/bills/methods/bill_methods.dart';
import 'package:labledger/screens/ui_components/window_scaffold.dart';
import 'package:labledger/screens/bills/widgets/cards/patient_details_card.dart';
import 'package:labledger/screens/bills/widgets/cards/billing_details_card.dart';
import 'package:labledger/screens/bills/widgets/cards/amount_details_card.dart';
import 'package:labledger/screens/bills/widgets/cards/diagnosis_details_card.dart';
import 'package:labledger/screens/bills/widgets/cards/bill_header_card.dart';
import 'package:labledger/screens/bills/widgets/full_screen_error_widget.dart';
import 'package:labledger/utils/controller_disposer.dart';

class AddUpdateBillScreen extends ConsumerStatefulWidget {
  final int? billId;
  final Color themeColor;

  const AddUpdateBillScreen({super.key, this.billId, required this.themeColor});

  @override
  ConsumerState<AddUpdateBillScreen> createState() =>
      _AddUpdateBillScreenState();
}

class _AddUpdateBillScreenState extends ConsumerState<AddUpdateBillScreen>
    with SingleTickerProviderStateMixin, ControllerDisposer {
  late TabController _tabController;
  late final VoidCallback _billStatusListener;
  final _formKey = GlobalKey<FormState>();
  late BillMethods _methods;

  late final TextEditingController patientNameController;
  late final TextEditingController patientAgeController;
  late final TextEditingController patientSexController;
  late final TextEditingController patientPhoneNumberController;
  late final TextEditingController diagnosisTypeController;
  late final TextEditingController franchiseNameController;
  late final TextEditingController refByDoctorController;
  late final TextEditingController dateOfTestController;
  late final TextEditingController dateOfBillController;
  late final TextEditingController billStatusController;
  late final TextEditingController paidAmountController;
  late final TextEditingController discByDoctorController;
  late final TextEditingController discByCenterController;
  late final TextEditingController diagnosisTypeDisplayController;
  late final TextEditingController franchiseNameDisplayController;
  late final TextEditingController refByDoctorDisplayController;
  late final TextEditingController _diagnosisTypeSearchController;

  bool get _isEditMode => widget.billId != null;

  final List<String> sexDropDownList = ["Male", "Female", "Others"];
  final List<String> billStatusList = [
    "Fully Paid",
    "Partially Paid",
    "Unpaid",
  ];

  @override
  void initState() {
    super.initState();
    _methods = BillMethods(ref, context);
    _methods.addListener(() {
      if (mounted) setState(() {});
    });
    _tabController = TabController(length: 3, vsync: this);
    _billStatusListener = () {
      if (mounted) {
        setState(() {});
      }
    };
    // create controllers via disposer
    patientNameController = createController();
    patientAgeController = createController();
    patientSexController = createController();
    patientPhoneNumberController = createController();
    diagnosisTypeController = createController();
    franchiseNameController = createController();
    refByDoctorController = createController();
    dateOfTestController = createController();
    dateOfBillController = createController();
    billStatusController = createController();
    paidAmountController = createController();
    discByDoctorController = createController();
    discByCenterController = createController();
    diagnosisTypeDisplayController = createController();
    franchiseNameDisplayController = createController();
    refByDoctorDisplayController = createController();
    _diagnosisTypeSearchController = createController();

    billStatusController.addListener(_billStatusListener);

    if (!_isEditMode) {
      final defaultDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
      dateOfTestController.text = defaultDate;
      dateOfBillController.text = defaultDate;
      billStatusController.text = billStatusList.first;
    }
  }

  @override
  void dispose() {
    _methods.dispose();
    _tabController.dispose();
    billStatusController.removeListener(_billStatusListener);
    disposeControllers();
    super.dispose();
  }

  void _initializeData(Bill bill) {
    if (_methods.isDataInitialized) return;

    final dateFormat = DateFormat('dd-MM-yyyy');
    patientNameController.text = bill.patientName;
    patientAgeController.text = bill.patientAge.toString();
    patientSexController.text = bill.patientSex;
    patientPhoneNumberController.text = bill.patientPhoneNumber.toString();
    dateOfTestController.text = dateFormat.format(bill.dateOfTest);
    dateOfBillController.text = dateFormat.format(bill.dateOfBill);
    _methods.selectedTestDateISO = bill.dateOfTest.toIso8601String();
    _methods.selectedBillDateISO = bill.dateOfBill.toIso8601String();
    billStatusController.text = bill.billStatus;
    paidAmountController.text = bill.paidAmount.toString();
    discByDoctorController.text = bill.discByDoctor.toString();
    discByCenterController.text = bill.discByCenter.toString();

    // Load multiple diagnosis types
    if (bill.diagnosisTypesOutput != null &&
        bill.diagnosisTypesOutput!.isNotEmpty) {
      _methods.selectedDiagnosisTypes = bill.diagnosisTypesOutput!
          .map((dt) => DiagnosisType.fromJson(dt))
          .toList();
    }
    if (bill.referredByDoctorOutput != null) {
      _methods.selectedDoctor = Doctor.fromJson(bill.referredByDoctorOutput!);
    }
    if (bill.franchiseNameOutput != null) {
      _methods.selectedFranchise = FranchiseName.fromJson(bill.franchiseNameOutput!);
    }
    diagnosisTypeController.text = bill.diagnosisTypes.join(',');
    refByDoctorController.text = bill.referredByDoctor.toString();
    franchiseNameController.text = bill.franchiseName?.toString() ?? '';

    // Display diagnosis types as comma-separated list or chips
    diagnosisTypeDisplayController.text = _methods.selectedDiagnosisTypes
        .map((dt) => '${dt.categoryName ?? "Unknown"} ${dt.name}')
        .join(', ');
    refByDoctorDisplayController.text =
        '${bill.referredByDoctorOutput?['first_name']} ${bill.referredByDoctorOutput?['last_name']}';
    franchiseNameDisplayController.text =
        bill.franchiseNameOutput?['franchise_name'] ?? '';

    _methods.initializeData();
  }

  void _updateDisplayControllers(
    List<DiagnosisType> diagnosisTypes,
    List<FranchiseName> franchises,
    List<Doctor> doctors,
  ) {
    if (!_isEditMode || !_methods.isDataInitialized) return;
    try {
      // Load diagnosis types from controller (comma-separated IDs)
      if (diagnosisTypeController.text.isNotEmpty) {
        final diagnosisIds = diagnosisTypeController.text
            .split(',')
            .map((id) => int.tryParse(id.trim()))
            .whereType<int>()
            .toList();

        if (diagnosisIds.isNotEmpty) {
          _methods.selectedDiagnosisTypes = diagnosisTypes
              .where((type) => diagnosisIds.contains(type.id))
              .toList();
          diagnosisTypeDisplayController.text = _methods.selectedDiagnosisTypes
              .map((dt) => '${dt.categoryName ?? "Unknown"} ${dt.name}')
              .join(', ');
        }
      }

      if (refByDoctorController.text.isNotEmpty) {
        final doctorId = int.tryParse(refByDoctorController.text);
        if (doctorId != null) {
          _methods.selectedDoctor = doctors.firstWhere((doc) => doc.id == doctorId);
          refByDoctorDisplayController.text =
              '${_methods.selectedDoctor!.firstName} ${_methods.selectedDoctor!.lastName ?? ''}';
        }
      }

      // Check if any selected diagnosis type is Franchise Lab
      bool hasFranchiseLab = _methods.selectedDiagnosisTypes.any(
        (dt) => dt.categoryName?.toLowerCase() == 'franchise lab',
      );
      if (hasFranchiseLab && franchiseNameController.text.isNotEmpty) {
        _methods.selectedFranchise = franchises.firstWhere(
          (f) => f.franchiseName == franchiseNameController.text,
        );
        franchiseNameDisplayController.text =
            "${_methods.selectedFranchise!.franchiseName}, ${_methods.selectedFranchise!.address}";
      }

      if (mounted) setState(() {});
    } catch (e) {
      //
    }
  }

  /// Recalculates total amount based on selected diagnosis types
  void _updateTotalAmount() {
    // Calculate total from selected diagnosis types
    _methods.selectedDiagnosisTypes.fold(0, (sum, dt) => sum + dt.price);

    // The Bill model will recalculate when saved, but this helps user see the total
    // Note: There's no totalAmountController because total is calculated from diagnosis types
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
                error: (err, st) => FullScreenErrorWidget(
                  message: err.toString(),
                  title: 'Error Loading Bill',
                  themeColor: widget.themeColor,
                  onRetry: () {
                    if (widget.billId != null) {
                      ref.invalidate(singleBillProvider(widget.billId!));
                    }
                  },
                ),
              )
        : _buildContent();

    return WindowScaffold(child: content);
  }

  Widget _buildContent({Bill? bill}) {
    final isLargeScreen = MediaQuery.of(context).size.width > 1200;

    if (isLargeScreen) {
      return Form(
        key: _formKey,
        child: Column(
          children: [
          BillHeaderCard(
            color: widget.themeColor,
            bill: bill,
            billId: widget.billId,
            isEditMode: _isEditMode,
            isDownloadingReport: _methods.isDownloadingReport,
            isSendingMessage: _methods.isSendingMessage,
            isSubmitting: _methods.isSubmitting,
            onDownloadReport: () {
              final reportAsyncValue = ref.read(getReportForBillProvider(bill!.id!));
              if (reportAsyncValue.hasValue && reportAsyncValue.value != null) {
                _methods.downloadReport(reportAsyncValue.value!.id);
              }
            },
            onDeleteReport: () {
              final reportAsyncValue = ref.read(getReportForBillProvider(bill!.id!));
              if (reportAsyncValue.hasValue && reportAsyncValue.value != null) {
                 ref.read(
                   deletePatientReportProvider((
                     reportId: reportAsyncValue.value!.id,
                     billId: bill.id!,
                   )).future,
                 );
              }
            },
            onSendMessage: () => _methods.sendBillMessage(bill!),
            onSaveBill: () => _methods.saveBill(
              formKey: _formKey,
              isEditMode: _isEditMode,
              originalBill: bill,
              billId: widget.billId,
              patientNameController: patientNameController,
              patientAgeController: patientAgeController,
              patientSexController: patientSexController,
              billStatusController: billStatusController,
              paidAmountController: paidAmountController,
              discByCenterController: discByCenterController,
              discByDoctorController: discByDoctorController,
              patientPhoneNumberController: patientPhoneNumberController,
              refByDoctorController: refByDoctorController,
              franchiseNameController: franchiseNameController,
            ),
            onDeleteBill: () => _methods.deleteBill(bill!),
          ),
            SizedBox(height: defaultHeight),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: defaultPadding),
                child: _buildLargeScreenLayout(color: widget.themeColor),
              ),
            ),
          ],
        ),
      );
    }

    return Form(
      key: _formKey,
      child: Column(
        children: [
          BillHeaderCard(
            color: widget.themeColor,
            bill: bill,
            billId: widget.billId,
            isEditMode: _isEditMode,
            isDownloadingReport: _methods.isDownloadingReport,
            isSendingMessage: _methods.isSendingMessage,
            isSubmitting: _methods.isSubmitting,
            onDownloadReport: () {
              final reportAsyncValue = ref.read(getReportForBillProvider(bill!.id!));
              if (reportAsyncValue.hasValue && reportAsyncValue.value != null) {
                _methods.downloadReport(reportAsyncValue.value!.id);
              }
            },
            onDeleteReport: () {
              final reportAsyncValue = ref.read(getReportForBillProvider(bill!.id!));
              if (reportAsyncValue.hasValue && reportAsyncValue.value != null) {
                 ref.read(
                   deletePatientReportProvider((
                     reportId: reportAsyncValue.value!.id,
                     billId: bill.id!,
                   )).future,
                 );
              }
            },
            onSendMessage: () => _methods.sendBillMessage(bill!),
            onSaveBill: () => _methods.saveBill(
              formKey: _formKey,
              isEditMode: _isEditMode,
              originalBill: bill,
              billId: widget.billId,
              patientNameController: patientNameController,
              patientAgeController: patientAgeController,
              patientSexController: patientSexController,
              billStatusController: billStatusController,
              paidAmountController: paidAmountController,
              discByCenterController: discByCenterController,
              discByDoctorController: discByDoctorController,
              patientPhoneNumberController: patientPhoneNumberController,
              refByDoctorController: refByDoctorController,
              franchiseNameController: franchiseNameController,
            ),
            onDeleteBill: () => _methods.deleteBill(bill!),
          ),
          SizedBox(height: defaultHeight),
          Expanded(
            child: Column(
              children: [
                _buildTabBar(color: widget.themeColor),
                Expanded(child: _buildTabContent(color: widget.themeColor)),
              ],
            ),
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
              PatientDetailsCard(
                defaultColor: color,
                nameController: patientNameController,
                sexController: patientSexController,
                ageController: patientAgeController,
                phoneController: patientPhoneNumberController,
                sexDropDownList: sexDropDownList,
                onSexSelected: (value) =>
                    setState(() => patientSexController.text = value),
              ),
              SizedBox(height: defaultHeight),
              DiagnosisDetailsCard(
                defaultColor: color,
                diagnosisTypesAsync: ref.watch(diagnosisTypeProvider),
                franchiseNamesAsync: ref.watch(franchiseProvider),
                doctorsAsync: ref.watch(doctorsProvider),
                selectedDiagnosisTypes: _methods.selectedDiagnosisTypes,
                isEditMode: _isEditMode,
                isDataInitialized: _methods.isDataInitialized,
                diagnosisTypeDisplayController: diagnosisTypeDisplayController,
                diagnosisTypeSearchController: _diagnosisTypeSearchController,
                franchiseNameDisplayController: franchiseNameDisplayController,
                refByDoctorDisplayController: refByDoctorDisplayController,
                onDiagnosisTypeRemoved: (dt) {
                  setState(() {
                    _methods.selectedDiagnosisTypes.remove(dt);
                    diagnosisTypeController.text =
                        _methods.selectedDiagnosisTypes
                            .map((d) => d.id.toString())
                            .join(',');
                    diagnosisTypeDisplayController.text =
                        _methods.selectedDiagnosisTypes
                            .map((d) => '${d.category} ${d.name}')
                            .join(', ');
                    _updateTotalAmount();
                  });
                },
                onDiagnosisTypeSelected: (selected) {
                  setState(() {
                    if (!_methods.selectedDiagnosisTypes.any(
                      (dt) => dt.id == selected.id,
                    )) {
                      _methods.selectedDiagnosisTypes.add(selected);
                      diagnosisTypeController.text =
                          _methods.selectedDiagnosisTypes
                              .map((d) => d.id.toString())
                              .join(',');
                      diagnosisTypeDisplayController
                          .text = _methods.selectedDiagnosisTypes
                          .map(
                            (d) =>
                                '${d.categoryName ?? "Unknown"} ${d.name}',
                          )
                          .join(', ');

                      bool hasFranchiseLab = _methods.selectedDiagnosisTypes.any(
                        (dt) =>
                            dt.categoryName?.toLowerCase() ==
                            'franchise lab',
                      );
                      if (!hasFranchiseLab) {
                        _methods.selectedFranchise = null;
                        franchiseNameController.clear();
                        franchiseNameDisplayController.clear();
                      }
                      _updateTotalAmount();
                    }
                  });
                },
                onFranchiseSelected: (selected) {
                  setState(() {
                    _methods.selectedFranchise = selected;
                    franchiseNameController.text = selected.id
                        .toString();
                    franchiseNameDisplayController.text =
                        selected.franchiseName ?? '';
                  });
                },
                onDoctorSelected: (selected) {
                  setState(() {
                    _methods.selectedDoctor = selected;
                    refByDoctorController.text = selected.id.toString();
                    refByDoctorDisplayController.text =
                        '${selected.firstName} ${selected.lastName ?? ''}';
                  });
                },
                onUpdateDisplayControllers: _updateDisplayControllers,
              ),
            ],
          ),
        ),
        SizedBox(width: defaultWidth),
        Expanded(
          child: Column(
            children: [
              BillingDetailsCard(
                defaultColor: color,
                dateOfTestController: dateOfTestController,
                dateOfBillController: dateOfBillController,
                billStatusController: billStatusController,
                billStatusList: billStatusList,
                onTestDateSelected: (iso) => _methods.selectedTestDateISO = iso,
                onBillDateSelected: (iso) => _methods.selectedBillDateISO = iso,
                onStatusSelected: (value) =>
                    setState(() => billStatusController.text = value),
              ),
              SizedBox(height: defaultHeight),
              AnimatedSize(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOutCubic,
                child: billStatusController.text != "Unpaid"
                    ? AmountDetailsCard(
                        defaultColor: color,
                        totalAmount: _methods.selectedDiagnosisTypes.fold(
                          0,
                          (sum, dt) => sum + dt.price,
                        ),
                        paidAmountController: paidAmountController,
                        discByDoctorController: discByDoctorController,
                        discByCenterController: discByCenterController,
                      )
                    : const SizedBox.shrink(),
              ),
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
        _buildPatientTab(color),
        _buildDiagnosisTab(color),
        _buildBillingTab(color),
      ],
    );
  }

  Widget _buildPatientTab(Color color) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(defaultPadding),
      child: PatientDetailsCard(
        defaultColor: color,
        height: 254,
        nameController: patientNameController,
        sexController: patientSexController,
        ageController: patientAgeController,
        phoneController: patientPhoneNumberController,
        sexDropDownList: sexDropDownList,
        onSexSelected: (value) =>
            setState(() => patientSexController.text = value),
      ),
    );
  }

  Widget _buildDiagnosisTab(Color color) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(defaultPadding),
      child: DiagnosisDetailsCard(
        defaultColor: color,
        height: 318,
        diagnosisTypesAsync: ref.watch(diagnosisTypeProvider),
        franchiseNamesAsync: ref.watch(franchiseProvider),
        doctorsAsync: ref.watch(doctorsProvider),
        selectedDiagnosisTypes: _methods.selectedDiagnosisTypes,
        isEditMode: _isEditMode,
        isDataInitialized: _methods.isDataInitialized,
        diagnosisTypeDisplayController: diagnosisTypeDisplayController,
        diagnosisTypeSearchController: _diagnosisTypeSearchController,
        franchiseNameDisplayController: franchiseNameDisplayController,
        refByDoctorDisplayController: refByDoctorDisplayController,
        onDiagnosisTypeRemoved: (dt) {
          setState(() {
            _methods.selectedDiagnosisTypes.remove(dt);
            diagnosisTypeController.text =
                _methods.selectedDiagnosisTypes
                    .map((d) => d.id.toString())
                    .join(',');
            diagnosisTypeDisplayController.text =
                _methods.selectedDiagnosisTypes
                    .map((d) => '${d.category} ${d.name}')
                    .join(', ');
            _updateTotalAmount();
          });
        },
        onDiagnosisTypeSelected: (selected) {
          setState(() {
            if (!_methods.selectedDiagnosisTypes.any(
              (dt) => dt.id == selected.id,
            )) {
              _methods.selectedDiagnosisTypes.add(selected);
              diagnosisTypeController.text =
                  _methods.selectedDiagnosisTypes
                      .map((d) => d.id.toString())
                      .join(',');
              diagnosisTypeDisplayController
                  .text = _methods.selectedDiagnosisTypes
                  .map(
                    (d) =>
                        '${d.categoryName ?? "Unknown"} ${d.name}',
                  )
                  .join(', ');

              bool hasFranchiseLab = _methods.selectedDiagnosisTypes.any(
                (dt) =>
                    dt.categoryName?.toLowerCase() ==
                    'franchise lab',
              );
              if (!hasFranchiseLab) {
                _methods.selectedFranchise = null;
                franchiseNameController.clear();
                franchiseNameDisplayController.clear();
              }
              _updateTotalAmount();
            }
          });
        },
        onFranchiseSelected: (selected) {
          setState(() {
            _methods.selectedFranchise = selected;
            franchiseNameController.text = selected.id
                .toString();
            franchiseNameDisplayController.text =
                selected.franchiseName ?? '';
          });
        },
        onDoctorSelected: (selected) {
          setState(() {
            _methods.selectedDoctor = selected;
            refByDoctorController.text = selected.id.toString();
            refByDoctorDisplayController.text =
                '${selected.firstName} ${selected.lastName ?? ''}';
          });
        },
        onUpdateDisplayControllers: _updateDisplayControllers,
      ),
    );
  }

  Widget _buildBillingTab(Color color) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(defaultPadding),
      child: Column(
        children: [
          BillingDetailsCard(
            defaultColor: color,
            height: 254,
            dateOfTestController: dateOfTestController,
            dateOfBillController: dateOfBillController,
            billStatusController: billStatusController,
            billStatusList: billStatusList,
            onTestDateSelected: (iso) => _methods.selectedTestDateISO = iso,
            onBillDateSelected: (iso) => _methods.selectedBillDateISO = iso,
            onStatusSelected: (value) =>
                setState(() => billStatusController.text = value),
          ),
          SizedBox(height: defaultHeight),
          AnimatedSize(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOutCubic,
            child: billStatusController.text != "Unpaid"
                ? AmountDetailsCard(
                    defaultColor: color,
                    height: 254,
                    totalAmount: _methods.selectedDiagnosisTypes.fold(
                      0,
                      (sum, dt) => sum + dt.price,
                    ),
                    paidAmountController: paidAmountController,
                    discByDoctorController: discByDoctorController,
                    discByCenterController: discByCenterController,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
