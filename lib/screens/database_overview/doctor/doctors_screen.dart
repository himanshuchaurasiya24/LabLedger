import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/main.dart';
import 'package:labledger/methods/custom_methods.dart';
import 'package:labledger/models/doctors_model.dart';
import 'package:labledger/providers/doctor_provider.dart';
import 'package:labledger/screens/database_overview/doctor/add_doctor_screen.dart';
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
      backgroundColor: Theme.of(context).colorScheme.tertiaryFixed,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Theme.of(context).colorScheme.primary,
        onPressed: () {
          navigatorKey.currentState?.push(
            MaterialPageRoute(builder: (context) => AddDoctorScreen()),
          );
        },
        label: Text(
          "Add Doctor",
          style: TextStyle(
            color: ThemeData.light().scaffoldBackgroundColor,
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: defaultPadding),
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
                    onSearch: (e) {
                      setState(() {}); // Trigger UI update for FutureBuilder
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
                                    crossAxisCount: 4,
                                    childAspectRatio: 1.64,
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
                                    navigatorKey.currentState?.push(
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return AddDoctorScreen(
                                            doctor: doctor,
                                          );
                                        },
                                      ),
                                    );
                                  },
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            height: 55,
                                            width: 55,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),

                                              color: Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                            ),
                                            child: Center(
                                              child: Text(
                                                doctor.firstName![0]
                                                        .toUpperCase() +
                                                    doctor.lastName![0]
                                                        .toUpperCase(),
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: ThemeData.light()
                                                      .scaffoldBackgroundColor,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "${doctor.firstName} ${doctor.lastName}",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleSmall
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 24,
                                                      ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 2,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary
                                                        .withValues(alpha: 0.8),

                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    doctor.hospitalName ?? "",
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        doctor.address ?? "",
                                        style: const TextStyle(fontSize: 20),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        doctor.phoneNumber ?? "",
                                        style: const TextStyle(fontSize: 20),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        doctor.email ?? "",
                                        style: TextStyle(fontSize: 19),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 5),
                                      Container(
                                        height: 40,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary
                                              .withValues(alpha: 0.8),
                                          borderRadius: BorderRadius.circular(
                                            defaultRadius / 2,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            "USG ${doctor.ultrasoundPercentage} Path ${doctor.pathologyPercentage} X-Ray ${doctor.xrayPercentage} ECG ${doctor.ecgPercentage} FLab ${doctor.franchiseLabPercentage} ",
                                            style: TextStyle(
                                              color: ThemeData.light()
                                                  .scaffoldBackgroundColor,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
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
    );
  }
}
