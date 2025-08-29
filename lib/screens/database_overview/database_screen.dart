import 'package:flutter/material.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/main.dart';
import 'package:labledger/methods/custom_methods.dart';
import 'package:labledger/screens/database_overview/center_details/center_details_screen.dart';
import 'package:labledger/screens/database_overview/diagnosis_type/diagnosis_type_screen.dart';
import 'package:labledger/screens/database_overview/doctor/doctors_screen.dart';
import 'package:labledger/screens/database_overview/franchise_name/franchise_name_list_screen.dart';
import 'package:labledger/screens/database_overview/incentive/incentive_screen.dart';
import 'package:labledger/screens/profile/account_list_screen.dart';

class OptionList {
  String title;
  IconData icon;
  Widget goToPage;
  OptionList({required this.title, required this.icon, required this.goToPage});
}

class DatabaseScreen extends StatelessWidget {
  const DatabaseScreen({super.key, required this.userId});
  final int userId;

  @override
  Widget build(BuildContext context) {
    final List<OptionList> optionList = [
      OptionList(
        title: "Doctor's List",
        icon: Icons.medical_services,
        goToPage: const DoctorsScreen(),
      ),
      OptionList(
        title: "Diagnosis Types",
        icon: Icons.label,
        goToPage: DiagnosisTypeScreen(),
      ),
      OptionList(
        title: "Franchise Labs",
        icon: Icons.local_hospital_outlined,
        goToPage: FranchiseNameListScreen(),
      ),
      OptionList(
        title: "Center Details",
        icon: Icons.business_center_outlined,
        goToPage: CenterDetailsScreen(userId: userId),
      ),
      OptionList(
        title: "Generate Incentives",
        icon: Icons.currency_rupee,
        goToPage: IncentiveScreen(),
      ),
    ];
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
            padding: EdgeInsetsGeometry.symmetric(
              horizontal: defaultPadding / 2,
            ),
            child: Column(
              children: [
                pageHeader(context: context, centerWidget: null),
                Expanded(
                  child: Center(
                    child: GridView.builder(
                      shrinkWrap: true, // <-- important
                      physics:
                          const NeverScrollableScrollPhysics(), // <-- disables scrolling
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            childAspectRatio: 1.3,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                      itemCount: optionList.length,
                      itemBuilder: (context, index) {
                        return GridCard(
                          context: context,
                          onTap: () {
                            navigatorKey.currentState?.push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    optionList[index].goToPage,
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                optionList[index].icon,
                                size: 60,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              Text(
                                optionList[index].title,
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.secondary,
                                    ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
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
