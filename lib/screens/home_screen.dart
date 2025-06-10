import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:labledger/methods/custom_methods.dart';
import 'package:labledger/providers/custom_providers.dart';
import 'package:labledger/screens/initials/login_screen.dart';
import 'package:labledger/screens/main_screens/dashboard.dart';
import 'package:labledger/screens/main_screens/settings.dart';
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
    'Diagnosis Types',
    'Center Details',
    'Settings',
    'Logout',
  ];
  void logout() {
    FlutterSecureStorage secureStorage = ref.read(secureStorageProvider);
    debugPrint(secureStorage.read(key: 'access_token').toString());
    secureStorage.delete(key: 'access_token');
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Row(
        children: [
          // Sidebar
          Expanded(
            flex: 1,
            child: Container(
              width: 240,
              color: Theme.of(context).colorScheme.primary,
              // color: Theme.of(context).colorScheme.primary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  appIconNameWidget(context: context),
                  SidebarItem(
                    icon: LucideIcons.home,
                    label: 'Dashboard',
                    onTap: () => setState(() => selectedIndex = 0),
                  ),
                  SidebarItem(
                    icon: LucideIcons.user,
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
                    icon: LucideIcons.userCheck,
                    label: 'Doctors',
                    onTap: () => setState(() => selectedIndex = 4),
                  ),
                  SidebarItem(
                    icon: LucideIcons.activity,
                    label: 'Diagnosis Types',
                    onTap: () => setState(() => selectedIndex = 5),
                  ),
                  SidebarItem(
                    icon: LucideIcons.building2,
                    label: 'Center Details',
                    onTap: () => setState(() => selectedIndex = 6),
                  ),
                  SidebarItem(
                    icon: LucideIcons.settings,
                    label: 'Settings',
                    onTap: () => setState(() => selectedIndex = 7),
                  ),
                  const Spacer(),
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
          Expanded(
            flex: 5,
            child: Column(
              children: [
                Container(
                  height: 60,
                  color:
                      Theme.of(context).appBarTheme.backgroundColor ??
                      Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: defaultPadding),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Dashboard',
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
                          CircleAvatar(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            child: Text(
                              widget.firstName[0].toUpperCase(),
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Main Screen content
                Padding(
                  padding: EdgeInsetsGeometry.symmetric(
                    horizontal: defaultPadding,
                  ),
                  child: mainScreenContentProvider(indexNumber: selectedIndex),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SidebarItem extends ConsumerWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const SidebarItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: Icon(icon, color: ref.read(lightScaffoldColorProvider)),
      title: Text(
        label,
        style: TextStyle(color: ref.read(lightScaffoldColorProvider)),
      ),
      onTap: onTap,
    );
  }
}

class SummaryCard extends StatelessWidget {
  final String title;
  final String count;
  final IconData icon;
  const SummaryCard({
    super.key,
    required this.title,
    required this.count,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 30, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              count,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(title, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

Widget mainScreenContentProvider({required int indexNumber}) {
  switch (indexNumber) {
    case 0:
      return Dashboard();
    case 7:
      return Settings();

    default:
      return Text('Invalid index');
  }
}
