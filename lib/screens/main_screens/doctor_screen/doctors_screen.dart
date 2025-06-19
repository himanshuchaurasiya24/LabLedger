import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/methods/custom_methods.dart';
import 'package:labledger/models/doctors_model.dart';
import 'package:labledger/providers/custom_providers.dart';
import 'package:labledger/providers/doctor_provider.dart';

class DoctorsScreen extends ConsumerStatefulWidget {
  const DoctorsScreen({super.key});

  @override
  ConsumerState<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends ConsumerState<DoctorsScreen> {
  final TextEditingController searchController = TextEditingController();
  final searhFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    setWindowBehavior(removeTitleBar: true);
    searhFocusNode.requestFocus();
  }

  @override
  void dispose() {
    searchController.dispose();
    searhFocusNode.dispose();
    super.dispose();
  }

  Future<Map<String, List<Doctor>>> fetchDoctors() async {
    final doctorAsync = ref.watch(doctorsProvider);
    final query = searchController.text.trim().toLowerCase();

    return doctorAsync.when(
      data: (data) {
        if (query.isEmpty) {
          return {'All Doctors': data};
        }

        final nameMatches = <Doctor>[];
        final hospitalMatches = <Doctor>[];
        final addressMatches = <Doctor>[];

        for (var doctor in data) {
          final fullName = "${doctor.firstName} ${doctor.lastName ?? ""}"
              .toLowerCase();
          final hospital = doctor.hospitalName?.toLowerCase() ?? "";
          final address = doctor.address?.toLowerCase() ?? "";

          if (fullName.contains(query) || query.contains(fullName)) {
            nameMatches.add(doctor);
          } else if (hospital.contains(query) || query.contains(hospital)) {
            hospitalMatches.add(doctor);
          } else if (address.contains(query) || query.contains(address)) {
            addressMatches.add(doctor);
          }
        }

        return {
          if (nameMatches.isNotEmpty) 'Name Matches': nameMatches,
          if (hospitalMatches.isNotEmpty) 'Hospital Matches': hospitalMatches,
          if (addressMatches.isNotEmpty) 'Address Matches': addressMatches,
        };
      },
      error: (err, st) => {},
      loading: () => {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(
          left: defaultPadding * 2,
          right: defaultPadding * 2,
          top: defaultPadding,
        ),
        child: FocusTraversalGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              settingsPageTopBar(
                context: context,
                centerWidget: CenterSearchBar(
                  controller: searchController,
                  hintText: "Search Doctors...",
                  searchFocusNode: searhFocusNode,
                  onSearch: () {
                    setState(() {}); // Trigger UI update for FutureBuilder
                  },
                ),
                chipColor: Colors.red[600]!,
              ),
              const SizedBox(height: 10),
              Expanded(
                child: FutureBuilder<Map<String, List<Doctor>>>(
                  future: fetchDoctors(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error: ${snapshot.error}',
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Text(
                          'No doctors found.',
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                      );
                    }

                    final grouped = snapshot.data!;
                    return ListView(
                      children: grouped.entries.map((entry) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 6,
                              ),
                              child: Text(
                                entry.key,
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineMedium,
                              ),
                            ),
                            ...entry.value.map((doctor) {
                              return customBar(
                                context: context,
                                barText:
                                    "${doctor.firstName} ${doctor.lastName ?? ''}",
                                iconData: Icons.person,
                                child: Text(doctor.hospitalName ?? ''),
                              );
                            }),
                            Divider(
                              thickness: 5,
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.light
                                  ? containerLightColor
                                  : containerDarkColor,
                              indent: 50,
                              endIndent: 50,
                              radius: BorderRadius.circular(
                                minimalBorderRadius,
                              ),
                            ),
                            const SizedBox(height: 30),
                          ],
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
