import 'package:flutter/material.dart';
import 'package:labledger/methods/custom_methods.dart';
import 'package:labledger/providers/custom_providers.dart';
import 'package:labledger/screens/doctor/doctors_screen.dart';

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
            goToPage: DoctorsScreen(),
          ),
        ],
      ),
    );
  }
}
