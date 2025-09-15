import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/models/doctors_model.dart';
import 'package:labledger/providers/authentication_provider.dart';
import 'package:labledger/providers/doctor_provider.dart';
import 'package:labledger/screens/initials/window_scaffold.dart';
import 'package:labledger/screens/ui_components/custom_text_field.dart';
import 'package:labledger/screens/ui_components/tinted_container.dart';

class DoctorEditScreen extends ConsumerStatefulWidget {
  const DoctorEditScreen({super.key, this.doctorId, this.themeColor});

  final int? doctorId;
  final Color? themeColor;

  @override
  ConsumerState<DoctorEditScreen> createState() => _DoctorEditScreenState();
}

class _DoctorEditScreenState extends ConsumerState<DoctorEditScreen> {
  // MODIFICATION: Removed TabController and second form key
  final _formKey = GlobalKey<FormState>();

  // Doctor details controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _hospitalController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  // Commission rates controllers
  final _ultrasoundController = TextEditingController();
  final _pathologyController = TextEditingController();
  final _ecgController = TextEditingController();
  final _xrayController = TextEditingController();
  final _franchiseController = TextEditingController();

  bool _isSaving = false;
  bool _isDeleting = false;
  bool _isDataInitialized = false;

  bool get _isEditMode => widget.doctorId != null;

  @override
  void dispose() {
    // MODIFICATION: Simplified dispose method
    _firstNameController.dispose();
    _lastNameController.dispose();
    _hospitalController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _ultrasoundController.dispose();
    _pathologyController.dispose();
    _ecgController.dispose();
    _xrayController.dispose();
    _franchiseController.dispose();
    super.dispose();
  }

  void _initializeData(Doctor doctor) {
    if (!_isDataInitialized) {
      _firstNameController.text = doctor.firstName ?? '';
      _lastNameController.text = doctor.lastName ?? '';
      _hospitalController.text = doctor.hospitalName ?? '';
      _emailController.text = doctor.email ?? '';
      _phoneController.text = doctor.phoneNumber ?? '';
      _addressController.text = doctor.address ?? '';
      _ultrasoundController.text =
          doctor.ultrasoundPercentage?.toString() ?? '0';
      _pathologyController.text = doctor.pathologyPercentage?.toString() ?? '0';
      _ecgController.text = doctor.ecgPercentage?.toString() ?? '0';
      _xrayController.text = doctor.xrayPercentage?.toString() ?? '0';
      _franchiseController.text =
          doctor.franchiseLabPercentage?.toString() ?? '0';
      _isDataInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = ref.watch(currentUserProvider).value?.isAdmin ?? false;
    final effectiveThemeColor =
        widget.themeColor ?? Theme.of(context).colorScheme.secondary;

    // The main content to be built, used in both add and edit modes
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
                    Center(child: Text("Error loading doctor: $err")),
              )
        : _buildContent(isAdmin, effectiveThemeColor);

    return WindowScaffold(
      // MODIFICATION: Removed Center and ConstrainedBox
      child: SingleChildScrollView(
        padding: EdgeInsets.all(defaultPadding),
        child: content,
      ),
    );
  }

