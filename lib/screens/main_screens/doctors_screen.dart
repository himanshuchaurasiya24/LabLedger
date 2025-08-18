import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/methods/custom_methods.dart';
import 'package:labledger/models/doctors_model.dart';
import 'package:labledger/providers/custom_providers.dart';
import 'package:labledger/providers/doctor_provider.dart';
import 'package:labledger/screens/profile/account_list_screen.dart';

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
        final phoneNumberMatches = <Doctor>[];

        for (var doctor in data) {
          final fullName = "${doctor.firstName} ${doctor.lastName ?? ""}"
              .toLowerCase();
          final hospital = doctor.hospitalName?.toLowerCase() ?? "";
          final address = doctor.address?.toLowerCase() ?? "";
          final phoneNumber = doctor.phoneNumber?.toString();
          if (fullName.contains(query) || query.contains(fullName)) {
            nameMatches.add(doctor);
          } else if (hospital.contains(query) || query.contains(hospital)) {
            hospitalMatches.add(doctor);
          } else if (address.contains(query) || query.contains(address)) {
            addressMatches.add(doctor);
          } else if (phoneNumber!.contains(query) ||
              query.contains(phoneNumber)) {
            phoneNumberMatches.add(doctor);
          }
        }

        return {
          if (nameMatches.isNotEmpty) 'Name Matches': nameMatches,
          if (hospitalMatches.isNotEmpty) 'Hospital Matches': hospitalMatches,
          if (addressMatches.isNotEmpty) 'Address Matches': addressMatches,
          if (phoneNumberMatches.isNotEmpty)
            'Phone Number Matches': phoneNumberMatches,
        };
      },
      error: (err, st) => {},
      loading: () => {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          height: MediaQuery.of(context).size.height * 0.95,
          width: MediaQuery.of(context).size.width * 0.7,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.tertiaryFixed,
            borderRadius: BorderRadius.circular(defaultPadding / 2),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: defaultPadding / 2),
            //FocusTraversalGroup
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                pageHeader(
                  context: context,
                  centerWidget: Row(
                    children: [
                      CenterSearchBar(
                        controller: searchController,
                        hintText: "Search Doctors...",
                        searchFocusNode: searhFocusNode,
                        onSearch: () {
                          setState(
                            () {},
                          ); // Trigger UI update for FutureBuilder
                        },
                      ),
                      const SizedBox(width: 160),
                    ],
                  ),
                ),
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
                      return SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: grouped.entries.map((e) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Group title (key)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 6,
                                    horizontal: 6,
                                  ),
                                  child: Text(
                                    e.key,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.headlineMedium,
                                  ),
                                ),

                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        childAspectRatio: 1.39,
                                        crossAxisSpacing: 16,
                                        mainAxisSpacing: 16,
                                      ),
                                  itemCount: e.value.length,
                                  itemBuilder: (ctx, index) {
                                    final doctor = e.value[index];
                                    return GridCard(
                                      context: context,

                                      onTap: () {
                                        // Handle card tap (navigate or show details)
                                      },
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          CircleAvatar(
                                            radius: 40,
                                            backgroundColor: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                            child: Text(
                                              doctor.firstName![0]
                                                  .toUpperCase(),
                                              style: TextStyle(
                                                fontSize: 30,
                                                fontWeight: FontWeight.bold,
                                                color: ThemeData.light()
                                                    .scaffoldBackgroundColor,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            "${doctor.firstName} ${doctor.lastName ?? ''}",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 27,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "${doctor.hospitalName}, ${doctor.address}"
                                            "",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(fontSize: 16),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "Phone: ${doctor.phoneNumber}",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(fontSize: 16),
                                          ),
                                          const SizedBox(height: 4),
                                          Container(
                                            padding: const EdgeInsets.all(8.0),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary
                                                  .withValues(alpha: 0.8),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    defaultPadding / 2,
                                                  ),
                                            ),
                                            child: Text(
                                              "USG: ${doctor.ultrasoundPercentage.toString()} Path: ${doctor.pathologyPercentage.toString()} ECG: ${doctor.ecgPercentage.toString()} X-Ray: ${doctor.xrayPercentage.toString()} FLab: ${doctor.franchiseLabPercentage.toString()}",
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: ThemeData.light()
                                                    .scaffoldBackgroundColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),

                                const SizedBox(height: 30),
                              ],
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
