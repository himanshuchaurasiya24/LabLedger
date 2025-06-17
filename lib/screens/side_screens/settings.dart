import 'package:flutter/material.dart';
import 'package:labledger/methods/custom_methods.dart';
import 'package:labledger/providers/custom_providers.dart';
import 'package:labledger/screens/main_screens/bills_database_screen.dart';
import 'package:labledger/screens/main_screens/diagnosis_type_database_screen.dart';
import 'package:labledger/screens/main_screens/doctors_database_screen.dart';
import 'package:labledger/screens/main_screens/report_database_screen.dart';
import "package:lucide_icons/lucide_icons.dart";

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          ThemeToggleBar(),
          SizedBox(height: defaultPadding),

          Text(
            "Database Manager",
            style: Theme.of(
              context,
            ).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: defaultPadding / 2),
          PageNavigatorBar(
            iconData: Icons.person_4_outlined,
            barText: 'Doctors',
            goToPage: DoctorsDatabaseScreen(),
          ),
          SizedBox(height: defaultPadding / 2),
          PageNavigatorBar(
            iconData: Icons.medical_services,
            barText: "Diagnonsis Types",
            goToPage: DiagnosisTypeDatabaseScreen(),
          ),
          SizedBox(height: defaultPadding / 2),
          PageNavigatorBar(
            iconData: LucideIcons.fileText,
            barText: "Bills",
            goToPage: BillsDatabaseScreen(),
          ),
          SizedBox(height: defaultPadding / 2),
          PageNavigatorBar(
            iconData: LucideIcons.bookOpen,
            barText: "Reports",
            goToPage: ReportDatabaseScreen(),
          ),
        ],
      ),
    );
  }
}
