// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:labledger/main.dart';
import 'package:labledger/methods/custom_methods.dart';

import 'package:labledger/providers/custom_providers.dart';
import 'package:labledger/screens/main_screens/doctors_screen.dart';
import 'package:labledger/screens/profile/account_list_screen.dart';

class OptionList {
  String title;
  IconData icon;
  Widget goToPage;
  OptionList({required this.title, required this.icon, required this.goToPage});
}

class DatabaseScreen extends StatelessWidget {
  DatabaseScreen({super.key});
  final List<OptionList> optionList = [
    OptionList(
      title: "Doctor's List",
      icon: Icons.medical_services,
      goToPage: const DoctorsScreen(),
    ),
    OptionList(
      title: "Diagnosis Types",
      icon: Icons.label,
      goToPage: DoctorsScreen(),
    ),
    OptionList(
      title: "Franchise Labs",
      icon: Icons.local_hospital_outlined,
      goToPage: DoctorsScreen(),
    ),
    OptionList(
      title: "Center Details",
      icon: Icons.business_center_outlined,
      goToPage: DoctorsScreen(),
    ),
  ];
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
            padding: EdgeInsetsGeometry.symmetric(
              horizontal: defaultPadding / 2,
            ),
            child: Column(
              children: [
                pageHeader(context: context, centerWidget: null),

                Spacer(),

                Expanded(
                  child: GridView.builder(
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
                              builder: (context) {
                                return optionList[index].goToPage;
                              },
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
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
