import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/models/doctors_model.dart';
import 'package:labledger/providers/doctor_provider.dart';

class DoctorsDatabaseScreen extends ConsumerStatefulWidget {
  const DoctorsDatabaseScreen({super.key});

  @override
  ConsumerState<DoctorsDatabaseScreen> createState() =>
      _DoctorsDatabaseScreenState();
}

class _DoctorsDatabaseScreenState extends ConsumerState<DoctorsDatabaseScreen> {
  @override
  void initState() {
    super.initState();
    // Invalidate to force refetch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(doctorNotifierProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final doctorsAsync = ref.watch(doctorNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Doctors List')),
      body: doctorsAsync.when(
        data: (doctors) {
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: doctors.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final doc = doctors[index];
              return DoctorCard(doc: doc);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class DoctorCard extends ConsumerStatefulWidget {
  final Doctor doc;

  const DoctorCard({super.key, required this.doc});

  @override
  ConsumerState<DoctorCard> createState() => _DoctorCardState();
}

class _DoctorCardState extends ConsumerState<DoctorCard> {
  bool isExpanded = false;

  void showEditDialog(Doctor doc) {
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
    final franchiseController = TextEditingController(
      text: doc.franchiseLabPercentage.toString(),
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Update Doctor Info'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              _buildPercentageField('Ultrasound %', ultrasoundController),
              _buildPercentageField('Pathology %', pathologyController),
              _buildPercentageField('ECG %', ecgController),
              _buildPercentageField('X-Ray %', xrayController),
              _buildPercentageField('Franchise Lab %', franchiseController),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final updated = doc.copyWith(
                ultrasoundPercentage: int.parse(ultrasoundController.text),
                pathologyPercentage: int.parse(pathologyController.text),
                ecgPercentage: int.parse(ecgController.text),
                xrayPercentage: int.parse(xrayController.text),
                franchiseLabPercentage: int.parse(franchiseController.text),
              );
              ref
                  .read(doctorNotifierProvider.notifier)
                  .updateDoctor(doc.id, updated.toJson());
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildPercentageField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final doc = widget.doc;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ExpansionTile(
        // visualDensity: VisualDensity.adaptivePlatformDensity,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
        title: Text(
          '${doc.firstName} ${doc.lastName}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(doc.phoneNumber),
        onExpansionChanged: (val) => setState(() => isExpanded = val),
        childrenPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        children: [
          _infoText('Address', doc.address),
          _infoText('Ultrasound %', doc.ultrasoundPercentage.toString()),
          _infoText('Pathology %', doc.pathologyPercentage.toString()),
          _infoText('ECG %', doc.ecgPercentage.toString()),
          _infoText('X-Ray %', doc.xrayPercentage.toString()),
          _infoText('Franchise Lab %', doc.franchiseLabPercentage.toString()),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => showEditDialog(doc),
                icon: const Icon(
                  Icons.edit,
                  size: 18,
                  color: Color(0xFF0061A8),
                ),
                label: const Text(
                  'Update',
                  style: TextStyle(color: Color(0xFF0061A8)),
                ),
              ),
              TextButton.icon(
                onPressed: () => ref
                    .read(doctorNotifierProvider.notifier)
                    .deleteDoctor(doc.id),
                icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                label: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
