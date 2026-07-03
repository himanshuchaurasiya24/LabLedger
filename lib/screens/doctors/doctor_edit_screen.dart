import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/models/doctors_model.dart';
import 'package:labledger/providers/authentication_provider.dart';
import 'package:labledger/providers/doctor_provider.dart';
import 'package:labledger/providers/category_provider.dart';
import 'package:labledger/models/diagnosis_category_model.dart';
import 'package:labledger/screens/ui_components/window_scaffold.dart';
import 'package:labledger/screens/ui_components/tinted_container.dart';
import 'package:labledger/screens/ui_components/edit_screen_header_card.dart';
import 'package:labledger/methods/string_utils.dart';
import 'package:labledger/screens/doctors/methods/doctor_methods.dart';
import 'package:labledger/utils/controller_disposer.dart';
import 'package:labledger/screens/doctors/widgets/doctor_details_form_card.dart';
import 'package:labledger/screens/doctors/widgets/doctor_incentives_form_card.dart';

class DoctorEditScreen extends ConsumerStatefulWidget {
  const DoctorEditScreen({super.key, this.doctorId, this.themeColor});

  final int? doctorId;
  final Color? themeColor;

  @override
  ConsumerState<DoctorEditScreen> createState() => _DoctorEditScreenState();
}

class _DoctorEditScreenState extends ConsumerState<DoctorEditScreen>
    with SingleTickerProviderStateMixin, ControllerDisposer {
  late TabController _tabController;
  final _detailsFormKey = GlobalKey<FormState>();
  final _incentivesFormKey = GlobalKey<FormState>();

  // Doctor details controllers
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _hospitalController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;

  // Dynamic incentives controllers map: category_id -> controller
  final Map<int, TextEditingController> _categoryControllers = {};
  List<DiagnosisCategory> _categories = [];
  
  late final DoctorMethods _methods;

  bool get _isEditMode => widget.doctorId != null;

  @override
  void initState() {
    super.initState();
    _methods = DoctorMethods(context, ref);
    _methods.addListener(() {
      if (mounted) setState(() {});
    });
    _tabController = TabController(length: 2, vsync: this);
    _firstNameController = createController();
    _lastNameController = createController();
    _hospitalController = createController();
    _emailController = createController();
    _phoneController = createController();
    _addressController = createController();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await ref.read(categoriesProvider.future);
      setState(() {
        _categories = categories;
        // Create controllers for each category
        for (var category in categories) {
          _categoryControllers[category.id] = createController();
        }
      });

      // Re-initialize doctor data if in edit mode and doctor was already loaded
      if (_isEditMode && _loadedDoctor != null) {
        _initializeData(_loadedDoctor!);
      }
    } catch (e) {
      // Handle error
    }
  }

  Doctor?
  _loadedDoctor; // Store loaded doctor for re-initialization after categories load

  @override
  void dispose() {
    _methods.dispose();
    _tabController.dispose();
    disposeControllers();
    // Note: disposeControllers will also dispose controllers created via createController
    super.dispose();
  }

  void _initializeData(Doctor doctor) {
    if (!_methods.isDataInitialized) {
      _loadedDoctor =
          doctor; // Store for re-initialization after categories load
      _firstNameController.text = doctor.firstName ?? '';
      _lastNameController.text = doctor.lastName ?? '';
      _hospitalController.text = doctor.hospitalName ?? '';
      _emailController.text = doctor.email ?? '';
      _phoneController.text = doctor.phoneNumber ?? '';
      _addressController.text = doctor.address ?? '';

      _methods.setInitialized();
    }

    // Always try to initialize category percentages (can be called multiple times)
    _initializeCategoryPercentages(doctor);
  }

  void _initializeCategoryPercentages(Doctor doctor) {
    // Initialize category percentages from category_percentages list
    if (doctor.categoryPercentages != null && _categoryControllers.isNotEmpty) {
      for (var catPercent in doctor.categoryPercentages!) {
        final controller = _categoryControllers[catPercent.category];
        if (controller != null) {
          controller.text = catPercent.percentage.toString();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = ref.watch(currentUserProvider).value?.isAdmin ?? false;
    final effectiveThemeColor =
        widget.themeColor ?? Theme.of(context).colorScheme.secondary;

    final content = _isEditMode
        ? ref
              .watch(singleDoctorProvider(widget.doctorId!))
              .when(
                data: (doctor) {
                  _initializeData(doctor);
                  return _buildContent(
                    isAdmin,
                    effectiveThemeColor,
                    doctor: doctor,
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, st) =>
                    _buildErrorWidget("Error loading doctor: $err"),
              )
        : _buildContent(isAdmin, effectiveThemeColor);

    return WindowScaffold(child: content);
  }

  Widget _buildContent(bool isAdmin, Color color, {Doctor? doctor}) {
    return Column(
      children: [
        _buildDoctorHeaderCard(isAdmin, color, doctor),
        SizedBox(height: defaultHeight),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 900) {
                return _buildLargeScreenLayout(color, doctor: doctor);
              } else {
                return Column(
                  children: [
                    _buildTabBar(color),
                    SizedBox(height: defaultHeight),
                    Expanded(child: _buildTabContent(color, doctor: doctor)),
                    SizedBox(height: defaultHeight),
                  ],
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorHeaderCard(bool isAdmin, Color color, Doctor? doctor) {
    final title = _isEditMode
        ? '${doctor?.firstName ?? ''} ${doctor?.lastName ?? ''}'
        : 'New Doctor Profile';
    final subtitle = _isEditMode
        ? doctor?.hospitalName ?? ''
        : 'Enter doctor details below';
    final initials = _isEditMode
        ? getInitials(doctor?.firstName, doctor?.lastName)
        : 'DR';

    return EditScreenHeaderCard(
      title: title,
      subtitle: subtitle,
      initials: initials,
      color: color,
      isEditMode: _isEditMode,
      isAdmin: isAdmin,
      isSaving: _methods.isSaving,
      isDeleting: _methods.isDeleting,
      onSave: () {
        if (!_detailsFormKey.currentState!.validate()) return;
        if (!_incentivesFormKey.currentState!.validate()) return;
        
        List<DoctorCategoryPercentage> categoryPercentages = [];
        _categoryControllers.forEach((categoryId, controller) {
          final percentageText = controller.text.trim();
          if (percentageText.isNotEmpty) {
            final percentage = int.tryParse(percentageText);
            if (percentage != null) {
              categoryPercentages.add(
                DoctorCategoryPercentage(
                  id: 0,
                  category: categoryId,
                  percentage: percentage,
                ),
              );
            }
          }
        });

        _methods.handleSave(
          isEditMode: _isEditMode,
          originalDoctor: doctor,
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          hospitalName: _hospitalController.text.trim(),
          email: _emailController.text.trim().isEmpty
              ? null
              : _emailController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          address: _addressController.text.trim(),
          categoryPercentages: categoryPercentages,
        );
      },
      onDelete: () => _methods.handleDelete(doctor: doctor!),
      saveLabel: _isEditMode ? 'Update' : 'Create',
    );
  }

  Widget _buildTabBar(Color color) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
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
                Text('Doctor Details'),
              ],
            ),
          ),
          Tab(
            height: 44,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.percent, size: 18),
                SizedBox(width: 8),
                Text('Incentives'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(Color color, {Doctor? doctor}) {
    return TabBarView(
      controller: _tabController,
      children: [
        DoctorDetailsFormCard(
          color: color,
          formKey: _detailsFormKey,
          firstNameController: _firstNameController,
          lastNameController: _lastNameController,
          hospitalController: _hospitalController,
          emailController: _emailController,
          phoneController: _phoneController,
          addressController: _addressController,
        ),
        DoctorIncentivesFormCard(
          color: color,
          formKey: _incentivesFormKey,
          categories: _categories,
          categoryControllers: _categoryControllers,
        ),
      ],
    );
  }

  Widget _buildLargeScreenLayout(Color color, {Doctor? doctor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: DoctorDetailsFormCard(
            color: color,
            formKey: _detailsFormKey,
            firstNameController: _firstNameController,
            lastNameController: _lastNameController,
            hospitalController: _hospitalController,
            emailController: _emailController,
            phoneController: _phoneController,
            addressController: _addressController,
          ),
        ),
        SizedBox(width: defaultWidth),
        Expanded(
          child: DoctorIncentivesFormCard(
            color: color,
            formKey: _incentivesFormKey,
            categories: _categories,
            categoryControllers: _categoryControllers,
          ),
        ),
      ],
    );
  }


  Widget _buildErrorWidget(String message) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final effectiveThemeColor =
        widget.themeColor ?? theme.colorScheme.secondary;

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
                'Error Loading Doctor',
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
                  if (widget.doctorId != null) {
                    ref.invalidate(singleDoctorProvider(widget.doctorId!));
                  }
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: effectiveThemeColor,
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
