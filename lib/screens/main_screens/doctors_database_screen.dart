import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/models/doctors_model.dart';
import 'package:labledger/providers/doctor_provider.dart';

class DoctorsDatabaseScreen extends ConsumerWidget {
  const DoctorsDatabaseScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int centerId = 0;
    final doctorsAsync = ref.watch(doctorNotifierProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Doctors')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: doctorsAsync.when(
          data: (doctors) => LayoutBuilder(
            builder: (context, constraints) {
              centerId = doctors[0].centerDetail!;
              debugPrint(centerId.toString());
              int crossAxisCount = (constraints.maxWidth ~/ 250).clamp(2, 5);
              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 4 / 3,
                ),
                itemCount: doctors.length,
                itemBuilder: (context, index) =>
                    DoctorSummaryCard(doc: doctors[index]),
              );
            },
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error: $err')),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDoctorDialog(context, ref, centerId),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDoctorDialog(BuildContext context, WidgetRef ref, int ctrId) {
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final hospitalController = TextEditingController();
    final addressController = TextEditingController();
    final phoneController = TextEditingController();
    final ultrasoundController = TextEditingController();
    final pathologyController = TextEditingController();
    final ecgController = TextEditingController();
    final xrayController = TextEditingController();
    final franchiseLabController = TextEditingController();

    showDialog(
      context: context,

      builder: (_) => AlertDialog(
        title: const Text('Add Doctor'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: firstNameController,
                decoration: const InputDecoration(labelText: 'First Name'),
              ),
              TextField(
                controller: lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name'),
              ),
              TextField(
                controller: hospitalController,
                decoration: const InputDecoration(labelText: 'Hospital Name'),
              ),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
              ),
              TextField(
                controller: ultrasoundController,
                decoration: const InputDecoration(labelText: 'Ultrasound %'),
              ),
              TextField(
                controller: pathologyController,
                decoration: const InputDecoration(labelText: 'Pathology %'),
              ),
              TextField(
                controller: ecgController,
                decoration: const InputDecoration(labelText: 'ECG %'),
              ),
              TextField(
                controller: xrayController,
                decoration: const InputDecoration(labelText: 'X-Ray %'),
              ),
              TextField(
                controller: franchiseLabController,
                decoration: const InputDecoration(labelText: 'Franchise Lab %'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newDoctor = Doctor.fromJson({
                "first_name": firstNameController.text,
                "last_name": lastNameController.text,
                "hospital_name": hospitalController.text,
                "address": addressController.text,
                "phone_number": phoneController.text,
                "ultrasound_percentage":
                    int.tryParse(ultrasoundController.text) ?? 0,
                "pathology_percentage":
                    int.tryParse(pathologyController.text) ?? 0,
                "ecg_percentage": int.tryParse(ecgController.text) ?? 0,
                "xray_percentage": int.tryParse(xrayController.text) ?? 0,
                "franchise_lab_percentage":
                    int.tryParse(franchiseLabController.text) ?? 0,
                "center_detail": ctrId,
              });
              await ref
                  .read(doctorNotifierProvider.notifier)
                  .createDoctor(newDoctor);
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class DoctorSummaryCard extends ConsumerWidget {
  final Doctor doc;
  const DoctorSummaryCard({super.key, required this.doc});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _showUpdateDialog(context, ref),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: const Color(0xFFF9F9F9),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${doc.firstName} ${doc.lastName}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0061A8),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                doc.hospitalName!,
                style: const TextStyle(fontSize: 13, color: Colors.black87),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      doc.address!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUpdateDialog(BuildContext context, WidgetRef ref) {
    final firstNameController = TextEditingController(text: doc.firstName);
    final lastNameController = TextEditingController(text: doc.lastName);
    final hospitalController = TextEditingController(text: doc.hospitalName);
    final addressController = TextEditingController(text: doc.address);
    final phoneController = TextEditingController(text: doc.phoneNumber);
    final ultrasoundController = TextEditingController(
      text: doc.ultrasoundPercentage.toString(),
    );
    final pathologyController = TextEditingController(
      text: doc.pathologyPercentage.toString(),
    );
    final ecgController = TextEditingController(
      text: doc.ecgPercentage.toString(),
    );
    final xrayController = TextEditingController(
      text: doc.xrayPercentage.toString(),
    );
    final franchiseLabController = TextEditingController(
      text: doc.franchiseLabPercentage.toString(),
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Doctor'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: firstNameController,
                decoration: const InputDecoration(labelText: 'First Name'),
              ),
              TextField(
                controller: lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name'),
              ),
              TextField(
                controller: hospitalController,
                decoration: const InputDecoration(labelText: 'Hospital'),
              ),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
              ),
              TextField(
                controller: ultrasoundController,
                decoration: const InputDecoration(labelText: 'Ultrasound %'),
              ),
              TextField(
                controller: pathologyController,
                decoration: const InputDecoration(labelText: 'Pathology %'),
              ),
              TextField(
                controller: ecgController,
                decoration: const InputDecoration(labelText: 'ECG %'),
              ),
              TextField(
                controller: xrayController,
                decoration: const InputDecoration(labelText: 'X-Ray %'),
              ),
              TextField(
                controller: franchiseLabController,
                decoration: const InputDecoration(labelText: 'Franchise Lab %'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final updated = doc.copyWith(
                firstName: firstNameController.text,
                lastName: lastNameController.text,
                hospitalName: hospitalController.text,
                address: addressController.text,
                phoneNumber: phoneController.text,
                ultrasoundPercentage:
                    int.tryParse(ultrasoundController.text) ??
                    doc.ultrasoundPercentage,
                pathologyPercentage:
                    int.tryParse(pathologyController.text) ??
                    doc.pathologyPercentage,
                ecgPercentage:
                    int.tryParse(ecgController.text) ?? doc.ecgPercentage,
                xrayPercentage:
                    int.tryParse(xrayController.text) ?? doc.xrayPercentage,
                franchiseLabPercentage:
                    int.tryParse(franchiseLabController.text) ??
                    doc.franchiseLabPercentage,
              );
              await ref
                  .read(doctorNotifierProvider.notifier)
                  .updateDoctor(doc.id!, updated.toJson());
              Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
