import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:labledger/methods/custom_methods.dart';
import 'package:labledger/providers/custom_providers.dart';
import 'package:labledger/screens/initials/login_screen.dart';
import 'package:labledger/screens/profile/profile_screen.dart';
import 'package:lucide_icons/lucide_icons.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({
    super.key,
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.isAdmin,
  });
  final bool isAdmin;
  final int id;
  final String firstName;
  final String lastName;
  final String username;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int selectedIndex = 0;

  final List<String> sidebarLabels = [
    'Dashboard',
    'Patients',
    'Bills',
    'Reports',
    'Doctors',
    'Settings',
    'Logout',
  ];

  void logout() {
    FlutterSecureStorage secureStorage = ref.read(secureStorageProvider);
    secureStorage.delete(key: 'access_token');
    secureStorage.delete(key: 'access_tokenn');
    setWindowBehavior(isForLogin: true);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  void initState() {
    super.initState();
    setWindowBehavior();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Expanded(
            flex: 1,
            child: Container(
              width: 240,
              color: Theme.of(context).brightness == Brightness.light
                  ? Theme.of(context).colorScheme.primary
                  : containerDarkColor,
              // : Theme.of(context).scaffoldBackgroundColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  appIconNameWidget(context: context),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SidebarItem(
                            icon: LucideIcons.layoutGrid,
                            label: 'Dashboard',

                            onTap: () => setState(() {
                              selectedIndex = 0;
                            }),
                          ),
                          SidebarItem(
                            icon: LucideIcons.bed,
                            label: 'Patients',
                            onTap: () => setState(() => selectedIndex = 1),
                          ),
                          SidebarItem(
                            icon: LucideIcons.fileText,
                            label: 'Bills',
                            onTap: () => setState(() => selectedIndex = 2),
                          ),
                          SidebarItem(
                            icon: LucideIcons.bookOpen,
                            label: 'Reports',
                            onTap: () => setState(() => selectedIndex = 3),
                          ),
                          SidebarItem(
                            icon: Icons.local_hospital_outlined,
                            label: 'Doctors',
                            onTap: () => setState(() => selectedIndex = 4),
                          ),
                          SidebarItem(
                            icon: LucideIcons.settings,
                            label: 'Settings',
                            onTap: () => setState(() => selectedIndex = 5),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SidebarItem(
                    icon: LucideIcons.logOut,
                    label: 'Logout',
                    onTap: () {
                      logout();
                    },
                  ),
                ],
              ),
            ),
          ),
          // Main content
          Expanded(
            flex: 5,
            child: Column(
              children: [
                Container(
                  height: 60,
                  color: Theme.of(context).scaffoldBackgroundColor,
                  padding: EdgeInsets.symmetric(horizontal: defaultPadding),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        sidebarLabels[selectedIndex],
                        style: Theme.of(context).textTheme.headlineMedium!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          Text(
                            "${widget.firstName} ${widget.lastName}",
                            style: Theme.of(context).textTheme.bodyLarge!
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: defaultPadding),
                          GestureDetector(
                            onTap: () async {
                              final updated = await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ProfileScreen(userId: widget.id),
                                ),
                              );
                              if (updated == true) {
                                setState(() {});
                              }
                            },
                            child: CircleAvatar(
                              backgroundColor:
                                  Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Theme.of(context).colorScheme.primary
                                  : containerDarkColor,
                              child: Text(
                                widget.firstName[0].toUpperCase(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Main screen content
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: defaultPadding),
                    child: mainScreenContentProvider(
                      indexNumber: selectedIndex,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