  Widget _buildContent(bool isAdmin, Color color, {Doctor? doctor}) {
    // MODIFICATION: This method is now much simpler
    return Column(
      children: [
        _buildDoctorHeaderCard(isAdmin, color, doctor),
        SizedBox(height: defaultHeight),
        _buildDoctorDetailsCard(isAdmin, color, doctor: doctor),
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
    final initials =
        '${doctor?.firstName?.isNotEmpty == true ? doctor!.firstName![0].toUpperCase() : 'D'}${doctor?.lastName?.isNotEmpty == true ? doctor!.lastName![0].toUpperCase() : 'R'}';

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
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
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
                        : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                SizedBox(height: defaultHeight / 2),
                if (isAdmin && _isEditMode)
                  _buildStatusBadge('Admin Edit Mode', Colors.purple),
              ],
            ),
          ),
          Column(
            children: [
              if (!_isEditMode || isAdmin)
                ElevatedButton.icon(
                  onPressed: _isSaving ? null : () => _handleSave(doctor),
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(180, 60),
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(defaultRadius),
                    ),
                  ),
                  icon: _isSaving
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(
                    _isSaving
                        ? 'Saving...'
                        : (_isEditMode ? 'Update Doctor' : 'Create Doctor'),
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              if (isAdmin && _isEditMode) ...[
                SizedBox(height: defaultHeight / 2),
                OutlinedButton.icon(
                  onPressed: _isDeleting ? null : () => _handleDelete(doctor!),
                  style: OutlinedButton.styleFrom(
                    fixedSize: Size(180, 50),
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(defaultRadius),
                    ),
                  ),
                  icon: _isDeleting
                      ? SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.error,
                          ),
                        )
                      : const Icon(Icons.delete_outline),
                  label: Text('Delete Doctor'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorDetailsCard(bool isAdmin, Color color, {Doctor? doctor}) {
    final bool isReadOnly = _isEditMode && !isAdmin;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Form(
      key: _formKey, // Use single form key
      child: TintedContainer(
        baseColor: color,
        height: 390,
        radius: defaultRadius,
        elevationLevel: 1,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    widget.themeColor == null
                          ? Theme.of(context).colorScheme.secondary.withValues(
                              alpha: isDark ? 0.2 : 0.1,
                            )
                          : widget.themeColor!
                      ..withValues(alpha: isDark ? 0.2 : 0.1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(defaultRadius),
                  topRight: Radius.circular(defaultRadius),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
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
                    'Doctor Details & Incentives',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? Colors.white
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: defaultHeight),
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'First Name',
                        controller: _firstNameController,
                        isRequired: true,
                        readOnly: isReadOnly,
                        tintColor: color,
                      ),
                    ),
                    SizedBox(width: defaultWidth),
                    Expanded(
                      child: CustomTextField(
                        label: 'Last Name',
                        controller: _lastNameController,
                        isRequired: true,
                        readOnly: isReadOnly,
                        tintColor: color,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: defaultHeight),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Hospital / Clinic Name',
                        controller: _hospitalController,
                        isRequired: true,
                        readOnly: isReadOnly,
                        tintColor: color,
                      ),
                    ),
                    SizedBox(width: defaultWidth),
                    Expanded(
                      child: CustomTextField(
                        label: 'Address',
                        controller: _addressController,
                        readOnly: isReadOnly,
                        tintColor: color,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: defaultHeight),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Email Address',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        readOnly: isReadOnly,
                        tintColor: color,
                      ),
                    ),
                    SizedBox(width: defaultWidth),
                    Expanded(
                      child: CustomTextField(
                        label: 'Phone Number',
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        isRequired: true,
                        readOnly: isReadOnly,
                        tintColor: color,
                      ),
                    ),
                  ],
                ),

                // MODIFICATION: Incentive fields moved here
                Divider(
                  height: 40,
                  thickness: 1,
                  color: color.withValues(alpha: 0.2),
                ),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Ultrasound %',
                        controller: _ultrasoundController,
                        keyboardType: TextInputType.number,
                        isNumeric: true,
                        isRequired: true,
                        readOnly: isReadOnly,
                        tintColor: color,
                      ),
                    ),
                    SizedBox(width: defaultWidth),
                    Expanded(
                      child: CustomTextField(
                        label: 'Pathology %',
                        controller: _pathologyController,
                        keyboardType: TextInputType.number,
                        isNumeric: true,
                        isRequired: true,
                        readOnly: isReadOnly,
                        tintColor: color,
                      ),
                    ),
                    SizedBox(width: defaultWidth),

                    Expanded(
                      child: CustomTextField(
                        label: 'ECG %',
                        controller: _ecgController,
                        keyboardType: TextInputType.number,
                        isNumeric: true,
                        isRequired: true,
                        readOnly: isReadOnly,
                        tintColor: color,
                      ),
                    ),
                    SizedBox(width: defaultWidth),
                    Expanded(
                      child: CustomTextField(
                        label: 'X-Ray %',
                        controller: _xrayController,
                        keyboardType: TextInputType.number,
                        isNumeric: true,
                        isRequired: true,
                        readOnly: isReadOnly,
                        tintColor: color,
                      ),
                    ),
                    SizedBox(width: defaultWidth),
                    Expanded(
                      child: CustomTextField(
                        label: 'Franchise Lab %',
                        controller: _franchiseController,
                        keyboardType: TextInputType.number,
                        isNumeric: true,
                        isRequired: true,
                        readOnly: isReadOnly,
                        tintColor: color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSave(Doctor? originalDoctor) async {
    // MODIFICATION: Validate single form key
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      if (_isEditMode) {
        final Map<String, dynamic> updatedData = {
          "first_name": _firstNameController.text.trim(),
          "last_name": _lastNameController.text.trim(),
          "hospital_name": _hospitalController.text.trim(),
          "email": _emailController.text.trim(),
          "phone_number": _phoneController.text.trim(),
          "address": _addressController.text.trim(),
          "ultrasound_percentage": int.parse(_ultrasoundController.text.trim()),
          "pathology_percentage": int.parse(_pathologyController.text.trim()),
          "ecg_percentage": int.parse(_ecgController.text.trim()),
          "xray_percentage": int.parse(_xrayController.text.trim()),
          "franchise_lab_percentage": int.parse(
            _franchiseController.text.trim(),
          ),
        };
        await ref.read(
          updateDoctorProvider({
            'id': originalDoctor!.id!,
            'data': updatedData,
          }).future,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Doctor updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        final newDoctor = Doctor(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          hospitalName: _hospitalController.text.trim(),
          email: _emailController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          address: _addressController.text.trim(),
          ultrasoundPercentage: int.parse(_ultrasoundController.text.trim()),
          pathologyPercentage: int.parse(_pathologyController.text.trim()),
          ecgPercentage: int.parse(_ecgController.text.trim()),
          xrayPercentage: int.parse(_xrayController.text.trim()),
          franchiseLabPercentage: int.parse(_franchiseController.text.trim()),
        );
        await ref.read(createDoctorProvider(newDoctor).future);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Doctor created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${e.toString().replaceAll("Exception: ", "")}',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
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
        title: const Text('Confirm Deletion'),
        content: Text(
          'Are you sure you want to delete Dr. ${doctor.firstName} ${doctor.lastName}? All the bills and records related to this doctor will be deleted which cannot be undone.',
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
          const SnackBar(
            content: Text('Doctor deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${e.toString().replaceAll("Exception: ", "")}',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
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
}
