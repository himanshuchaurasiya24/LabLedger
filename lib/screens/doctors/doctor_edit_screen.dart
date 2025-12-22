import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/models/doctors_model.dart';
import 'package:labledger/providers/authentication_provider.dart';
import 'package:labledger/providers/doctor_provider.dart';
import 'package:labledger/providers/category_provider.dart';
import 'package:labledger/models/diagnosis_category_model.dart';
import 'package:labledger/screens/initials/window_scaffold.dart';
import 'package:labledger/screens/ui_components/custom_error_dialog.dart';
import 'package:labledger/screens/ui_components/custom_text_field.dart';
import 'package:labledger/screens/ui_components/tinted_container.dart';

class DoctorEditScreen extends ConsumerStatefulWidget {
  const DoctorEditScreen({super.key, this.doctorId, this.themeColor});

  final int? doctorId;
  final Color? themeColor;

  @override
  ConsumerState<DoctorEditScreen> createState() => _DoctorEditScreenState();
}

class _DoctorEditScreenState extends ConsumerState<DoctorEditScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _detailsFormKey = GlobalKey<FormState>();
  final _incentivesFormKey = GlobalKey<FormState>();

  // Doctor details controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _hospitalController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  // Dynamic incentives controllers map: category_id -> controller
  Map<int, TextEditingController> _categoryControllers = {};
  List<DiagnosisCategory> _categories = [];

  bool _isSaving = false;
  // ignore: unused_field
  bool _isDeleting = false;
  bool _isDataInitialized = false;

  bool get _isEditMode => widget.doctorId != null;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await ref.read(categoriesProvider.future);
      setState(() {
        _categories = categories;
        // Create controllers for each category
        for (var category in categories) {
          _categoryControllers[category.id] = TextEditingController();
        }
      });

      // Re-initialize doctor data if in edit mode and doctor was already loaded
      if (_isEditMode && _loadedDoctor != null) {
        _initializeData(_loadedDoctor!);
      }
    } catch (e) {
      // Handle error
      print('Error loading categories: $e');
    }
  }

  Doctor?
  _loadedDoctor; // Store loaded doctor for re-initialization after categories load

  @override
  void dispose() {
    _tabController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _hospitalController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    // Dispose all dynamic category controllers
    for (var controller in _categoryControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initializeData(Doctor doctor) {
    if (!_isDataInitialized) {
      _loadedDoctor =
          doctor; // Store for re-initialization after categories load
      _firstNameController.text = doctor.firstName ?? '';
      _lastNameController.text = doctor.lastName ?? '';
      _hospitalController.text = doctor.hospitalName ?? '';
      _emailController.text = doctor.email ?? '';
      _phoneController.text = doctor.phoneNumber ?? '';
      _addressController.text = doctor.address ?? '';

      _isDataInitialized = true;
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final title = _isEditMode
        ? '${doctor?.firstName ?? ''} ${doctor?.lastName ?? ''}'
        : 'New Doctor Profile';
    final subtitle = _isEditMode
        ? doctor?.hospitalName ?? ''
        : 'Enter doctor details below';
    final initials = _isEditMode
        ? '${doctor?.firstName?.isNotEmpty == true ? doctor!.firstName![0].toUpperCase() : 'D'}${doctor?.lastName?.isNotEmpty == true ? doctor!.lastName![0].toUpperCase() : 'R'}'
        : 'DR';

    final lightThemeColor = Color.lerp(
      color,
      isDark ? Colors.black : Colors.white,
      isDark ? 0.3 : 0.2,
    )!;

    return TintedContainer(
      baseColor: color,
      height: 160,
      radius: defaultRadius,
      intensity: isDark ? 0.15 : 0.08,
      useGradient: true,
      elevationLevel: 2,
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
                  color: color.withValues(
                    alpha: 0.3,
                  ), // Using withValues alpha:  for simplicity
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: defaultWidth / 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? Colors.white70
                        : theme.colorScheme.onSurface.withValues(
                            alpha: 0.7,
                          ), // Using withValues alpha:  for simplicity
                  ),
                ),
                SizedBox(height: defaultHeight / 2),
                Row(
                  children: [
                    if (isAdmin && _isEditMode) ...[
                      _buildStatusBadge('Admin Edit Mode', Colors.purple),
                      SizedBox(width: defaultWidth / 2),
                    ],
                    _buildStatusBadge(
                      _isEditMode ? 'Edit Mode' : 'Create Mode',
                      _isEditMode
                          ? Colors.blue
                          : Theme.of(context).colorScheme.secondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // ✅ Conditional visibility for the entire button column
          if (!_isEditMode || isAdmin)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _isSaving ? null : () => _handleSave(doctor),
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(180, 60),
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(defaultRadius),
                    ),
                  ),
                  icon: _isSaving
                      ? SizedBox(
                          height: defaultHeight,
                          width: defaultWidth,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Icon(_isEditMode ? Icons.update : Icons.save),
                  label: Text(
                    _isSaving
                        ? 'Saving...'
                        : (_isEditMode ? 'Update Doctor' : 'Create Doctor'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // ✅ The delete button is now conditional on BOTH edit mode AND admin status
                if (_isEditMode && isAdmin) ...[
                  SizedBox(height: defaultHeight / 2),
                  OutlinedButton.icon(
                    onPressed: () => _handleDelete(doctor!),
                    style: OutlinedButton.styleFrom(
                      fixedSize: const Size(180, 60),
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
        _buildDoctorDetailsCard(color, doctor: doctor),
        _buildIncentivesCard(color, doctor: doctor),
      ],
    );
  }

  Widget _buildLargeScreenLayout(Color color, {Doctor? doctor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildDoctorDetailsCard(color, doctor: doctor)),
        SizedBox(width: defaultWidth),
        Expanded(child: _buildIncentivesCard(color, doctor: doctor)),
      ],
    );
  }

  Widget _buildDoctorDetailsCard(Color color, {Doctor? doctor}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TintedContainer(
      baseColor: color,
      height: 510,
      radius: defaultRadius,
      elevationLevel: 1,
      child: Column(
        children: [
          Container(
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
                  child: Icon(
                    Icons.medical_services_outlined,
                    color: color,
                    size: 20,
                  ),
                ),
                SizedBox(width: defaultWidth / 2),
                Text(
                  'Doctor Information',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: defaultHeight),
          Expanded(
            child: Form(
              key: _detailsFormKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            label: 'First Name',
                            controller: _firstNameController,
                            isRequired: true,
                            tintColor: color,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'First name is required';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(width: defaultWidth / 2),
                        Expanded(
                          child: CustomTextField(
                            label: 'Last Name',
                            controller: _lastNameController,
                            isRequired: true,
                            tintColor: color,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Last name is required';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: defaultHeight),
                    CustomTextField(
                      label: 'Hospital / Clinic Name',
                      controller: _hospitalController,
                      isRequired: true,
                      tintColor: color,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Hospital/Clinic name is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: defaultHeight),
                    CustomTextField(
                      label: 'Email Address',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      tintColor: color,
                      validator: (value) {
                        if (value != null && value.trim().isNotEmpty) {
                          if (!RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          ).hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: defaultHeight),
                    CustomTextField(
                      label: 'Phone Number',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      isRequired: true,
                      tintColor: color,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Phone number is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: defaultHeight),
                    CustomTextField(
                      label: 'Address',
                      controller: _addressController,
                      tintColor: color,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Address is required';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncentivesCard(Color color, {Doctor? doctor}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TintedContainer(
      baseColor: color,
      radius: defaultRadius,
      height: 510,
      elevationLevel: 1,
      child: Column(
        children: [
          Container(
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
                  child: Icon(Icons.percent, color: color, size: 20),
                ),
                SizedBox(width: defaultWidth / 2),
                Text(
                  'Incentives Rates (%)',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: defaultHeight),
          Expanded(
            child: Form(
              key: _incentivesFormKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(defaultPadding),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: isDark ? 0.1 : 0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: color.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: color, size: 20),
                          SizedBox(width: defaultWidth / 2),
                          Expanded(
                            child: Text(
                              'Leave fields empty or enter 0 if no Incentives applies for that service.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDark
                                    ? Colors.white70
                                    : theme.colorScheme.onSurface.withValues(
                                        alpha: 0.7,
                                      ),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: defaultHeight),
                    // Dynamic category incentive fields
                    ..._buildDynamicIncentiveFields(color),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper to build dynamic incentive fields
  List<Widget> _buildDynamicIncentiveFields(Color color) {
    if (_categories.isEmpty) {
      return [
        Center(
          child: Padding(
            padding: EdgeInsets.all(defaultPadding * 2),
            child: Text('Loading categories...'),
          ),
        ),
      ];
    }

    List<Widget> widgets = [];
    // Build in pairs for 2-column layout
    for (int i = 0; i < _categories.length; i += 2) {
      final category1 = _categories[i];
      final controller1 = _categoryControllers[category1.id];

      if (i + 1 < _categories.length) {
        // Two categories in this row
        final category2 = _categories[i + 1];
        final controller2 = _categoryControllers[category2.id];

        widgets.add(
          Row(
            children: [
              Expanded(
                child: _buildIncentiveField(
                  '${category1.name} Incentives',
                  controller1!,
                  color,
                  _getIconForCategory(category1.name),
                ),
              ),
              SizedBox(width: defaultWidth),
              Expanded(
                child: _buildIncentiveField(
                  '${category2.name} Incentives',
                  controller2!,
                  color,
                  _getIconForCategory(category2.name),
                ),
              ),
            ],
          ),
        );
      } else {
        // Single category in this row
        widgets.add(
          _buildIncentiveField(
            '${category1.name} Incentives',
            controller1!,
            color,
            _getIconForCategory(category1.name),
          ),
        );
      }

      if (i + 2 < _categories.length) {
        widgets.add(SizedBox(height: defaultHeight));
      }
    }

    return widgets;
  }

  // Helper to get appropriate icon for category
  IconData _getIconForCategory(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('ultrasound')) return Icons.monitor_heart_outlined;
    if (name.contains('pathology')) return Icons.biotech_outlined;
    if (name.contains('ecg')) return Icons.favorite_outline;
    if (name.contains('x-ray') || name.contains('xray'))
      return Icons.camera_outlined;
    if (name.contains('franchise')) return Icons.business_outlined;
    return Icons.medical_services_outlined;
  }

  Widget _buildIncentiveField(
    String label,
    TextEditingController controller,
    Color color,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(width: defaultWidth / 2),

            Icon(icon, color: color, size: 16),
            SizedBox(width: defaultWidth / 4),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        CustomTextField(
          label: '${label.split(' ')[0]} %',
          controller: controller,
          keyboardType: TextInputType.number,
          isNumeric: true,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          tintColor: color,
          validator: (value) {
            if (value != null && value.trim().isNotEmpty) {
              final parsed = int.tryParse(value.trim());
              if (parsed == null) {
                return 'Please enter a valid number';
              }
              if (parsed < 0 || parsed > 100) {
                return 'Percentage must be between 0 and 100';
              }
            }
            return null;
          },
        ),
      ],
    );
  }

  Future<void> _handleSave(Doctor? originalDoctor) async {
    // Validate both forms
    final detailsValid = _detailsFormKey.currentState!.validate();
    final incentivesValid = _incentivesFormKey.currentState!.validate();

    if (!detailsValid || !incentivesValid) {
      if (!detailsValid) {
        _tabController.animateTo(0); // Switch to details tab
      } else if (!incentivesValid) {
        _tabController.animateTo(1); // Switch to incentives tab
      }
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Build category percentages list from dynamic controllers
      final categoryPercentages = _categoryControllers.entries.map((entry) {
        final categoryId = entry.key;
        final controller = entry.value;
        final percentage = int.tryParse(controller.text) ?? 0;

        return DoctorCategoryPercentage(
          id: 0, // Will be assigned by backend
          category: categoryId,
          percentage: percentage,
        );
      }).toList();

      if (_isEditMode) {
        await ref.read(
          updateDoctorProvider(
            Doctor(
              id: widget.doctorId,
              address: _addressController.text,
              email: _emailController.text,
              firstName: _firstNameController.text,
              hospitalName: _hospitalController.text,
              lastName: _lastNameController.text,
              phoneNumber: _phoneController.text,
              categoryPercentages: categoryPercentages,
            ),
          ).future,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,

              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Doctor updated successfully!'),
                ],
              ),
              backgroundColor: Theme.of(context).colorScheme.secondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      } else {
        final newDoctor = Doctor(
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

        await ref.read(createDoctorProvider(newDoctor).future);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,

              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Doctor created successfully!'),
                ],
              ),
              backgroundColor: Theme.of(context).colorScheme.secondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      }

      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => ErrorDialog(
            title: 'Operation Failed',
            errorMessage: e.toString().replaceAll("Exception: ", ""),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _handleDelete(Doctor doctor) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(defaultRadius),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 8),
            const Text('Confirm Deletion'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete Dr. ${doctor.firstName} ${doctor.lastName}?\n\nAll bills and records related to this doctor will be permanently deleted. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Delete',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isDeleting = true);
    try {
      await ref.read(deleteDoctorProvider(doctor.id!).future);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,

            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Doctor deleted successfully!'),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.secondary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(
          'Delete Failed',
          e.toString().replaceAll("Exception: ", ""),
        );
      }
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
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

  void _showErrorDialog(String title, String errorMessage) {
    showDialog(
      context: context,
      builder: (context) =>
          ErrorDialog(title: title, errorMessage: errorMessage),
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
